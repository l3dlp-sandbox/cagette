package controller;
import pro.service.PCatalogService;
import Common;
import haxe.Json;
import sugoi.Web;
import sugoi.db.Variable;

class Catalog extends controller.Controller
{

	@tpl("catalog/default.mtt")
	public function doDefault(catalog:pro.db.PCatalog,?args:{?bgcolor:String,?container:String}){
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
	
	@tpl("catalog/askImport.mtt")
	public function doAskImport(catalog:pro.db.PCatalog){
		var vendor = catalog.company.vendor;
		if(app.user==null) throw Error("/user/login?__redirect=/catalog/askImport/"+catalog.id,"Vous devez être connecté à " + App.current.getTheme().name + " pour faire cette action");

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

}