package controller;
import pro.db.CagettePro;
import Common;
import connector.db.RemoteCatalog;
import datetime.DateTime;
import db.Basket.BasketStatus;
import db.Catalog;
import db.UserOrder;
import form.CagetteDatePicker;
import form.CagetteDatePicker;
import service.CatalogService;
import service.OrderService;
import service.ProductService;
import sugoi.form.Form;
import sugoi.form.elements.Checkbox;
import sugoi.form.elements.IntInput;
import sugoi.form.elements.NativeDatePicker.NativeDatePickerType;
import sugoi.form.elements.RadioGroup;
import sugoi.form.elements.Selectbox;
import sugoi.form.elements.StringInput;
import tink.core.Error;

using tools.DateTool;
using tools.ObjectListTool;


class ContractAdmin extends Controller
{

	public function new() 
	{
		super();
		if (!app.user.isContractManager()) throw Error("/", t._("You don't have the authorization to manage contracts"));
		view.nav = ["contractadmin"];
		

	}
	
	public function sendNav(c){
		var navbar = new Array<Link>();
		var e = Nav(navbar,"contractAdmin",c.id);
		app.event(e);
		view.navbar = e.getParameters()[0];
	}
	
	/**
	 * Contract admin main page
	 */
	@tpl("contractadmin/default.mtt")
	function doDefault(?args:{old:Bool}) {
		
		view.nav.push("default");

		var now = Date.now();
		
		var contracts;
		if (args != null && args.old) {
			contracts = db.Catalog.manager.search($group == app.user.getGroup() && $endDate < Date.now() ,{orderBy:-startDate},false);	
		}else {
			contracts = db.Catalog.getActiveContracts(app.user.getGroup(), true, false);	
		}

		//filter if current user is not manager
		if (!app.user.isGroupManager()) {
			for ( c in Lambda.array(contracts).copy()) {				
				if(!app.user.canManageContract(c)) contracts.remove(c);				
			}
		}
		
		view.contracts = contracts;
		var vendors = app.user.getGroup().getActiveVendors();
		view.vendors = vendors;
		view.places = app.user.getGroup().getPlaces();
		view.group = app.user.getGroup();
		
		checkToken();
	}

	/**
	 * Edit a contract/catalog
	 */
	 @logged @tpl("contractadmin/form.mtt")
	 function doEdit( catalog : db.Catalog ) {
		 
		view.category = 'contractadmin';
		if (!app.user.isContractManager( catalog )) throw Error('/', t._("Forbidden action"));

		view.title = 'Modifier le catalogue "${catalog.name}"';

		var group = catalog.group;
		var currentContact = catalog.contact;
		var messages = new Array<String>() ;

		var form = CatalogService.getForm(catalog);
		
		app.event( EditContract( catalog, form ) );
		
		if ( form.checkToken() ) {

			form.toSpod( catalog );
		
			try {

				CatalogService.checkFormData(catalog,  form );
				catalog.update();

				//update rights
				if ( catalog.contact != null && (currentContact==null || catalog.contact.id!=currentContact.id) ) {
					var ua = db.UserGroup.get( catalog.contact, catalog.group, true );
					ua.giveRight(ContractAdmin(catalog.id));
					ua.giveRight(Messages);
					ua.giveRight(Membership);
					ua.update();
					
					//remove rights to old contact
					if (currentContact != null) {
						var x = db.UserGroup.get(currentContact, catalog.group, true);
						if (x != null) {
							x.removeRight(ContractAdmin(catalog.id));
							x.update();
						}
					}
				}

			} catch ( e : Error ) {
				throw Error( '/contractAdmin/edit/' + catalog.id, e.message );
			}
			
			
			var text = "Catalogue mis à jour.";
			if(messages.length > 0){
				text += "<br/>" + messages.join(". ");
			} 
			throw Ok( "/contractAdmin/view/" + catalog.id,  text );
		}
		 
		view.form = form;
	}

