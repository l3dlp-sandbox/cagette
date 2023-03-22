package pro.controller;

import mangopay.db.MangopayLegalUser;
import payment.Check;
import service.PaymentService;
import controller.Cron;
import service.DistributionService;
import db.User;
import haxe.DynamicAccess;
import db.MultiDistrib;
import db.Group.BetaFlags;
import tools.DateTool;
import pro.db.PUserCompany;
import tink.core.Error;
import service.VendorService;
import connector.db.RemoteCatalog;
import hosted.db.CompanyCourse;
import pro.payment.MangopayECPayment;
import pro.db.CagettePro;
import haxe.Json;
import db.Operation;
import form.CagetteForm;
import db.Vendor;
import pro.db.VendorStats;
import tools.ObjectListTool;
import sugoi.tools.Csv;
import sugoi.form.Form;
import Common;
import mangopay.Mangopay;
import db.UserGroup;

using Std;

class Admin extends controller.Controller {
	public function new() {
		super();

		view.nav = nav("admin");
	}

	/**
		Deduplicate Vendors
	**/
	@tpl('plugin/pro/admin/deduplicate.mtt')
	function doDeduplicate() {
		var sql = "SELECT MAX(id) as id,MAX(name) as name,MAX(email) as email,COUNT(id) as duplicates,MAX(zipCode) as zipCode from Vendor GROUP BY email HAVING duplicates>2 ORDER BY duplicates DESC ";
		var res = sys.db.Manager.cnx.request(sql).results();
		view.vendors = res;
		var d = 0;
		for (r in res)
			d += r.duplicates - 1;
		view.duplicates = d;		
	}

	@tpl('plugin/pro/admin/dedupInfo.mtt')
	function doDedupInfo(email:String) {
		var vendors = db.Vendor.manager.search($email == email, true);

		view.vendors = vendors;
		var isCpro = function(v:db.Vendor) {
			return pro.db.CagettePro.manager.select($vendor == v) != null;
		};
		view.isCpro = isCpro;

		if (checkToken()) {
			var survivorId = Std.parseInt(app.params.get("vid"));
			var type = app.params.get("type") == "formation" ? "formation" : "master";
			if (survivorId == null)
				throw "no vid";
			var survivor = Lambda.find(vendors, function(v) return v.id == survivorId);
			var lastContract = null;
			for (v in vendors) {
				// hey, do not delete the survivor
				if (v.id == survivorId)
					continue;
				if (v.status == "formation" && type == "master")
					continue;
				if (v.status == "master")
					continue;
				if (v.status != "formation" && type == "formation")
					continue; // on efface que les comptes formation

				if (isCpro(v))
					throw "cant delete a vendor linked to a cpro";

				for (contract in db.Catalog.manager.search($vendor == v, true)) {
					contract.vendor = survivor;
					contract.update();

					if (contract.contact != null) {
						lastContract = contract;
					}
				}

				v.delete();
			}

			/*survivor.lock();
				survivor.status = "master";
				survivor.update(); */

			/*if (lastContract != null && lastContract.contact != null) {
				service.VendorService.sendEmailOnAccountCreation(survivor, lastContract.contact, lastContract.group);
			}*/

			throw Ok("/p/pro/admin/deduplicate", survivor.name + " a été dédupliqué");
		}
	}

	@tpl('plugin/pro/admin/dedupInfoByName.mtt')
	function doFindduplicatesbyname(name:String) {
		view.vendors = VendorService.findVendors({name:name});
	}

	@tpl('plugin/pro/admin/dedupInfoByZip.mtt')
	function doFindduplicatesbyzip(zip:String) {
		view.vendors = db.Vendor.manager.search($zipCode == zip, false);
	}

	@tpl('plugin/pro/admin/nullEmailVendors.mtt')
	function doNullEmailVendors() {
		view.vendors = db.Vendor.manager.search($email == null, false);
		view.getStats = pro.db.VendorStats.getOrCreate;
	}

	@admin
	function doUserOrderFix(){
		/**
			2022-05-25
			need to assign basketId to UserOrders... there is still userOrder without basketId
		**/
		for( order in db.UserOrder.manager.search($basket==null,{limit:1000},true)){

			order.basket = db.Basket.getOrCreate(order.user, order.distribution.multiDistrib);	
			order.update();
			Sys.println('order ${order.id} fixed<br>');
		}
		var count = db.UserOrder.manager.count($basket==null);
		Sys.println('Still ${count} userOrder without basket<br>');
	}

