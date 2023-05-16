package controller;

import service.VolunteerService;
import db.Basket;
import Common;
import db.Distribution;
import db.MultiDistrib;
import db.UserOrder;
import haxe.Json;
import haxe.macro.Expr.Error;
import haxe.web.Dispatch;
import sugoi.Web;
import sugoi.form.elements.StringInput;
import sugoi.tools.ResultsBrowser;
import tools.ArrayTool;
import tools.DateTool;

class Main extends Controller {
	public function new() {
		super();

		// init group breadcrumb
		var group = App.current.getCurrentGroup();
		if (group != null)
			addBc("g" + group.id, "::theme.groupWording:: : " + group.name, "/home");
	}

	function doDefault(?permalink:String) {
		if (permalink == null || permalink == "")
			throw Redirect("/home");
		// if permalink is an ID , could use it for group selection ? app.cagette.net/1/contractAdmin ...
		var p = sugoi.db.Permalink.get(permalink);
		if (p == null)
			throw Error("/home", t._("The link \"::link::\" does not exists.", {link: permalink}));

		app.event(Permalink({link: p.link, entityType: p.entityType, entityId: p.entityId}));
	}

	/**
	 * public pages 
	 */
	function doGroup(d:haxe.web.Dispatch) {
		d.dispatch(new controller.Group());
	}

	@tpl("home.mtt")
	function doHome() {
		addBc("home", "Commandes", "/home");

		// If the session has been closed, Neko has been logged out while Nest might still be logged in
		if (app.user == null){
			var cookies = Web.getCookies();
			var authSidCookie = cookies["Auth_sid"];
			if (authSidCookie != null && authSidCookie != view.sid){
				throw Redirect('/user/logout');
			}
		}

		var group = app.getCurrentGroup();
		if (app.user != null && group == null) {
			throw Redirect("/user/choose");
		} else if (app.user == null && (group == null || group.regOption != db.Group.RegOption.Open)) {
			throw Redirect("/user/login");
		}else if(group.disabled!=null){
			if(app.user!=null && app.user.isAdmin()){
				app.session.addMessage('Ce '+App.current.getTheme().groupWordingShort+' est bloqué, mais en tant que superadmin vous pouvez y accéder (${group.disabled})');
			}else{
				throw Redirect("/group/disabled");
			}
		}
		view.amap = group;

		// freshly created group
		view.newGroup = app.session.data.newGroup == true;

		var n = Date.now();
		var now = new Date(n.getFullYear(), n.getMonth(), n.getDate(), 0, 0, 0);
		var in1Month = DateTools.delta(now, 1000.0 * 60 * 60 * 24 * 30);
		var timeframe = new tools.Timeframe(now, in1Month);

		var distribs = db.MultiDistrib.getFromTimeRange(group, timeframe.from, timeframe.to);

		// special case : only one distrib , far in future.
		if (distribs.length == 0) {
			timeframe = new tools.Timeframe(now, DateTools.delta(now, 1000.0 * 60 * 60 * 24 * 30 * 12));
			distribs = db.MultiDistrib.getFromTimeRange(group, timeframe.from, timeframe.to);
		}

		view.timeframe = timeframe;
		view.distribs = distribs;

		// view functions
		view.getWhosTurn = function(orderId:Int, distrib:Distribution) {
			return db.UserOrder.manager.get(orderId, false).getWhosTurn(distrib);
		}

		// register to group without ordering block
		var isMemberOfGroup = app.user == null ? false : app.user.isMemberOf(group);
		var registerWithoutOrdering = (!isMemberOfGroup && group.regOption == db.Group.RegOption.Open);
		view.registerWithoutOrdering = registerWithoutOrdering;
		if (registerWithoutOrdering)
			service.UserService.prepareLoginBoxOptions(view, group);

		// event for additionnal blocks on home page
		var e = Blocks([], "home");
		app.event(e);
		view.blocks = e.getParameters()[0];

		// message if phone is required
		if (app.user != null && group.flags.has(db.Group.GroupFlags.PhoneRequired) && app.user.phone == null) {
			app.session.addMessage("Les membres de ce "+App.current.getTheme().groupWordingShort+" doivent fournir un numéro de téléphone. <a href='/account'>Cliquez ici pour mettre à jour votre compte</a>.",true);
		}

		// message if address is required
		if (app.user != null && group.flags.has(db.Group.GroupFlags.AddressRequired) && app.user.city == null) {
			app.session.addMessage("Les membres de ce "+App.current.getTheme().groupWordingShort+" doivent fournir leur adresse. <a href='/account'>Cliquez ici pour mettre à jour votre compte</a>.",true);
		}

		// Delete demo contracts
		if (checkToken() && app.params.get('action') == 'deleteDemoContracts') {
			var contracts = app.getCurrentGroup().deleteDemoContracts();
			if (contracts.length > 0)
				throw Ok("/", "Contrats suivants effacés : " + contracts.map(function(c) return c.name).join(", "));
		}

		view.timeSlotService = function(d:db.MultiDistrib) {
			return new service.TimeSlotsService(d);
		}

		view.visibleDocuments = group.getVisibleDocuments(isMemberOfGroup);
		view.hasRoles = VolunteerService.getRolesFromGroup(group).length>0;

		view.user = app.user;
	}

