package controller;
import Common;
/**
 * Base Cagette.net Controller
 * @author fbarbut
 */
class Controller extends sugoi.BaseController
{
	var t: sugoi.i18n.GetText;
	
	public function new() 
	{
		super();
		
		//gettext translator
		this.t = sugoi.i18n.Locale.texts;	

		var cagettePros = service.VendorService.getCagetteProFromUser(App.current.user);
		view.cagettePros = cagettePros;
	}

	public function addBc(id:String,name:String,link:String){
		app.breadcrumb.push({id:id,name:name,link:link});
	}

	function nav(id:String):Array<Link>{
		//trigger a "Nav" event
		var nav = new Array<Link>();
		var e = Nav(nav,id);
		app.event(e);
		return e.getParameters()[0];
	}


	public function checkIsLogged(){
		if(app.user==null) {
			throw new tink.core.Error(t._("You should be logged in to perform this action."));
		}
	}

	
	function json(data:Dynamic){
		Sys.print(haxe.Json.stringify(data,Formatting.jsonReplacer));
	}
	

}