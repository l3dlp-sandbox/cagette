package connector.controller;
import Common;
/**
 * ...
 * @author fbarbut
 */
class Main extends controller.Controller
{

	public function new() 
	{
		super();
	}
	
	public function doContract(c:db.Catalog){
		
		var rc = connector.db.RemoteCatalog.manager.get(c.id);
		view.linkage = rc;
		view.catalog = rc.getPCatalog();

		//unlink catalog and archive
		if(checkToken()){

			try{
				pro.service.PCatalogService.breakLinkage(c);
			}catch(e:tink.core.Error){
				throw Error("/contractAdmin/view/"+c.id , e.message);
			}
			
			throw Ok("/contractAdmin/view/"+c.id,"Le contrat \""+c.name+"\" a été archivé.");

		}
	
	}
}