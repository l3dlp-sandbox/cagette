package controller;
import sugoi.form.elements.Html;
import sugoi.form.elements.Checkbox;
import haxe.EnumFlags;
import Common;
import datetime.DateTime;
import db.Group.GroupFlags;
import db.UserGroup;
import neko.Web;
import sugoi.form.Form;
import sugoi.form.elements.FloatInput;
import sugoi.form.elements.Input.InputType;
import sugoi.form.elements.IntInput;
import sugoi.form.elements.IntSelect;
import sugoi.form.elements.StringInput;
using tools.DateTool;

class AmapAdmin extends Controller
{

	public function new() 
	{
		super();
		if (!app.user.isAmapManager()) throw Error("/", t._("Access forbidden"));
		
		//lance un event pour demander aux plugins si ils veulent ajouter un item dans la nav
		var nav = new Array<Link>();

		nav.push({id: "stripe",name: "Paiement en ligne Stripe", 	link:"/amapadmin/stripe",icon:"bank-card"});				
				
		var e = Nav(nav,"groupAdmin");
		app.event(e);
		view.nav = e.getParameters()[0];
	}

	@tpl("amapadmin/default.mtt")
	function doDefault() {

		var group = app.user.getGroup();
		view.membersNum = UserGroup.manager.count($group == group);
		view.contractsNum = group.getActiveContracts().length;
		
		//visible on map
		#if plugins
		var h = hosted.db.GroupStats.getOrCreate(group.id, true);
		var o = h.updateStats();
		
		var str = "";
		if(!o.cagetteNetwork){
			str += "L'option 'Lister ce marché sur la carte' n'est pas cochée.";
		}
		if (!o.geoloc){
			str += "Votre lieu de distribution n'a pas pu être géolocaliser, merci de compléter ou corriger son adresse. ";
		}
		if( ! o.distributions ){
			str += "Vous devez avoir des distributions planifiées. ";
		}
		if(!o.members){
			str += "Vous devez avoir au moins 3 personnes dans votre marché. ";
		}

		view.visibleOnMapText = str;
		view.visibleOnMap = o.visible;

		#else
		view.visibleOnMap = true;
		#end
	}
	
	@tpl("amapadmin/form.mtt")
	function doMembership(){
		
		addBc('membership',"Adhésions","amapadmin/membership");
		var form = new sugoi.form.Form("membership");
		var group = app.user.getGroup();

		//membership
		form.addElement( new sugoi.form.elements.Checkbox("membership","Gestion des adhésions",group.hasMembership), 13);
		form.addElement( new sugoi.form.elements.IntInput("membershipFee","Montant de l'adhésion (laisser vide si variable)",group.membershipFee), 14);
		var dp = new form.CagetteDatePicker("membershipRenewalDate","Date de renouvellement annuelle des adhésions",group.membershipRenewalDate);
		// dp.format = "D MMMM";
		form.addElement( dp ,15 );
		//avoid modifiying another group
		var groupId = new sugoi.form.elements.IntInput("groupId","groupId",group.id);
		groupId.inputType = InputType.ITHidden;
		form.addElement( groupId );

		if (form.checkToken()) {

			if( form.getValueOf("groupId") != group.id ) throw "Vous avez changé de marché.";

			group.lock();
			group.hasMembership = form.getValueOf("membership")==true;			
			group.membershipFee = form.getValueOf("membershipFee");
			group.membershipRenewalDate = form.getValueOf("membershipRenewalDate");
			group.update();
			throw Ok("/amapadmin","Paramètres d'adhésion mis à jour");
			
		}

		view.form = form;
		view.title = "Adhésions";
	}

