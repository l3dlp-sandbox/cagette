package pro.controller;
import pro.service.PCatalogService;
import pro.db.CagettePro.CagetteProOffer;
import sugoi.Web;
import mangopay.Mangopay;
import pro.db.PVendorCompany;
import service.BridgeService;
import service.VendorService;
import sugoi.form.elements.FloatInput;
import sugoi.form.elements.Html;
import sugoi.form.elements.StringInput;
import sugoi.form.elements.TextArea;

class Company extends controller.Controller
{
	var company : pro.db.CagettePro;
	var vendor : db.Vendor;
	
	public function new(company:pro.db.CagettePro) 
	{
		super();
		view.company = this.company = company;
		view.vendor = this.vendor = company.vendor;

		view.nav = ["company"];
		view.navbar = nav("company");
	}
	
	@tpl("plugin/pro/company/default.mtt")
	public function doDefault(){

		view.nav.push("default");

		//create permalink
		var link = sugoi.db.Permalink.getByEntity(vendor.id,"vendor");
		if(link==null){
			var proposals = sugoi.db.Permalink.propose(vendor.name,[vendor.zipCode.substr(0,2),vendor.city]);
			if(proposals.length>0){
				link  = new sugoi.db.Permalink();
				link.entityType = "vendor";
				link.entityId = vendor.id;
				link.link = proposals[0];
				link.insert();
			}
			
		}

		if(company==null){
			var groups = Lambda.map(vendor.getActiveContracts(),function(c) return c.group);
			view.groups = tools.ObjectListTool.deduplicate(groups);
		}
	}
	
	@tpl('plugin/pro/company/form.mtt')
	function doEdit() {
		view.nav.push("default");
		var theme = App.current.getTheme();
		
		var form = new sugoi.form.Form("company");
		form.addElement(new TextArea("desc","Description courte de votre ferme",vendor.desc));
		// form.addElement(new StringInput("linkText","Intitulé du lien<br/>(site web, page facebook...)",vendor.linkText));
		// form.addElement(new StringInput("linkUrl","URL du lien",vendor.linkUrl));
		
		view.title = "Modifier la description";
				
		if (form.isValid()) {
			vendor.lock();
			try{
				vendor = VendorService.update(vendor,form.getDatasAsObject(),false);
			}catch(e:tink.core.Error){
				throw Error(sugoi.Web.getURI(),e.message);
			}			
			vendor.update();
			throw Ok(vendor.getURL()+'/company','Votre profil a été mis à jour');
		}		
		view.form = form;
	}
	
	@tpl('plugin/pro/company/form.mtt')
	function doEditLink() {
		view.nav.push("default");
		var theme = App.current.getTheme();
		
		var form = new sugoi.form.Form("company");
		form.addElement(new StringInput("linkText","Intitulé du lien<br/>(site web, page facebook...)",vendor.linkText));
		form.addElement(new StringInput("linkUrl","URL du lien",vendor.linkUrl));		
		view.title = "Modifier le lien de votre site web";
				
		if (form.isValid()) {
			vendor.lock();
			try{
				vendor = VendorService.update(vendor,form.getDatasAsObject(),false);
			}catch(e:tink.core.Error){
				throw Error(sugoi.Web.getURI(),e.message);
			}			
			vendor.update();
			throw Ok(vendor.getURL()+'/company','Votre profil a été mis à jour');
		}		
		view.form = form;
	}

