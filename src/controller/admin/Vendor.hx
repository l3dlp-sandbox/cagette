package controller.admin;
import form.CagetteForm;
import haxe.Json;
import pro.db.VendorStats;
import service.BridgeService;
import sugoi.apis.linux.Curl;
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

/**
 * Vendor admin
 */
class Vendor extends controller.Controller
{

	public function new() 
	{
		super();	
	}

	/**
		Vendors admin
	**/
	@tpl('admin/vendor/default.mtt')
	function doDefault() {
		var vendors = [];
		var total = 0;
		var totalCpros = 0;
		var totalActive = 0;
		var defaultType = VTMarketplace;

		// form
		var f = new sugoi.form.Form("vendors");
		f.method = GET;
		f.addElement(new sugoi.form.elements.StringInput("companyNumber", "SIRET ou RNA"));
		var data = [
			{label: "Tous", value: "all"},
			{label: "Gratuit", value: VTFree.string()},
			{label: "Invité", value: VTInvited.string()},
			{label: "Invité dans un espace producteur", value: VTInvitedPro.string()},
			{label: "Formule Membre (formé)", value: VTCpro.string()},
			{label: "Compte pédagogique", value: VTStudent.string()},
			{label: "Formule Découverte", value: VTDiscovery.string()},
			{label: "Formule Pro (abo annuel)", value: VTCproSubscriberYearly.string()},
			{label: "Formule Pro (abo mensuel)", value: VTCproSubscriberMontlhy.string()},
			{label: "Formule Marketplace", value: VTMarketplace.string()},
		];
		f.addElement(new sugoi.form.elements.StringSelect("type", "Type de producteur", data, defaultType.string(), true, ""));
		f.addElement(new sugoi.form.elements.StringInput("zipCodes", "Saisir des numéros de département séparés par des virgules ou laisser vide."));
		f.addElement(new sugoi.form.elements.StringSelect("country", "Pays", db.Place.getCountries(), "FR", true, ""));
		var data = [
			{label: "Actifs", value: "active"},
			{label: "Inactifs", value: "inactive"},
			{label: "Tous", value: "all"}
		];
		f.addElement(new sugoi.form.elements.StringSelect("active", "Actifs ou pas", data, "active", true, ""));
		var data = [
			{label: "Tableau", value: "table"},
			{label: "Emails", value: "emails"},
			{label: "CSV", value: "csv"}
		];
		f.addElement(new sugoi.form.elements.StringSelect("output", "Sortie", data, "table", true, ""));

		var sql_select = "SELECT v.*,s.active,s.type,s.turnoverTotal,s.turnover90days";
		var sql_where_or = [];
		var sql_where_and = [];
		var sql_end = "ORDER BY SUBSTRING(v.zipCode,0,2),v.name ASC";
		var sql_from = ["Vendor v LEFT JOIN  VendorStats s ON v.id=s.vendorId "];

		if (f.isValid()) {
			// filter by zip codes
			var zipCodes:Array<Int> = f.getValueOf("zipCodes") != null ? f.getValueOf("zipCodes").split(",").map(Std.parseInt) : [];
			if (zipCodes.length > 0) {
				for (zipCode in zipCodes) {
					var min = zipCode * 1000;
					var max = zipCode * 1000 + 999;
					sql_where_or.push('(v.zipCode>=$min and v.zipCode<=$max)');
				}
			}

			// active
			switch (f.getValueOf("active")) {
				case "active":
					sql_where_and.push("active=1");
				case "inactive":
					sql_where_and.push("active=0");
				default:
			}

			// type
			if (f.getValueOf("type") != "all") {
				var t:VendorType = Type.createEnum(VendorType, f.getValueOf("type"));
				sql_where_and.push("type=" + Type.enumIndex(t));
			}

			// country
			sql_where_and.push('country="${f.getValueOf("country")}"');

			//SIRET
			if(f.getValueOf("companyNumber")!=null){
				sql_where_and.push('companyNumber="${f.getValueOf("companyNumber")}"');
			}

		} else {
			// default settings
			sql_where_and.push('active=1');
			sql_where_and.push('type=${Type.enumIndex(defaultType)}');
			sql_where_and.push('country="FR"');
		}

		// QUERY
		if (sql_where_and.length == 0)
			sql_where_and.push("true");
		if (sql_where_or.length == 0)
			sql_where_or.push("true");
		var sql = '$sql_select FROM ${sql_from.join(", ")} WHERE (${sql_where_or.join(" OR ")}) AND ${sql_where_and.join(" AND ")} $sql_end';
		for (v in db.Vendor.manager.unsafeObjects(sql, false)) {
			vendors.push(v);
		}

		view.form = f;

		// remove trainee accounts
		/*for( v in vendors.copy()){
			if(v.name.indexOf("(formation)")>-1) vendors.remove(v);
		}*/

		for (v in vendors) {
			// refresh active
			if (app.params.exists("force")) {
				pro.db.VendorStats.updateStats(v);
			} else {
				// force creation of vendorStats
				VendorStats.getOrCreate(v);
			}

			if (untyped v.active)
				totalActive++;
			if (untyped v.type == 0)
				totalCpros++;
		}

		// TOTALS
		total = vendors.length;
		view.total = total;
		view.vendors = vendors;
		view.totalCpros = totalCpros;
		view.totalActive = totalActive;

		switch (f.getValueOf("output")) {
			case "table":

			case "emails":
				app.setTemplate(null);
				Sys.println("<html><body>");
				for (v in vendors)
					Sys.println('${v.email}<br/>');
				Sys.println('<hr/><a href="${makeMailtoLink(vendors)}">Leur Ecrire</a>');
				Sys.println("</body></html>");

			case "csv":
				var headers = [
					"id", "name", "email", "phone", "address1", "address2", "zipCode", "city", "active", "type","profession"
				];
				var data = [];
				for (v in vendors) {
					var active:Bool = untyped v.active;
					var type:Int = untyped v.type;
					data.push({
						id: v.id,
						name: v.name,
						email: v.email,
						phone: v.phone,
						address1: v.address1,
						address2: v.address2,
						zipCode: v.zipCode,
						city: v.city,
						active: switch (active) {
							case true: "OUI";
							case false: "NON";
						},
						type: Std.string(Type.createEnumIndex(VendorType,type)),
						profession : v.getProfession()
					});
				}

				sugoi.tools.Csv.printCsvDataFromObjects(data, headers, "producteurs");
		}
	}
	
	
	@admin @tpl("admin/vendor/view.mtt")
	function doView(v:db.Vendor) {
		var cpro = pro.db.CagettePro.getFromVendor(v);
		view.vendor = v;
		view.cpro = cpro;

		if (app.params["refresh"] == "1") {
			pro.db.VendorStats.updateStats(v);
			BridgeService.syncVendorToHubspot(v);
		}

		if (app.params["canOpenStripeAccount"] == "1") {
			v.lock();
			v.betaFlags.set(CanOpenStripeAccount);
			v.update();
		}

		if (app.params["canOpenStripeAccount"] == "0") {
			v.lock();
			v.betaFlags.unset(CanOpenStripeAccount);
			v.update();
		}

		/*if (app.params["disableAccess"] != null) {
			var user = db.User.manager.get(Std.parseInt(app.params["disableAccess"]), false);
			var uc = pro.db.PUserCompany.get(user, cpro, true);
			uc.disabled = true;
			uc.update();
		}
		if (app.params["enableAccess"] != null) {
			var user = db.User.manager.get(Std.parseInt(app.params["enableAccess"]), false);
			var uc = pro.db.PUserCompany.get(user, cpro, true);			
			uc.disabled = false;
			uc.update();
		}*/

		/*var req = new Curl();
		req.setPostData("body",Json.stringify(v.getInfos()));
		req.call("POST","https://hooks.zapier.com/hooks/catch/6566570/b868f9v/");
		*/
		if (app.params["giveAdminRights"] != null) {
			var cproUsers = cpro.getUsers();
			for( group in cpro.getGroups()){
				for( user in cproUsers ){
					var ua = db.UserGroup.getOrCreate(user, group);
					ua.giveRight(db.UserGroup.Right.GroupAdmin);
					ua.giveRight(db.UserGroup.Right.Membership);
					ua.giveRight(db.UserGroup.Right.Messages);
					ua.giveRight(db.UserGroup.Right.ContractAdmin());					
				}
			}	
			throw Ok("/admin/vendor/view/"+v.id,"Droits donnés");
		}		

		view.stats = pro.db.VendorStats.getOrCreate(v);
		view.courses = hosted.db.CompanyCourse.manager.search($company == cpro, false);
		view.isCproCatalog = function(c:db.Catalog) {
			return connector.db.RemoteCatalog.getFromContract(c) != null;
		}
		view.profession = service.VendorService.getVendorProfessions().find(p -> return p.id == v.profession);
		if (v.activityCode != null) {
			var naf:String = v.activityCode.split(".").join("");
			view.activityCode = service.VendorService.getActivityCodes().find(p -> return p.id == naf);
		}
		view.isCorrectNAF = function(activityCode:String):Bool{
			if(activityCode==null) return true;
			var code = activityCode.split(".")[0].parseInt();
			if(code==null || code==0) return true;
			if( code==1 || code==3 || code==10 || code==11){
				return true;
			}
			return false;
		};

		var res = sys.db.Manager.cnx.request('select * from TmpVendor where vendorId = ${v.id}').results();
		var tmpVendor = res.first();
		view.tmpVendor = tmpVendor;
		
	}

