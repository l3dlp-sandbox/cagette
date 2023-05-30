package connector;
import Common;
import sugoi.ControllerAction;
import pro.db.PNotif;
import sugoi.plugin.*;

class ConnectorPlugIn extends PlugIn implements IPlugIn{
	
	public function new() {
		super();
		name = "connector";
		file = sugoi.tools.Macros.getFilePath();
		
		//suscribe to events
		App.eventDispatcher.add(onEvent);
		
		//add i18n strings
		//var i18n = App.t.getStrings();
		//i18n.set("dateStart","Début de validité");
		//i18n.set("dateEnd","Fin de validité");
		
	}
	
	function getRemoteCatalog(contractId:Int,?lock=false){
		var contract = db.Catalog.manager.get(contractId);
		return connector.db.RemoteCatalog.getFromContract(contract,lock);
	}
	
	public function onEvent(e:Event) {
		
		switch(e) {
			case Nav(navigation, name, cid):
				
			case PreNewDistrib(contract):
				
			case NewDistrib(distrib):
				
			case EditDistrib(distrib):
				
			case DeleteDistrib(d):
				var remoteCata = getRemoteCatalog(d.catalog.id);
				if (remoteCata != null){
					throw ErrorAction("/contractAdmin/distributions/" + d.catalog.id, "Impossible d'effacer cette distribution car ce catalogue est géré par le producteur depuis son espace producteur.");
				}
				
			case PreEditProduct(p), EditProduct(p), DeleteProduct(p), NewProduct(p):
				var remoteCata = getRemoteCatalog(p.catalog.id);
				if (remoteCata != null){
					throw ErrorAction("/contractAdmin/products/" + p.catalog.id, "Vous ne pouvez pas modifier ce produit car ce catalogue est géré par le producteur depuis son espace producteur.");
				}
			case PreNewProduct(c):
				var remoteCata = getRemoteCatalog(c.id);
				if (remoteCata != null){
					throw ErrorAction("/contractAdmin/products/" + c.id, "Vous ne pouvez pas créer de produit car ce catalogue est géré par le producteur depuis son espace producteur.");
				}
				
			case BatchEnableProducts(data) :
				var pids = data.pids;				
				var c = db.Product.manager.get(pids[0], false).catalog;								
				var remoteCata = getRemoteCatalog(c.id, true);				
				if (remoteCata != null){
					
					var cata = remoteCata.getPCatalog();
					var offers = cata.getOffers();
					
					if (data.enable){
						var localDisabledProducts = remoteCata.getDisabledProducts();
						var msgs = [];
						//locally enable products
						for (pid in pids.copy() ){
							
							//check that I can enable it 
							var p = db.Product.manager.get(pid, false);
							var off = Lambda.find(offers, function(x) return x.offer.ref == p.ref);
							if (off == null || !off.offer.active){
								pids.remove(pid);
								msgs.push(p.name+" ("+p.ref+")");
							}
							
							//remove from local list
							localDisabledProducts.remove(pid);							
						}
						
						remoteCata.setDisabledProducts(localDisabledProducts);
						remoteCata.update();
						
						if(msgs.length>0 && App.current.session!=null )
							App.current.session.addMessage("Vous ne pouvez pas activer les produits suivants, car le producteur les a signalés comme indisponibles : " + msgs.join(", "));
						
					}else{
						//locally disable products
						var localDisabledProducts = remoteCata.getDisabledProducts();
						for( pid in pids){
							if(pid!=null && !Lambda.has(localDisabledProducts,pid)) localDisabledProducts.push(pid);
						}
						remoteCata.setDisabledProducts(localDisabledProducts);
						remoteCata.update();
					}
					
					
				}
				
			case DeleteContract(contract) :
				
				var remote = getRemoteCatalog(contract.id,true);
				if ( remote != null){
					remote.delete();
				}

			case DuplicateContract(contract) :
				if ( getRemoteCatalog(contract.id,true) != null){
					throw sugoi.ControllerAction.ErrorAction("/contractAdmin","C'est un catalogue relié à un espace producteur, il n'est pas possible de le dupliquer");
				}

			case EditContract(contract,form)	 :
				
				if ( getRemoteCatalog(contract.id,true) != null){

					//allow only to edit some options.
					form.removeElementByName("startDate");
					form.removeElementByName("endDate");
					form.removeElementByName("name");
					form.removeElementByName("vendorId");					
					// form.removeElementByName("description"); //desc can be edited in group.

					var text = "Ce catalogue est géré par un producteur depuis son espace producteur, vous n'avez donc accès qu'à un nombre restreint de paramètres.";
					form.addElement(new sugoi.form.elements.Html("info","<div class='alert alert-info'>"+text+"</div>"),0);
				}
					
				
			default :
		}
	}
	
	/*function getDistributorsList(d:db.Distribution):Array<Int>{
		if (d == null) return null;
		var out = [];
		for ( x in [d.distributor1, d.distributor2, d.distributor3, d.distributor4]){
			if ( x != null ) out.push(x.id);
		}
		return out;
	}*/
}