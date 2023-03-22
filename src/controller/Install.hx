package controller;
import sugoi.db.Variable;
import sugoi.form.elements.StringInput;
//import thx.semver.Version;
import service.VolunteerService;
import Common;

/**
 * ...
 * @author fbarbut
 */
class Install extends controller.Controller
{
	/**
	 * checks if its a first install or an update
	 */
	@tpl("install/default.mtt")
	public function doDefault() {
		if (db.User.manager.get(1) == null) {
						
			throw Redirect("/install/firstInstall");
			
		}else {
			//throw Error("/", "L'utilisateur admin a déjà été créé. Essayez de vous connecter avec admin@cagette.net, mot de passe : admin");
			
			var status = new Array<{parameter:String,valid:Bool,message:String}>(); 
			
			status.push(getVersionStatus());
			
			view.status = status;
		}
	}

	public function doDiagnostics(){

		var webroot = sugoi.Web.getCwd();

		if(!sys.FileSystem.exists(webroot+"file")){
			Sys.println("no File directory : created");
			sys.FileSystem.createDirectory(webroot+"file");
		} 
		if(!sys.FileSystem.exists(webroot+"file/.htaccess")){
			Sys.println("no .htaccess file in 'File' directory");
		} 
		if(!sys.FileSystem.exists(webroot+"../tmp")) {
			Sys.println("no tmp directory : created");
			sys.FileSystem.createDirectory(webroot+"../tmp");
		}

	}
	
	/**
	 * First install 
	 */
	@tpl("form.mtt")
	public function doFirstInstall(){
		view.title = "Installation de Cagette.net";

			var f = new sugoi.form.Form("c");
			f.addElement(new StringInput("amapName", t._("Name of your group"),"",true));
			f.addElement(new StringInput("userFirstName", t._("Your firstname"),"",true));
			f.addElement(new StringInput("userLastName", t._("Your lastname"),"",true));

			if (f.checkToken()) {
	
				var user = new db.User();
				user.firstName = f.getValueOf("userFirstName");
				user.lastName = f.getValueOf("userLastName");
				user.email = "admin@cagette.net";
				user.setPass("admin");
				user.insert();
			
				var amap = new db.Group();
				amap.name = f.getValueOf("amapName");
				amap.contact = user;

				amap.hasMembership = true;
				//amap.flags.set(db.Group.GroupFlags.IsAmap);
				amap.insert();
				
				var ua = new db.UserGroup();
				ua.user = user;
				ua.group = amap;				
				ua.insert();
				ua.giveRight(Right.GroupAdmin);
				ua.giveRight(Right.Membership);
				ua.giveRight(Right.Messages);
				ua.giveRight(Right.ContractAdmin(null));
				
				//example datas
				var place = new db.Place();
				place.name = t._("Marketplace");
				place.group = amap;
				place.address1 = t._("Place Jules Verne");
				place.zipCode = "00000";
				place.city = t._("St Martin de la Cagette");
				place.insert();
				
				var vendor = new db.Vendor();
				vendor.name = t._("Jean Martin EURL");
				vendor.email = "jean.martin@cagette.net";
				vendor.zipCode = "00000";
				vendor.city = "Martignac";
				vendor.insert();
				
				var contract = new db.Catalog();
				contract.name = t._("Vegetables Contract Example");
				contract.group  = amap;
				contract.type = 0;
				contract.vendor = vendor;
				contract.startDate = Date.now();
				contract.endDate = DateTools.delta(Date.now(), 1000.0 * 60 * 60 * 24 * 364);
				contract.contact = user;
				contract.distributorNum = 2;
				contract.insert();
				
				var p = new db.Product();
				p.name = t._("Big basket of vegetables");
				p.price = 15;
				p.vat = 5;
				p.catalog = contract;
				p.insert();
				
				var p = new db.Product();
				p.name = t._("Small basket of vegetables");
				p.price = 10;
				p.vat = 5;
				p.catalog = contract;
				p.insert();
			
				var uc = new db.UserOrder();
				uc.user = user;
				uc.product = p;
				uc.quantity = 1;
				uc.productPrice = 10;
				uc.insert();
				
				var d = new db.Distribution();
				d.catalog = contract;
				d.date = DateTools.delta(Date.now(), 1000.0 * 60 * 60 * 24 * 14);
				d.end = DateTools.delta(d.date, 1000.0 * 60 * 90);
				d.place = place;
				d.insert();
				
				App.current.user = null;
				App.current.session.data.amapId  = amap.id;
				
				throw Ok("/", t._("Group and user 'admin' created. Your email is 'admin@cagette.net' and your password is 'admin'"));
			}	
			
			view.form= f;
	}
	