	/**
	 * Manage products
	 */
	@tpl("contractadmin/products.mtt")
	function doProducts(contract:db.Catalog,?args:{?enable:String,?disable:String}) {
		view.nav.push("products");
		sendNav(contract);

		if (!app.user.canManageContract(contract)) throw Error("/", t._("Access forbidden") );
		view.c = contract;
		
		var isRemote = RemoteCatalog.getFromContract(contract)!=null;
		view.isRemote = isRemote;

		//batch enable / disable products
		if (args != null){
			
			if (args.disable != null){
				var pids = Lambda.array(Lambda.map(args.disable.split("|"), function(x) return Std.parseInt(x)));				
				service.ProductService.batchDisableProducts(pids);
			}
			
			if (args.enable != null){
				var pids = Lambda.array(Lambda.map(args.enable.split("|"), function(x) return Std.parseInt(x)));
				service.ProductService.batchEnableProducts(pids);
			}
			
		}
		
		//generate a token
		checkToken();
	}
	
	

	
	/**
	 * global view on orders within a timeframe
	 */
	@tpl('contractadmin/ordersByTimeFrame.mtt')
	function doOrdersByTimeFrame(?from:Date, ?to:Date/*, ?place:db.Place*/){

		if(!app.user.canManageAllContracts())  throw Error('/',"Accès interdit");
		
		if (from == null) {
		
			var f = new sugoi.form.Form("listBydate", null, sugoi.form.Form.FormMethod.GET);
			
			var now = DateTime.now();	
			var from = now.snap(Month(Down)).getDate();			
			var to = now.snap(Month(Up)).add(Day(-1)).getDate();
			
			var el = new form.CagetteDatePicker("from", t._("Start date"), from, NativeDatePickerType.date, true);			
			el.format = 'LL';
			f.addElement(el);
			
			var el = new form.CagetteDatePicker("to", t._("End date"), to, NativeDatePickerType.date, true);
			el.format = 'LL';
			f.addElement(el);
			
			//var places = Lambda.map(app.user.getGroup().getPlaces(), function(p) return {label:p.name,value:p.id} );
			//f.addElement(new sugoi.form.elements.IntSelect("placeId", "Lieu", Lambda.array(places),app.user.getGroup().getMainPlace().id,true));
			
			view.form = f;
			view.title = t._("Global view of orders");
			app.setTemplate("contractadmin/form.mtt");
			
			if (f.checkToken()) {
				
				var url = '/contractAdmin/ordersByTimeFrame/' + f.getValueOf("from").toString().substr(0, 10) +"/"+f.getValueOf("to").toString().substr(0, 10);
				//var p = f.getValueOf("placeId");
				//if (p != null) url += "/"+p;
				throw Redirect( url );
			}
			
			return;
			
		}else {
			
			var d1 = tools.DateTool.setHourMinute(from,0,0);
			var d2 = tools.DateTool.setHourMinute(to,23,59);
			var contracts = app.user.getGroup().getActiveContracts(true);
			var cids = contracts.getIds();
			
			//distribs
			var distribs = db.Distribution.manager.search(($catalogId in cids)   && $date >= d1 && $date <= d2 /*&& place.id==$placeId*/, false);								
			if (distribs.length == 0) throw Error("/contractAdmin/ordersByTimeFrame", t._("There is no delivery at this date"));
			
			var orders = [];
			for ( d in distribs ){
				for( o in d.getOrders()){
					orders.push(o);
				}
			}
			var orders = service.OrderService.prepare(orders);
			
			view.orders = orders;
			view.from = from;
			view.to = to;
			view.ctotal = app.params.exists("ctotal");
			
		}
	}
	
