package controller.admin;

import mangopay.Mangopay;
import payment.*;
import service.GroupService;
import service.ProductService;
import hosted.db.GroupStats;
import pro.db.VendorStats;
import pro.payment.MangopayECPayment;

class Group extends controller.Controller
{

	public function new() {
		super();	
	}

	/**
		Group admin home
	**/
	@tpl("admin/group/default.mtt")
	function doDefault(){
		var groups = [];
		var total = 0;
		var totalActive = 0;
		var defaultType = "all";

		// form
		var f = new sugoi.form.Form("groups");
		f.method = GET;
		f.addElement(new sugoi.form.elements.StringInput("groupName", "Nom du marché"));
		f.addElement(new sugoi.form.elements.StringInput("zipCodes", "Saisir des numéros de département séparés par des virgules ou laisser vide."));
		f.addElement(new sugoi.form.elements.StringSelect("country", "Pays", db.Place.getCountries(), "FR", true, ""));
		

		var data = [{label: "Tous", value: "any"},{label: "Paiement en ligne Stripe", value: "stripe"}, {label: "Paiement sur place", value: "onthespot"},{label: "Paiement en ligne Mangopay", value: "mangopay"}];
		f.addElement(new sugoi.form.elements.StringSelect("payment", "Moyen de paiement", data, "table", true, ""));

		var data = [
			{label: "Actifs", value: "active"},
			{label: "Inactifs", value: "inactive"},
			{label: "Tous", value: "all"}
		];
		f.addElement(new sugoi.form.elements.StringSelect("active", "Actifs ou pas", data, "active", true, ""));
		var data = [{label: "Tableau", value: "table"}, {label: "CSV", value: "csv"}];
		f.addElement(new sugoi.form.elements.StringSelect("output", "Sortie", data, "table", true, ""));

		var sql_select = "SELECT g.*,gs.active,gs.membersNum,gs.vendorNum,gs.iro,gs.turnover90days,p.name as pname, p.address1,p.address2,p.zipCode,p.country,p.city";
		var sql_where_or = [];
		var sql_where_and = [];
		var sql_end = "ORDER BY g.id ASC";
		var sql_from = [
			"`Group` g LEFT JOIN  GroupStats gs ON g.id=gs.groupId LEFT JOIN Place p ON g.placeId=p.id"
		];

		if (f.isValid()) {
			// filter by zip codes
			var zipCodes:Array<Int> = f.getValueOf("zipCodes") != null ? f.getValueOf("zipCodes").split(",").map(Std.parseInt) : [];
			if (zipCodes.length > 0) {
				for (zipCode in zipCodes) {
					var min = zipCode * 1000;
					var max = zipCode * 1000 + 999;
					sql_where_or.push('(p.zipCode>=$min and p.zipCode<=$max)');
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

			// country
			sql_where_and.push('p.country="${f.getValueOf("country")}"');

			// group name
			if (f.getValueOf("groupName") != null) {
				sql_where_and.push('g.name like "%${f.getValueOf("groupName")}%"');
			}

			//payment
			if (f.getValueOf("payment") != null && f.getValueOf("payment") != "any") {
				switch (f.getValueOf("payment")){
					case "stripe" : sql_where_and.push('g.allowedPaymentsType LIKE "%stripe%"');
					case "onthespot" : sql_where_and.push('( g.allowedPaymentsType LIKE "%cash%" OR g.allowedPaymentsType LIKE "%check%" OR g.allowedPaymentsType LIKE "%card-terminal%" )');
					case "mangopay" : sql_where_and.push('g.allowedPaymentsType LIKE "%mangopay-ec%"');
				}
				
			}
			



		} else {
			// default settings
			sql_where_and.push('active=1');
			// sql_where_and.push('type=${Type.enumIndex(defaultType)}');
			sql_where_and.push('p.country="FR"');
		}

		// QUERY
		if (sql_where_and.length == 0)
			sql_where_and.push("true");
		if (sql_where_or.length == 0)
			sql_where_or.push("true");
		var sql = '$sql_select FROM ${sql_from.join(", ")} WHERE (${sql_where_or.join(" OR ")}) AND ${sql_where_and.join(" AND ")} $sql_end';
		for (g in db.Group.manager.unsafeObjects(sql, false)) {
			groups.push(g);
		}

		view.form = f;

		for (g in groups) {
			if (untyped g.active)
				totalActive++;
			total++;
		}

		// TOTALS
		total = groups.length;
		view.total = total;
		view.groups = groups;
		view.totalActive = totalActive;

		switch (f.getValueOf("output")) {
			case "table":

			case "csv":
				var headers = [
					"id", "name", "mode", "placeName", "address1", "address2", "zipCode", "city", "active", "url", "contactName", "contactEmail",
					"contactPhone", "membersNum", "contractNum"
				];
				var data = [];
				for (g in groups) {
					var active:Bool = untyped g.active;
					var contact = g.contact;
					data.push({
						id: g.id,
						name: g.name,
						mode: "Marché",
						placeName: untyped g.pname,
						address1: untyped g.address1,
						address2: untyped g.address2,
						zipCode: untyped g.zipCode,
						city: untyped g.city,
						active: switch (active) {
							case true: "OUI";
							case false: "NON";
						},
						url: "https://app.cagette.net/group/" + g.id,
						contactName: contact != null ? contact.getName() : "",
						contactEmail: contact != null ? contact.email : "",
						contactPhone: contact != null ? contact.phone : "",
						membersNum: untyped g.membersNum,
						contractNum: untyped g.contractNum
					});
				}

				sugoi.tools.Csv.printCsvDataFromObjects(data, headers, "marchés");
		}
	}

	@admin
	@tpl("admin/group/view.mtt")
	function doView(group:db.Group) {
		
		view.group = group;
		var mgpConf = mangopay.MangopayPlugin.getGroupConfig(group);
		if(mgpConf!=null){
			view.debugLegalUserModule = haxe.crypto.Base64.encode(haxe.io.Bytes.ofString(haxe.Json.stringify({moduleName:"mangopay-legal-user-module",props:{"mangopayUserId":mgpConf.legalUser.mangopayUserId}})));
		}
		view.mangopay = mgpConf;

		if( app.params.get("roleIds")=="1" ){
			for( md in db.MultiDistrib.manager.search($distribStartDate > Date.now() && $group==group,true) ){
				var rids = [];
				for( d in md.getDistributions() ){
					for( role in service.VolunteerService.getRolesFromContract(d.catalog) ){
						rids.push(role.id);
					}
				}
				md.lock();
				md.volunteerRolesIds = rids.join(",");
				md.update();
			}
		}

		/*if( app.params.get("dispatch")=="1" ){
			//ENABLE DISPATCH
			group.lock();
			group.betaFlags.set(Dispatch);
			group.setAllowedPaymentTypes(["stripe"]);
			
			//get active and non disabled vendors
			var vendors = group.getActiveContracts(false).map(c -> c.vendor).filter(v -> !v.isDisabled()).array();
			vendors = ObjectListTool.deduplicate(vendors);

			if( vendors.length > vendors.filter(v -> v.isDispatchReady()).length){
				var badVendors = vendors.filter(v -> !v.isDispatchReady());
				throw Error("/admin/group/view/"+group.id,"Les producteurs suivants ne sont pas prêts pour le dispatch : <b>"+badVendors.map(v-> "#"+v.id+"-"+v.name).join(", ")+"</b>");
			}

			group.update();

			throw Ok("/admin/group/view/"+group.id,"Le groupe est configuré pour le dispatch");
		}*/

		if( app.params.get("removeMangopay")=="1" ){

			group.lock();

			//delete LegalUserGroup if wallet is empty
			var mgpLegalUserGroup = mangopay.MangopayPlugin.getGroupConfig(group);
			if(mgpLegalUserGroup==null){
				throw "No mgpLegalUserGroup";
			}
			var mgpLegalUser = mgpLegalUserGroup.legalUser;						
			var wallet = Mangopay.getOrCreateGroupWallet(mgpLegalUser.mangopayUserId,group);

			if(wallet.Balance.Amount > 0){
				throw "Wallet "+wallet.Id+" is not empty";
			}

			mgpLegalUserGroup.delete();

			//payments types
			var pt = group.getAllowedPaymentTypes().filter(p -> p!=MangopayECPayment.TYPE);
			if(pt.length==0){
				pt = [Cash.TYPE,Check.TYPE];
			}
			group.setAllowedPaymentTypes(pt);
			group.update();

			throw Ok("/admin/group/view/"+group.id,"Mangopay retiré, moyens de paiements : "+pt.join(","));

		}

		if( app.params.get("duplicate")=="1" ){

			//duplicate group

			var g = GroupService.duplicateGroup(group);
			g.name = group.name+" (marché)";
			g.setAllowedPaymentTypes([Cash.TYPE,Check.TYPE]);
			g.update();

			var place = group.getMainPlace();

			var p = new db.Place();
			p.name = place.name;
			p.group = g;
			p.address1 = place.address1;
			p.address2 = place.address2;
			p.city = place.city;
			p.zipCode = place.zipCode;
			p.insert();

			//add members in the new group
			for(m in group.getMembers()){
				var ug = db.UserGroup.getOrCreate(m,g);
			}

			//give main rights
			for(ug in group.getGroupAdmins()){

				var ug2 = db.UserGroup.getOrCreate(ug.user,g);

				for( r in ug.getRights()){
					switch (r.right){
						case "GroupAdmin" 	: ug2.giveRight(GroupAdmin);
						case "Messages" 	: ug2.giveRight(Messages);
						case "Membership" 	: ug2.giveRight(Membership);
						default: //
					}
				}
			}

			//copy catalogs
			for ( c in group.getActiveContracts()){

				var newcat = new db.Catalog();
				newcat.name = c.name;
				newcat.startDate = c.startDate;
				newcat.endDate = c.endDate;
				newcat.description = c.description;
				newcat.contact = c.contact;
				newcat.vendor = c.vendor;
				newcat.group = g;
				newcat.insert();

				//copy products
				for( p in c.getProducts()){

					var newproduct = ProductService.duplicate(p);
					newproduct.catalog = newcat;
					newproduct.update();
				}

			}
			throw Ok("/admin/group/view/"+g.id,"Marché copié");
		}

	
		view.vendors = group.getActiveVendors();
		var gs = GroupStats.getOrCreate(group.id,true);

		if( app.params.get("refresh")=="1" ){
			gs.updateStats();
		}
		
		view.groupStats = gs; 
		view.getVendorStats = function(v:db.Vendor){
			return VendorStats.getOrCreate(v);
		}
		
		checkToken();
	
	}

	@admin public function doAddMe(g:db.Group){		
		var ua = app.user.makeMemberOf(g);
		throw Ok("/user/choose?group="+g.id, "Vous faites maintenant partie de " + ua.group.name);
	}
	
	@admin public function doDeleteGroup(a:db.Group) {
	
		if (checkToken()) {
			a.lock();
			a.delete();
			throw Ok("/p/hosted/","Marché effacé");
		}
	}
	
	
	@admin
	function doGeocode(group:db.Group){		
		/*var coords = hosted.HostedPlugIn.geocodeGroup(group);		
		throw Ok("/admin/group/view/"+group.id,"Geocoding OK "+coords);*/
	}
	
	@admin
	function doRefresh(group:db.Group){
		
		var h = hosted.db.GroupStats.getOrCreate(group.id, true);
		var o = h.updateStats();		
		var str = "ACTIF : " + o.active+", VISIBLE : " + o.visible+" ( CagetteNetwork : " + o.cagetteNetwork + ", distributions : " + o.distributions + ", geoloc : " + o.geoloc + ", MembersNum : " + o.members+" )";		
		throw Ok("/admin/group/view/"+group.id,"Visible sur la carte : "+str);
	}


	/*@admin
	public function doDebugOps(group:db.Group) {

		//essaye de trouver les ops de commande en double (faille dans findVOrderOperation )
		var basketIds = [];
		for( m in group.getMembers()){
			for (op in db.Operation.getOperations(m, group) ){

				if(op.type == VOrder){
					trace(op);
					var i : VOrderInfos = op.getOrderInfos();
					trace(i.basketId);

					if(Lambda.has(basketIds,i.basketId)) trace("DOUBLE BASKET ID "+i.basketId);

					basketIds.push(i.basketId);
				}

			}
		} 

	}*/	

	@admin
	function doResetBalances(g:db.Group){
		for ( m in g.getMembers()){

			var ua = db.UserGroup.get(m, g);
			var balance = ua.balance;
			if(balance<0 || balance>0){
				Sys.print('update ${m.getName()} : balance : $balance, fix : ${0-balance}<br/>');
				var op = service.PaymentService.makePaymentOperation(m,g,payment.Cash.TYPE,0-balance,"Correction de solde");
				//fix op
				op.pending = false;
				op.amount = 0-balance;
				op.update();
				Sys.print(op+"<br>");
				service.PaymentService.updateUserBalance(m,g);
			}
		}
		throw Ok("/admin/group/view/"+g.id,"Soldes corrigés");
	}

	public function doSyncToHubspot(group:db.Group) {

		for( vendor in group.getActiveVendors()){
			service.BridgeService.syncVendorToHubspot(vendor);
		}
		
		throw Ok("/admin/group/view/"+group.id,"Synchronisation hubspot faite");
	}

	function doDeleteDemoContracts(a:db.Group){
		var contracts = a.deleteDemoContracts();
		throw Ok("/admin/group/view/"+a.id,"Contrats suivants effacés : "+contracts.map(function(c) return c.name).join(", "));
	}
	
	function doDisableNotifs(g:db.Group){
		for ( m in g.getMembers()){
			m.lock();
			m.flags.unset(db.User.UserFlags.HasEmailNotif24h);
			m.flags.unset(db.User.UserFlags.HasEmailNotif4h);
			m.update();
		}
		throw Ok("/admin/group/view/"+g.id, "Notifications désactivées pour tous les membres de ce marché");
	}

	function doEnableNotifs(g:db.Group){
		for ( m in g.getMembers()){
			m.lock();
			m.flags.set(db.User.UserFlags.HasEmailNotif24h);
			// m.flags.unset(db.User.UserFlags.HasEmailNotif4h);
			m.flags.set(db.User.UserFlags.HasEmailNotifOuverture);
			m.update();
		}
		throw Ok("/admin/group/view/"+g.id, "Notifications activées pour tous les membres de ce marché");
	}

}
