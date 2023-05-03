package pro.controller;
import service.BridgeService;
import service.VendorService;
import Common;
import pro.db.CagettePro;
using tools.ObjectListTool;

class Main extends controller.Controller
{
	var company : pro.db.CagettePro;
	var vendor : db.Vendor;
	
	public function new() 
	{
		super();
		view.company = company = pro.db.CagettePro.getCurrentCagettePro();
		view.vendor = vendor = pro.db.CagettePro.getCurrentVendor();

		//hack into breadcrumb
		if(vendor!=null){
			App.current.breadcrumb[0] = {id:"v"+vendor.id,name:"Espace producteur : "+vendor.name,link:"/p/pro"};
		}
	}
	
	/**
	 * check is the user is looged to a company
	 */
	function checkCompanySelected(){

		if (company == null && vendor == null){
			throw Redirect('/user/choose?show=1');
		}else if(company==null && vendor!=null){
			throw Redirect('/p/pro/company');
		}
	}
	
	/**
		CPro homepage + login
	**/
	@logged @tpl("plugin/pro/default.mtt")
	public function doDefault(?args:{vendor:Int}){
		addBc("home","Mes marchés", "/p/pro");
		
		//login to a vendor/cagettePro
		if (args!=null && args.vendor!=null) {

			var vendor = db.Vendor.manager.get(args.vendor,false);
			if ( !pro.db.CagettePro.canLogIn(app.user,vendor) && !app.user.isAdmin()){
				throw Error("/", "Vous ne pouvez pas gérer ce compte");
			}

			if(app.session.data==null) app.session.data = {};

			app.session.data.vendorId = args.vendor;			

			throw Redirect('/p/pro/');
		}else{
			checkCompanySelected();
		}

		//check CGS for non representative
		if(this.vendor.tosVersion != sugoi.db.Variable.getInt('platformtermsofservice') && app.user.isAdmin()==false){
			var isNonLegalRep = pro.db.PUserCompany.manager.select($user == app.user && $company == this.company && $legalRepresentative==false, false) != null;
			if(isNonLegalRep){
				throw Redirect("/p/pro/tosblocked");
			}
		} 
		
		view.nav = ["home"];
		
		//notifs
		view.notifs = pro.db.PNotif.getNotifications(this.company);
		
		//get client list
		var remoteCatalogs = connector.db.RemoteCatalog.manager.search($remoteCatalogId in company.getCatalogs().map(x -> x.id), false); 
		var clients = new Map<Int,Array<connector.db.RemoteCatalog>>();
		for ( rc in Lambda.array(remoteCatalogs)){
			var contract = rc.getContract();
			if (contract == null) {
				rc.lock();
				rc.delete();
				remoteCatalogs.remove(rc);
			}else{
				var c = clients[contract.group.id];
				if ( c == null ) c = [];
				c.push(rc);
				clients.set(contract.group.id, c);
			}
		}
		//sort by group name
		var clients = Lambda.array(clients);
		clients.sort(function(b, a) {
			return (a[0].getContract().group.name.toUpperCase() < b[0].getContract().group.name.toUpperCase())?1:-1;
		});


		var adminClients = [];
		var regularClients = [];
		var groups = [];

		for( client in clients ){
			var group = client[0].getContract().group;
			groups.push(group);
			var ua = db.UserGroup.get(app.user,group);
			
			if(ua!=null && ( ua.isGroupManager() || ua.canManageAllContracts() )){
				adminClients.push(client);
			}else{
				regularClients.push(client);
			}
		}

		view.adminClients = adminClients;
		view.regularClients = regularClients;

		//next deliveries
		var now = Date.now();
		var oneMonth = DateTools.delta(now, 1000.0 * 60 * 60 * 24 * 30);	
		var today = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, 0, 0);
		
		var distribs = db.Distribution.manager.search( ($catalogId in remoteCatalogs.getIds()) && $date <= oneMonth && $date >= today , {orderBy:date}, false);
		view.distribs = distribs.groupDistributionsByGroupAndDay();
		