	@admin
	function doBasketFixes() {
		/*
			vérifie la cohérence des datas des paniers
			- tout doit etre du meme user
			- tout doit etre pour la même multidistrib

			Les peuple avec les champs "user" et "multidistrib"
		 */
		/*var lastId:Int = sugoi.db.Variable.getInt("basketFixCounter");
			if(lastId==null) lastId = 0;
			Sys.print("<h2>Start from "+lastId+"</h2>"); */

		Sys.print("<h2>Still " + db.Basket.manager.count($multiDistrib == null) + " non migrated baskets</h2>");

		// Populate md and user field in baskets
		var baskets = db.Basket.manager.search($multiDistrib == null, {limit: 10000}, true);
		for (b in baskets) {
			// lastId = b.id;
			var ok = true;

			// check orders are for the same user and same md
			var orders = Lambda.array(b.getOrders());

			if (orders.length == 0) {
				b.delete();
				continue;
			}

			for (o in orders) {
				if (o == null)
					throw "null order in " + orders;
				if (o.user.id != orders[0].user.id)
					throw "various users in basket " + b.id;

				if (o.distribution == null) {
					Sys.print('basket#${b.id} : $o has null distrib, its from a ${o.product.catalog.type} type<br/>');
					Sys.print('date : ' + b.cdate + '<br/>');
					Sys.print('all orders are : ' + orders + '<br/>');
					ok = false;

					// fix : effacer les commandes avec qt zero, puisque la distrib derrière a été effacée
					for (ord in orders) {
						if (ord.quantity == 0) {
							ord.lock();
							ord.delete();
						}
					}

					// fix : si c'est un contrat AMAP, ça n'a rien à faire dans un basket.
					for (ord in orders) {
						if (ord.product.catalog.type == db.Catalog.TYPE_CONSTORDERS) {
							ord.lock();
							ord.basket = null;
							ord.update();
						}
					}

					// fix : c'est une commande d'un groupe pédagogique
					// dont la distrib a été effacée sauvagement au moment de la coupure du compte pedago
					for (ord in orders) {
						if (ord.product.catalog.vendor.status == "formation") {
							ord.lock();
							ord.delete();
						}
					}

					break;
				}

				if (o.distribution.multiDistrib == null) {
					Sys.print('basket#${b.id} : $o has null multidistrib, its from a ${o.product.catalog.type} type<br/>');
					Sys.print('date : ' + b.cdate + '<br/>');
					Sys.print('all orders are : ' + orders + '<br/>');
					ok = false;
					break;
				}

				if (o.distribution.multiDistrib.id != orders[0].distribution.multiDistrib.id) {
					Sys.print("various multidistrib in basket " + b.id + "<br/>");
					Sys.print('date : ' + b.cdate + '<br/>');
					Sys.print('all orders are : <br/>');
					for (o in orders) {
						if (o.distribution == null || o.distribution.multiDistrib == null)
							continue;
						Sys.print(o + " , MD = " + o.distribution.multiDistrib + " , producteur = " + o.distribution.catalog.vendor.name + "<br/>");
					}
					ok = false;

					// FIX IT
					var ordersByMd = new Map<Int, Array<db.UserOrder>>();
					for (o in orders) {
						if (o.distribution == null)
							continue;
						if (ordersByMd[o.distribution.multiDistrib.id] == null)
							ordersByMd[o.distribution.multiDistrib.id] = [];
						ordersByMd[o.distribution.multiDistrib.id].push(o);
					}
					var user = orders[0].user;

					for (mdid in ordersByMd.keys()) {
						var md = db.MultiDistrib.manager.get(mdid, false);
						var basket = new db.Basket();
						basket.insert();
						for (ord in ordersByMd[mdid]) {
							ord.lock();
							ord.basket = basket;
							ord.update();
						}
					}

					break;
				}
			}

			if (ok) {
				b.multiDistrib = orders[0].distribution.multiDistrib;
				b.user = orders[0].user;
				b.update();
				Sys.print("--------- updated basket " + b.id + "<br/>");
			}
		}

		// sugoi.db.Variable.set("basketFixCounter",lastId);
	}

