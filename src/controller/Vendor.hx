package controller;
import sugoi.db.Cache;
import db.Catalog;
import haxe.crypto.Md5;
import service.VendorService;
import sugoi.form.Form;
import sugoi.tools.Utils;


class Vendor extends Controller
{

	public function new()
	{
		super();	
	}

	@tpl('vendor/signup.mtt')
	public function doSignup(?group:db.Group, ?invitationSender:db.User){

		view.pageTitle = "";

		if (App.current.getSettings().noVendorSignup == true) {
			throw Redirect("/");
		}

		if (group!=null) {
			view.groupName = group.name;
			view.groupId = group.id;
		}
		
		if(app.user==null) {
			view.userName = "";
			view.sid = App.current.session.sid;
			return;
		}
		
		//checks
		//has access to a cpro
		var uc = pro.db.PUserCompany.manager.search($user ==app.user);
		if( uc.length>0 && !App.current.user.isAdmin()){
			// if (uc.find( c -> c.company.vendor.isTest==true) == null) {
				throw Error("/","Vous avez déjà accès à un espace Producteur : "+uc.map(c -> return c.company.vendor.name).join(', ')+"</b>. Contactez le support sur <a href='mailto:"+app.getTheme().supportEmail+"'>"+app.getTheme().supportEmail+"</a> pour clarifier votre situation.");
			// }
		}

		//has same mail than a vendor
		var vendor = db.Vendor.manager.select($email != null && ($email == app.user.email || $email == app.user.email2),true);
		if( vendor!=null && !App.current.user.isAdmin()){
			//is this vendor cpro
			if(vendor.getCpro()!=null){
				throw Error("/","Vous avez déjà accès à un espace Producteur : "+vendor.name);
			}
			view.vendorId = vendor.id;
		}
		
		view.userName = app.user.getName();
		
		if (invitationSender!=null) {
			view.invitationSenderId = invitationSender.id;
		}
	}

	/**
		vendor page
	**/
	@tpl('vendor/default.mtt')
	public function doDefault(vendor:db.Vendor){

		//Anti scraping
		var bl = sugoi.db.Variable.get('IPBlacklist');
		if(bl!=null){
			var bl : Array<String> = haxe.Json.parse(bl);
			if( bl.has(sugoi.Web.getClientIP())){
				App.current.setTemplate(null);
				return;
			}
		}

		if(sugoi.Web.getClientHeader('user-agent')==null || sugoi.Web.getClientHeader('user-agent').toLowerCase().indexOf("python")>-1){
			App.current.setTemplate(null);
			return;
		}

		vendorPage(vendor);
	}

	public static function vendorPage(vendor:db.Vendor){
		App.current.setTemplate("vendor/default.mtt");
		App.current.view.vendor = vendor.getInfos();
		App.current.view.pageTitle = ""/*vendor.name + " - " + App.current.getTheme().name*/;

		var cpro = pro.db.CagettePro.getFromVendor(vendor);
		if(cpro!=null && cpro.demoCatalog!=null){

			App.current.view.catalog = cpro.demoCatalog;

			//Twitter Card Meta Tags
			if(cpro.demoCatalog.getOffers()[0]!=null){
				var firstProduct = cpro.demoCatalog.getOffers()[0].offer.getInfos();
				var socialShareData: Common.SocialShareData = {
					facebookType: "website",
					url: "https://" + App.config.HOST + "/" + sugoi.Web.getURI(),
					title: vendor.name,
					description: vendor.desc,
					imageUrl: "https://" + App.config.HOST + firstProduct.image,
					imageAlt: firstProduct.name,
					twitterType: "summary_large_image",
					twitterUsername: "@Cagettenet"
				};

				App.current.view.socialShareData = socialShareData;
			}

		}else{

			//Twitter Card Meta Tags
			var vendor = vendor.getInfos();
			var socialShareData: Common.SocialShareData = {
				facebookType: "website",
				url: "https://" + App.config.HOST + "/" + sugoi.Web.getURI(),
				title: vendor.name,
				description: vendor.desc,
				imageUrl: "https://" + App.config.HOST + vendor.image,
				imageAlt: vendor.name,
				twitterType: "summary_large_image",
				twitterUsername: "@Cagettenet"
			};

			App.current.view.socialShareData = socialShareData;
		}
	}
}