	@tpl("amapadmin/rights.mtt")
	public function doRights() {
		view.users = app.user.getGroup().getGroupAdmins();
		addBc('rights','Droits d\'administration','/amapadmin/rights');
	}
	
	
	@tpl("amapadmin/form.mtt")
	public function doEditRight(?u:db.User) {
		addBc('rights','Droits d\'administration','/amapadmin/rights');
		var form = new sugoi.form.Form("editRight");
		
		if (u == null) {
			form.addElement( new IntSelect("user", t._("Member") , app.user.getGroup().getMembersFormElementData(), null, true) );	
		}
		
		var data = [];
		data.push({label:t._("Group administrator"), value:"GroupAdmin"});
		data.push({label:t._("Membership management"),value:"Membership"});
		data.push({label:t._("Messages"),value:"Messages"});
		
		var ua : db.UserGroup = null;
		var populate :Array<String> = null;
		if (u != null) {
			ua = db.UserGroup.get(u, app.user.getGroup(), true);
			if (ua == null) throw "no user";
			populate = ua.getRights().map(r -> r.right);
		}
		
		form.addElement( new sugoi.form.elements.CheckboxGroup("rights", t._("Rights"), data, populate, true, true) );
		form.addElement( new sugoi.form.elements.Html("html","<hr/>"));
		
		//Rights on contracts
		var data = [];
		var populate :Array<String> = [];
		data.push({value:"contractAll",label:t._("All catalogs")});
		for (r in app.user.getGroup().getActiveContracts(true)) {
			data.push( { label:r.name , value:"contract"+Std.string(r.id) } );
		}
		
		if(ua!=null && ua.getRights()!=null && ua.getRights().length>0){
			for ( r in ua.getRights()) {
				switch(r.right) {
					case "ContractAdmin":
						if (r.params == null) {
							populate.push("contractAll");
						}else {
							populate.push("contract"+r.params[0]);	
						}
						
					default://
				}
			}
		}
		

		form.addElement( new sugoi.form.elements.CheckboxGroup("rights", t._("Catalogs management") , data, populate, true, true) );
		
		if (form.checkToken()) {
			
			var wasManager = app.user.isGroupManager();
			
			if (u == null) {				
				ua = db.UserGroup.manager.select($userId == Std.parseInt(form.getValueOf("user")) && $groupId == app.user.getGroup().id, true);
			}			

			ua.rights = "[]";

			var arr : Array<String> = cast form.getElement("rights").value;
			for ( r in arr) {
				if (r.substr(0, 8) == "contract") {
					if (r == "contractAll") {
						ua.giveRight( Right.ContractAdmin() );
					}else {
						ua.giveRight( Right.ContractAdmin(Std.parseInt(r.substr(8)) ) );	
					}
					
				}else {
					ua.giveRight( Right.createByName(r) );	
				}
			}
			
			//avoid "cut my own hands" problem
			if (ua.user.id == app.user.id && wasManager ) {
				if (!ua.hasRight(GroupAdmin)) {
					throw Error("/amapadmin/rights", t._("You cannot strip yourself of admin rights."));
				}
			}			
			
			ua.update();
			
			if (ua.getRights().length == 0) {
				throw Ok("/amapadmin/rights", t._("Rights removed"));
			}else {
				throw Ok("/amapadmin/rights", t._("Rights created or modified"));
			}
			
		}
		
		if (u == null) {
			view.title = t._("Give rights to a user");
		}else {
			view.title = t._("Modify the rights of ::user::",{user:u.getName()});
		}
		
		view.form = form;
		
	}
	
	function doVolunteers(d:haxe.web.Dispatch) {
		addBc('volunteers',"Permanences","amapadmin/volunteers");
		d.dispatch(new controller.amapadmin.Volunteers());
	}

	function doDocuments( dispatch : haxe.web.Dispatch ) {
		addBc('documents',"Documents","amapadmin/documents");
		dispatch.dispatch( new controller.Documents() );
	}

	/**
	 * Set up group currency. Default is EURO
	 */
	@tpl("amapadmin/form.mtt")
	function doCurrency(){
		addBc("currency","Monnaie","/amapadmin/currency");
		view.title = t._("Currency used by your group.");
		
		var f = new sugoi.form.Form("curr");
		f.addElement(new sugoi.form.elements.StringInput("currency", t._("Currency symbol"), app.user.getGroup().getCurrency()));
		f.addElement(new sugoi.form.elements.StringInput("currencyCode", t._("3 digit ISO code"), app.user.getGroup().currencyCode));
		
		if ( f.isValid()){
			
			app.user.getGroup().lock();
			app.user.getGroup().currency = f.getValueOf("currency");
			app.user.getGroup().currencyCode = f.getValueOf("currencyCode");
			app.user.getGroup().update();
			
			throw Ok("/amapadmin/currency", t._("Currency updated"));
		}
		
		view.form = f;
	}
	
