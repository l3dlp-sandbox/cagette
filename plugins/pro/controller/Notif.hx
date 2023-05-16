package pro.controller;

import pro.db.PNotif.CatalogImportContent;
import pro.db.PNotif.NotifType;


class Notif extends controller.Controller
{

	var company : pro.db.CagettePro;
	
	public function new()
	{
		super();
		view.company = company = pro.db.CagettePro.getCurrentCagettePro();
		view.category = "notif";		
	}
	
	public function doDelete(n:pro.db.PNotif) {
		
		if (checkToken()){
			n.lock();
			n.delete();
			throw Ok("/p/pro", "Notification effacée");
			
			//TODO : faire un mail à l'emetteur
		}
		
	}
	
	@logged @tpl("plugin/pro/notif.mtt")
	public function doView(n:pro.db.PNotif){
		view.category = "home";
		view.notif = n;
		var content = n.getContent();
		view.notifContent = content;

		view.getCatalog = function(cid){
			return pro.db.PCatalog.manager.get(cid, false);
		}
				
		view.getOffer = function(ref:String){			
			var pids = Lambda.map(n.company.getProducts(),function(x) return x.id);
			return pro.db.POffer.manager.select($ref == ref && $productId in pids, false);
		}

		view.getDistrib = function(did:Int){
			return db.MultiDistrib.manager.get(did,false);
		}
		view.vendor = pro.db.CagettePro.getCurrentVendor();

		if (n.type == pro.db.PNotif.NotifType.NTDeliveryRequest){
			view.multiDistribId = content.distribId;
			var pCatalog = pro.db.PCatalog.manager.get(content.pcatalogId,false);
			var rcs = connector.db.RemoteCatalog.getFromPCatalog(pCatalog);
			var rc = Lambda.find(rcs,function(rc) return rc.getContract().group.id==n.group.id );
			if(rc==null){
				throw Error("/p/pro","Vous n'êtes plus reliés à ce catalogue, vous pouvez supprimer cette demande.");
			}
			var catalog = rc.getContract();
			view.catalogId = catalog.id;
		}

		checkToken();
	}
	
	
	
}