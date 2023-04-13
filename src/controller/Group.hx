package controller;
import Common;
import db.Group;
import payment.Cash;
import payment.Cash;
import service.BridgeService;
import service.DistributionService;
import service.OrderService;
import service.WaitingListService;
import sugoi.form.elements.StringInput;

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

		if(group.disabled!=null){
			throw Redirect("/group/disabled/"+group.id);
		}
		
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
	 * create a new group
	 */
	@tpl("group/create.mtt")
	function doCreate() {
		App.current.session.data.amapId = null;

		var cagettePros = service.VendorService.getCagetteProFromUser(App.current.user);
		if (!(App.current.getSettings().onlyVendorsCanCreateGroup==null
			 || App.current.getSettings().onlyVendorsCanCreateGroup==false 
			 || (App.current.getSettings().onlyVendorsCanCreateGroup==true && cagettePros!=null && cagettePros.length>0))
			 ) {
			throw Redirect("/");
		}
		
		if(app.user==null) {
			view.userName = "";
			view.sid = App.current.session.sid;
			return;
		}
	}

	@admin
	function doTest(){
		#if plugins
		
		var user = db.User.manager.get(1,false);
		Sys.print("sync user "+user.getName());
		BridgeService.syncUserToHubspot(user);
		service.BridgeService.triggerWorkflow(29805116, user.email);
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
		
		view.lat = args.lat;
		view.lng = args.lng;
		view.address = args.address;
	}

	@tpl("group/disabled.mtt")
	public function doDisabled(?group: db.Group){
		var group = group != null ? group : App.current.getCurrentGroup();
		if (group == null) throw Redirect("/");
		view.group = group;
	}
}