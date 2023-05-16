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

class MarketAdmin extends Controller
{

	public function new() 
	{
		super();
		if (!app.user.isGroupManager()) throw Error("/", t._("Access forbidden"));
		
		//lance un event pour demander aux plugins si ils veulent ajouter un item dans la nav
		var nav = new Array<Link>();

		nav.push({id: "stripe",name: "Paiement en ligne Stripe", 	link:"/marketadmin/stripe",icon:"bank-card"});				
				
		var e = Nav(nav,"groupAdmin");
		app.event(e);
		view.nav = e.getParameters()[0];
	}

	@tpl("marketadmin/default.mtt")
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
			str += "L'option 'Lister ce "+App.current.getTheme().groupWordingShort+" sur la carte' n'est pas cochée.";
		}
		if (!o.geoloc){
			str += "Votre lieu de distribution n'a pas pu être géolocaliser, merci de compléter ou corriger son adresse. ";
		}
		if( ! o.distributions ){
			str += "Vous devez avoir des distributions planifiées. ";
		}
		if(!o.members){
			str += "Vous devez avoir au moins 3 personnes dans votre "+App.current.getTheme().groupWordingShort+".";
		}

		view.visibleOnMapText = str;
		view.visibleOnMap = o.visible;

		#else
		view.visibleOnMap = true;
		#end
	}
	
	@tpl("marketadmin/form.mtt")
	function doMembership(){
		
		addBc('membership',"Adhésions","marketadmin/membership");
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

			if( form.getValueOf("groupId") != group.id ) throw "Vous avez changé de "+App.current.getTheme().groupWordingShort+".";

			group.lock();
			group.hasMembership = form.getValueOf("membership")==true;			
			group.membershipFee = form.getValueOf("membershipFee");
			group.membershipRenewalDate = form.getValueOf("membershipRenewalDate");
			group.update();
			throw Ok("/marketadmin","Paramètres d'adhésion mis à jour");
			
		}

		view.form = form;
		view.title = "Adhésions";
	}

	@tpl("marketadmin/rights.mtt")
	public function doRights() {
		view.users = app.user.getGroup().getGroupAdmins();
		view.getJsonRightName = UserGroup.getJsonRightName;
		addBc('rights','Droits d\'administration','/marketadmin/rights');
	}
	
	
	@tpl("marketadmin/form.mtt")
	public function doEditRight(?u:db.User) {
		addBc('rights','Droits d\'administration','/marketadmin/rights');
		var form = new sugoi.form.Form("editRight");
		
		if (u == null) {
			form.addElement( new IntSelect("user", t._("Member") , app.user.getGroup().getMembersFormElementData(), null, true) );	
		}
		
		var data = [];
		data.push({label:UserGroup.getRightName(Membership),value:"Membership"});
		data.push({label:UserGroup.getRightName(ContractAdmin()), value:"ContractAdmin"});
		data.push({label:UserGroup.getRightName(Messages),value:"Messages"});
		data.push({label:UserGroup.getRightName(GroupAdmin), value:"GroupAdmin"});
		
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
		
		for (catalog in app.user.getGroup().getActiveContracts(true)) {
			data.push( { label:catalog.name , value:"catalog"+Std.string(catalog.id) } );
		}
		
		if(ua!=null && ua.getRights()!=null && ua.getRights().length>0){
			for ( r in ua.getRights()) {
				switch(r.right) {
					case "ContractAdmin":
						if(r.params!=null && r.params.length>0){
							populate.push("catalog"+r.params[0]);	
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
				if (r.substr(0, 7) == "catalog") {
					var cid = Std.parseInt(r.substr(7));
					ua.giveRight( Right.ContractAdmin(cid) );
				}else if(r=="ContractAdmin"){
					ua.giveRight( Right.ContractAdmin(null) );				
				}else {
					ua.giveRight( Right.createByName(r) );	
				}
			}
			
			//avoid "cut my own hands" problem
			if (ua.user.id == app.user.id && wasManager ) {
				if (!ua.hasRight(GroupAdmin)) {
					throw Error("/marketadmin/rights", t._("You cannot strip yourself of admin rights."));
				}
			}			
			
			ua.update();
			
			if (ua.getRights().length == 0) {
				throw Ok("/marketadmin/rights", t._("Rights removed"));
			}else {
				throw Ok("/marketadmin/rights", t._("Rights created or modified"));
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
		addBc('volunteers',"Permanences","marketadmin/volunteers");
		d.dispatch(new controller.marketadmin.Volunteers());
	}

	function doDocuments( dispatch : haxe.web.Dispatch ) {
		addBc('documents',"Documents","marketadmin/documents");
		dispatch.dispatch( new controller.Documents() );
	}

	/**
	 * Set up group currency. Default is EURO
	 */
	@tpl("marketadmin/form.mtt")
	function doCurrency(){
		addBc("currency","Monnaie","/marketadmin/currency");
		view.title = t._("Currency used by your group.");
		
		var f = new sugoi.form.Form("curr");
		f.addElement(new sugoi.form.elements.StringInput("currency", t._("Currency symbol"), app.user.getGroup().getCurrency()));
		f.addElement(new sugoi.form.elements.StringInput("currencyCode", t._("3 digit ISO code"), app.user.getGroup().currencyCode));
		
		if ( f.isValid()){
			
			app.user.getGroup().lock();
			app.user.getGroup().currency = f.getValueOf("currency");
			app.user.getGroup().currencyCode = f.getValueOf("currencyCode");
			app.user.getGroup().update();
			
			throw Ok("/marketadmin/currency", t._("Currency updated"));
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
			throw Error("/marketadmin","Ce "+App.current.getTheme().groupWordingShort+" utilise le paiement en ligne avec Stripe, il n'est pas possible d'y ajouter d'autres moyens de paiement.");
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
			
			if( f.getValueOf("groupId") != group.id ) throw "Vous avez changé de "+App.current.getTheme().groupWordingShort+".";

			group.lock();
			var paymentTypes:Array<String> = f.getValueOf("paymentTypes");

			if(paymentTypes.length==0){
				throw Error(sugoi.Web.getURI(),"Vous devez choisir au moins un moyen de paiement");
			}

			group.setAllowedPaymentTypes(paymentTypes);
			// group.checkOrder = f.getValueOf("checkOrder");
			group.IBAN = f.getValueOf("IBAN");
			group.update();
			
			throw Ok("/marketadmin/payments", t._("Payment options updated"));
			
		}
		
		view.title = t._("Means of payment");
		view.form = f;
	}



	@tpl("marketadmin/stats.mtt")
	function doStats(){
		addBc("stats","Statistiques","marketadmin/stats");

		view.groupId = app.getCurrentGroup().id;
	}

	@tpl("marketadmin/stripe.mtt")
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
				throw Error("/marketadmin/stripe","Les producteurs suivants n'ont pas de compte Stripe configuré : <b>"+badVendors.map(v-> "#"+v.id+"-"+v.name).join(", ")+"</b>");
			}

			//block if MGP !
			// if(mangopay.db.MangopayLegalUserGroup.get(group)!=null){
			// 	throw Error("/marketadmin/stripe","Ce "+App.current.getTheme().groupWordingShort+" fonctionne avec le paiement en ligne Mangopay, vous devez d'abord fermer votre compte Mangopay avant de passer à Stripe. Contactez le support pour le faire en écrivant à support@cagette.net");
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

			throw Ok("/marketadmin/stripe","Votre "+App.current.getTheme().groupWordingShort+" est maintenant configuré avec le paiement en ligne Stripe.");

		}

		view.vendors = vendors;
		view.group = group;
	}
}