	@tpl('plugin/pro/company/demoProducts.mtt')
	function doEditDemoCatalog() {
		view.nav.push("default");

		//get or create demoCatalog
		var catalog = PCatalogService.getOrCreateDemoCatalog(company);
		if(company.demoCatalog==null || company.demoCatalog.id!=catalog.id){
			company.lock();
			company.demoCatalog = catalog;
			company.update();
		}

		var AllOffers = company.getOffers(); 
		var selectedOffers = [];		
		var catalogOffers = catalog.getOffers();
		
		for ( o in  AllOffers){			
			var checked : Bool  = Lambda.find(catalogOffers, function(cp) return cp.offer.id == o.id) != null;		
			selectedOffers.push({offer:o,checked:checked});
		}		
		
		view.catalog = catalog;
		view.products = selectedOffers;
		
		if (checkToken()){
			
			//sync width existing products			
			for ( k in app.params.keys()){
				if (k.substr(0,1) == "p"){
					var pid = k.substr(1).parseInt();					
					var cp = Lambda.find(catalogOffers, function(cp) return cp.offer.id == pid);
					
					//new products
					if (cp == null){
						cp = new pro.db.PCatalogOffer();
						cp.catalog = catalog;
						var x = pro.db.POffer.manager.get(pid, false);
						cp.offer = x;
						cp.price = x.price;
						cp.insert();
					}
				}
			}
			
			//remove products
			for ( cp in catalogOffers){
				var found = false;
				for ( k in app.params.keys()){
					if (k.substr(0, 1) == "p"){
						if (k.substr(1).parseInt() == cp.offer.id) {
							found = true;
							break;
						}
					}
				}
				if (!found){
					cp.lock();
					cp.delete();
				}
			}
			throw Ok(vendor.getURL()+'/company','Votre catalogue de démonstration a été mis à jour');
		}

		/*var form = new sugoi.form.Form("company");
		var catalogs = sugoi.form.ListData.fromSpod(company.getCatalogs());
		form.addElement(new sugoi.form.elements.IntSelect("demoCatalogId","Catalogue affiché sur votre page",catalogs,company.demoCatalog==null?null:company.demoCatalog.id));		
		view.title = "Modifier le catalogue de démonstration";
				
		if (form.isValid()) {
			company.lock();
			try{
				company.demoCatalog = pro.db.PCatalog.manager.get(form.getValueOf("demoCatalogId"));
			}catch(e:tink.core.Error){
				throw Error(sugoi.Web.getURI(),e.message);
			}			
			company.update();
			throw Ok(vendor.getURL()+'/company','Votre catalogue de démonstration a été mis à jour');
		}		
		view.form = form;*/
		
	}

	@tpl('plugin/pro/company/form.mtt')
	function doEditPeople() {
		view.nav.push("default");
		var form = new sugoi.form.Form("company");
		form.addElement(new StringInput("peopleName","Nom du ou des producteur(s)",vendor.peopleName));		
		view.title = "Modifier le nom du ou des producteur(s)";
				
		if (form.isValid()) {
			vendor.lock();
			try{
				vendor = VendorService.update(vendor,form.getDatasAsObject(),false);
			}catch(e:tink.core.Error){
				throw Error(sugoi.Web.getURI(),e.message);
			}			
			vendor.update();
			throw Ok(vendor.getURL()+'/company','Votre profil a été mis à jour');
		}		
		view.form = form;
	}

	@tpl('plugin/pro/company/form.mtt')
	function doEditLongDesc() {
		view.nav.push("default");
		var theme = App.current.getTheme();
		
		var form = new sugoi.form.Form("company");
		// form.addElement(new StringInput("peopleName","Nom du ou des producteur(s)",vendor.peopleName));		
		form.addElement(new sugoi.form.elements.TextArea("longDesc","Description longue de votre exploitation",vendor.longDesc));
		view.title = "Modifier la description";
				
		if (form.isValid()) {
			vendor.lock();
			try{
				vendor = VendorService.update(vendor,form.getDatasAsObject(),false);
			}catch(e:tink.core.Error){
				throw Error(sugoi.Web.getURI(),e.message);
			}			
			vendor.update();
			throw Ok(vendor.getURL()+'/company','Votre profil a été mis à jour');
		}		
		view.form = form;
		view.tinymce = true;
	}

	@tpl('plugin/pro/company/form.mtt')
	function doEditOffCagette() {
		view.nav.push("default");
		var theme = App.current.getTheme();
		
		var form = new sugoi.form.Form("company");
		form.addElement(new sugoi.form.elements.TextArea("offCagette","En dehors de Cagette.net, où peut-on trouver vos produits ?",vendor.offCagette));
		// view.title = "Modifier la description";
				
		if (form.isValid()) {
			vendor.lock();
			try{
				vendor = VendorService.update(vendor,form.getDatasAsObject(),false);
			}catch(e:tink.core.Error){
				throw Error(sugoi.Web.getURI(),e.message);
			}			
			vendor.update();
			throw Ok(vendor.getURL()+'/company','Votre profil a été mis à jour');
		}		
		view.form = form;
		view.tinymce = true;
	}
	
