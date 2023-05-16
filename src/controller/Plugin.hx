package controller;

class Plugin extends sugoi.BaseController
{

	public function new(){
		super();
	}
	
	#if plugins
	
	//cagette-hosted
	public function doHosted(d:haxe.web.Dispatch) {
		d.dispatch(new hosted.controller.Main());
	}	
	
	//cagette-pro
	public function doPro(?vendor:db.Vendor,d:haxe.web.Dispatch) {		
		d.dispatch(new pro.controller.Main(vendor));
	}	
	
	//cagette-connector
	public function doConnector(d:haxe.web.Dispatch) {
		d.dispatch(new connector.controller.Main());
	}
	
	//cagette-wholesale-order
	public function doWho(d:haxe.web.Dispatch) {
		d.dispatch(new who.controller.Main());
	}
	
	#end
	
}