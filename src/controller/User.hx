package controller;
import sugoi.form.elements.Html;
import haxe.crypto.Md5;
import pro.db.CagettePro;
import pro.db.VendorStats;
import sugoi.Web;
import sugoi.form.Form;
import sugoi.form.elements.Checkbox;
import sugoi.form.elements.Input;
import sugoi.form.elements.IntInput;
import sugoi.form.elements.StringInput;
import sugoi.form.validators.EmailValidator;
import ufront.mail.*;

class User extends Controller
{
	public function new() 
	{
		super();
	}
	
	@tpl("user/default.mtt")
	function doDefault() {
		
	}
	
	
	@tpl("user/login.mtt")
	function doLogin() {
		
		if (App.current.user != null) {
			throw Redirect('/');
		}


		view.sid = App.current.session.sid;

		// If the session has been closed, Neko has been logged out while Nest might still be logged in
		var cookies = Web.getCookies();
		var authSidCookie = cookies["Auth_sid"];
		if (authSidCookie != null && authSidCookie != view.sid){
			throw Redirect('/user/logout');
		}

		service.UserService.prepareLoginBoxOptions(view);

		//if its needed to redirect after login
		if (app.params.exists("redirect")){
			view.redirect = app.params.exists("redirect");
		}else if (getParam("__redirect")!=null) {
			view.redirect = getParam("__redirect");
		} else {
			view.redirect = '/';
		}
}

	/**
	 * Choose which group to connect to.
	 */
	@logged
	@tpl("user/choose.mtt")
	function doChoose(?args: { group:db.Group } ) {

		//home page
		app.breadcrumb = [];
		
		var groups = app.user.getGroups();
		
		if (args!=null && args.group!=null) {
			//select a group
			var which = app.session.data==null ? 0 : app.session.data.whichUser ;
			if(app.session.data==null) app.session.data = {};
			app.session.data.order = null;
			app.session.data.newGroup = null;
			app.session.data.amapId = args.group.id;
			app.session.data.whichUser = which;
			throw Redirect('/home');
		}
		
		view.groups = groups;
		view.wl = db.WaitingList.manager.search($user == app.user, false);
		
		if(app.user!=null){
			//need to check new ToS
			if(app.user.tosVersion != sugoi.db.Variable.getInt('tosVersion')){
				throw Redirect("/user/tos");
			} 

			//need to check new CGS
			// for( cpro in service.VendorService.getCagetteProFromLegalRep(app.user) ){
			// 	if(cpro.vendor.tosVersion != sugoi.db.Variable.getInt('platformtermsofservice')){
			// 		throw Redirect("/user/tos");
			// 	} 
			// }
		}
		
		if(app.user!=null){
			view.pageTitle = "Bonjour "+(view.whichUser()==0?app.user.firstName:app.user.firstName2);
		}else{
			view.pageTitle = "Bonjour !";
		}
		
	}

	// @logged
	@tpl("user/myMarkets.mtt")
	function doMyMarkets(?args: { group:db.Group } ) {

		if(app.user!=null){
			if (args!=null && args.group!=null) {
				//select a group
				var which = app.session.data==null ? 0 : app.session.data.whichUser ;
				if(app.session.data==null) app.session.data = {};
				app.session.data.order = null;
				app.session.data.newGroup = null;
				app.session.data.amapId = args.group.id;
				app.session.data.whichUser = which;
				throw Redirect('/distributions');
			}
			
			var userGroups = app.user.getUserGroups();
			if (!app.user.isAdmin()){
				userGroups = userGroups.filter(ug -> return ug.getRights().length > 0);
			}
			view.groups = userGroups.map(ug -> ug.group);
		}else{
			view.groups = [];
		}

		view.pageTitle = "Mes "+App.current.getTheme().groupWordingShort_plural;
	}
	
	function doLogout() {
		service.BridgeService.logout(App.current.user);
		var domain = App.config.HOST;
		if (domain.lastIndexOf('app.',0) == 0) {
			domain = domain.split('app.').join("");
		}
		Web.setHeader("Set-Cookie", 'Refresh=; HttpOnly; Path=/; Max-Age=0; Domain=$domain');

		App.current.session.delete();

		// Haxe allows neither to set multiple "set-cookie" headers (https://github.com/HaxeFoundation/haxe/issues/3550)
		// nor to set multiple cookies in one set-cookie header (https://www.rfc-editor.org/rfc/rfc2109#section-4.2.2)
		// Hence we can workaround this by redirecting 3 times : one redirect for each cookie we want to delete
		throw Redirect('/user/logoutDeleteAuthenticationCookie');
	}

	function doLogoutDeleteAuthenticationCookie() {
		var domain = App.config.HOST;
		if (domain.lastIndexOf('app.',0) == 0) {
			domain = domain.split('app.').join("");
		}
		Web.setHeader("Set-Cookie", 'Authentication=; HttpOnly; Path=/; Max-Age=0; Domain=$domain');
		throw Redirect('/user/logoutDeleteAuthSidCookie');
	}