	@admin @tpl('plugin/pro/admin/siret.mtt')
	function doSiret() {
		var badVendors = db.Vendor.manager.unsafeCount("SELECT count(v.id) FROM Vendor v, VendorStats vs where v.id=vs.vendorId and vs.active=1 and v.companyNumber is null");
		var total = db.Vendor.manager.unsafeCount("SELECT count(v.id) FROM Vendor v, VendorStats vs where v.id=vs.vendorId and vs.active=1");
		view.badVendors = badVendors;
		view.total = total;

		if (app.params["type"] == "good") {
			view.vendors = db.Vendor.manager.unsafeObjects("SELECT v.* FROM Vendor v, VendorStats vs where v.id=vs.vendorId and vs.active=1 and v.companyNumber is not null",
				false);
		}

		if (app.params["type"] == "bad") {
			view.vendors = db.Vendor.manager.unsafeObjects("SELECT v.* FROM Vendor v, VendorStats vs where v.id=vs.vendorId and vs.active=1 and v.companyNumber is null",
				false);
		}

		view.type = app.params["type"];

		// view.vendors = db.Vendor.manager.search($isTest,{orderBy:-id});
	}

	/**
		Vendors to delete
	**/
	function doListVendorsToDelete() {
		var cdate = DateTools.delta(Date.now(), -1000 * 60 * 60 * 24 * 30);
		// vendors created since more than 1 month
		for (v in db.Vendor.manager.search($cdate < cdate)) {
			if (v.getContracts().length == 0) {
				Sys.println('Vendor <a href="/admin/vendor/view/${v.id}">${v.name}</a> has no catalogs ! <br/>');
			} else if (v.email == null) {
				Sys.println('Vendor <a href="/admin/vendor/view/${v.id}">${v.name}</a> has no email ! <br/>');
			}
		}
	}

	/**
		@fbarbut
		2020-05-05
		- Fix missing remoteId in Mgp refunds
		- Spot "wrong" manually made mangopay payments
	**/
	function doFixGroupOps(group:db.Group) {
		// fix missing remoteOpId in MGP refunds
		var print = controller.Cron.print;
		print("<h1>Fix remoteId in refunds</h1>");
		for (op in db.Operation.manager.search($type == Payment && $group == group && $amount < 0, true)) {
			if (op.getPaymentType() != MangopayECPayment.TYPE)
				continue;
			var infos = op.getPaymentData();
			if (infos.remoteOpId == null) {
				// print(infos);
				print("==========");

				op.amount = Math.round(op.amount * 100) / 100;
				print('#${op.id} name : ${op.name}, amount : ${op.amount}, date : ${op.date}');

				// find refund
				var orderOp = op.relation;
				for (payment in orderOp.getRelatedPayments()) {
					if (payment.type == Payment && op.getPaymentType() == MangopayECPayment.TYPE) {
						var payinId = Std.parseInt(payment.getPaymentData().remoteOpId);
						if (payinId == null)
							continue;
						for (refund in Mangopay.getPayInRefunds(payinId)) {
							print("found refund : " + (refund.CreditedFunds.Amount / 100) + ", id : " + refund.Id);
							if (refund.CreditedFunds.Amount / 100 + op.amount == 0) {
								print("fix it");
								op.setPaymentData({type: MangopayECPayment.TYPE, remoteOpId: refund.Id.string()});
								op.update();
							}
						}
					}
				}
			}
		}

		print("<h1>Spot wrong MGP payments</h1>");
		for (op in db.Operation.manager.search($type == Payment && $group == group, false)) {
			if (op.getPaymentType() != MangopayECPayment.TYPE)
				continue;
			var infos = op.getPaymentData();
			if (infos.remoteOpId == null) {
				print("=========");
				print('<a href="/db/Operation/edit/${op.id}" target="_blank">#${op.id}</a>, name : ${op.name}, amount : ${op.amount}, date : ${op.date}');
				print(infos);
			}
		}
	}

