package pro.controller;

import pro.db.PNotif.CatalogImportContent;
import pro.db.PNotif.NotifType;


class Notif extends controller.Controller
{

	var company : pro.db.CagettePro;
	var vendor : db.Vendor;
	
	public function new(company:pro.db.CagettePro) 
	{
		super();
		view.company = this.company = company;
		view.vendor = this.vendor = company.vendor;
	}
	
	public function doDelete(n:pro.db.PNotif) {
		
		if (checkToken()){
			n.lock();
			n.delete();
			throw Ok(vendor.getURL(), "Notification effacée");
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
		checkToken();
	}
	
	
	
}