	/**
		make a link to write to vendors
	**/
	function makeMailtoLink(vendors:Array<db.Vendor>) {
		var l = "mailto:?subject=Une%20formation%20Cagette%20Pro%20s'organise%20pr%C3%A8s%20de%20chez%20vous";

		// dedup on mail
		var vendors2 = new Map<String, db.Vendor>();
		for (v in vendors)
			vendors2.set(v.email, v);
		var vendors2 = Lambda.array(vendors2);

		for (v in vendors2) {
			if (sugoi.form.validators.EmailValidator.check(v.email)) {
				l += "&bcc=" + v.email;
			}
		}
		return l;
	}

	function doBan(v:db.Vendor, args:{?reason:db.Vendor.DisabledReason,?unban:Bool}){

		if(args.unban==true){
			v.lock();
			v.disabled = null;
			v.update();
			throw Ok("/admin/vendor/view/"+v.id,"Producteur débloqué");
		}else{
			v.lock();
			v.disabled = args.reason;
			v.update();
			throw Ok("/admin/vendor/view/"+v.id,"Producteur bloqué");
		}		
	}


	@tpl("form.mtt")
	function doEdit(v:db.Vendor) {
		var form = service.VendorService.getForm(v);
		if (form.isValid()) {
			v.lock();
			service.VendorService.update(v, form.getDatasAsObject(), true);
			v.update();
			throw Ok("/admin/vendor/view/" + v.id, "Producteur mis à jour");
		}
		view.form = form;
	}
	
