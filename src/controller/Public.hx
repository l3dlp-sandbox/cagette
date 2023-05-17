package controller;
import pro.service.PCatalogService;
import Common;
import haxe.Json;
import sugoi.Web;
import sugoi.db.Variable;

class Public extends controller.Controller
{

	@tpl("public/catalog.mtt")
	public function doCatalog(catalog:pro.db.PCatalog,?args:{?bgcolor:String,?container:String}){
		view.catalog = catalog;
		view.noGroup = true;
		
		if (args != null && args.bgcolor != null){				
			view.bgcolor = "#"+args.bgcolor;
		}else{
			view.bgcolor = "#FFF";
		}
		
		if (args != null && args.container != null){				
			view.container = args.container; 
		}else{
			view.container = "container"; //boostrap 3 fluid layout
		}	
	}
	
	@tpl("plugin/pro/catalog/askImport.mtt")
	public function doAskImport(catalog:pro.db.PCatalog){
		var vendor = catalog.company.vendor;
		if(app.user==null) throw Error("/user/login?__redirect="+vendor.getURL()+"/public/askImport/"+catalog.id,"Vous devez être connecté à " + App.current.getTheme().name + " pour faire cette action");

		// var isVendor = isCproVendor(catalog.company);
		view.title = 'Relier un catalogue';
		var group = app.user.getGroup();

		var f = new sugoi.form.Form("import");		
		f.addElement( new sugoi.form.elements.Html("html1",catalog.company.vendor.name, "Producteur :") );
		f.addElement( new sugoi.form.elements.Html("html2",catalog.name, "Catalogue :") );
		var datas = [];
		for( ua in app.user.getUserGroups()){
			if(ua.isGroupManager() || ua.canManageAllContracts()){
				datas.push({label:ua.group.name,value:ua.group.id});
			}
		}
		f.addElement( new sugoi.form.elements.IntSelect("group",App.current.getTheme().groupWordingShort.toUpperCase()+" qui accueillera le catalogue", datas, (group==null ? null : group.id) , true) );
		view.form = f;
		
		if ( f.isValid() ){
			
			/*if (group.getPlaces().length == 0) {
				throw Error(vendor.getURL()+"/public/" + catalog.id, "Votre "+App.current.getTheme().groupWordingShort+" n'a aucun lieu de livraison ! Vous devez en créer au moins un avant d'importer un catalogue.");
			}
			if (!app.user.isContractManager() && !app.user.isGroupManager()){
				throw Error(vendor.getURL()+"/public/askImport/" + catalog.id, "Vous devez être coordinateur pour pouvoir importer un catalogue.");
			}*/

			group = db.Group.manager.get(f.getValueOf("group"),false);

			var contracts = connector.db.RemoteCatalog.getContracts( catalog, group );
			if ( contracts.length>0 ){
				throw Error("/contractAdmin/view/" + contracts.first().id, "Ce catalogue existe déjà dans ce "+App.current.getTheme().groupWordingShort+". Il n'est pas nécéssaire d'importer plusieurs fois le même catalogue dans un "+App.current.getTheme().groupWordingShort+".");
			}

			try{
				PCatalogService.linkCatalogToGroup(catalog,group,App.current.user.id);
			}catch(e:tink.core.Error){
				throw Error(sugoi.Web.getURI(), e.message);
			}

			app.session.data.amapId = group.id;
			
			
			//send email
			var e = new sugoi.mail.Mail();		
			e.setSubject("Le "+App.current.getTheme().groupWordingShort+" "+group.name+" a relié votre catalogue "+catalog.name);
			e.setRecipient(catalog.company.vendor.email);			
			e.setSender(App.current.getTheme().email.senderEmail,"Cagette.net");		
			var html = app.processTemplate("plugin/pro/mail/catalogLinked.mtt", {catalog:catalog,group:group,user:app.user});		
			e.setHtmlBody(html);
			App.sendMail(e);	
			
			throw Ok("/contractAdmin", "Le catalogue a été relié à votre "+App.current.getTheme().groupWordingShort+". Le producteur a été prévenu par email.");
			
		}
	}

	function isCproVendor(company:pro.db.CagettePro):Bool{
		for( u in company.getUsers()){
			if(u.id == app.user.id) return true;
		}
		return false;
	}

	@tpl('public/vendor.mtt')
	public function doVendor(vendor:db.Vendor){

		//Anti scraping
		var bl = Variable.get('IPBlacklist');
		if(bl!=null){
			var bl : Array<String> = Json.parse(bl);
			if( bl.has(Web.getClientIP())){
				App.current.setTemplate(null);
				return;
			}
		}

		if(Web.getClientHeader('user-agent')==null || Web.getClientHeader('user-agent').toLowerCase().indexOf("python")>-1){
			App.current.setTemplate(null);
			return;
		}

		vendorPage(vendor);
	}

	public static function vendorPage(vendor:db.Vendor){
		App.current.setTemplate("public/vendor.mtt");
		App.current.view.vendor = vendor.getInfos();
		App.current.view.pageTitle = vendor.name + " - " + App.current.getTheme().name;
		App.current.view.noGroup = true;
		var cpro = pro.db.CagettePro.getFromVendor(vendor);
		if(cpro!=null && cpro.demoCatalog!=null){

			App.current.view.catalog = cpro.demoCatalog;

			//Twitter Card Meta Tags
			if(cpro.demoCatalog.getOffers()[0]!=null){
				var firstProduct = cpro.demoCatalog.getOffers()[0].offer.getInfos();
				var socialShareData: SocialShareData = {
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
			var socialShareData: SocialShareData = {
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