	@admin
	function doMigrateOperations() {
		// 2020-07-31 : refacto payment ops
		/*var from = Date.fromString(app.params.get("from"));
		var to = Date.fromString(app.params.get("to"));

			for( op in db.Operation.manager.search($date >= from && $date < to && $data2 == null ,true)){
				try{

					switch(op.type){
						case VOrder:
							var data :VOrderInfos = op.data;
							var basket = data==null ? null : db.Basket.manager.get(data.basketId);
							// on peut migrer une op si le basket n'existe plus, pas la peine d'essayer de fixer un autre problème.
							
							if(basket!=null){
								op.basket = basket;
								op.setData({basketId:basket.id});
								Sys.print('Op ${op.id} OK<br/>');
							}else{

								//sometimes op.basket is null in data, but populated in op.basket
								if(op.basket!=null){
									op.setData({basketId:op.basket.id});
								}else{
									op.setData({basketId:null});
									Sys.print('Warning "basket null" avec op <a href="/db/db.Operation/edit/${op.id}">#${op.id}</a><br>');
								}								
								
							}
						
						//case COrder :
							//delete this, it it exists its shit
							// op.delete();	
						case SubscriptionTotal:

							//no need to migrate

						case Payment :
							var data :PaymentInfos = op.data;
							op.setData({type:data.type,remoteOpId:data.remoteOpId});

						case Membership :
							var data :MembershipInfos = op.data;
							op.setData({year:data.year});							
					}

					try{
						op.unsafeUpdate();
					}catch(e:Error){
						Sys.print("Error : "+e.message);
					}

				}catch(e:Dynamic){

					Sys.print('Erreur "$e" avec op <a href="/db/db.Operation/edit/${op.id}">#${op.id}</a><br>');

				}
				
		}*/
	}

	/**
		check and recompute payments ops
	**/
	@admin @tpl('plugin/pro/admin/checkOperations.mtt')
	function doCheckOperations(group:db.Group,from:Date,to:Date,?autoFix=false) {

		// var g = db.Group.manager.get(6598);
		var out = [];

		// for ( md in db.MultiDistrib.getFromTimeRange(g,new Date(2021,3,1,0,0,0), new Date(2021,11,30,0,0,0))){
		for ( md in db.MultiDistrib.getFromTimeRange(group,from,to) ){
			
			var msgs = [];
			for( b in md.getBaskets()){
				
				var op = b.getOrderOperation(false);
				var ordersTotal = Formatting.cleanFloat(0 - b.getOrdersTotal());
				var opAmount = op==null ? null : Formatting.cleanFloat(op.amount);

				if(autoFix){
					service.PaymentService.onOrderConfirm( b.getOrders() );
				}else{
					if(op==null){
						msgs.push('${b.user.getName()} , total commande : ${ordersTotal} != aucune operation');
						
					} else if( ordersTotal != opAmount ){
						msgs.push('${b.user.getName()} , total commande : ${ordersTotal} != opération : ${opAmount}');
						if(autoFix) service.PaymentService.onOrderConfirm( b.getOrders() );
					}
				}
			}

			out.push({
				md : md.toString(),
				messages : msgs
			});
		}

		if(autoFix) {			
			throw Ok('/p/pro/admin/checkOperations/${group.id}/$from/$to',"Operations corrigées");
		}

		view.mds = out;
		view.group = group;
		view.from = from;
		view.to = to;

	}

	@admin
	function doPreprod() {
		for (u in db.User.manager.all(true)) {
			u.flags.unset(HasEmailNotif4h);
			u.flags.unset(HasEmailNotif24h);
			u.flags.unset(HasEmailNotifOuverture);
			u.update();
		}
	}

	/**
	 * Create a cagette pro account from a vendor
	 */
	function doCreateCpro(vendor:db.Vendor) {
		if (pro.db.CagettePro.getFromVendor(vendor) != null)
			throw Error("/admin/vendor/view/" + vendor.id, vendor.name + " a deja un compte producteur");

		vendor.lock();

		var cpro = new pro.db.CagettePro();
		cpro.vendor = vendor;
		cpro.insert();

		// vendor.isTest = false;
		vendor.update();

		// user
		var user = service.UserService.get(vendor.email);

		// access
		if(user!=null){
			var uc = new pro.db.PUserCompany();
			uc.company = cpro;
			uc.user = user;
			uc.insert();
		}
		

		VendorStats.updateStats(vendor);

		throw Ok("/admin/vendor/view/" + vendor.id, "Compte Cagette Pro créé");
	}

	@tpl("form.mtt")
	public function doNewVendor() {
		var vendor = new db.Vendor();
		var form = CagetteForm.fromSpod(vendor);

		if (form.isValid()) {
			form.toSpod(vendor);
			vendor.insert();

			/*service.VendorService.getOrCreateRelatedUser(vendor);
				service.VendorService.sendEmailOnAccountCreation(vendor,app.user,app.user.getAmap()); */

			throw Ok('/admin/vendor/view/' + vendor.id, t._("This supplier has been saved"));
		}

		view.title = t._("Key-in a new vendor");
		// view.text = t._("We will send him/her an email to explain that your group is going to organize orders for him very soon");
		view.form = form;
	}

