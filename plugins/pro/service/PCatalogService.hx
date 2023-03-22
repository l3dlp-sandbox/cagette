package pro.service;
import pro.db.CagettePro;
import Common;
import connector.db.RemoteCatalog;
import service.BridgeService;

class PCatalogService{

	/**
	 * Synchronizes catalog to contracts, offers to products, company info to vendor.
	 If catalogId is given, force sync of this catalog
	 */
	public static function sync(?catalogId:Int){

		var log = [];

		var remoteCatalogs = new List();
		if ( catalogId!=null ){
			remoteCatalogs = connector.db.RemoteCatalog.manager.search($remoteCatalogId == catalogId,true);
		}else{
			remoteCatalogs = connector.db.RemoteCatalog.manager.search($needSync);
		}
		
		for ( rc in remoteCatalogs){
			
			var contract = rc.getContract();
			if (contract == null) continue;
			var catalog = rc.getPCatalog();			
			if( catalog==null ) continue;
			
			
			var fullUpdate = !contract.hasOpenOrders() || catalogId!=null;
			
			//log.push( "<h4>" + /*contract.name+" - " +*/ contract.amap.name /*+(fullUpdate?"[Full]":"[Light]")*/ + "</h4>" );
			log.push( "<h4>" +  contract.group.name + "</h4>" );

			syncCatalog(contract,catalog);
			
			//sync cpro products to group products
			var groupProducts = contract.getProducts(false);
			var disabledProducts = rc.getDisabledProducts();
			
			for ( cproProduct in catalog.getOffers() ){
				
				//find remote product by ref.
				var groupProduct = Lambda.find(groupProducts, function(x) return x.ref == cproProduct.offer.ref);				
				var disabledInGroup = false;
				if(groupProduct!=null){
					disabledInGroup = Lambda.has(disabledProducts, groupProduct.id);
					//debug
					/*if(disabledInGroup){
						log.push( cproProduct.offer+" est désactivé dans le groupe" );
					}else{
						log.push( cproProduct.offer+" est actif dans le groupe" );
					}*/
				}else{
					//debug
					//log.push( cproProduct.offer+" n'existe pas, faut le créer" );
				} 
				log = log.concat( syncProduct(cproProduct, groupProduct, contract, fullUpdate, disabledInGroup) );	
				groupProducts.remove(groupProduct);				
			}
			
			//removed product from catalog, let's disable them.
			//do NOT remove them to keep previous orders.
			for ( p in groupProducts){
				if (p.active == false) continue;
				log.push("Produit désactivé : " + p.name);
				p.lock();
				p.active = false;
				p.update();
				
			}

			//once everything is updated, set needSync to false
			if (fullUpdate){
				rc.needSync = false;
				rc.update();	
			}
			
			
		}
		//log = log.split("\n").join("<br/>\n");
		return log;
	}


	/**
	 * Synchro from catalog offer -> product.
	 * Manages also new products
	 */
	public static function syncProduct(co:pro.db.PCatalogOffer, ?groupProduct:db.Product, contract:db.Catalog, fullUpdate:Bool, ?isLocallyDisabled=false){
		
		var log = [];
		if (groupProduct == null){
			log.push("Nouveau produit : " + co.offer.product.name);
			groupProduct = new db.Product();
			groupProduct.catalog = contract;
		}else{
			groupProduct.lock();
		}
		
		//if its a new product, sync completely
		if (groupProduct.id == null){			
			fullUpdate = true;
		}
		
		//log.push("update product " + co.offer.ref + " " + groupProduct.name+ (isLocallyDisabled?"  (locally disabled)":"") + "\n";		
		
		groupProduct.desc = co.offer.product.desc;
		groupProduct.unitType = co.offer.product.unitType;
		groupProduct.qt = co.offer.quantity;
		groupProduct.image = co.offer.image==null ? co.offer.product.image : co.offer.image;
		groupProduct.ref = co.offer.ref;
		groupProduct.vat = co.offer.vat;
		groupProduct.txpProduct = co.offer.product.txpProduct;
		groupProduct.organic = co.offer.product.organic;		
		groupProduct.variablePrice = co.offer.product.variablePrice;
		groupProduct.multiWeight = co.offer.product.multiWeight;
		groupProduct.wholesale = co.offer.product.wholesale;
		groupProduct.retail = co.offer.product.retail;
		groupProduct.bulk = co.offer.product.bulk;
		groupProduct.smallQt = co.offer.smallQt;
		
		//set stock if it's a new product
		if(groupProduct.id == null && co.offer.stock!=null){
			groupProduct.stock = PStockService.getStocks(co.offer).availableStock;
		}
		
		groupProduct.active = co.offer.active && !isLocallyDisabled;		
		
		//name change
		if (fullUpdate) {
			groupProduct.name = co.offer.product.name;				
			if (co.offer.name != null){
				groupProduct.name += " - " + co.offer.name;
			}
		}
		
		//made this because of this fucking bug with float comparison !
		if (groupProduct.price == null) groupProduct.price = 0;
		if ( Formatting.roundTo(groupProduct.price,2) != Formatting.roundTo(co.price,2)  && fullUpdate ){
			log.push("Changement de prix : " + groupProduct.name + " : '" + groupProduct.price + "' -> '" + co.price +"'");	
			groupProduct.price = co.price;	
		}		
		
		if (groupProduct.id == null){
			groupProduct.insert();
		}else{
			groupProduct.update();			
		}		

		return log;
	}