	@tpl('plugin/pro/company/users.mtt')
	public function doUsers(){
		view.nav.push("users");
		checkToken();
		view.users = pro.db.PUserCompany.getUsers(company);
	}
	
	@tpl('plugin/pro/form.mtt')
	public function doInsertUser(){
		view.nav.push("users");
		
		var f = new sugoi.form.Form("user");
		f.addElement( new sugoi.form.elements.StringInput("email","Email",null,true));
		f.addElement( new sugoi.form.elements.Checkbox("salesRepresentative","Contact commercial (l'email de cet utilisateur sera celui visible par vos clients)",null,true));
		
		if (f.isValid()){
			var v = new pro.db.PUserCompany();
			var u = service.UserService.get(f.getValueOf("email"));
			if(u==null){
				throw Error(vendor.getURL()+'/company/users','Il n\'y a aucun compte avec l\'email "${f.getValueOf("email")}". Cette personne doit s\'inscrire avant que vous puissiez lui donner accès à votre espace producteur.');
			}

			if(company.getUsers().find(uc -> uc.id==u.id)!=null){
				throw Error(vendor.getURL()+'/company/users','Cet utilisateur a déjà accès à votre espace producteur.');
			}

			v.company = company;
			v.user = u;
			v.salesRepresentative = f.getValueOf("salesRepresentative");
			
			if(v.salesRepresentative){
				// Sync the new sales representative to HS as Marketing and associated it with vendor's Company
				BridgeService.syncUserToHubspot(u, company.vendor);
				
				// If there is another SalesRepresentative (and we should always have one)
				// set it to false
				var existingSalesRepresentative = pro.db.PUserCompany.manager.select($company==company && $salesRepresentative);
				if(existingSalesRepresentative!=null) {
					existingSalesRepresentative.salesRepresentative = false;
					existingSalesRepresentative.update();
					if (!existingSalesRepresentative.legalRepresentative) {
						// Set it as non-marketing and delete association
						BridgeService.triggerWorkflow(BridgeService.HUBSPOT_WORKFLOWS_ID.setContactAsNonMarketing, existingSalesRepresentative.user.email);
						BridgeService.deleteHubspotAssociationContactToCompany(existingSalesRepresentative.user, company.vendor);
					}
				}

				// Set the vendor.email to the SalesRepresentative email
				var vendor = company.vendor;
				vendor.lock();
				vendor.email = u.email;
				vendor.update();
			}

			v.insert();
			
			throw Ok(vendor.getURL()+"/company/users", "Nouvel utilisateur ajouté");
		}
		view.title = "Ajouter un nouvel utilisateur à mon espace producteur";
		view.form = f;
	}

	@tpl('plugin/pro/form.mtt')
	public function doEditUser(user:db.User){
		view.nav.push("users");

		var uc = pro.db.PUserCompany.manager.select( $company==company && $user==user, true );
		
		var f = new sugoi.form.Form("user");
		f.addElement( new sugoi.form.elements.Checkbox("salesRepresentative","Contact commercial (l'email de cet utilisateur sera celui visible par vos clients)",uc.salesRepresentative,true));
		
		if (f.isValid()){
			
			uc.company = company;
			uc.salesRepresentative = f.getValueOf("salesRepresentative");

			if(uc.salesRepresentative){
				// Sync the new sales representative to HS as Marketing and associated it with vendor's Company
				BridgeService.syncUserToHubspot(user, company.vendor);

				// If there is another SalesRepresentative (and we should always have one)
				// set it to false
				var existingSalesRepresentative = pro.db.PUserCompany.manager.select($company==company && $salesRepresentative && $user!=user);
				if(existingSalesRepresentative!=null) {
					existingSalesRepresentative.salesRepresentative = false;
					existingSalesRepresentative.update();
					if (!existingSalesRepresentative.legalRepresentative) {
						// Set it as non-marketing and delete association
						BridgeService.triggerWorkflow(BridgeService.HUBSPOT_WORKFLOWS_ID.setContactAsNonMarketing, existingSalesRepresentative.user.email);
						BridgeService.deleteHubspotAssociationContactToCompany(existingSalesRepresentative.user, company.vendor);
					}
				}

				// Set the vendor.email to the SalesRepresentative email
				var vendor = company.vendor;
				vendor.lock();
				vendor.email = uc.user.email;
				vendor.update();
			}else{
				// Prevent deleting the SalesRepresentative
				throw Error(vendor.getURL()+"/company/users", "Vous devez avoir un contact commercial pour votre espace Producteur.");
			}

			uc.update();
			
			throw Ok(vendor.getURL()+"/company/users", "Utilisateur mis à jour");
		}
		view.title = "Gérer un utilisateur de mon espace producteur";
		view.form = f;
	}
	