	/**
	 * Global view on orders, producer view
	 */
	@tpl('contractadmin/vendorsByTimeFrame.mtt')
	function doVendorsByTimeFrame(from:Date,to:Date){
			
		var d1 = tools.DateTool.setHourMinute(from,0,0);
		var d2 = tools.DateTool.setHourMinute(to,23,59);
		var contracts = app.user.getGroup().getActiveContracts(true);
		var cids = contracts.getIds();
		
		//distribs for both types in active contracts
		var distribs = db.Distribution.manager.search(($catalogId in cids) && $date >= d1 && $date <= d2 /*&& $place==place*/, false);		
		if ( distribs.length == 0 ) throw Error("/contractAdmin/", t._("There is no delivery during this period"));
		
		var out = new Map<Int,{contract:db.Catalog,distrib:db.Distribution,orders:Array<OrderByProduct>}>();//key : vendor id
		
		for (d in distribs){
			var vid = d.catalog.vendor.id;
			var o = out.get(vid);
			
			if (o == null){
				out.set( vid, {contract:d.catalog,distrib:d,orders:service.ReportService.getOrdersByProduct(d) });	
			}else{
				
				//add orders with existing ones
				for ( x in service.ReportService.getOrdersByProduct(d) ){
					
					//find record in existing orders
					var f : OrderByProduct = Lambda.find(o.orders, function(a:OrderByProduct) return a.pid == x.pid);
					if (f == null){
						//new product order
						o.orders.push(x);						
					}else{
						//increment existing
						f.quantity += x.quantity;
						f.totalHT += x.totalHT;
						f.totalTTC += x.totalTTC;
					}
				}
				out.set(vid, o);
			}
		}
		
		view.orders = Lambda.array(out);
		
		if ( app.params.exists("csv") ){
			var totalHT = 0.0;
			var totalTTC = 0.0;
			
			var orders = [];
			for ( x in out){
				//empty line
				orders.push({"quantity":null, 					"pname":null, "ref":null, "priceHT":null, "priceTTC":null, "totalHT":null, "totalTTC":null});				
				orders.push({"quantity":null, "pname":x.contract.vendor.name, "ref":null, "priceHT":null, "priceTTC":null, "totalHT":null, "totalTTC":null});				
				
				for (o in x.orders){
					if(o.vat==null) o.vat = 0;
					orders.push({
						"quantity":view.formatNum(o.quantity),
						"pname":o.pname,
						"ref":o.ref,
						"priceHT":view.formatNum(o.priceTTC / (1 + o.vat / 100) ),
						"priceTTC":view.formatNum(o.priceTTC),
						"totalHT":view.formatNum(o.totalHT),					
						"totalTTC":view.formatNum(o.totalTTC)					
					});
					totalTTC += o.totalTTC;
					totalHT += o.totalHT;
				}
				
				//total line
				orders.push({
					"quantity":null,
					"pname":null,
					"ref":null,
					"priceHT":null,
					"priceTTC":null,
					"totalHT":view.formatNum(totalHT) + "",
					"totalTTC":view.formatNum(totalTTC)+""					
				});								
				totalTTC = 0;
				totalHT = 0;
				
			}			
			var fileName = t._("Orders from the ::fromDate:: to the ::toDate:: per supplier.csv", {fromDate:from.toString().substr(0, 10), toDate:to.toString().substr(0, 10)});
			sugoi.tools.Csv.printCsvDataFromObjects(orders, ["quantity", "pname", "ref", "priceHT", "priceTTC", "totalHT","totalTTC"], fileName);
			return;
		}
		
		view.from = from;
		view.to = to;
	}
	
	
	/**
	 * Overview of orders for this contract in backoffice
	 */
	@tpl("contractadmin/orders.mtt")
	function doOrders( catalog:db.Catalog, ?args:{ d:db.Distribution, ?delete:db.UserOrder } ) {

		view.nav.push( "orders" );
		sendNav( catalog );
		
		//Checking permissions
		if ( !app.user.canManageContract( catalog ) ) throw Error( "/", t._("You do not have the authorization to manage this contract") );
		if ( args == null || args.d == null ) throw Redirect( "/contractAdmin/selectDistrib/" + catalog.id );

		//Delete specified order with quantity of zero
		if ( checkToken() && args != null && args.delete != null ) {

			try {
				service.OrderService.delete(args.delete);
			}	catch( e : tink.core.Error ) {
				throw Error( "/contractAdmin/orders/" + catalog.id, e.message );
			}
			if( args.d != null ) {
				throw Ok("/contractAdmin/orders/" + catalog.id + "?d="+args.d.id, t._("The order has been deleted."));
			} else {
				throw Ok("/contractAdmin/orders/" + catalog.id, t._("The order has been deleted."));
			}
			
		}
		
		view.distribution = args.d;
		view.multiDistribId = args.d.multiDistrib.id;
		view.c = view.catalog = catalog;		

		if ( App.current.params.get("csv")=="1" ) {

			var data = [];			
			for( basket in args.d.multiDistrib.getBaskets()){
				for(o in service.OrderService.prepare(basket.getDistributionOrders(args.d))){
					data.push( { 
						"name":o.userName,
						"productName":o.productName,
						"price":view.formatNum(o.productPrice),
						"quantity":view.formatNum(o.quantity),
						"fees":view.formatNum(o.fees),
						"total":view.formatNum(o.total),
						"paid":o.paid
					});				
				}
			}
			
			var exportName = catalog.group.name + " - " + t._("Delivery ::contractName:: ", {contractName:catalog.name}) + args.d.date.toString().substr(0, 10);								
			sugoi.tools.Csv.printCsvDataFromObjects(data, ["name",  "productName", "price", "quantity", "fees", "total", "paid"], exportName+" - " + t._("Per member"));			
		}
	}
	
