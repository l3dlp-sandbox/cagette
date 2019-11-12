package controller;
import db.Catalog;
import db.UserOrder;
import db.VolunteerRole;
import sugoi.form.elements.DateDropdowns;
import sugoi.form.elements.Input;
import sugoi.form.elements.Selectbox;
import sugoi.form.Form;
import Common;
import plugin.Tutorial;
import service.OrderService;
using Std;
using Lambda;


class Contract extends Controller
{

	public function new() 
	{
		super();
		view.nav = ["contractadmin"];
	}
	
	//retrocompat
	public function doDefault(){
		throw Redirect("/account");
	}

	
	@tpl("contract/view.mtt")
	public function doView( catalog : db.Catalog ) {

		view.category = 'amap';
		view.catalog = catalog;

		var isSubscribedToCatalog = true;
		var allDocuments : List<sugoi.db.EntityFile>  = sugoi.db.EntityFile.getByEntity('catalog', catalog.id, 'document');
		if ( catalog.type == 0 ) { //Amap catalog

			var userCatalogs : Array<db.Catalog> = app.user.getContracts();
			isSubscribedToCatalog = Lambda.exists( userCatalogs, function( usercatalog ) return usercatalog.id == catalog.id ); 
		}
		
		view.visibleDocuments = isSubscribedToCatalog ? allDocuments : allDocuments.filter( function( doc ) return doc.data != 'subscribers' );
		
	}
	


	/**
	 * Edit a contract 
	 */
	@tpl("form.mtt")
	function doEdit(c:db.Catalog) {
		
		view.category = 'contractadmin';
		if (!app.user.isContractManager(c)) throw Error('/', t._("Forbidden action"));

		view.title = t._("Edit catalog \"::contractName::\"",{contractName:c.name});

		var group = c.group;
		var currentContact = c.contact;
		
		var form = Form.fromSpod(c);
		form.removeElement( form.getElement("groupId") );
		form.removeElement(form.getElement("type"));
		form.removeElement(form.getElement("distributorNum"));
		form.getElement("userId").required = true;

		app.event(EditContract(c,form));
		
		if (form.checkToken()) {
			form.toSpod(c);
			c.group = group;
			
			//checks & warnings
			if (c.hasPercentageOnOrders() && c.percentageValue==null) throw Error("/contract/edit/"+c.id, t._("If you would like to add fees to the order, define a rate (%) and a label."));
			
			if (c.hasStockManagement()) {
				for (p in c.getProducts()) {
					if (p.stock == null) {
						app.session.addMessage(t._("Warning about management of stock. Please fill the field \"stock\" for all your products"), true);
						break;
					}
				}
			}
			
			//no stock mgmt for constant orders
			if (c.hasStockManagement() && c.type==db.Catalog.TYPE_CONSTORDERS) {
				c.flags.unset(CatalogFlags.StockManagement);
				app.session.addMessage(t._("Managing stock is not available for CSA contracts"), true);
			}
			
			
			c.update();
			
			//update rights
			if ( c.contact != null && (currentContact==null || c.contact.id!=currentContact.id) ) {
				var ua = db.UserGroup.get(c.contact, c.group, true);
				ua.giveRight(ContractAdmin(c.id));
				ua.giveRight(Messages);
				ua.giveRight(Membership);
				ua.update();
				
				//remove rights to old contact
				if (currentContact != null) {
					var x = db.UserGroup.get(currentContact, c.group, true);
					if (x != null) {
						x.removeRight(ContractAdmin(c.id));
						x.update();						
					}
				}
				
			}
			
			throw Ok("/contractAdmin/view/"+c.id, t._("Catalog updated"));
		}
		
		view.form = form;
	}
	
	/**
		1- define the vendor
	**/
	@tpl("form.mtt")
	function doDefineVendor(?type=1){
		if (!app.user.canManageAllContracts()) throw Error('/', t._("Forbidden action"));
		
		view.title = t._("Define a vendor");
		view.text = t._("Before creating a record for the vendor you want to work with, let's search our database to check if he's not already referenced.");

		var f = new sugoi.form.Form("defVendor");
		f.addElement(new sugoi.form.elements.StringInput("name",t._("Vendor or farm name"),null,true));
		f.addElement(new sugoi.form.elements.StringInput("email",t._("Vendor email"),null,false));
		//f.addElement(new sugoi.form.elements.IntInput("zipCode",t._("zip code"),null,true));

		if(f.isValid()){
			
			//look for identical names
			var vendors = service.VendorService.findVendors( f.getValueOf('name') , f.getValueOf('email') );

			app.setTemplate('contractadmin/defineVendor.mtt');
			view.vendors = vendors;
			view.email = f.getValueOf('email');
			view.name = f.getValueOf('name');
		}

		view.form = f;
	}