	/**
		Link first Catalog in a cpro
	**/
	public static function linkFirstCatalog(catalog:db.Catalog,cagettePro:pro.db.CagettePro){

		var offers = [];

		//is this catalog invited in another cpro ?
		var rc = RemoteCatalog.getFromContract(catalog);
		if(rc != null){
			//just move products and catalog
			var pcatalog = rc.getPCatalog();
			pcatalog.lock();

			for (p in pcatalog.getProducts()) {
				p.product.lock();
				p.product.company = cagettePro;
				p.product.update();
			}

			pcatalog.company = cagettePro;
			pcatalog.update();

			return;
		}

		for (p in catalog.getProducts(false)) {
			// product
			var pp = new pro.db.PProduct();
			pp.name = p.name;

			var ref = pro.service.PProductService.generateRef(cagettePro);
			p.lock();
			p.ref = ref+"-1";
			p.update();
			
			pp.ref = ref;
			pp.image = p.image;
			pp.desc = p.desc;
			pp.company = cagettePro;
			pp.unitType = p.unitType;
			pp.active = p.active;
			pp.organic = p.organic;
			pp.txpProduct = p.txpProduct;
			pp.bulk = p.bulk;
			pp.multiWeight = p.multiWeight;
			pp.variablePrice = p.variablePrice;
			pp.insert();

			// create one offer
			var off = new pro.db.POffer();
			off.price = p.price;
			off.vat = p.vat;
			off.ref = ref + "-1";
			off.product = pp;
			off.quantity = p.qt;
			off.active = p.active;
			off.smallQt = p.smallQt;
			off.insert();

			offers.push(off);
		}

		//create pcatalog
		var pcatalog = new pro.db.PCatalog();
		pcatalog.name = "Mes produits en vente";
		pcatalog.company = cagettePro;
		pcatalog.visible = true;
		var now = Date.now();
		pcatalog.startDate = new Date(now.getFullYear(),0,0,0,0,0);
		pcatalog.endDate = new Date(now.getFullYear()+10,0,0,0,0,0);
		pcatalog.insert();

		//bind offers to this catalog
		for(off in offers){
			pro.db.PCatalogOffer.make(off,pcatalog,off.price);
		}

		//create link to remote catalog
		link(pcatalog,catalog);
	}

	/**
	 *  Create or sync a catalog ( from a vendor catalog (PCatalog) to a group catalog (Catalog) )
	 */
	public static function syncCatalog(groupCatalog:db.Catalog, proCatalog:pro.db.PCatalog, ?contact:db.User, ?group:db.Group){

		if(proCatalog==null) throw "catalog cannot be null";
		if(groupCatalog==null){

			if(group==null) throw "you should provide a group";
			if(contact==null) throw "you should provide a contact";
			if(proCatalog.company.vendor==null) throw "catalog should be linked to a CagettePro/Vendor accound";

			//create it
			groupCatalog = new db.Catalog();
			groupCatalog.vendor = proCatalog.company.vendor;
			groupCatalog.group = group;
			groupCatalog.flags.set(db.Catalog.CatalogFlags.UsersCanOrder);
			groupCatalog.contact = contact;
		
		}else{
			//just sync it
			groupCatalog.lock();
		}
		
		groupCatalog.startDate = proCatalog.startDate;
		groupCatalog.endDate = proCatalog.endDate;
		groupCatalog.flags.set(db.Catalog.CatalogFlags.StockManagement);
		if(proCatalog.contractName!=null) {
			groupCatalog.name = proCatalog.contractName;
		}else{
			groupCatalog.name = "Commande "+groupCatalog.vendor.name;
		}

				
		//vendor
		if( proCatalog.vendor==null){
			if(proCatalog.company.vendor==null) throw "catalog "+proCatalog.id+" company has no vendor";
			groupCatalog.vendor = proCatalog.company.vendor;
		}else{
			if(proCatalog.vendor==null) throw "catalog "+proCatalog.id+" vendor is null";
			groupCatalog.vendor = proCatalog.vendor;	
		}
		
		if(groupCatalog.id==null){
			groupCatalog.insert();
		}else{
			groupCatalog.update();
		}

		//check that the farmer can access the contract in the group
		for( user in proCatalog.company.getUsers() ){
			var ua = db.UserGroup.getOrCreate(user, groupCatalog.group);
			if(proCatalog.company.captiveGroups){
				//cagette cpro users are admin in all groups if captiveGroups is activated
				ua.giveRight(Right.GroupAdmin);
				ua.giveRight(Right.Membership);
				ua.giveRight(Right.Messages);
				ua.giveRight(Right.ContractAdmin());
			}else{
				ua.giveRight(Right.ContractAdmin(groupCatalog.id));
			}
		}

		return groupCatalog;
	}