	/**
	 * hidden feature : updates orders by setting current product price.
	 */
	function doUpdatePrices(contract:db.Catalog, args:{?d:db.Distribution}) {
		
		sendNav(contract);
		
		if (!app.user.canManageContract(contract)) throw Error("/", t._("You do not have the authorization to manage this contract"));
		if (args.d == null ) { 
			throw Redirect("/contractAdmin/selectDistrib/" + contract.id); 
		}
		var d = null;
		view.distribution = args.d;
		d = args.d;
		
		for ( o in contract.getOrders(d)){
			o.lock();
			o.productPrice = o.product.price;
			o.update();
			
		}
		throw Ok("/contractAdmin/orders/"+contract.id+"?d="+args.d.id, t._("Prices are now up to date."));
	}
	
	/**
	 * Orders grouped by product
	 */
	@tpl("contractadmin/ordersByProduct.mtt")
	function doOrdersByProduct(contract:db.Catalog, args:{?d:db.Distribution}) {
		
		sendNav(contract);		
		if (!app.user.canManageContract(contract)) throw Error("/", t._("You do not have the authorization to manage this contract"));
		if (args.d == null ) throw Redirect("/contractAdmin/selectDistrib/" + contract.id); 
		
		var d = args != null ? args.d : null;
		if (d == null) d = contract.getDistribs(false).first();
		if (d == null) throw Error("/contractAdmin/orders/"+contract.id,t._("There is no delivery in this catalog, please create at least one distribution."));

		var orders = service.ReportService.getOrdersByProduct(d,app.params.exists("csv"));
		view.orders = orders;
		view.distribution = d; 
		view.c = contract;
		
	}
	
	/**
	 * Purchase order to print
	 */
	@tpl("contractadmin/ordersByProductList.mtt")
	function doOrdersByProductList(contract:db.Catalog, args:{d:db.Distribution}) {
		
		sendNav(contract);		
		if (!app.user.canManageContract(contract)) throw Error("/", t._("Forbidden access"));
		if(args.d.catalog.id!=contract.id) throw 'Distribution does not belong to this catalog';
				
		view.distribution = args.d;
		view.c = contract;
		view.group = contract.group;
		view.orders = service.ReportService.getOrdersByProduct(args.d,false);
	}
	
	/**
	 * Lists deliveries for this contract
	 */
	@tpl("contractadmin/distributions.mtt")
	function doDistributions(contract:db.Catalog, ?args: { ?participateToAllDistributions:Bool } ) {

		view.nav.push("distributions");
		sendNav(contract);
		
		if (!app.user.canManageContract(contract)) throw Error("/", t._("You do not have the authorization to manage this contract"));

		var now = Date.now();
		//snap to beggining of the month , end is 3 month later 
		var from = new Date(now.getFullYear(),now.getMonth(),1,0,0,0);
		var to = new Date(now.getFullYear(),now.getMonth()+3,-1,23,59,59);
		var timeframe = new tools.Timeframe(from,to);

		var multidistribs =  db.MultiDistrib.getFromTimeRange(contract.group,timeframe.from , timeframe.to);

		if(args!=null && args.participateToAllDistributions){
			for( d in multidistribs){
				if( d.getDistributionForContract(contract)==null ){
					try{
						service.DistributionService.participate(d,contract);
					}catch(e:Error){
						app.session.addMessage(e.message,true);
					}
				}				
			}
			app.session.addMessage(contract.vendor.name+" participe maintenant à toutes les distributions");
		}
		
		view.multidistribs = multidistribs;
		view.c = contract;
		view.contract = contract;
		view.timeframe = timeframe;

				
	}