	function doLogoutDeleteAuthSidCookie() {
		var domain = App.config.HOST;
		if (domain.lastIndexOf('app.',0) == 0) {
			domain = domain.split('app.').join("");
		}
		Web.setHeader("Set-Cookie", 'Auth_sid=; HttpOnly; Path=/; Max-Age=0; Domain=$domain');
		throw Redirect('/user/login');
	}
	
	/**
	 * Ask for password renewal by mail
	 * when password is forgotten
	 */
	@tpl("user/forgottenPassword.mtt")
	function doForgottenPassword(?key:String, ?u:db.User, ?definePassword:Bool){
		
		//STEP 1
		var step = 1;
		var error : String = null;
		var url = "/user/forgottenPassword";
		
		//ask for mail
		var askmailform = new Form("askemail");
		askmailform.addElement(new StringInput("email", t._("Please key-in your E-Mail address"),null,true));
	
		//change pass form
		var chpassform = new Form("chpass");
		
		var pass1 = new StringInput("pass1", t._("Your new password"),null,true);
		pass1.password = true;
		chpassform.addElement(pass1);
		
		var pass2 = new StringInput("pass2", t._("Again your new password"),null,true);
		pass2.password = true;
		chpassform.addElement(pass2);
		
		var uid = new IntInput("uid","uid", u == null?null:u.id);
		uid.inputType = ITHidden;
		chpassform.addElement(uid);
		
		if (askmailform.isValid()) {
			//STEP 2
			//send password renewal email
			step = 2;
			
			var email :String = askmailform.getValueOf("email");
			var user = db.User.manager.select(email == $email, false);
			//could be user 2
			if(user==null) user = db.User.manager.select(email == $email2, false);
			
			//user not found
			if (user == null) throw Error(url, t._("This E-mail is not linked to a known account"));
			
			//create token
			var token = haxe.crypto.Md5.encode("chp"+Std.random(1000000000));
			sugoi.db.Cache.set(token, user.id, 60 * 60 * 24 * 30);
			
			var m = new sugoi.mail.Mail();
			m.setSender(App.current.getTheme().email.senderEmail, App.current.getTheme().name);					
			m.setRecipient(email, user.getName());					
			m.setSubject( App.current.getTheme().name+" : "+t._("Password change"));
			m.setHtmlBody( app.processTemplate('mail/forgottenPassword.mtt', { user:user, link:'http://' + App.config.HOST + '/user/forgottenPassword/'+token+"/"+user.id }) );
			App.sendMail(m);	
		}
		
		if (key != null && u!=null) {
			//check key and propose to change pass
			step = 3;
			
			if ( u.id == sugoi.db.Cache.get(key) ) {
				view.form = chpassform;
			}else {
				error = t._("Invalid request");
			}
		}
		
		if (chpassform.isValid()) {
			//change pass
			step = 4;
						
			if ( chpassform.getValueOf("pass1") == chpassform.getValueOf("pass2")) {
				
				var uid = Std.parseInt( chpassform.getValueOf("uid") );
				var user = db.User.manager.get(uid, true);
				var pass = chpassform.getValueOf("pass1");
				user.setPass(pass);
				user.update();

				sugoi.db.Cache.destroy(key);

				var m = new sugoi.mail.Mail();
				m.setSender(App.current.getTheme().email.senderEmail, App.current.getTheme().name);					
				m.setRecipient(user.email, user.getName());					
				if(user.email2!=null) m.setRecipient(user.email2, user.getName());					
				m.setSubject( "["+App.current.getTheme().name+"] : "+t._("New password confirmed"));
				var emails = [user.email];
				if(user.email2!=null) emails.push(user.email2);
				var params = {
					user:user,
					emails:emails.join(", "),
					password:pass
				}
				m.setHtmlBody( app.processTemplate('mail/newPasswordConfirmed.mtt', params) );
				App.sendMail(m);	
				
			}else {
				error = t._("You must key-in two times the same password");
			}
		}
			
		if (step == 1) {
			view.form = askmailform;
		}
		
		view.step = step;
		view.error = error;
		view.title = definePassword == null ? "Changement de mot de passe" : t._("Create a password for your account");

	}
	
	
	/**
	 * generate a custom key for transactionnal emails, valid during the current day
	 */
	//function getKey(m:db.User) {
		//return haxe.crypto.Md5.encode(App.config.get("key")+m.email+(Date.now().getDate())).substr(0,12);
	//}
	
	
	/**
		The user just registred or logged in, and want to be a member of this group
	**/
	function doJoingroup(){

		if(app.user==null) throw "no user";

		var group = App.current.getCurrentGroup();
		if(group==null) throw "no group selected";
		if(group.regOption!=db.Group.RegOption.Open) throw "this group is not open";

		/*var user = app.user;
		user.lock();
		user.flags.set(HasEmailNotif24h);
		user.flags.set(HasEmailNotifOuverture);
		user.update();*/
		db.UserGroup.getOrCreate(app.user,group);

		//warn manager by mail
		if(group.contact!=null){
			var url = "http://" + App.config.HOST + "/member/view/" + app.user.id;
			var text = t._("A new member joined the group without ordering : <br/><strong>::newMember::</strong><br/> <a href='::url::'>See contact details</a>",{newMember:app.user.getCoupleName(),url:url});
			App.quickMail(
				group.contact.email,
				t._("New member") + " : " + app.user.getCoupleName(),
				text,
				group
			);	
		}

		throw Ok("/", t._("You're now a member of \"::group::\" ! You'll receive an email as soon as next order will open", {group:group.name}));
	}

