package pro;
import sugoi.ControllerAction;
import pro.db.VendorStats;
import sugoi.tools.TransactionWrappedTask;
import pro.service.PStockService;
import Common;
import sugoi.plugin.*;
using tools.DateTool;

class ProPlugIn extends PlugIn implements IPlugIn{

	public function new() {
		super();
		name = "pro";
		file = sugoi.tools.Macros.getFilePath();
		//suscribe to events
		App.eventDispatcher.add(onEvent);		
	}
	
	public function onEvent(e:Event) {
		
		switch(e) {
			case Nav(nav, name, id):
				
				if(name=="admin"){
					nav.push({id:"cpro",name:"Producteurs", link:"/admin/vendor",icon:"farmer"});
					nav.push({id:"cprodedup",name:"Déduplication Producteurs", link:"/admin/vendor/deduplicate",icon:"farmer"});		
					nav.push({id:"certification",name:"Certification Producteurs", link:"/admin/vendor/certification",icon:"farmer-pro"});		
				}

			case Permalink(p):
				if(p.entityType=="vendor"){

					var vendor = db.Vendor.manager.get(p.entityId,false);
					if(vendor==null) throw new tink.core.Error("Ce permalien n'est plus valide");
					if(vendor.isDisabled()) throw ControllerAction.ErrorAction("/","Ce producteur est désactivé. Raison : "+vendor.getDisabledReason());

					controller.Vendor.vendorPage(vendor);
				}	

			case HourlyCron(now):
				//can send fake now date
				
				var task = new TransactionWrappedTask("Send orders by products to cpro accounts");
				task.setTask(function(){
					//Email product report when orders close				
					var range = tools.DateTool.getLastHourRange( now );
					task.log('Find all distributions that have closed in the last hour from >=${range.from} to <${range.to} \n');
					var distribs = db.Distribution.manager.search($orderEndDate >= range.from && $orderEndDate < range.to, false);

					for ( d in distribs){

						//We ignore all non cpro distribs
						var rc = connector.db.RemoteCatalog.getFromContract(d.catalog);					
						if(rc==null) {
							task.log(" -- not cpro : "+d.toString());
							continue;
						}
						
						var pcatalog = rc.getPCatalog();						
						var distribService = new pro.service.PDistributionService(pcatalog.company);					
						distribService.sendOrdersByProductReport(d,rc);
						task.log(" -- Sent orders by product for : "+d.toString());
					}
				});
				task.execute(!App.config.DEBUG);

				//update vendor stats every hour
				var task = new TransactionWrappedTask("Refresh vendor stats");
				task.setTask(function (){	
					var count = VendorStats.manager.count(true);					
					//full sync take 3 days					
					var num = Math.ceil(count/(24*3));
					task.log('will update $num vendors on a total of $count');
					for ( vs in pro.db.VendorStats.manager.search(true,{limit:num,orderBy:ldate},true)){
						if(vs.vendor==null){
							vs.delete();
							continue;
						}
						task.log(" - "+vs.vendor.name);
						VendorStats.updateStats(vs.vendor);
					}
				});
				task.execute();

				

			case MinutelyCron(now,jobs,outputFormat):
				
				//Catalogs synchro
				if (Date.now().getMinutes() % 10 == 0 || (App.current.user!=null && App.current.user.isAdmin()) ){	
									
					var task = new TransactionWrappedTask("Cpro Catalogs sync");
					if(outputFormat=="json"){
						jobs.push(task);
						task.printLog = false;
					}
					task.setTask(function (){
						var log = pro.service.PCatalogService.sync();
						for( l in log) task.log(l);
					});
					task.execute();
				}

				
			case DailyCron(now):

			case StockMove(e):
				
			default :
		}
	}

	
}