	// login and stuff
	function doUser(d:Dispatch) {
		// addBc("user","Membres","/user");
		d.dispatch(new controller.User());
	}

	function doCron(d:Dispatch) {
		d.dispatch(new controller.Cron());
	}

	/**
	 *  JSON REST API Entry point
	 */
	function doApi(d:Dispatch) {
		sugoi.Web.setHeader("Content-Type", "application/json");
		sugoi.Web.setHeader("Access-Control-Allow-Credentials","true");
		try {
			d.dispatch(new controller.Api());
		} catch (e:tink.core.Error) {
			// manage tink Errors (service errors)
			sugoi.Web.setReturnCode(e.code);
			Sys.print(Json.stringify({error: {code: e.code, message: e.message, stack: e.exceptionStack}}));
			app.rollback();
		} catch (e:Dynamic) {
			// manage other errors
			sugoi.Web.setReturnCode(500);
			var stack = haxe.CallStack.toString(haxe.CallStack.exceptionStack());
			App.current.logError(e, stack);
			Sys.print(Json.stringify({error: {code: 500, message: Std.string(e), stack: stack}}));
			app.rollback();
		}
	}

	@tpl("cssDemo.mtt")
	function doCssdemo() {
		// debug stringmap haxe4
		var users = new Map<String, String>();
		users["bob"] = "is a nice fellow";
		view.users = users;
	}

	@tpl("form.mtt")
	function doInstall(d:Dispatch) {
		d.dispatch(new controller.Install());
	}

	function doP(d:Dispatch) {
		/*
			* Invalid array access
			Stack (ADMIN|DEBUG)

			Called from C:\HaxeToolkit\haxe\std/haxe/web/Dispatch.hx line 463
			Called from controller/Main.hx line 117
			* 
			var plugin = d.parts.shift();
			for ( p in App.plugins) {
				var n = Type.getClassName(Type.getClass(p)).toLowerCase();
				n = n.split(".").pop();
				if (plugin == n) {
					d.dispatch( p.getController() );
					return;
				}
			}

			throw Error("/","Plugin '"+plugin+"' introuvable.");
		 */

		d.dispatch(new controller.Plugin());
	}

	@logged
	function doMember(d:Dispatch) {
		addBc("member", "Membres", "/member");
		d.dispatch(new controller.Member());
	}

	function doHistory(d:Dispatch) {
		addBc("history", "Historique", "/history");
		d.dispatch(new controller.History());
	}

	function doAccount(d:Dispatch) {
		addBc("account", "Mon compte", "/account");
		d.dispatch(new controller.Account());
	}

	@logged
	function doVendor(d:Dispatch) {
		addBc("contractAdmin", "Producteur", "/contractAdmin");
		d.dispatch(new controller.Vendor());
	}

	@logged
	function doPlace(d:Dispatch) {
		d.dispatch(new controller.Place());
	}

	function doTransaction(d:Dispatch) {
		addBc("shop", "Boutique", "/shop");
		d.dispatch(new controller.Transaction());
	}

	@logged
	function doDistributions(d:Dispatch) {
		addBc("distribution", "Distributions", "/distributions");
		d.dispatch(new controller.Distributions());
	}

	function doShop(d:Dispatch) {
		addBc("shop", "Boutique", "/shop");
		d.dispatch(new controller.Shop());
	}

	@logged
	function doProduct(d:Dispatch) {
		d.dispatch(new controller.Product());
	}

	@logged
	function doAmap(d:Dispatch) {
		addBc("amap", "Producteurs", "/amap");
		d.dispatch(new controller.Amap());
	}

	function doContract(d:Dispatch) {
		addBc("contract", "Catalogues", "/contractAdmin");
		d.dispatch(new Contract());
	}

	@logged
	function doContractAdmin(d:Dispatch) {
		addBc("contract", "Catalogues", "/contractAdmin");
		d.dispatch(new ContractAdmin());
	}

