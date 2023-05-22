package pro.controller;
import pro.db.PCatalog;
import Common;
import db.UserGroup;
import form.CagetteForm;
import pro.db.PNotif;
import sugoi.form.Form;
import sugoi.form.elements.IntSelect;

using Std;

class Catalog extends controller.Controller
{

	var company : pro.db.CagettePro;
	var vendor : db.Vendor;
	
	public function new(company:pro.db.CagettePro) 
	{
		super();
		view.company = this.company = company;
		view.vendor = this.vendor = company.vendor;
		view.category = "catalog";
		view.nav = ["catalog"];
	}
	
	private function checkRights(catalog:pro.db.PCatalog){
		if (catalog.company.id != this.company.id){
			throw "Erreur, accès interdit à ce catalogue";
		}
	}
	
	@logged @tpl("plugin/pro/catalog/default.mtt")
	public function doDefault() {
		
		view.nav.push("default");

		view.catalogs = company.getCatalogs();
		view.getLinkages = function(catalog:pro.db.PCatalog){
			return connector.db.RemoteCatalog.getFromPCatalog(catalog);				
		}
		checkToken();
	}
	
	/**
	 * choose which offers to include in the catalog
	 * @param	c
	 */
	@tpl('plugin/pro/catalog/products.mtt')
	function doProducts(catalog:pro.db.PCatalog){
		checkRights(catalog);
		view.nav.push("products");
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
			
			catalog.toSync();			
			throw Redirect(vendor.getURL()+"/catalog/prices/" + catalog.id);
		}
	}
	
	/**
	 * update product prices in this catalog
	 */
	@tpl('plugin/pro/catalog/prices.mtt')
	function doPrices(catalog:pro.db.PCatalog){
		checkRights(catalog);
		view.nav.push("prices");
		view.catalogProducts = catalog.getOffers();
		view.catalog = catalog;

		if (checkToken()){
			
			for ( k in app.params.keys()){
				if (k.substr(0, 5) == "price"){
					var pid = k.substr(5).parseInt();
					var co = pro.db.PCatalogOffer.manager.select($catalog == catalog && $offerId == pid,true);
					var val = app.params.get(k);
					//trace("offre "+pid+" produit"+p.offer.product.name+" valeur :"+val+"<br/>");
					var ff = new sugoi.form.filters.FloatFilter();
					co.price = ff.filterString(val);
					co.update();
				}
			}
			
			catalog.toSync();
			
			throw Ok(vendor.getURL()+"/catalog/view/"+catalog.id,"Prix mis à jour");
		}
	}
	
	@tpl('plugin/pro/catalog/view.mtt')
	function doView(catalog:pro.db.PCatalog){
		view.nav.push("view");		
		checkRights(catalog);
		view.catalog = catalog;
		view.company = catalog.company;

		if(checkToken()){
			var log = pro.service.PCatalogService.sync(catalog.id );
			throw Ok(vendor.getURL()+"/catalog/view/"+catalog.id,"Mise à jour effectuée<br/>"+log.join("<br/>"));
		}
	}
	
	// @tpl('plugin/pro/catalog/conditions.mtt')
	// function doConditions(c:pro.db.PCatalog){
	// 	checkRights(c);
	// 	view.nav.push("conditions");
	// 	view.catalog = c;
		
	// 	view.data = c.deliveryAvailabilities;
		
	// 	if (app.params.exists("submit")){
	// 		//delivery availabilities
	// 		var data = new Array<{startHour:Int,startMinutes:Int,endHour:Int,endMinutes:Int}>();
	// 		for ( d in 0...7){
				
	// 			if (app.params.exists("day" + d)){
	// 				data[d] = {
	// 					startHour:app.params.get('startHour' + d).parseInt(),
	// 					startMinutes:app.params.get('startMinutes' + d).parseInt(),
	// 					endHour:app.params.get('endHour' + d).parseInt(),
	// 					endMinutes:app.params.get('endMinutes' + d).parseInt(),
					
	// 				};
					
	// 			}
	// 		}
			
	// 		c.lock();
	// 		if ( c.deliveryAvailabilities == null) c.deliveryAvailabilities = [];
	// 		c.deliveryAvailabilities = data;
			
	// 		//distance
	// 		if (app.params.exists("maxDistance")){
	// 			var d = Std.parseInt(app.params.get("maxDistance"));
	// 			c.maxDistance = d;
	// 		}else{
	// 			c.maxDistance = null;
	// 		}
			
	// 		c.update();
	// 		throw Ok(vendor.getURL()+"/catalog/publish/" + c.id, "Conditions mises à jour");
	// 	}
	// }

	/**
	Create a catalog
	**/
	@tpl("plugin/pro/form.mtt")
	public function doInsert() {
		
		var catalog = new pro.db.PCatalog();
		catalog.startDate = Date.now();
		catalog.endDate = DateTools.delta(catalog.startDate, 1000.0 * 60 * 60 * 24 * 365 * 5);
		
		var f = CagetteForm.fromSpod(catalog);
		f.getElement("contractName").value = "Commande "+company.vendor.name;
		// f.addElement(new sugoi.form.elements.StringSelect("visible","Visibilité",[{label:"Public",value:"public"},{label:"Privé",value:"private"}],(catalog.visible?"public":"private"),true ));
		
		if (f.isValid()) {
			f.toSpod(catalog);
			catalog.company = company;
			catalog.visible = true;//f.getValueOf("visible") == "public";
			catalog.insert();
			if(company.offer==Marketplace && PCatalog.manager.count($company==this.company)==1){
				service.BridgeService.ga4Event(app.user.id,"FirstCatalog");
			}
			throw Ok(vendor.getURL()+"/catalog/products/"+catalog.id,'Le catalogue a été créé');
		}
		
		view.form = f;
		view.title = "Créer un nouveau catalogue";
		view.text = "Nommez votre catalogue de produits, par exemple \"Catalogue Vente à la ferme\".";
	}
	
	/**
		Edit a catalog
	**/
	@tpl("plugin/pro/catalog/form.mtt")
	public function doEdit(catalog:pro.db.PCatalog) {
		checkRights(catalog);
		view.nav.push("edit");
		var f = CagetteForm.fromSpod(catalog);
		// f.addElement(new sugoi.form.elements.StringSelect("visible","Visibilité",[{label:"Public",value:"public"},{label:"Privé",value:"private"}],(catalog.visible?"public":"private"),true ));

		if(catalog.contractName==null){
			f.getElement("contractName").value = "Commande "+company.vendor.name;
		}
		
		if (f.isValid()) {
			f.toSpod(catalog);
			catalog.visible = true;//f.getValueOf("visible") == "public";
			catalog.update();
			throw Ok(vendor.getURL()+"/catalog/view/"+catalog.id,'Le catalogue a été mis à jour');
		}
		
		view.form = f;
		view.title = 'Propriétés du catalogue';
		view.text = "Nommez votre catalogue de produits, par exemple \"Tarifs Vente à la ferme\".";
		view.catalog = catalog;
	}
	
	function doDelete(catalog:pro.db.PCatalog){
		
		checkRights(catalog);
		
		if (checkToken()){
			
			if (connector.db.RemoteCatalog.manager.search($remoteCatalogId == catalog.id).length > 0){
				throw Error(vendor.getURL()+"/catalog","Vous ne pouvez pas effacer ce catalogue car il est utilisé par vos clients.");
			}
			
			catalog.lock();
			catalog.delete();
			throw Ok(vendor.getURL()+"/catalog","Catalogue supprimé");
		}
		
		
	}

	/**
	 * Approve a catalog import
	 * @param	notif
	 */
	function doApproveImport(notif:pro.db.PNotif){
		
		notif.lock();
		if (notif.type != pro.db.PNotif.NotifType.NTCatalogImportRequest){
			throw "error";
		}
		var content : CatalogImportContent = haxe.Json.parse(notif.content);		
		var catalog = pro.db.PCatalog.manager.get( content.catalogId );		
		try{
			pro.service.PCatalogService.linkCatalogToGroup(catalog, notif.group , content.userId );
		}catch(e:tink.core.Error){
			throw Error(vendor.getURL(),e.message);
		}		
		
		notif.delete();
		
		throw Ok(vendor.getURL(), "Félicitations, le catalogue a bien été relié dans à "+notif.group.name );
	}
	
	/**
		break linkage
	**/
	function doBreakLinkage(rc:connector.db.RemoteCatalog){
		
		if (checkToken()){
			
			var c = rc.getContract(true);
			try{
				pro.service.PCatalogService.breakLinkage(c);
			}catch(e:tink.core.Error){
				throw Error(vendor.getURL()+"/catalog/" , e.message);
			}
			
			throw Ok(vendor.getURL()+"/catalog/","Le catalogue \""+c.name+"\" a été archivé. Il reste consultable dans les catalogues archivés du "+App.current.getTheme().groupWordingShort+".");
			
		}
		
	}

	function doExport(catalog:pro.db.PCatalog){

		var datas = new Array<Array<String>>();

		for( catOff in catalog.getOffers() ){
			datas.push([catOff.offer.ref, catOff.offer.getName(), Formatting.formatNum(catOff.price)+" €" ]);
		}

		sugoi.tools.Csv.printCsvDataFromStringArray(datas,["ref","name","price"],catalog.name);
	}

}