	@tpl('form.mtt')
	function doEditLegalRepresentative(company:pro.db.CagettePro) {
		var f = new sugoi.form.Form("user");
		f.addElement( new sugoi.form.elements.StringInput("email","Email",null,true));
		
		if (f.isValid()){
			var uc = new pro.db.PUserCompany();
			var u = service.UserService.get(f.getValueOf("email"));
			if(u==null){
				throw Error('/admin/vendor/view/${company.vendor.id}','Il n\'y a aucun compte avec l\'email "${f.getValueOf("email")}". Cette personne doit s\'inscrire avant que vous puissiez lui donner accès à l\'espace producteur.');
			}

			uc.company = company;
			uc.user = u;
			uc.legalRepresentative = true;
			
			// Sync the new legal representative to HS as Marketing and associated it with vendor's Company
			BridgeService.syncUserToHubspot(u, company.vendor);
			
			// If there is another legalRepresentative (and we should always have one) set it to false
			var existingLegalRepresentative = pro.db.PUserCompany.manager.select($company==company && $legalRepresentative && $user!=u);
			if(existingLegalRepresentative!=null) {
				existingLegalRepresentative.legalRepresentative = false;
				existingLegalRepresentative.update();
				if (!existingLegalRepresentative.salesRepresentative) {
					// Set it as non-marketing and delete association
					BridgeService.triggerWorkflow(BridgeService.HUBSPOT_WORKFLOWS_ID.setContactAsNonMarketing, existingLegalRepresentative.user.email);
					BridgeService.deleteHubspotAssociationContactToCompany(existingLegalRepresentative.user, company.vendor);
				}
			}

			var isAlreadyUc = pro.db.PUserCompany.manager.select( $company==company && $user==u, true );
			if (isAlreadyUc!=null){
				isAlreadyUc.legalRepresentative = true;
				isAlreadyUc.update();
			}else{
				uc.insert();
			}
			
			throw Ok('/admin/vendor/view/${company.vendor.id}', "Représentant légal modifié");
		}
		view.title = 'Nouveau représentant légal du producteur "${company.vendor.name}"';
		view.form = f;
	}

	/**
		Deduplicate Vendors
	**/
	@tpl('admin/vendor/deduplicate.mtt')
	function doDeduplicate() {
		var sql = "SELECT MAX(id) as id,MAX(name) as name,MAX(email) as email,COUNT(id) as duplicates,MAX(zipCode) as zipCode from Vendor GROUP BY email HAVING duplicates>2 ORDER BY duplicates DESC ";
		var res = sys.db.Manager.cnx.request(sql).results();
		view.vendors = res;
		var d = 0;
		for (r in res)
			d += r.duplicates - 1;
		view.duplicates = d;		
	}

	@admin @tpl('admin/vendor/certification.mtt')
	function doCertification() { }

	@tpl('admin/vendor/dedupInfo.mtt')
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