	function doParticipate(md:db.MultiDistrib,contract:db.Catalog){
		try{
			service.DistributionService.participate(md,contract);
		}catch(e:tink.core.Error){
			throw Error("/contractAdmin/distributions/"+contract.id,e.message);
		}
		
		throw Ok('/contractAdmin/distributions/${contract.id}?_from=${app.params.get("_from")}&_to=${app.params.get("_to")}',t._("Distribution date added"));
	}
	
	@tpl("contractadmin/view.mtt")
	function doView( catalog : db.Catalog ) {

		view.nav.push("view");
		sendNav(catalog);
		checkToken();

		catalog.check();

		view.rc = RemoteCatalog.getFromContract(catalog);
		
		if ( !app.user.canManageContract( catalog ) ) throw Error("/", t._("You do not have the authorization to manage this contract"));

		view.c = view.contract = catalog;
	}	

	function doDocuments( dispatch : haxe.web.Dispatch ) {
		dispatch.dispatch( new controller.Documents() );
	}

	@tpl("contractadmin/stats.mtt")
	function doStats(contract:db.Catalog, ?args: { stat:Int } ) {
		sendNav(contract);
		if (!app.user.canManageContract(contract)) throw Error("/", t._("You do not have the authorization to manage this contract"));
		view.c = contract;
		
		if (args == null) args = { stat:0 };
		view.stat = args.stat;
		var pids = contract.getProducts().map(function(x) return x.id);
		switch(args.stat) {
			case 0 : 
				if(pids.length==0){
					view.anciennete = new List();
				}else{
					view.anciennete = sys.db.Manager.cnx.request("select YEAR(u.cdate) as uyear ,count(DISTINCT u.id) as cnt from User u, UserOrder up where up.userId=u.id and up.productId IN (" + pids.join(",") + ") group by uyear;").results();
				}
				
			case 1 : 
				//repartition des commandes
				var repartition = new List();
				var total = 0;
				var totalPrice = 0;
				if(pids.length!=0){	
					var repartition = sys.db.Manager.cnx.request("select sum(quantity) as quantity,productId,p.name,p.price from UserOrder up, Product p where up.productId IN (" + contract.getProducts().map(function(x) return x.id).join(",") + ") and up.productId=p.id group by productId").results();
					for ( r in repartition) {
						total += r.quantity;
						totalPrice += r.price*r.quantity; 
					}
					for (r in repartition) {
						Reflect.setField(r, "percent", Math.round((r.quantity/total)*100)  );
					}
					
					if ( app.params.exists("csv") ){					
						sugoi.tools.Csv.printCsvDataFromObjects(Lambda.array(repartition), ["quantity","productId","name","price","percent"], "stats-" + contract.name+".csv");
					}
				}				
				
				view.repartition = repartition;
				view.totalQuantity = total;
				view.totalPrice = totalPrice;
				
		}
		
	}
	
	@tpl("contractadmin/tmpBaskets.mtt")
	function doTmpBaskets(md:db.MultiDistrib){
		view.md = md;
		view.tmpBaskets = db.Basket.manager.search($multiDistrib == md && $status==Std.string(BasketStatus.OPEN),false);
	}

	/**
	 * Delete a catalog (... and its products, orders & distributions)
	 */
	@logged
	function doDelete(c:db.Catalog) {
		
		if (!app.user.canManageAllContracts()) throw Error("/contractAdmin", t._("Forbidden access"));
		
		if (checkToken()) {
			c.lock();
			
			//check if there is orders in this contract
			var pids = c.getProducts().map(p -> p.id);
			var orders = db.UserOrder.manager.search($productId in pids);
			var qt = 0.0;
			for ( o in orders) qt += o.quantity; //there could be "zero c qt" orders
			if (qt > 0 && !c.isDemoCatalog()) {
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

	
	
}
