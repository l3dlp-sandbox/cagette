package controller;
import service.SubscriptionService;
import sugoi.form.elements.StringInput;
import service.OrderService;
import service.WaitingListService;
import service.DistributionService;
import db.Group;
import Common;

/**
 * Groups
 */
class Group extends controller.Controller
{

	/**
	 * Public page of a group
	 */
	@tpl('group/view.mtt')
	function doDefault( group : db.Group ) {
		
		if ( group.regOption == db.Group.RegOption.Open ) {

			if (app.session.data == null) app.session.data = {};
			app.session.data.amapId = group.id;
			throw Redirect("/");
		}
		
		view.group = group;
		var activeCatalogs = group.getActiveContracts();
		view.contracts = activeCatalogs;
		view.pageTitle = group.name;
		group.getMainPlace(); //just to update cache

		var isMemberOfGroup = app.user == null ? false : app.user.isMemberOf(group); 
		view.isInWaitingList = app.user == null ? false : db.WaitingList.manager.select($amapId == group.id && $user == app.user);

		if ( app.user == null ) {
			service.UserService.prepareLoginBoxOptions(view,group);
		}	
		view.user = app.user;
		view.isMember = isMemberOfGroup;

		// Documents
		view.visibleGroupDocuments = group.getVisibleDocuments( isMemberOfGroup );
		var visibleCatalogsDocuments = new Map< Int, List<sugoi.db.EntityFile> >();
		for ( catalog in activeCatalogs ) {
			
			visibleCatalogsDocuments.set( catalog.id, catalog.getVisibleDocuments( app.user ) );
		}
		view.visibleCatalogsDocuments = visibleCatalogsDocuments;
	}
	
	/**
	 * Register to a waiting list.
	 * the user can be logged or not !
	 */
	@tpl('form.mtt')
	function doList(group:db.Group){
		if ( app.user==null ) {
			throw Redirect("/group/"+group.id);
		}
		
		//checks
		if (group.regOption != db.Group.RegOption.WaitingList) throw Redirect("/group/" + group.id);
		if (app.user != null) {
			try{
				WaitingListService.canRegister(app.user,group);
			}catch(e:tink.core.Error){				
				throw Error("/group/" + group.id,e.message);
			}
		}
		
		//build form
		var form = new sugoi.form.Form("reg");				
		
		form.addElement(new sugoi.form.elements.TextArea("msg", t._("Leave a message")));
		
		if (form.isValid()){
			try{
				WaitingListService.registerToWl(app.user,group,form.getValueOf("msg"));
				throw Ok("/group/" + group.id,t._("Your subscription to the waiting list has been recorded. You will receive an e-mail as soon as your request is processed.") );
			}catch(e:tink.core.Error){
				throw Error("/group/list/" + group.id,e.message);
			}
			
		}
		
		view.title = t._("Subscription to \"::groupeName::\" waiting list", {groupeName:group.name});
		view.form = form;		
	}

	/**
		Cancel suscription request
	**/
	function doListCancel(group:db.Group){
		try{
			WaitingListService.removeFromWl(app.user,group);
		}catch(e:tink.core.Error){				
			throw Error("/group/" + group.id,e.message);
		}
		throw Ok("/group/" + group.id,t._("You've been removed from the waiting list"));
	}
	
	
	/**
	 * 	Register direclty in an open group
	 * 
	 * 	the user can be logged or not !
	
	@tpl('form.mtt')
	function doRegister(group:db.Group){
		
		if (group.regOption != db.Group.RegOption.Open) throw Redirect("/group/" + group.id);
		if (app.user != null){			
			if ( db.UserGroup.manager.select($amapId == group.id && $user == app.user) != null) throw Error("/group/" + group.id, t._("You are already member of this group."));			
		}
		
		var form = new sugoi.form.Form("reg");	
		form.submitButtonLabel = t._("Join the group");
		form.addElement(new sugoi.form.elements.Html("html",t._("Confirm your subscription to \"::groupName::\"", {groupName:group.name})));
		if (app.user == null){
			form.addElement(new StringInput("userFirstName", t._("Your firstname"),"",true));
			form.addElement(new StringInput("userLastName", t._("Your lastname"), "", true));
			var em = new StringInput("userEmail", t._("Your e-mail"), "", true);
			em.addValidator(new EmailValidator());
			form.addElement(em);		
			form.addElement(new StringInput("address", t._("Address"), "", true));					
			form.addElement(new StringInput("zipCode", t._("Zip code"), "", true));		
			form.addElement(new StringInput("city", t._("City"), "", true));		
			form.addElement(new StringInput("phone", t._("Phone"), "", true));		
		}
		
		if (form.isValid()){
			
			if (app.user == null){
				var f = form;
				var user = new db.User();
				user.email = f.getValueOf("userEmail");
				user.firstName = f.getValueOf("userFirstName");
				user.lastName = f.getValueOf("userLastName");
				user.address1 = f.getValueOf("address");
				user.zipCode = f.getValueOf("zipCode");
				user.city = f.getValueOf("city");
				user.phone = f.getValueOf("phone");
				
				if ( db.User.getSameEmail(user.email).length > 0 ) {
					throw Ok("/user/login",t._("You already subscribed to Cagette.net, please log in on this page"));
				}
				
				user.insert();				
				app.session.setUser(user);
				
			}			
			
			var w = new db.UserGroup();
			w.user = app.user;
			w.amap = group;
			w.insert();
			
			throw Ok("/user/choose", t._("Your subscription has been taken into account"));
		}
		
		view.title = t._("Subscription to \"::groupName::\"", {groupName:group.name});
		view.form = form;
		
	}*/
	