	/**
	 * get version status
	 */
	private function getVersionStatus(){
		
		
		var out = {parameter:"version", valid:false, message:""};
		
		/*var v = Variable.get("version");
		if (v == null || v=="") {
			Variable.set("version", App.VERSION.toString());
			v = App.VERSION.toString();
		}
		
		var v :thx.semver.Version = thx.semver.Version.stringToVersion(v);
		
		if (v.lessThan(App.VERSION)){
			
			//need update !
			out.valid = false;
			out.message = t._("You must update your database to version ") +App.VERSION.toString()+"";
			
		}else{
			out.valid = true;
			out.message = t._("Current version") +v.toString()+"";
		}*/
		
		return out;
		
	}
	
	/**
	 * perform migrations from a version to another
	 */
	@admin
	public function doUpdateversion(){
		
		var log = [];
		
		/*var currentVersion = thx.semver.Version.stringToVersion(Variable.get("version"));
		
		//Migrations to 0.9.2
		if (currentVersion.lessThan( thx.semver.Version.arrayToVersion([0,9,2]) )){
			
			log.push(t._("Installation of the dictionnary of products (taxonomy)"));
			_0_9_2_installTaxonomy();
			
			log.push(t._("Improvement on saving orders"));
			_0_9_2_dbMigration();
			
			sugoi.db.Variable.set("version", "0.9.2");
		}*/
		
		//Migrations to 1.0.0
		//...
		
		throw Ok("/install", t._("Following update have been performed:<ul>")+Lambda.map(log,function(x) return "<li>"+x+"</li>").join("")+"</ul>");
		
	}
	
	/*@admin
	function _0_9_2_installTaxonomy(){
		
		db.TxpCategory.manager.delete(true);
		db.TxpSubCategory.manager.delete(true);
		db.TxpProduct.manager.delete(true);
		
		var taxo = sys.io.File.getContent(sugoi.Web.getCwd() + "../data/productTaxonomy.json");
		var taxo = haxe.Json.parse(taxo);
		
		var categories :  Array<Dynamic> = taxo.categories;
		var subcategories : Array<Dynamic> = taxo.subCategories;
		var products : Array<Dynamic> = taxo.products;
		
		for ( c in categories){
			var cat = new db.TxpCategory();
			cat.id = c.id;
			cat.name = c.name;
			cat.insert();
		}
		
		for ( sc in subcategories){
			var scat = new db.TxpSubCategory();
			scat.id = sc.id;
			scat.name = sc.name;
			scat.category = db.TxpCategory.manager.get(Std.parseInt(sc.category));
			scat.insert();
			
		}
		
		for ( p in products){
			var pro = new db.TxpProduct();
			pro.name = p.name;
			pro.id = p.id;
			pro.category = db.TxpCategory.manager.get(Std.parseInt(p.category));
			pro.subCategory = db.TxpSubCategory.manager.get(Std.parseInt(p.subCategory));
			pro.insert();
		}
		
	}*/

	public function doFillOrderEndDateInAllDistribs(){

		// 2020-11-23
		// MAJ gestion des paiements pour les AMAPs
		// db.Distribution.orderEndDate ne peut plus être nul

		// for(d in db.Distribution.manager.search($orderEndDate==null,{limit:1000},true).array() ){

		// 	var c = d.catalog;
		// 	if(c.orderEndHoursBeforeDistrib==null) c.orderEndHoursBeforeDistrib = 24;

		// 	d.orderEndDate = DateTools.delta( d.date, -1000.0 * 60 * 60 * c.orderEndHoursBeforeDistrib );
		// 	d.update();
		// 	trace("update distrib "+d.id+"<br/>");

		// }
	}

}