			throw Ok("/admin/vendor/deduplicate", survivor.name + " a été dédupliqué");
		}
	}

	@tpl('admin/vendor/dedupInfoByName.mtt')
	function doFindduplicatesbyname(name:String) {
		view.vendors = VendorService.findVendors({name:name});
	}

	@tpl('admin/vendor/dedupInfoByZip.mtt')
	function doFindduplicatesbyzip(zip:String) {
		view.vendors = db.Vendor.manager.search($zipCode == zip, false);
	}

	@tpl('admin/vendor/nullEmailVendors.mtt')
	function doNullEmailVendors() {
		view.vendors = db.Vendor.manager.search($email == null, false);
		view.getStats = pro.db.VendorStats.getOrCreate;
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

	/**
		check and recompute payments ops
	**/
	@admin @tpl('admin/vendor/checkOperations.mtt')
	function doCheckOperations(group:db.Group,from:Date,to:Date,?autoFix=false) {
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
			throw Ok('/admin/vendor/checkOperations/${group.id}/$from/$to',"Operations corrigées");
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
			throw Error("/admin/vendor/view/" + vendor.id, vendor.name + " a deja un espace producteur");

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
			
			throw Ok('/admin/vendor/view/' + vendor.id, t._("This supplier has been saved"));
		}

		view.title = t._("Key-in a new vendor");
		// view.text = t._("We will send him/her an email to explain that your group is going to organize orders for him very soon");
		view.form = form;
	}

	@admin @tpl('admin/vendor/import.mtt')
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

		f.addElement(new sugoi.form.elements.IntSelect("group", "Choisissez un "+App.current.getTheme().groupWordingShort+" à dupliquer", cast data, true));

		if (f.isValid()) {
			var s = new pro.service.ProGroupService();
			var x = db.Group.manager.get(f.getValueOf("group"));
			s.duplicateGroup(x, true, x.name + "(copy)", x.getMainPlace().name);

			throw Ok("/", App.current.getTheme().groupWordingShort + " dupliqué");
		}

		view.form = f;
		view.title = "Dupliquer un "+App.current.getTheme().groupWordingShort;
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
							throw Error("/admin/vendor/view/" + vendor.id, "Ce producteur a encore des catalogues reliés à des "+App.current.getTheme().groupWordingShort_plural);
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
							throw Error("/admin/vendor/view/" + vendor.id, "Ce producteur a encore des catalogues reliés à des "+App.current.getTheme().groupWordingShort_plural);
						}
					}
				}

				cpro.lock();
				cpro.delete();

				VendorStats.updateStats(vendor);

				throw Ok("/admin/vendor/view/" + vendor.id, "Espace producteur effacé");

			case "delete":
				if (vendor.getContracts().length > 0) {
					throw Error("/admin/vendor/view/" + vendor.id, "Ce producteur a encore des catalogues dans des "+App.current.getTheme().groupWordingShort_plural);
				} else {
					vendor.lock();
					vendor.delete();

					throw Ok("/admin/vendor/", "Producteur effacé");
				}
		}
	}

	/**
	 * ADMIN : Transform a contract to a catalog
	 */
	@admin @tpl('form.mtt')
	public function doContractToCatalog(?catalog:db.Catalog, ?cagettePro:pro.db.CagettePro) {
		var f = new sugoi.form.Form("contract");
		view.title = "Importer un catalogue invité dans un espace producteur";
		if (catalog != null && cagettePro != null) {
			/*f.addElement(new sugoi.form.elements.IntInput("cid",catalog.name+" dans le "+App.current.getTheme().groupWordingShort+" "+catalog.group.name,catalog.id,true));
				f.addElement(new sugoi.form.elements.IntInput("companyId",cagettePro.vendor.name,cagettePro.id,true)); */

			view.text = 'Voulez vous importer ce catalogue <b>${catalog.name}</b><br/> dans l\'espace producteur <b>${cagettePro.vendor.name}</b> ?';

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
			f.addElement(new sugoi.form.elements.IntInput("companyId", "ID de l'espace producteur (CagettePro)", null, true));

			if (f.isValid()) {
				var cid = f.getElement("cid").getValue();
				var companyId:Int = f.getValueOf("companyId");
				var company = pro.db.CagettePro.manager.get(companyId, false);
				var contract = db.Catalog.manager.get(cid, false);

				if (company == null)
					throw "Cet espace producteur n'existe pas";
				if (contract == null)
					throw "Ce contrat n'existe pas";

				throw Redirect("/admin/vendor/contractToCatalog/" + contract.id + "/" + company.id);
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
		f.addElement(new sugoi.form.elements.IntInput("vid", "ID du producteur (qui doit avoir espace producteur) qui va recevoir le catalogue", null, true));

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

			throw Ok("/admin/vendor/moveCatalog", "Le catalogue \"" + catalog.name + "\" a été déplacé chez \"" + company.vendor.name + "\"");
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

			throw Ok("/admin/vendor/copyProducts", "Les produits de  \"" + vendor.name + "\" a été copiés chez \"" + destVendor.name + "\"");
		}

		view.form = f;
	}
	
	function doFixDuplicateRefs(catalog:db.Catalog){
		var s = new who.service.WholesaleOrderService(catalog);
		s.fixDuplicateRefs();
	}

}