	/**
		Quit a group.  Should work even if user is not logged in. ( link in emails footer )
	**/
	@tpl('account/quit.mtt')
	function doQuitGroup(group:db.Group,user:db.User,key:String){

		if (haxe.crypto.Sha1.encode(App.config.KEY+group.id+user.id) != key){
			// For legacy, key might still be using MD5
			if (haxe.crypto.Md5.encode(App.config.KEY+group.id+user.id) == key){
				key=haxe.crypto.Sha1.encode(App.config.KEY+group.id+user.id);
			} else {
				throw Error("/","Lien invalide");
			}
		}

		view.groupId = group.id;
		view.userId = user.id;
		view.controlKey = key;
	}

	/**
		Quit a group without a userId.  Should work ONLY if the user is logged in. ( link in emails footer from Messaging Service )
	**/
	@tpl('account/quit.mtt')
	function doQuitGroupFromMessage(group:db.Group,key:String){

		if ( app.user == null && getParam('__redirect')==null ) {
			throw sugoi.ControllerAction.RedirectAction(Web.getURI()+"?__redirect="+Web.getURI());
		}

		if (haxe.crypto.Sha1.encode(App.config.KEY+group.id) != key){
			throw Error("/","Lien invalide");
		}

		view.groupId = group.id;
		if (app.user!=null) {
			view.userId = app.user.id;
			view.controlKey = haxe.crypto.Sha1.encode(App.config.KEY+group.id+app.user.id);
		}
	}

	@tpl('form.mtt')
	function doTos(){
					
		var form = new sugoi.form.Form("tos");
		var legalRepCagettePros = service.VendorService.getCagetteProFromLegalRep(app.user);

		if(app.user.tosVersion!=sugoi.db.Variable.getInt("tosVersion")){
			form.addElement(new Html("","Afin de répondre à la réglementation des places de "+App.current.getTheme().groupWordingShort+" en ligne à laquelle nous sommes soumis, nous mettons à jour nos conditions générales d'utilisation et notre politique de confidentialité. Celles-ci s'appliquent à partir du 9 janvier 2023"));
			var c = new sugoi.form.elements.Checkbox("tos","J'accepte les <br/><a href='/tos' target='_blank'>conditions générales d'utilisation</a><br/>et la <a href='/privacypolicy' target='_blank'>politique de confidentialité</a>");
			form.addElement(c);
		}

		for( cpro in legalRepCagettePros ){
			var vendor = cpro.vendor;
			if(vendor.tosVersion != sugoi.db.Variable.getInt('platformtermsofservice')){
				form.addElement(new Html("","Afin de répondre à la réglementation des places de "+App.current.getTheme().groupWordingShort+" en ligne à laquelle nous sommes soumis, nous mettons à jour nos conditions générales de services destinées aux producteurs. Celles-ci s'appliquent à partir du 9 février 2023"));
				form.addElement(new sugoi.form.elements.Checkbox("cgs"+vendor.id,"J'accepte les <a href='/platformtermsofservice' target='_blank'>Conditions générales de service</a> qui encadrent les services fournis par Cagette.net aux Producteurs (compte \""+vendor.name+"\")"));
			} 
		}

		if(form.isValid() ){

			if(form.getElement("tos")!=null && form.getValueOf("tos")==true){
				app.user.lock();
				app.user.tosVersion = sugoi.db.Variable.getInt("tosVersion");
				app.user.update();
			}

			var platformtermsofservice = sugoi.db.Variable.getInt('platformtermsofservice');

			for( cpro in legalRepCagettePros ){
				var vendor = cpro.vendor;
				if(vendor.tosVersion != platformtermsofservice && form.getElement("cgs"+vendor.id)!=null && form.getValueOf("cgs"+vendor.id)==true){
					vendor.lock();
					vendor.tosVersion = platformtermsofservice;
					vendor.update();
				}
			}

			throw Redirect('/');
		}
		
		view.title = "Mise à jour des conditions générales";
		view.form = form;
	}
	
}