	/**
	  2- create vendor
	**/
	@tpl("form.mtt")
	public function doInsertVendor(email:String,name:String) {
				
		var vendor = new db.Vendor();
		var form = db.Vendor.getForm(vendor);
		
				
		if (form.isValid()) {
			form.toSpod(vendor);
			vendor.insert();

			/*service.VendorService.getOrCreateRelatedUser(vendor);
			service.VendorService.sendEmailOnAccountCreation(vendor,app.user,app.user.getGroup());*/
			
			throw Ok('/contract/insert/'+vendor.id, t._("This supplier has been saved"));
		}else{
			form.getElement("email").value = email;
			form.getElement("name").value = name;
		}

		view.title = t._("Key-in a new vendor");
		//view.text = t._("We will send him/her an email to explain that your group is going to organize orders for him very soon");
		view.form = form;
	}

	/**
		3 - Select VARIABLE ORDER / CSA Contract
	**/
	//@tpl("contract/insertChoose.mtt")
	function doInsertChoose(vendor:db.Vendor) {
		throw Redirect("/contract/insert/"+vendor.id);
	}
	
	/**
	 * 4 - create the contract
	 */
	@tpl("contract/insert.mtt")
	function doInsert(vendor:db.Vendor) {
		if (!app.user.canManageAllContracts()) throw Error('/', t._("Forbidden action"));
		
		view.title = t._("Create a catalog");
		
		var c = new db.Catalog();

		var form = Form.fromSpod(c);
		form.removeElement(form.getElement("groupId") );
		form.removeElement(form.getElement("type"));
		form.getElement("name").value = "Commande "+vendor.name;
		form.getElement("userId").required = true;
		form.getElement("endDate").value = DateTools.delta(Date.now(),365.25*24*60*60*1000);
		form.removeElement(form.getElement("vendorId"));
		form.addElement(new sugoi.form.elements.Html("vendorHtml",'<b>${vendor.name}</b> (${vendor.zipCode} ${vendor.city})', t._("Vendor")));
		form.addElement( new sugoi.form.elements.Checkbox("csa","Ce catalogue est un contrat AMAP",false));
			
		if (form.checkToken()) {
			form.toSpod(c);
			c.group = app.user.getGroup();
			c.type = form.getValueOf("csa")==true ? db.Catalog.TYPE_CONSTORDERS : db.Catalog.TYPE_VARORDER;
			c.vendor = vendor;
			c.insert();

			//Let's add the Volunteer Roles for the number of volunteers needed
			service.VolunteerService.createRoleForContract(c,form.getValueOf("distributorNum"));
			
			//right
			if (c.contact != null) {
				var ua = db.UserGroup.get(c.contact, app.user.getGroup(), true);
				ua.giveRight(ContractAdmin(c.id));
				ua.giveRight(Messages);
				ua.giveRight(Membership);
				ua.update();
			}
			
			throw Ok("/contractAdmin/view/"+c.id, t._("New catalog created"));
		}
		
		view.form = form;
	}
	
	/**
	 * Delete a contract (... and its products, orders & distributions)
	 */
	function doDelete(c:db.Catalog) {
		
		if (!app.user.canManageAllContracts()) throw Error("/contractAdmin", t._("Forbidden access"));
		
		if (checkToken()) {
			c.lock();
			
			//demo contracts
			var isDemoContract = c.vendor.email=="galinette@cagette.net" || c.vendor.email=="jean@cagette.net";

			//check if there is orders in this contract
			var products = c.getProducts();

			var orders = db.UserOrder.manager.search($productId in Lambda.map(products, function(p) return p.id));
			var qt = 0.0;
			for ( o in orders) qt += o.quantity; //there could be "zero c qt" orders
			if (qt > 0 && !isDemoContract) {
				throw Error("/contractAdmin", t._("You cannot delete this catalog because some orders are linked to it."));
			}
			
			//remove admin rights and delete contract	
			if(c.contact!=null){
				var ua = db.UserGroup.get(c.contact, c.group, true);
				if (ua != null) {
					ua.removeRight(ContractAdmin(c.id));
					ua.update();	
				}			
			}
			
			app.event(DeleteContract(c));
			
			c.delete();
			throw Ok("/contractAdmin", t._("Catalog deleted"));
		}
		
		throw Error("/contractAdmin", t._("Token error"));
	}
	