	@admin @tpl('plugin/pro/admin/import.mtt')
	function doImportUsersCustom() {
		var csv = new sugoi.tools.Csv();
		csv.step = 1;
		var request = sugoi.tools.Utils.getMultipart(1024 * 1024 * 4);

		// on recupere le contenu de l'upload
		if (request.get("file") != null) {
			csv.setHeaders([
				"groupName",
				"firstName",
				"lastName",
				"email",
				"phone",
				"address1",
				"address2",
				"zipCode",
				"city"
			]);
			var datas = csv.importDatasAsMap(request.get("file"));

			for (d in datas) {
				// generate email if needed
				if (d["email"] == null)
					d["email"] = d["lastName"].toLowerCase() + Std.random(100) + "@vrac-asso.org";

				var group = db.Group.manager.select($name.like(d["groupName"]));

				if (group == null) {
					throw "not found group named '" + d["groupName"] + "'";
				}

				if (group.name.toLowerCase() != d["groupName"].toLowerCase()) {
					throw group.name;
				}

				var u = db.User.manager.select($email == d["email"] || $email2 == d["email"], true);
				if (u == null) {
					u = new db.User();
					u.firstName = d["firstName"];
					u.lastName = d["lastName"];
					u.email = d["email"];
					u.address1 = d["address1"];
					u.address2 = d["address2"];
					u.zipCode = d["zipCode"];
					u.city = d["city"];
					u.countryOfResidence = "FR";
					u.flags = sys.db.Types.SFlags.ofInt(0);
					u.insert();
				}
				u.makeMemberOf(group);
			}
			csv.step = 3;
		}
		view.csv = csv;
	}

	/**
		Duplicate a group
	**/
	@admin
	@tpl('plugin/pro/form.mtt')
	function doDuplicate() {
		var f = new sugoi.form.Form("g");

		// get client list
		var data = [];
		var gids = tools.ObjectListTool.getIds(hosted.db.GroupStats.manager.search($active, false));
		var groups = db.Group.manager.search($id in gids, false);

		for (g in groups) {
			data.push({label: "#" + g.id + " " + g.name, value: g.id});
		}

		f.addElement(new sugoi.form.elements.IntSelect("group", "Choisissez un groupe à dupliquer", cast data, true));

		if (f.isValid()) {
			var s = new pro.service.ProGroupService();
			var x = db.Group.manager.get(f.getValueOf("group"));
			s.duplicateGroup(x, true, x.name + "(copy)", x.getMainPlace().name);

			throw Ok("/", "Groupe dupliqué");
		}

		view.form = f;
		view.title = "Dupliquer un groupe";
	}

	/**
		delete/disable a vendor
	**/
	function doDelete(vendor:db.Vendor, action:String) {
		switch (action) {
			case "disable":
				var cpro = CagettePro.getFromVendor(vendor);
				if (cpro == null)
					throw "is not cpro";

				for (cat in cpro.getCatalogs()) {
					for (rc in connector.db.RemoteCatalog.getFromPCatalog(cat)) {
						if (rc.getContract() != null) {
							throw Error("/admin/vendor/view/" + vendor.id, "Ce compte producteur a encore des catalogues reliés à des groupes");
						}
					}
				}

				for (uc in pro.db.PUserCompany.getUsers(cpro)) {
					uc.lock();
					uc.delete();
				}

				
				vendor.lock();
				vendor.disabled = DisabledReason.Banned;
				vendor.update();

				VendorStats.updateStats(vendor);

				throw Ok("/admin/vendor/view/" + vendor.id, "Producteur désactivé");

			case "deleteCpro":
				var cpro = CagettePro.getFromVendor(vendor);
				if (cpro == null)
					throw "is not cpro";

				for (cat in cpro.getCatalogs()) {
					for (rc in connector.db.RemoteCatalog.getFromPCatalog(cat)) {
						if (rc.getContract() != null) {
							throw Error("/admin/vendor/view/" + vendor.id, "Ce compte producteur a encore des catalogues reliés à des groupes");
						}
					}
				}

				cpro.lock();
				cpro.delete();

				VendorStats.updateStats(vendor);

				throw Ok("/admin/vendor/view/" + vendor.id, "compte producteur désactivé");

			case "delete":
				if (vendor.getContracts().length > 0) {
					throw Error("/admin/vendor/view/" + vendor.id, "Ce producteur a encore des catalogues dans des groupes");
				} else {
					vendor.lock();
					vendor.delete();

					throw Ok("/p/pro/admin/", "Producteur effacé");
				}
		}
	}