	/**
	 * Link a pcatalog to a group
	 */
	public static function linkCatalogToGroup(pcatalog:pro.db.PCatalog,clientGroup:db.Group,remoteUserId:Int):connector.db.RemoteCatalog{
		
		//checks
		var contracts = connector.db.RemoteCatalog.getContracts(pcatalog, clientGroup);
		if ( contracts.length>0 ){
			throw new tink.core.Error("Ce catalogue existe déjà dans ce groupe. Il n'est pas nécéssaire d'importer plusieurs fois le même catalogue dans un groupe.");
		}

		if (pcatalog.company.vendor.disabled==db.Vendor.DisabledReason.MarketplaceNotActivated){
			throw new tink.core.Error("Ce catalogue ne peut pas être relié à ce groupe car le producteur n'a pas activé le prélèvement des frais Cagette.net.");
		}

		if(clientGroup.isDispatch()){
			if(!pcatalog.company.vendor.isDispatchReady()){
				throw new tink.core.Error("Ce catalogue ne peut pas être relié à ce groupe car le producteur n'a pas de compte Stripe (Obligatoire afin de pouvoir accepter le paiement en ligne).");
			}
		}

		//coordinator
		var contact = db.User.manager.get(remoteUserId);
		
		//create contract		
		var contract = syncCatalog(null,pcatalog,contact,clientGroup);

		//create remoteCatalog record
		var rc = link(pcatalog,contract);
		
		//create products
		for ( co in pcatalog.getOffers()){
			pro.service.PCatalogService.syncProduct(co, null, contract,true, false);
		}

		BridgeService.ga4Event(pcatalog.company.getMainContact().id,"FirstCatalogLinked");
		
		return rc;
	}

	/**
		break linkage and archive catalog
	**/
	public static function breakLinkage(catalog:db.Catalog){

		var rc = RemoteCatalog.getFromContract(catalog);
		if(rc == null) throw new tink.core.Error("Ce catalogue n'est pas relié à un catalogue de compte producteur");
		
		//do not participate in future distribs
		var futureDistribs = db.Distribution.manager.search($end > Date.now() && $catalog == catalog,true);
		for(fd in futureDistribs){
			if(fd.getBaskets().length>0){
				throw new tink.core.Error("Impossible d'annuler la distribution du "+fd.date.toString()+" car elle a des commandes. Supprimez d'abord les commandes.");
			}else{
				fd.delete();
			}
		}

		//archive catalog
		catalog.lock();
		catalog.endDate = Date.now();
		catalog.update();
		
		rc.lock();
		rc.delete();

	}
	
	public static function makeCatalogOffer(offer:pro.db.POffer,catalog:pro.db.PCatalog,price:Float){
		var cp = new pro.db.PCatalogOffer();
		cp.catalog = catalog;
		cp.offer = offer;
		cp.price = price;
		cp.insert();
		return cp;
	}

	public static function link(pcatalog:pro.db.PCatalog, catalog:db.Catalog){

		var cats = connector.db.RemoteCatalog.getContracts( pcatalog, catalog.group );
		if ( cats.length>0 ){
			throw new tink.core.Error("Ce catalogue existe déjà dans ce groupe. Il n'est pas nécéssaire d'importer plusieurs fois le même catalogue dans un groupe.");
		}

		var rc = new connector.db.RemoteCatalog();
		rc.id = catalog.id;
		rc.remoteCatalogId = pcatalog.id;
		rc.insert();

		return rc;
	}

}