	/**
	 * create a new group
	 */
	@tpl("form.mtt")
	function doCreate() {
		
		view.title = t._("Create a new Cagette Group");

		var f = new sugoi.form.Form("c");
		f.addElement(new StringInput("name", t._("Name of your group"), "", true));
		
		//group type
		var data = [
			{ 
				label:t._("CSA"),
				value:"0",
				desc : "Commandes en <a href='https://wiki.cagette.net/admin:admin_boutique#mode_amap' target='_blank'>Mode AMAP</a> ( contrats AMAP classiques ou variables ), groupe fermé avec liste d'attente et gestion des adhésions."
			},
			{
				label:t._("Grouped orders"),
				value:"1",
				desc : "Commandes en <a href='https://wiki.cagette.net/admin:admin_boutique#mode_boutique' target='_blank'>Mode Boutique</a>, groupe fermé avec liste d'attente et gestion des adhésions."
			},
			{
				label:"En direct d'un collectif de producteurs",
				value:"2",
				desc : "Commandes en <a href='https://wiki.cagette.net/admin:admin_boutique#mode_boutique' target='_blank'>Mode Boutique</a>, groupe ouvert : n'importe qui peut commander."
			},
			{
				label:"En direct d'un producteur",
				value:"3",
				desc : "Commandes en <a href='https://wiki.cagette.net/admin:admin_boutique#mode_boutique' target='_blank'>Mode Boutique</a>, groupe ouvert : n'importe qui peut commander."
			},
		];	
		var gt = new sugoi.form.elements.RadioGroup("type", t._("Group type"), data ,"1", Std.string( db.Catalog.TYPE_VARORDER ), true, true, true);
		f.addElement(gt);
		
		if (f.checkToken()) {
			
			var user = app.user;
			
			var g = new db.Group();
			g.name = f.getValueOf("name");
			g.contact = user;
			
			var type:GroupType = Type.createEnumIndex(GroupType, Std.parseInt(f.getValueOf("type")) );
			
			switch(type){
			case null : 
				throw "unknown group type";

			case Amap : 
				g.flags.unset(ShopMode);
				g.flags.set(HasPayments);
				g.hasMembership=true;
				g.regOption = WaitingList;
				
			case GroupedOrders :
				g.flags.set(ShopMode);
				g.hasMembership=true;
				g.regOption = WaitingList;
				
			case ProducerDrive,FarmShop : 
				g.flags.set(ShopMode);								
				g.flags.set(PhoneRequired);
				g.regOption = Open;
			}
			
			g.groupType = type;
			g.insert();
			
			var ua = new db.UserGroup();
			ua.user = user;
			ua.group = g;
			ua.insert();
			ua.giveRight(Right.GroupAdmin);
			ua.giveRight(Right.Membership);
			ua.giveRight(Right.Messages);
			ua.giveRight(Right.ContractAdmin(null));
			
			//example datas
			var place = new db.Place();
			place.name = t._("Market square");
			place.zipCode  = "000";
			place.city = "St Martin de la Cagette";
			place.group = g;
			place.insert();
			
			//contrat AMAP
			var vendor = db.Vendor.manager.select($email=="jean@cagette.net",false);
			if(vendor==null){
				vendor = new db.Vendor();
				vendor.name = "Jean Martin EARL";
				vendor.zipCode = "000";
				vendor.city = "St Martin de la Cagette";
				vendor.email = "jean@cagette.net";
				vendor.insert();
			}
			
			if ( type == Amap ) {

				var contract = new db.Catalog();
				contract.name = t._("Vegetables CSA contract - Example");
				contract.description = t._("CSA contract example");
				contract.group  = g;
				contract.type = db.Catalog.TYPE_CONSTORDERS;
				contract.vendor = vendor;
				contract.startDate = Date.now();
				contract.endDate = DateTools.delta(Date.now(), 1000.0 * 60 * 60 * 24 * 364);
				contract.contact = user;
				contract.distributorNum = 2;
				contract.orderStartDaysBeforeDistrib = 365;
				contract.orderEndHoursBeforeDistrib = 24;
				contract.insert();
				
				var product = new db.Product();
				product.name = t._("Big basket of vegetables");
				product.price = 15;
				product.organic = true;
				product.catalog = contract;
				product.insert();
				
				var product = new db.Product();
				product.name = t._("Small basket of vegetables");
				product.price = 10;
				product.organic = true;
				product.catalog = contract;
				product.insert();
				
				var date = DateTools.delta(Date.now(), 1000.0 * 60 * 60 * 24 * 14);
				DistributionService.create(
					contract,
					date,
					DateTools.delta(date, 1000.0 * 60 * 90),
					place.id,
					Date.now(),
					DateTools.delta( Date.now(), 1000.0 * 60 * 60 * 24 * 13)
				);	
				var ordersData = new Array< { productId : Int, quantity : Float, invertSharedOrder : Bool, userId2 : Int } >();
				ordersData.push( { productId : product.id, quantity : 1, invertSharedOrder : false, userId2 : null } );
				var ss = new SubscriptionService();
				ss.createSubscription( user, contract, ordersData, null );
			}
			
			//contrat variable
			var vendor = db.Vendor.manager.select($email=="galinette@cagette.net",false);
			if(vendor==null){
				vendor = new db.Vendor();
				vendor.name = t._("Farm Galinette");
				vendor.zipCode = "000";
				vendor.city = "St Martin de la Cagette";
				vendor.email = "galinette@cagette.net";
				vendor.insert();			
			}			
			
			var contract = new db.Catalog();
			contract.name = t._("Chicken catalog - Example");
			contract.description = t._("Chicken catalog example.");
			contract.group  = g;
			contract.type = db.Catalog.TYPE_VARORDER;
			contract.vendor = vendor;
			contract.startDate = Date.now();
			contract.endDate = DateTools.delta(Date.now(), 1000.0 * 60 * 60 * 24 * 364);
			contract.contact = user;
			contract.distributorNum = 2;
			contract.flags.set(db.Catalog.CatalogFlags.UsersCanOrder);
			contract.insert();
			
			var egg = new db.Product();
			egg.name = t._("12 eggs");
			egg.price = 5;
			//egg.type = 6;
			egg.organic = true;
			egg.catalog = contract;
			egg.insert();
			
			var p = new db.Product();
			p.name = t._("Chicken");
			//p.type = 2;
			p.price = 9.50;
			p.organic = true;
			p.catalog = contract;
			p.insert();
			
			var date = DateTools.delta(Date.now(), 1000.0 * 60 * 60 * 24 * 14);
			var d = DistributionService.create(
				contract,
				date,
				DateTools.delta(date, 1000.0 * 60 * 90),
				place.id,
				Date.now(),
				DateTools.delta( Date.now(), 1000.0 * 60 * 60 * 24 * 13)
			);

			var ordersData = new Array< { productId : Int, quantity : Float, ?userId2 : Int, ?invertSharedOrder : Bool } >();
			ordersData.push( { productId : egg.id, quantity : 2 } );
			ordersData.push( { productId : p.id, quantity : 1 } );
			var ss = new SubscriptionService();
			var subscription = ss.createSubscription( user, contract, ordersData, null );
			
			OrderService.make(user, 2, egg, d.id, false, subscription );
			OrderService.make(user, 1, p, d.id, false, subscription );
			
			App.current.session.data.amapId  = g.id;
			app.session.data.newGroup = true;

			#if plugins
			try{
				//sync if this user is not cpro
				if(service.VendorService.getVendorsFromUser(app.user).length==0){
					crm.CrmService.syncToSiB(app.user,true,"group_created",{groupName:g.name,userName:app.user.firstName});
				}
			}catch(e:Dynamic){
				//fail silently
				app.logError(Std.string(e));
			}
			#end

			throw Redirect("/");
		}
		
		view.form= f;
		
	}

	@admin
	function doTest(){
		#if plugins
		var user = db.User.manager.get(1,false);

		crm.CrmService.syncToSiB(user,true,"group_created",{groupName:"mon Groupe",userName:user.firstName});

		#end
	}
	
	/**
		Displays a google map in a popup
	**/
	// @tpl('group/place.mtt')
	// public function doPlace(place:db.Place){
	// 	view.place = place;
		
	// 	//build adress for google maps
	// 	var addr = "";
	// 	if (place.address1 != null) addr += place.address1;
	// 	if (place.address2 != null) addr += ", " + place.address2;
	// 	if (place.zipCode != null) addr += " " + place.zipCode;
	// 	if (place.city != null) addr += " " + place.city;
		
	// 	view.addr = view.escapeJS(addr);
	// }

	@tpl("group/map.mtt")
	public function doMap(?args:{?lat:Float,?lng:Float,?address:String}){

		view.container = "container-fluid";
		
		//if no param is sent, focus on Paris
		if (args == null || (args.address == null && args.lat == null && args.lng == null)){
			args = {lat:48.855675, lng:2.3472365};
		}
		
		view.lat = args.lat;
		view.lng = args.lng;
		view.address = args.address;		
	}
}