	public function doDeleteUser(userToDelete:db.User){
		
		if (checkToken()){
			
			if (userToDelete.id == app.user.id && !app.user.isAdmin() ) {
				throw Error(vendor.getURL()+"/company/users", "Vous ne pouvez pas vous retirer l'accès à vous même");
			}

			if(company.getUsers().count(user -> return userToDelete.id!=user.id)==0){
				throw Error(vendor.getURL()+"/company/users", "Vous ne pouvez pas supprimer cet utilisateur. Au moins une personne doit avoir accès à un espace producteur.");
			}
			
			var uc = pro.db.PUserCompany.get(userToDelete, company);			
			if (uc != null){
				if (uc.legalRepresentative){
					throw Error(vendor.getURL()+"/company/users", "Vous ne pouvez pas supprimer le représentant légal.");
				}
				if (uc.salesRepresentative){
					throw Error(vendor.getURL()+"/company/users", "Vous ne pouvez pas supprimer le contact commercial.");
				}

				uc.lock();
				uc.delete();
			}
			
			throw Ok(vendor.getURL()+"/company/users/", "Utilisateur effacé");
		}else{
			throw Redirect(vendor.getURL()+"/company/users/");
		}
	}
	
	@tpl('plugin/pro/form.mtt')
	public function doVatRates() {
		view.nav.push("default");
		var f = new sugoi.form.Form("vat");
		
		if (company.vatRates == null) {
			company.lock();
			var x = new pro.db.CagettePro();
			company.vatRates = x.vatRates;
			company.update();
		}
		
		// Storing 4  values.
		//Get recorded values
		var i = 1;
		for (vatRate in company.getVatRates()) {
			f.addElement(new StringInput(i+"-k", "Nom "+i, vatRate.label));
			f.addElement(new FloatInput(i + "-v", "Taux "+i, vatRate.value ));
			i++;
		}
		//fill in to 4 values
		for (x in 0...5 - i) {
			f.addElement(new StringInput(i+"-k", "Nom "+i, null));
			f.addElement(new FloatInput(i + "-v", "Taux "+i, null));
			i++;
		}
		
		if (f.isValid()) {
			var d = f.getData();
			var vats = new Array<{value:Float,label:String}>();
			for (i in 1...5) {
				if (d.get(i + "-k") == null) continue;
				vats.push({label:d.get(i + "-k"), value: d.get(i + "-v")});
			}
			if (vats.length > 0) { // Prevent setting an empty array of vat rates
				company.lock();
				company.setVatRates(vats);
				company.update();
			}
			throw Ok(vendor.getURL()+"/product/", "Taux mis à jour");
			
		}
		view.title = "Editer les taux de TVA";
		view.form = f;
		
	}
	