	/**
	 * ADMIN : Transform a contract to a catalog
	 */
	@admin @tpl('form.mtt')
	public function doContractToCatalog(?catalog:db.Catalog, ?cagettePro:pro.db.CagettePro) {
		var f = new sugoi.form.Form("contract");
		view.title = "Importer un catalogue groupe dans un compte producteur";
		if (catalog != null && cagettePro != null) {
			/*f.addElement(new sugoi.form.elements.IntInput("cid",catalog.name+" dans le groupe "+catalog.group.name,catalog.id,true));
				f.addElement(new sugoi.form.elements.IntInput("companyId",cagettePro.vendor.name,cagettePro.id,true)); */

			view.text = 'Voulez vous importer ce catalogue <b>${catalog.name}</b><br/> dans le compte producteur <b>${cagettePro.vendor.name}</b> ?';

			if (f.isValid()) {
				for (p in catalog.getProducts(false)) {
					// product
					var pp = new pro.db.PProduct();
					pp.name = p.name;

					// créé une ref si existe pas...
					if (p.ref == null || p.ref == "") {
						p.ref = p.name.toUpperCase().substr(0, 4);
					}
					pp.ref = p.ref;
					pp.image = p.image;
					pp.desc = p.desc;
					pp.company = cagettePro;
					pp.unitType = p.unitType;
					pp.active = p.active;
					pp.organic = p.organic;
					pp.txpProduct = p.txpProduct;
					pp.insert();

					// create one offer
					var off = new pro.db.POffer();
					off.price = p.price;
					off.vat = p.vat;
					if (pp.ref != null) {
						off.ref = pp.ref + "-1";
					}
					off.product = pp;
					off.quantity = p.qt;
					off.active = p.active;
					off.insert();
				}
				throw Ok("/admin/vendor/view/" + catalog.vendor.id, "Catalogue copié");
			}
		} else {
			f.addElement(new sugoi.form.elements.IntInput("cid", "ID du catalogue", null, true));
			f.addElement(new sugoi.form.elements.IntInput("companyId", "ID du Compte producteur", null, true));

			if (f.isValid()) {
				var cid = f.getElement("cid").getValue();
				var companyId:Int = f.getValueOf("companyId");
				var company = pro.db.CagettePro.manager.get(companyId, false);
				var contract = db.Catalog.manager.get(cid, false);

				if (company == null)
					throw "Ce compte producteur n'existe pas";
				if (contract == null)
					throw "Ce contrat n'existe pas";

				throw Redirect("/p/pro/admin/contractToCatalog/" + contract.id + "/" + company.id);
			}
		}

		view.form = f;
	}

	/**
		Move a Cpro Catalog (and its products and offers) from one company to another
	**/
	@admin @tpl("form.mtt")
	function doMoveCatalog() {
		var f = new sugoi.form.Form("movecata");
		f.addElement(new sugoi.form.elements.IntInput("catalogId", "ID du catalogue cpro à déplacer", null, true));
		f.addElement(new sugoi.form.elements.IntInput("vid", "ID du producteur (qui doit avoir compte producteur) qui va recevoir le catalogue", null, true));

		if (f.isValid()) {
			var catalog = pro.db.PCatalog.manager.get(f.getValueOf("catalogId"));
			var vendor = db.Vendor.manager.get(f.getValueOf("vid"));
			var company = pro.db.CagettePro.getFromVendor(vendor);

			for (p in catalog.getProducts()) {
				p.product.lock();
				p.product.company = company;
				p.product.update();
			}

			catalog.company = company;
			catalog.update();

			throw Ok("/p/pro/admin/moveCatalog", "Le catalogue \"" + catalog.name + "\" a été déplacé chez \"" + company.vendor.name + "\"");
		}

		view.form = f;
	}

