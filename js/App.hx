import bootstrap.Modal;
import js.Browser;

class App {

    public static var instance : App;    
    	
	public var currency : String; //currency symbol like &euro; or $
	public var Modal = bootstrap.Modal;
    public var lang : String;
    

	function new(?lang="fr",?currency="&euro;") {
		//singleton
		instance = this;
		if(lang!=null) this.lang = lang;
		this.currency = currency;
	}


	/**
	 * The JS App will be available as "_" in the document.
	 */
	public static function main() {
        var app = new App();
        untyped js.Browser.window._Cagette = app;//avoid conflicts with lodash
    }
    
	/**
	 * Ajax loads a page and display it in a modal window
	 * @param	url
	 * @param	title
	 */
	public function overlay(url:String,?title,?large=true) {
		if(title != null) title = StringTools.urlDecode(title);
		var r = new haxe.Http(url);
		r.onData = function(data) {
			//setup body and title

			var modalElement = Browser.document.getElementById("myModal");
			var modal = new Modal(modalElement);
			modalElement.querySelector(".modal-body").innerHTML = data;
			if (title != null) modalElement.querySelector(".modal-title").innerHTML = title;
			if (!large) modalElement.querySelector(".modal-dialog").classList.remove("modal-lg");
			modal.show();
		}
		r.request();
	}

	/**
	 * Anti Doubleclick with btn elements.
	 * Can be bypassed by adding a .btn-noAntiDoubleClick class
	 */
	public function antiDoubleClick(){

		for( n in js.Browser.document.querySelectorAll(".btn:not(.btn-noAntiDoubleClick)") ){
			n.addEventListener("click",function(e:js.html.MouseEvent){
				var x = untyped e.target;
				x.classList.add("disabled");
				haxe.Timer.delay(function(){
					x.classList.remove("disabled");
				},3000);
			});
		}
		
	}

    /**
	 * Used in TS code after leaving a group
	 */
    public function resetGroupInSession(groupId:Int) {
        var req = new haxe.Http("/account/quitGroup/"+groupId);
        req.request();
    }

}