	@tpl('plugin/pro/company/publicPage.mtt')
	function doPublicPage(){

		view.link = sugoi.db.Permalink.getByEntity(company.vendor.id,"vendor");
		var vendor = company.vendor;
		var f = new sugoi.form.Form("publicPage");
		var catalogs = sugoi.form.ListData.fromSpod(company.getCatalogs());
		//for( c in company.getCatalogs()) catalogs.push({label:c.name,value:c.id});
		f.addElement(new sugoi.form.elements.IntSelect("catalog","Catalogue affiché sur votre page",catalogs,company.demoCatalog==null?null:company.demoCatalog.id));
		f.addElement(new sugoi.form.elements.Checkbox("directory","Référencer ma page sur les annuaires partenaires de Cagette.net",vendor.directory));
		f.getElement("directory").description = "Etre référencé sur <a href='https://www.118712.fr' target='_blank'>118712.fr</a> pour augmenter votre visibilité sur le web.";
		f.addElement(new sugoi.form.elements.TextArea("longDesc","Description longue de votre exploitation",vendor.longDesc));
		f.addElement(new sugoi.form.elements.TextArea("offCagette","En dehors de "+App.current.getTheme().name+", où peut on trouver vos produits ?",vendor.offCagette));

		view.images = company.vendor.getImages();
		view.farmImagesNum = [0,1,2,3];

		if(f.isValid()){
			company.lock();
			company.demoCatalog = pro.db.PCatalog.manager.get(f.getValueOf("catalog"),false);
			company.update();

			vendor.lock();
			vendor.directory = f.getValueOf("directory");
			vendor.offCagette = f.getValueOf("offCagette");
			vendor.longDesc = f.getValueOf("longDesc");
			vendor.update();
			
			throw Ok(vendor.getURL()+"/company/publicPage/","Votre page producteur à été mise à jour");
		}

		view.form = f;
	}

	@tpl('plugin/pro/company/link.mtt')
	function doCreateLink(){
		var vendor = company.vendor;
		view.proposals = sugoi.db.Permalink.propose(vendor.name,[vendor.zipCode.substr(0,2),vendor.city]);

		if(checkToken()){
			var link  = new sugoi.db.Permalink();
			link.entityType = "vendor";
			link.entityId = vendor.id;
			link.link = app.params.get('link');
			link.insert();
			throw Ok(vendor.getURL()+"/company/publicPage","Félicitations, vous venez de créer votre page producteur.");
		}

	}
	
	@tpl('plugin/pro/company/stripe.mtt')
	function doStripe(){

		if(company.offer==CagetteProOffer.Training) throw "Les espaces producteurs de formation n'ont pas le droit d'ouvrir de compte Stripe";
		var vendor = company.vendor;
		view.vendor = vendor;
		view.nav.push("stripe");
	}

	@tpl('plugin/pro/company/accounting.mtt')
	function doAccounting(){
		var vendor = company.vendor;
		view.vendor = vendor;
		view.nav.push("accounting");
	}

	@tpl('plugin/pro/company/cgvcgs.mtt')
	function doCgvcgs(){
		var vendor = company.vendor;
		view.vendor = vendor;
		view.nav.push("cgvcgs");
	}


	@tpl('plugin/pro/company/cgv.mtt')
	function doCgv(){

		view.vendor = vendor;
		view.nav.push("cgvcgs");
		var request = new Map();
		try {
			request = sugoi.tools.Utils.getMultipart( 1024 * 1024 * 10 ); //10Mb	
		} catch ( e:Dynamic ) {
			throw Error( Web.getURI(), 'Le document importé est trop volumineux. Il ne doit pas dépasser 10 Mo.');
		}
		
		if ( request.exists( 'document' ) ) {
			
			var doc = request.get( 'document' );
			if ( doc != null && doc.length > 0 ) {

				var originalFilename = request.get( 'document_filename' );
				if ( !StringTools.endsWith( originalFilename.toLowerCase(), '.pdf' ) ) {
					throw Error( Web.getURI(), 'Le document n\'est pas au format pdf. Veuillez sélectionner un fichier au format pdf.');
				}
				
				var filename = ( request.get( 'name' ) == null || request.get( 'name' ) == '' ) ? originalFilename : request.get( 'name' );
				var file : sugoi.db.File = sugoi.db.File.create( request.get( 'document' ), filename );					
				
				vendor.lock();
				vendor.customizedTermsOfSaleFile = file;
				vendor.update();
	
				throw Ok( Web.getURI(), 'Le document ' + file.name + ' a bien été ajouté.' );
			}
		}
	}

	@tpl('plugin/pro/company/differenciated-pricing.mtt')
	function doDifferenciatedPricing(){
		if (App.current.getSettings().differenciatedPricing == false){
			throw Redirect(vendor.getURL());
		}
		view.nav.push("differenciatedPricing");
	}
}