	/**
	 * Make an order by contract ( CSA mode )
	 * The form is prepopulated if orders have already been made.
	 * 
	 * It should work for constant orders ( will display one column )
	 * or varying orders ( with as many columns as distributions dates )
	 * 
	 */
	@tpl("contract/order.mtt")
	function doOrder( c:db.Catalog ) {
		
		//checks
		//if (app.user.getGroup().hasPayments()) throw Redirect("/contract/orderAndPay/" + c.id);
		if (app.user.getGroup().hasShopMode()) throw Redirect("/shop");
		if (!c.isUserOrderAvailable()) throw Error("/", t._("This catalog is not opened for orders"));

		
		var distributions = [];
		// If its a varying contract, we display a column by distribution
		if (c.type == db.Catalog.TYPE_VARORDER) {
			distributions = db.Distribution.getOpenToOrdersDeliveries(c);
		}else{
			distributions = [null];
		}
		
		//list of distribs with a list of product and optionnaly an order
		var userOrders = new Array< {distrib:db.Distribution,datas:Array<{order:db.UserOrder,product:db.Product}>} >();
		var products = c.getProducts();
		
		if ( c.type == db.Catalog.TYPE_VARORDER ){
			
			for ( d in distributions){
				var datas = [];
				for ( p in products) {
					var ua = { order:null, product:p };					
					var order = db.UserOrder.manager.select($user == app.user && $productId == p.id && $distributionId==d.id, true);						
					if (order != null) ua.order = order;
					datas.push(ua);
				}				
				userOrders.push({distrib:d,datas:datas});
			}
			
		}else{
			
			var datas = [];
			for ( p in products) {
				var ua = { order:null, product:p };				
				var order = db.UserOrder.manager.select($user == app.user && $productId == p.id, true);				
				if (order != null) ua.order = order;
				datas.push(ua);
			}
			
			userOrders.push({distrib:null,datas:datas});			
		}

		
		//form check
		if (checkToken()) {

			var orders = [];

			for (k in app.params.keys()) {
				
				if (k.substr(0, 1) != "d") continue;
				var qt = app.params.get(k);
				if (qt == "") continue;
				
				var pid = null;
				var did = null;
				try{
				pid = Std.parseInt(k.split("-")[1].substr(1));
				did = Std.parseInt(k.split("-")[0].substr(1));
				}catch (e:Dynamic){trace("unable to parse key "+k); }
				
				//find related element in userOrders
				var uo = null;
				for ( x in userOrders){
					if (x.distrib!=null && x.distrib.id != did) {
						continue;
					}else{
						for (a in x.datas){
							if (a.product.id == pid){
								uo = a;
								break;
							}
						}
					}
				}
				
				if (uo == null) throw t._("Could not find the product ::product:: and delivery ::delivery::", {product:pid, delivery:did});
				
				var q = 0.0;
				
				if (uo.product.hasFloatQt ) {
					var param = StringTools.replace(qt, ",", ".");
					q = Std.parseFloat(param);
				}else {
					q = Std.parseInt(qt);
				}
				
				
				if (uo.order != null) {	
					orders.push( OrderService.edit(uo.order, q));
				}else {
					orders.push( OrderService.make(app.user, q, uo.product, did));
				}
				
			}

			//create order operation only
			if (app.user.getGroup().hasPayments()){		
				var orderOps = db.Operation.onOrderConfirm(orders);
			}

			throw Ok("/contract/order/"+c.id, t._("Your order has been updated"));
		}
		
		view.c = view.contract = c;
		view.userOrders = userOrders;
	}
	
	
	/**
	 * Make an order by contract ( standard mode ) + payment process
	 */
	/*@tpl("contract/orderAndPay.mtt")
	function doOrderAndPay(c:db.Catalog ) {
		
		//checks
		if (!app.user.getGroup().hasPayments()) throw Redirect("/contract/order/" + c.id);
		if (app.user.getGroup().hasShopMode()) throw Redirect("/");
		if (!c.isUserOrderAvailable()) throw Error("/", t._("This catalog is not opened for orders"));
		
		var distributions = [];
		// If its a varying contract, we display a column by distribution
		if (c.type == db.Catalog.TYPE_VARORDER) {
			distributions = db.Distribution.getOpenToOrdersDeliveries(c);
		}
		
		//list of distribs with a list of product and optionnaly an order
		var userOrders = new Array< {distrib:db.Distribution,datas:Array<{order:db.UserOrder,product:db.Product}>} >();
		var products = c.getProducts();
		
		for ( d in distributions){
			var datas = [];
			for ( p in products) {
				var ua = { order:null, product:p };
				
				var order : db.UserOrder = null;
				if (c.type == db.Catalog.TYPE_VARORDER) {
					order = db.UserOrder.manager.select($user == app.user && $productId == p.id && $distributionId==d.id, true);	
				}else {
					order = db.UserOrder.manager.select($user == app.user && $productId == p.id, true);
				}
				
				if (order != null) ua.order = order;
				datas.push(ua);
			}
			
			userOrders.push({distrib:d,datas:datas});
		}
		
		
		//form check
		if (checkToken()) {
			
			//get distrib if needed
			var distrib = null;
			if (c.type == db.Catalog.TYPE_VARORDER) {
				distrib = db.Distribution.manager.get(Std.parseInt(app.params.get("distribution")), false);
			}
			
			var orders : OrderInSession = {products:[],userId:app.user.id,total:0};
			
			for (k in app.params.keys()) {
				
				if (k.substr(0, 1) != "d") continue;
				var qt = app.params.get(k);
				if (qt == "") continue;
				
				var pid = null;
				var did = null;
				try{
					pid = Std.parseInt(k.split("-")[1].substr(1));
					did = Std.parseInt(k.split("-")[0].substr(1));
				}catch (e:Dynamic){
					trace("unable to parse key "+k);					
				}
				
				//find related element in userOrders
				var uo = null;
				for ( x in userOrders){
					if (x.distrib!=null && x.distrib.id != did) {
						continue;
					}else{
						for (a in x.datas){
							if (a.product.id == pid){
								uo = a;
								break;
							}
						}
					}
				}
				
				if (uo == null) throw t._("Could not find the product ::produ:: and delivery ::deliv::", {produ:pid, deliv:did});
					
				//quantity
				var q = 0.0;				
				if (uo.product.hasFloatQt ) {
					var param = StringTools.replace(qt, ",", ".");
					q = Std.parseFloat(param);
				}else {
					q = Std.parseInt(qt);
				}
				
				orders.products.push({productId:pid, quantity:q, distributionId:did});
				
				var p = db.Product.manager.get(pid, false);
				orders.total += p.getPrice() * q;
				
			}
			
			App.current.session.data.order = orders;
			
			//Go to payments page			
			if (c.type == db.Catalog.TYPE_CONSTORDERS) {
				throw Ok("/contract/order/"+c.id, t._("Your CSA order has been saved"));
			}else{
				throw Ok("/transaction/pay/", t._("In order to save your order, please choose a means of payment."));
			}
			
			
			
		}
		
		view.c = view.contract = c;
		view.userOrders = userOrders;		
	}*/
	
	
	/**
	 * A user edit an order for a multidistrib.
	 */
	@tpl("contract/orderByDate.mtt")
	function doEditOrderByDate(date:Date) {
		
		if (app.user.getGroup().hasPayments()) {
			//when payments are active, the user cannot modify his order
			throw Redirect("/");
		}
		
		// cannot edit order if date is in the past
		if (Date.now().getTime() > date.getTime()) {
			
			var msg = t._("This delivery has already taken place, you can no longer modify the order.");
			if (app.user.isContractManager()) msg += t._("<br/>As the manager of the catalog you can modify the order from this page: <a href='/contractAdmin'>Catalog management</a>");
			
			throw Error("/account", msg);
		}
		
		// Il faut regarder le contrat de chaque produit et verifier si le contrat est toujours ouvert à la commande.		
		var d1 = new Date(date.getFullYear(), date.getMonth(), date.getDate(), 0, 0, 0);
		var d2 = new Date(date.getFullYear(), date.getMonth(), date.getDate(), 23, 59, 59);

		var cids = Lambda.map(app.user.getGroup().getActiveContracts(true), function(c) return c.id);
		var distribs = db.Distribution.manager.search(($catalogId in cids) && $date >= d1 && $date <=d2 , false);
		var orders = db.UserOrder.manager.search($userId==app.user.id && $distributionId in Lambda.map(distribs,function(d)return d.id)  );
		view.orders = service.OrderService.prepare(orders);
		view.date = date;
		
		//form check
		if (checkToken()) {
			
			var orders_out = [];
			
			for (k in app.params.keys()) {
				var param = app.params.get(k);
				if (k.substr(0, "product".length) == "product") {
					
					//trouve le produit dans userOrders
					var pid = Std.parseInt(k.substr("product".length));
					var order = Lambda.find(orders, function(uo) return uo.product.id == pid);
					if (order == null) throw t._("Error, could not find the order");
					
					var q = 0.0;
					if (order.product.hasFloatQt ) {
						param = StringTools.replace(param, ",", ".");
						q = Std.parseFloat(param);
					}else {
						q = Std.parseInt(param);
					}
					
					var quantity = Math.abs( q==null?0:q );

					if ( order.distribution.canOrderNow() ) {
						//met a jour la commande
						var o = OrderService.edit(order, quantity);
						if(o!=null) orders_out.push( o );
					}					
				}
			}
			
			app.event(MakeOrder(orders_out));
			
			throw Ok("/account", t._("Your order has been updated"));
		}
	}
}
