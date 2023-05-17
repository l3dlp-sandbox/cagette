package controller;

class Plugin extends sugoi.BaseController
{

	public function new(){
		super();
	}
	
	//redirect /p/pro?vendor=XXX
	public function doPro() {		
		if(app.params.exists("vendor")){
			var v = db.Vendor.manager.get(app.params.get("vendor").parseInt(),false);
			if(v!=null){
				throw Redirect(v.getURL());
			}else{
				throw Redirect("/");
			}			
		}else{
			throw Redirect("/");
		}
	}	
	
	//cagette-connector
	public function doConnector(d:haxe.web.Dispatch) {
		d.dispatch(new connector.controller.Main());
	}
	
	//cagette-wholesale-order
	public function doWho(d:haxe.web.Dispatch) {
		d.dispatch(new who.controller.Main());
	}
	
	//cagette-hosted
	public function doHosted(d:haxe.web.Dispatch) {
		d.dispatch(new hosted.controller.Main());
	}	

}