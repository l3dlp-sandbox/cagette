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
	
	public function new(?vendor:db.Vendor) 
	{
		super();
		view.vendor = this.vendor = vendor;
	}

	function checkRights(){

		if ( !pro.db.CagettePro.canLogIn(app.user,vendor)){
			throw Error("/", "Vous ne pouvez pas gérer ce compte");
		}
		
		view.company = this.company = vendor.getCpro();

		if ( this.company==null){
			throw Error("/", "Ce producteur n'a pas d'espace producteur");
		}

		//hack into breadcrumb
		if(vendor!=null){
			App.current.breadcrumb[0] = {id:"v"+vendor.id,name:"Espace producteur : "+vendor.name,link:"/p/pro"};
		}
	}
	
	/**
		CPro homepage + login
	**/
	@logged @tpl("plugin/pro/default.mtt")
	public function doDefault(){
		checkRights();
		addBc("home","Tableau de bord", "/p/pro");
		
		//check CGS for non representative
		if(this.vendor.tosVersion != sugoi.db.Variable.getInt('platformtermsofservice') && app.user.isAdmin()==false){
			var isNonLegalRep = pro.db.PUserCompany.manager.select($user == app.user && $company == this.company && $legalRepresentative==false, false) != null;
			if(isNonLegalRep){
				throw Redirect(vendor.getURL()+"/tosblocked");
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
		checkRights();
		d.dispatch(new pro.controller.CatalogLinker(this.company));
	}
	
	@logged 
	public function doNotif(d:haxe.web.Dispatch){
		checkRights();
		d.dispatch(new pro.controller.Notif(this.company));
	}
	
	@logged 
	public function doGroup(d:haxe.web.Dispatch){
		checkRights();
		d.dispatch(new pro.controller.Group(this.company));
	}
	
	@logged 
	public function doProduct(d:haxe.web.Dispatch){
		checkRights();
		addBc("product","Produits", "/p/pro/product");
		d.dispatch(new pro.controller.Product(this.company));
	}
	
	/**
		legacy distribution manager
	**/
	@logged 
	public function doDelivery(d:haxe.web.Dispatch){
		checkRights();
		addBc("delivery","Vente", "/p/pro/delivery");
		d.dispatch(new pro.controller.Delivery(this.company));
	}

	/**
		New distribution manager
	**/
	@logged 
	public function doSales(d:haxe.web.Dispatch){
		checkRights();
		addBc("delivery","Vente", "/p/pro/delivery");
		d.dispatch(new pro.controller.Sales(this.company));
	}
	
	@logged 
	public function doOffer(d:haxe.web.Dispatch){
		checkRights();
		addBc("product","Produits", "/p/pro/product");
		d.dispatch(new pro.controller.Offer());
	}
	
	@logged 
	public function doCatalog(d:haxe.web.Dispatch){
		checkRights();
		addBc("catalog","Catalogues", "/p/pro/catalog");
		d.dispatch(new pro.controller.Catalog(this.company));
	}

	@logged 
	public function doStock(d:haxe.web.Dispatch){
		checkRights();
		addBc("stock","Stocks", "/p/pro/stock");
		d.dispatch(new pro.controller.Stock(company));
	}
	
	@logged 
	public function doCompany(d:haxe.web.Dispatch){
		checkRights();
		addBc("company","Producteur", "/p/pro/company");
		d.dispatch(new pro.controller.Company(this.company));
	}
	
	@logged 
	public function doMessages(d:haxe.web.Dispatch){
		checkRights();
		addBc("messages","Messagerie", "/p/pro/messages");
		d.dispatch(new pro.controller.Messages(this.company));
	}

	@logged 
	public function doNetwork(d:haxe.web.Dispatch){
		checkRights();
		d.dispatch(new pro.controller.Network(company));
	}

	@tpl('plugin/pro/tosblocked.mtt')
	function doTosblocked(){
		view.legalRep = pro.db.PUserCompany.manager.select($company == this.company && $legalRepresentative==true, false);
	}

	@logged @tpl("plugin/pro/upgrade.mtt")
	public function doUpgrade(){
	}

	/**
	 * create a new group
	 */
	@tpl("plugin/pro/form.mtt")
	function doCreateGroup() {
		App.current.session.data.amapId = null;

		// var cagettePros = service.VendorService.getCagetteProFromUser(App.current.user);
		// if (!(App.current.getSettings().onlyVendorsCanCreateGroup==null
		// 	|| App.current.getSettings().onlyVendorsCanCreateGroup==false 
		// 	|| (App.current.getSettings().onlyVendorsCanCreateGroup==true && cagettePros!=null && cagettePros.length>0))
		// 	) {
		// 	throw Redirect("/");
		// }
		if(company.offer!=Member){
			throw "non autorisé";
		}

		view.title = "Créer un nouveau "+App.current.getTheme().groupWordingShort+" en paiement sur place";

		var p = new db.Place();
		var f = form.CagetteForm.fromSpod(p);
		f.addElement(new sugoi.form.elements.Html("html","<div class='alert alert-warning'><i class='icon icon-info'></i> En tant que producteur Membre, vous pouvez à titre exceptionnel créer un "+App.current.getTheme().groupWordingShort+" en paiement sur place, tant que vous restez seul sur ce "+App.current.getTheme().groupWordingShort+".<br/><br/>N'oubliez pas que vous pouvez <a href=\"/group/newMarket\">créer directement un "+App.current.getTheme().groupWordingShort+" avec paiement en ligne Stripe</a> pour pouvoir collaborer avec d'autres producteurs sur ce "+App.current.getTheme().groupWordingShort+".</div>"),0);
		
		f.addElement(new sugoi.form.elements.StringSelect('country',t._("Country"),db.Place.getCountries(),p.country,true));			
		f.addElement(new sugoi.form.elements.StringInput("groupName", "Nom du "+App.current.getTheme().groupWordingShort, "La Cagette de ...", true),1);
		
		f.getElement("name").label = "Nom du lieu";
		f.removeElementByName("lat");
		f.removeElementByName("lng");

		f.addElement(new sugoi.form.elements.Html("infos","<h4>Lieu de distribution</h4>Renseignez le nom et adresse du lieu qui acceuillera les distributions de produits.<br/>Vous pourrez changer cette adresse plus tard si nécéssaire."),3);
		
		if (f.checkToken()) {
			
			var user = app.user;
			
			var g = new db.Group();
			g.name = f.getValueOf("groupName");
			g.contact = user;
			g.regOption = Open;
			g.setAllowedPaymentTypes([payment.Cash.TYPE,payment.Check.TYPE]);
			g.insert();
			
			var ua = new db.UserGroup();
			ua.user = user;
			ua.group = g;
			ua.insert();
			ua.giveRight(Right.GroupAdmin);
			ua.giveRight(Right.Membership);
			ua.giveRight(Right.Messages);
			ua.giveRight(Right.ContractAdmin(null));
			
			//insert place
			f.toSpod(p); 	
			p.group = g;		
			p.insert();

			service.PlaceService.geocode(p);

			App.current.session.data.amapId  = g.id;
			app.session.data.newGroup = true;

			#if plugins
			try{
				//sync if this user is not cpro && market mode group
				if( service.VendorService.getCagetteProFromUser(app.user).length==0 ){					
					BridgeService.syncUserToHubspot(app.user);
					service.BridgeService.triggerWorkflow(29805116, app.user.email);
				}
			}catch(e:Dynamic){
				//fail silently
				app.logError(Std.string(e));
			}
			#end

			throw Redirect("/");
		}
		
		view.form= f;
		
	}
	
	public function doTransaction(d:haxe.web.Dispatch){
		d.dispatch(new pro.controller.Transaction());
	}

	
	
	@admin
	function doAdmin(d:haxe.web.Dispatch){
		d.dispatch(new pro.controller.Admin());		
	}

	public function doSignup(d:haxe.web.Dispatch){		
		d.dispatch(new pro.controller.Signup());
	}
	
}