	/**
		Copy products from a cpro to another
	**/
	@admin @tpl("form.mtt")
	function doCopyProducts() {
		var f = new sugoi.form.Form("movecata");
		f.addElement(new sugoi.form.elements.IntInput("sourcevid", "ID du producteur source", null, true));
		f.addElement(new sugoi.form.elements.IntInput("desvid", "ID du producteur destination", null, true));

		if (f.isValid()) {
			var vendor = db.Vendor.manager.get(f.getValueOf("sourcevid"));
			var company = pro.db.CagettePro.getFromVendor(vendor);

			var destVendor = db.Vendor.manager.get(f.getValueOf("desvid"));
			var destCompany = pro.db.CagettePro.getFromVendor(destVendor);

			for (product in company.getProducts()) {
				var p2 = new pro.db.PProduct();
				for (key in [
					"name", "ref", "txpProduct", "desc", "imageId", "active", "unitType", "organic", "variablePrice", "multiWeight"
				]) {
					Reflect.setProperty(p2, key, Reflect.getProperty(product, key));
				}
				p2.company = destCompany;
				p2.insert();

				for (off in product.getOffers()) {
					var off2 = new pro.db.POffer();
					for (key in ["name", "ref", "imageId", "quantity", "price", "vat", "active"]) {
						Reflect.setProperty(off2, key, Reflect.getProperty(off, key));
					}
					off2.product = p2;
					off2.insert();
				}
			}

			throw Ok("/p/pro/admin/copyProducts", "Les produits de  \"" + vendor.name + "\" a été copiés chez \"" + destVendor.name + "\"");
		}

		view.form = f;
	}

	/**
		stats pour https://docs.google.com/spreadsheets/d/131YGMLCBD22JFgANv6Y2QjYKncHvd_lpaG8_ujSlh4c/edit#gid=404041288
	**/
	function doCastats(?to:Date){

		var from = new Date(2020,5,1,0,0,0);
		if(to==null) to = new Date(2020,6,1,0,0,0);

		var turnovers = [];

		var createdFrom = new Date(2020,5,1,0,0,0);
		var createdTo = new Date(2020,5,30,23,59,59);

		for( v in Vendor.manager.search($cdate>=createdFrom && $cdate<createdTo ,false)){

			var vs = VendorStats.getOrCreate(v);
			if(vs.type==VendorType.VTCpro) continue;
			if(vs.type==VendorType.VTStudent) continue;
			if(vs.type==VendorType.VTDiscovery) continue;

			var cids = v.getContracts().array().map(v -> v.id);
			var turnover = 0.0;
			for( d in db.Distribution.manager.search($date >= from && $date < to && ($catalogId in cids), false)){
				turnover += d.getTurnOver();
			}

			turnovers.push( Math.round(turnover) );
		}

		//besoin de compter les producteurs par tranche de c.a
		var vendors = new Map<String,Int>();
		vendors.set("0-250",0);
		vendors.set("250-500",0);
		vendors.set("500-750",0);
		vendors.set("750-1000",0);
		vendors.set("1000-1250",0);
		vendors.set("1250-1500",0);
		vendors.set("1500-1750",0);
		vendors.set("1750-2000",0);
		vendors.set("2000-3000",0);
		vendors.set("3000-5000",0);
		vendors.set("5000-10000",0);
		vendors.set("10000-20000",0);
		vendors.set("20000-30000",0);
		vendors.set("30000-40000",0);
		vendors.set("40000",0);

		// var inc = function(k:String){
		// 	var v = vendors.get(k);
		// 	vendors.get
		// }

		for( t in turnovers){

			if(t< 250){
				vendors["0-250"]++;
			}else if (t >= 250 && t< 500){
				vendors["250-500"]++;
			}else if (t >= 500 && t< 750){
				vendors["500-750"]++;
			}else if (t >= 750 && t< 1000){
				vendors["750-1000"]++;
			}else if (t >= 1000 && t< 1250){
				vendors["1000-1250"]++;
			}else if (t >= 1250 && t< 1500){
				vendors["1250-1500"]++;
			}else if (t >= 1500 && t< 1750){
				vendors["1500-1750"]++;
			}else if (t >= 1750 && t< 2000){
				vendors["1750-2000"]++;
			}else if (t >= 2000 && t< 3000){
				vendors["2000-3000"]++;
			}else if (t >= 3000 && t< 5000){
				vendors["3000-5000"]++;
			}else if (t >= 5000 && t< 10000){
				vendors["5000-10000"]++;
			}else if (t >= 10000 && t< 20000){
				vendors["10000-20000"]++;
			}else if (t >= 20000 && t< 30000){
				vendors["20000-30000"]++;
			}else if (t >= 30000 && t< 40000){
				vendors["30000-40000"]++;
			}else if (t >= 40000){
				vendors["40000"]++;
			}
		}

		Sys.print("from "+from.toString()+" to "+to.toString()+"<br/>");
		Sys.print("<table>");

		var keys = [];
		for( k in vendors.keys()){
			keys.push(k);
		}

		keys.sort(function(a,b){
			return a.split("-")[0].parseInt() - b.split("-")[0].parseInt();
		});

		for( k in keys ){
			Sys.print("<tr>");
			Sys.print("<td>"+k+"</td><td>"+vendors[k]+"</td>");
			Sys.print("</tr>");
		}

		Sys.print("</table>");

	}