	/**
	 * payment types config
	 */
	@tpl("form.mtt")
	function doPayments(){
		
		var f = new sugoi.form.Form("paymentTypes");
		var types = service.PaymentService.getPaymentTypes(PCGroupAdmin);
		var formdata = [for (t in types){label:t.name, value:t.type, desc:t.adminDesc, docLink:t.docLink}];		
		var selected = app.user.getGroup().getAllowedPaymentTypes();
		f.addElement(new sugoi.form.elements.CheckboxGroup("paymentTypes", t._("Authorized payment types"),formdata, selected) );
		
		var group = app.user.getGroup();

		if(group.isDispatch()){
			throw Error("/amapadmin","Ce marché utilise le paiement en ligne avec Stripe, il n'est pas possible d'y ajouter d'autres moyens de paiement.");
		}

		// if (group.checkOrder == ""){
		// 	group.lock();
		// 	group.checkOrder = app.user.getGroup().name;
		// 	group.update();
		// }
		// f.addElement( new sugoi.form.elements.StringInput("checkOrder", t._("Make the check payable to"), app.user.getGroup().checkOrder, false)); 
		f.addElement( new sugoi.form.elements.StringInput("IBAN", t._("IBAN of your bank account for transfers"), app.user.getGroup().IBAN, false)); 
		//avoid modifiying another group
		var groupId = new sugoi.form.elements.IntInput("groupId","groupId",group.id);
		groupId.inputType = InputType.ITHidden;
		f.addElement( groupId );

		if (f.isValid()){
			
			if( f.getValueOf("groupId") != group.id ) throw "Vous avez changé de marché.";

			group.lock();
			var paymentTypes:Array<String> = f.getValueOf("paymentTypes");

			if(paymentTypes.length==0){
				throw Error(sugoi.Web.getURI(),"Vous devez choisir au moins un moyen de paiement");
			}

			group.setAllowedPaymentTypes(paymentTypes);
			// group.checkOrder = f.getValueOf("checkOrder");
			group.IBAN = f.getValueOf("IBAN");
			group.update();
			
			throw Ok("/amapadmin/payments", t._("Payment options updated"));
			
		}
		
		view.title = t._("Means of payment");
		view.form = f;
	}



	@tpl("amapadmin/stats.mtt")
	function doStats(){
		addBc("stats","Statistiques","amapadmin/stats");

		view.groupId = app.getCurrentGroup().id;
	}

	@tpl("amapadmin/stripe.mtt")
	public function doStripe(){
		var group = app.getCurrentGroup();

		//get active and non disabled vendors
		var vendors = group.getActiveContracts(false).map(c -> c.vendor).filter(v -> !v.isDisabled()).array();
		vendors = tools.ObjectListTool.deduplicate(vendors);

		if(app.params.get("enableStripe")=="1"){

			//ENABLE DISPATCH
			group.lock();
			group.betaFlags.set(Dispatch);
			group.setAllowedPaymentTypes(["stripe"]);

			if( vendors.length > vendors.filter(v -> v.isDispatchReady()).length){
				var badVendors = vendors.filter(v -> !v.isDispatchReady());
				throw Error("/amapadmin/stripe","Les producteurs suivants n'ont pas de compte Stripe configuré : <b>"+badVendors.map(v-> "#"+v.id+"-"+v.name).join(", ")+"</b>");
			}

			//block if MGP !
			// if(mangopay.db.MangopayLegalUserGroup.get(group)!=null){
			// 	throw Error("/amapadmin/stripe","Ce marché fonctionne avec le paiement en ligne Mangopay, vous devez d'abord fermer votre compte Mangopay avant de passer à Stripe. Contactez le support pour le faire en écrivant à support@cagette.net");
			// }

			try{
				service.BridgeService.syncUserToHubspot(app.user);
				service.BridgeService.triggerWorkflow(42244245, app.user.email);
				
			}catch(e:Dynamic){
				app.logError(Std.string(e));
			}

			try{
				service.BridgeService.syncGroupToHubspot(group);
			}catch(e:Dynamic){
				//fail silently
				app.logError(Std.string(e));
			}

			group.update();

			throw Ok("/amapadmin/stripe","Votre marché est maintenant configuré avec le paiement en ligne Stripe.");

		}

		view.vendors = vendors;
		view.group = group;
	}
}