		view.getCatalog = function(d:db.Distribution){			
			var rc = connector.db.RemoteCatalog.getFromContract(d.catalog);
			return rc.getPCatalog();			
		};
		
		//find unlinked catalogs		
		view.unlinkedCatalogs = VendorService.getUnlinkedCatalogs(company);
		
		view.vendorId = vendor.id;

	}

	public function doCatalogLinker(d:haxe.web.Dispatch){
		// checkCompanySelected();
		d.dispatch(new pro.controller.CatalogLinker());
	}
	
	@logged 
	public function doNotif(d:haxe.web.Dispatch){
		checkCompanySelected();
		d.dispatch(new pro.controller.Notif());
	}
	
	@logged 
	public function doGroup(d:haxe.web.Dispatch){
		checkCompanySelected();
		d.dispatch(new pro.controller.Group());
	}
	
	@logged 
	public function doProduct(d:haxe.web.Dispatch){
		checkCompanySelected();
		addBc("product","Produits", "/p/pro/product");
		d.dispatch(new pro.controller.Product());
	}
	
	/**
		legacy distribution manager
	**/
	@logged 
	public function doDelivery(d:haxe.web.Dispatch){
		checkCompanySelected();
		addBc("delivery","Vente", "/p/pro/delivery");
		d.dispatch(new pro.controller.Delivery());
	}

	/**
		New distribution manager
	**/
	@logged 
	public function doSales(d:haxe.web.Dispatch){
		checkCompanySelected();
		addBc("delivery","Vente", "/p/pro/delivery");
		d.dispatch(new pro.controller.Sales());
	}
	
	@logged 
	public function doOffer(d:haxe.web.Dispatch){
		addBc("product","Produits", "/p/pro/product");
		checkCompanySelected();		
		d.dispatch(new pro.controller.Offer());
	}
	
	@logged 
	public function doCatalog(d:haxe.web.Dispatch){
		addBc("catalog","Catalogues", "/p/pro/catalog");
		checkCompanySelected();
		d.dispatch(new pro.controller.Catalog());
	}

	@logged 
	public function doStock(d:haxe.web.Dispatch){
		addBc("stock","Stocks", "/p/pro/stock");
		checkCompanySelected();
		d.dispatch(new pro.controller.Stock());
	}
	
	@logged 
	public function doCompany(d:haxe.web.Dispatch){
		//checkCompanySelected(); should be accessible by a simple vendor
		addBc("company","Producteur", "/p/pro/company");
		d.dispatch(new pro.controller.Company());
	}
	
	@logged 
	public function doMessages(d:haxe.web.Dispatch){
		checkCompanySelected();
		addBc("messages","Messagerie", "/p/pro/messages");
		d.dispatch(new pro.controller.Messages());
	}

	@logged 
	public function doNetwork(d:haxe.web.Dispatch){
		checkCompanySelected();
		d.dispatch(new pro.controller.Network());
	}

	/**
	 * public pages for pros
	 */
	public function doPublic(d:haxe.web.Dispatch){
		d.dispatch(new pro.controller.Public());
	}
	
	public function doTransaction(d:haxe.web.Dispatch){
		d.dispatch(new pro.controller.Transaction());
	}

	public function doDirectory(d:haxe.web.Dispatch){
		d.dispatch(new pro.controller.Directory());
	}
	
	@admin
	function doAdmin(d:haxe.web.Dispatch){
		d.dispatch(new pro.controller.Admin());		
	}

	public function doSignup(d:haxe.web.Dispatch){		
		d.dispatch(new pro.controller.Signup());
	}

	@tpl('plugin/pro/tosblocked.mtt')
	function doTosblocked(){
		view.legalRep = pro.db.PUserCompany.manager.select($company == this.company && $legalRepresentative==true, false);
	}

	@logged @tpl("plugin/pro/upgrade.mtt")
	public function doUpgrade(){
	}
	
}