	@admin @tpl('plugin/pro/admin/certification.mtt')
	function doCertification() { }

	//vrac 2022-07-01
	function doVrac(usersToDelete:Int){

		var themeId = App.current.getTheme().id;

		var vendorIds = [
			12640, //Bordeaux
			13715, //Lyon
			14000, //Strasbourg
			14001, //Toulouse
			14002, //Paris
			21640, //rennes
			22409, //nantes
			23371, //marseille
			24068, //st etienne
			24225, //haut de france
			24226, //montpellier
			24482, //bruxelles
			24697, //lyon 2
			//drome reliée à Lyon
			//finistere
		];

		var vendors = db.Vendor.manager.search($id in vendorIds);
		var print = controller.Cron.print;
		var cpros = vendors.map( v -> CagettePro.getFromVendor(v));
		var groups = [];
		print("==== CPRO");
		if(themeId=="cagette"){
			for(cpro in cpros){
				print(cpro.vendor.name);

				for( g in cpro.getGroups()){
					print("- "+g.name);
					groups.push(g);

					
					//RUN THIS ON CAGETTE.NET
					g.lock();
					g.disabled = Std.string(db.Group.GroupDisabledReason.MOVED);
					g.extUrl = "https://epicerie.vrac-asso.org/group/"+g.id;
					g.update();

					//remove future distribs that have no orders !!
					var mds = MultiDistrib.getFromTimeRange(g,Date.now(),DateTools.delta(Date.now(),1000*60*60*24*30.5*12*1000));
					for(md in mds){
						var orders = md.getOrders();
						if(orders.length==0){
							md.lock();
							print("delete "+md.toString());
							md.delete();
						}else{
							print(" "+md.toString()+" has orders !!");
						}
					}
					
				}
			}
		}

		//RUN THIS ON VRAC
		if(themeId=="vrac"){

			for(cpro in cpros){
				print(cpro.vendor.name);
				for( g in cpro.getGroups()){
					print("- "+g.name);
					groups.push(g);
				}
			}

			var gids:Array<Int> = groups.map(g -> g.id);
			var groupsToDelete = db.Group.manager.unsafeObjects('select * from `Group` where id not in (${gids.join(",")}) LIMIT 1000',true);
			print("====  1000 Groupes a effacer");
			for(g in groupsToDelete){
				print("delete "+g.name);
				g.delete();
			}

			if(usersToDelete>0){

				for( u in db.User.manager.unsafeObjects("SELECT * FROM User order by RAND() limit "+usersToDelete,true)){

					//ne pas effacer ceux qui sont dans un groupe VRAC
					if( db.UserGroup.manager.count($userId==u.id && $groupId in gids) > 0 ){
						print(""+u.toString()+" is VRAC member");
						continue;
					}
	
					//ne pas effacer ceux qui ont des commandes VRAC
					var mds = db.MultiDistrib.manager.search($groupId in gids,false);
					var mdIds = mds.map(x -> x.id);
					if( db.Basket.manager.count($userId==u.id && $multiDistribId in mdIds) > 0 ){
						print(""+u.toString()+" has VRAC baskets");
						continue;
					}
	
					print("delete "+u.toString());
					u.delete();
				}
			}
			
		}
	}


	function doFixDuplicateRefs(catalog:db.Catalog){
		var s = new who.service.WholesaleOrderService(catalog);
		s.fixDuplicateRefs();
	}

	/**
		https://go.mangopay.com/webmail/307741/669277924/5dba440638d2ee7e9bb8b5d00ee7291f52e450a7d392384fe7f73846cf6691f0
	**/
	/*public function doMangopayMigration2023(){

		for(mgpLegalUser in MangopayLegalUser.manager.search($disabled==false,false)){

			var m = Mangopay.getLegalUser(mgpLegalUser.mangopayUserId);

			if(m.TermsAndConditionsAccepted) continue;

			Sys.println('get ${m.Id}<pre>$m</pre>');
			var res = Mangopay.updateLegalUser(m);
			Sys.println('RES <pre>$res</pre>');

			// break;
		}
	}*/
}