	@logged
	function doDocuments(dispatch:Dispatch) {
		dispatch.dispatch(new Documents());
	}

	@logged
	function doMessages(d:Dispatch) {
		addBc("messages", "Messagerie", "/messages");
		d.dispatch(new Messages());
	}

	@logged
	function doAmapadmin(d:Dispatch) {
		addBc("amapadmin", "Paramètres", "/amapadmin");
		d.dispatch(new AmapAdmin());
	}

	@admin
	function doAdmin(d:Dispatch) {
		d.dispatch(new controller.admin.Admin());
	}

	@admin
	function doDb(d:Dispatch) {
		d.parts = []; // disable haxe.web.Dispatch
		sys.db.admin.Admin.handler();
	}

	// @admin
	function doDebug(d:Dispatch) {
		d.dispatch(new controller.Debug());
	}

	/**
		Landing page when a user is invited in a group.
	**/
	@tpl('invite.mtt')
	function doInvite(hash:String){

		var cacheStringified = sugoi.db.Cache.manager.get(hash).value;
		var cache:{firstName:String,lastName:String,email:String,groupId:Int,?id:Int,?differenciatedPricingId:Int} = haxe.Json.parse(cacheStringified);
		if (cache == null){
			throw Error("/","Lien invalide");
		}

		var group = db.Group.manager.get(cache.groupId);
		app.session.data.amapId = cache.groupId;

		if (cache.id!=null) {
			var user = db.User.manager.get(cache.id);
			var userGroup = db.UserGroup.getOrCreate(user,group);
			if (cache.differenciatedPricingId!=null){
				userGroup.differenciatedPricingId = cache.differenciatedPricingId;
				userGroup.update();
			}
			throw Ok("/", t._("You're now a member of \"::group::\" ! You'll receive an email as soon as next order will open", {group:group.name}));
		} else {
			service.UserService.prepareLoginBoxOptions(view, group);
			view.invitedUserEmail = cache.email;
			view.invitedGroupId = group.id;
		}
	}

	function doDiscovery(){
		throw Redirect('/p/pro/signup/discovery');
	}

	// TOS (CGU)
	public function doTos() {
		throw Redirect(App.current.getTheme().terms.termsOfServiceLink);
	}

	public function doCgu() {
		throw Redirect('/tos');
	}

	// Privacy policy (politique de confidentialité)
	public function doPrivacypolicy() {
		throw Redirect(App.current.getTheme().terms.privacyPolicyLink);
	}

	// CCP (Conditions Commerciales par défaut de la Plateforme)
	public function doCgv() {
		throw Redirect('/termsofsale');
	}
	public function doCcp() {
		throw Redirect('/termsofsale');
	}
	public function doTermsofsale() {		
		throw Redirect(App.current.getTheme().terms.termsOfSaleLink);
	}

	//CGS
	public function doPlatformtermsofservice() {		
		throw Redirect(App.current.getTheme().terms.platformTermsOfServiceLink);
	}
	public function doCgs() {
		throw Redirect('/platformtermsofservice');
	}

	// CGU Mangopay
	public function doMgp() {
		throw Redirect("https://www.cagette.net/wp-content/uploads/2023/01/CGU-MangoPay.pdf");
	}

	// charte
	public function doCharte() {
		throw Redirect("https://www.cagette.net/charte-producteurs/");
	}

	public function doPing() {
		Sys.print(haxe.Json.stringify({version: App.VERSION.toString()}));
	}

	public function doHealth() {
		var vars = sugoi.db.Variable.manager.search(true);
		var json = {version: App.VERSION.toString()};
		for (v in vars) {
			Reflect.setField(json, v.name, v.value);
		}
		Sys.print(haxe.Json.stringify(json));
	}
	/**
		Maintenance and migration scripts
	**/
	function doScripts(d:Dispatch) {
		try {
			d.dispatch(new controller.Scripts());
		} catch (e:Dynamic) {
			//errors for CLI context
			sugoi.Web.setReturnCode(500);
			var stack = haxe.CallStack.toString(haxe.CallStack.exceptionStack());
			App.current.logError(e, stack);
			Sys.println("");
			Sys.println(Std.string(e));
			for(m in stack.split("\n")) Sys.println(m);
			Sys.println("");

			app.rollback();

		}
	}

	@tpl("help.mtt")
	public function doHelp() {
		view.noGroup = true;
		if (app.user!=null){
			var userGroups = app.user.getUserGroups().filter(ug -> return ug.isGroupManager());
			view.hasMarket = userGroups.length > 0;
		}
	}

}