package service;
import Common;
import tink.core.Error;

/**
 * Order Service
 * @author web-wizard,fbarbut
 */
class OrderService
{

	static function canHaveFloatQt(product:db.Product):Bool{
		return product.hasFloatQt || product.wholesale || product.variablePrice;
	}

	/**
	 * Make a product Order
	 * 
	 * @param	quantity
	 * @param	productId
	 */
	public static function make(user:db.User, quantity:Float, product:db.Product, ?distribId:Int, ?paid:Bool, ?user2:db.User, ?invert:Bool, ?subscription : db.Subscription ) : db.UserOrder {
		
		var t = sugoi.i18n.Locale.texts;

		if( distribId == null ) throw new Error( "You have to provide a distribId" );
		if( quantity == null ) throw new Error( "Quantity is null" );
		if( quantity < 0 ) throw new Error( "Quantity is negative" );

		//quantity
		if ( !canHaveFloatQt(product) ){
			if( !tools.FloatTool.isInt(quantity)  ) {
				throw new Error( t._("Error : product \"::product::\" quantity should be integer",{product:product.name}) );
			}
		}
		
		//multiweight : make one row per product
		if (product.multiWeight && quantity > 1.0){
			if (product.multiWeight && quantity != Math.abs(quantity)) throw new Error( t._("multi-weighing products should be ordered only with integer quantities") );
			
			var o = null;
			for ( i in 0...Math.round(quantity)){
				o = make(user, 1, product, distribId, paid, user2, invert);
			}			
			return o;
		}
		
		//checks
		if (quantity <= 0) return null;
		
		//check for previous orders on the same distrib
		var prevOrders = new List<db.UserOrder>();
		if (distribId == null) {
			prevOrders = db.UserOrder.manager.search($product==product && $user==user, true);
		}else {
			prevOrders = db.UserOrder.manager.search($product==product && $user==user && $distributionId==distribId, true);
		}
		
		//Create order object
		var o = new db.UserOrder();
		o.product = product;
		o.quantity = quantity;
		o.productPrice = product.price;
		if ( product.catalog.hasPercentageOnOrders() ){
			o.feesRate = product.catalog.percentageValue;
		}
		o.user = user;
		if (user2 != null) {
			o.user2 = user2;
			if (invert != null) o.flags.set(InvertSharedOrder);
		}
		if (paid != null) o.paid = paid;
		if (distribId != null) o.distribution = db.Distribution.manager.get(distribId);
		
		//cumulate quantities if there is a similar previous order
		if (prevOrders.length > 0 && !product.multiWeight) {
			for (prevOrder in prevOrders) {
				//if (!prevOrder.paid) {
					o.quantity += prevOrder.quantity;
					prevOrder.delete();
				//}
			}
		}
		
		//create a basket
		if (distribId != null){
			o.basket = db.Basket.getOrCreate(user, o.distribution.multiDistrib);			
		}

		//checks
		if(o.distribution==null) throw new Error( "cant record an order for a variable catalog without a distribution linked" );
		if(o.basket==null) throw new Error( "this order should have a basket" );

		if (subscription != null ) { 

			o.subscription = subscription;
		 }
		
		o.insert();
		
		//Stocks
		if (o.product.stock != null) {
			var c = o.product.catalog;
			if (c.hasStockManagement()) {
				//trace("stock for "+quantity+" x "+product.name);
				if (o.product.stock == 0) {
					if (App.current.session != null) {
						App.current.session.addMessage(t._("There is no more '::productName::' in stock, we removed it from your order", {productName:o.product.name}), true);
					}
					o.quantity -= quantity;
					if ( o.quantity <= 0 ) {
						o.delete();
						return null;	
					}
				}else if (o.product.stock - quantity < 0) {
					var canceled = quantity - o.product.stock;
					o.quantity -= canceled;
					o.update();
					
					if (App.current.session != null) {
						var msg = t._("We reduced your order of '::productName::' to quantity ::oQuantity:: because there is no available products anymore", {productName:o.product.name, oQuantity:o.quantity});
						App.current.session.addMessage(msg, true);
					}
					o.product.lock();
					o.product.stock = 0;
					o.product.update();
					App.current.event(StockMove({product:o.product, move:0 - (quantity - canceled) }));
					
				}else {
					o.product.lock();
					o.product.stock -= quantity;
					o.product.update();	
					App.current.event(StockMove({product:o.product, move:0 - quantity}));
				}
			}	
		}
		return o;
	}


	/**
	 * Edit an existing order (quantity)
	 */
	public static function edit(order:db.UserOrder, newquantity:Float, ?paid:Bool , ?user2:db.User,?invert:Bool):db.UserOrder {
		
		var t = sugoi.i18n.Locale.texts;
		
		order.lock();
		
		//quantity
		if (newquantity == null) newquantity = 0;
		if(newquantity<0) throw new Error( "Quantity is negative" );
		
		if ( !canHaveFloatQt(order.product) ){
			if( !tools.FloatTool.isInt(newquantity)  ) {
				throw new Error( t._( "Error : product \"::product::\" quantity should be integer",{ product:order.product.name } ) );
			}
		}
		
		//paid
		if (paid != null) {
			order.paid = paid;
		}else {
			if (order.quantity < newquantity) order.paid = false;	
		}
		
		//shared order
		if (user2 != null){
			order.user2 = user2;	
			if (invert == true) order.flags.set(InvertSharedOrder);
			if (invert == false) order.flags.unset(InvertSharedOrder);
		}else{
			order.user2 = null;
			order.flags.unset(InvertSharedOrder);
		}

		//stocks
		var e : Event = null;
		if (order.product.stock != null) {
			var c = order.product.catalog;
			
			if (c.hasStockManagement()) {
				
				if (newquantity < order.quantity) {

					//on commande moins que prévu : incrément de stock						
					order.product.lock();
					order.product.stock +=  (order.quantity-newquantity);
					e = StockMove({product:order.product, move:0 - (order.quantity-newquantity) });
					
				}else {
				
					//on commande plus que prévu : décrément de stock
					var addedquantity = newquantity - order.quantity;
					
					if (order.product.stock - addedquantity < 0) {
						
						//stock is not enough, reduce order
						newquantity = order.quantity + order.product.stock;
						if( App.current.session!=null) App.current.session.addMessage(t._("We reduced your order of '::productName::' to quantity ::oQuantity:: because there is no available products anymore", {productName:order.product.name, oQuantity:newquantity}), true);
						
						e = StockMove({product:order.product, move: 0 - order.product.stock });
						
						order.product.lock();
						order.product.stock = 0;
						
					}else{
						
						//stock is big enough
						order.product.lock();
						order.product.stock -= addedquantity;
						
						e = StockMove({ product:order.product, move: 0 - addedquantity });
					}					
				}				
				order.product.update();					
			}	
		}

		//update order
		if (newquantity == 0) {
			order.quantity = 0;			
			order.paid = true;
			order.update();
		}else {
			order.quantity = newquantity;
			order.update();				
		}	

		//checks
		var o = order;
		if(o.distribution==null) throw new Error( "cant record an order for a variable catalog without a distribution linked");
		if(o.basket==null) throw new Error( "this order should have a basket" );

		App.current.event(e);	

		return order;
	}


	/**
	 *  Delete an order
	 */
	public static function delete(order:db.UserOrder) {
		var t = sugoi.i18n.Locale.texts;

		if(order==null) throw new Error( t._( "This order has already been deleted." ) );
		
		order.lock();
		
		if (order.quantity == 0) {

			var contract = order.product.catalog;
			var user = order.user;

			//Amap Contract
			if ( contract.type == db.Catalog.TYPE_CONSTORDERS ) {

				order.delete();

				if( contract.group.hasPayments() ){
					var orders = contract.getUserOrders(user);
					if( orders.length == 0 ){
						var operation = db.Operation.findCOrderOperation(contract, user);
						if(operation!=null) operation.delete();
					}
				}
			}
			else { //Variable orders contract
				
				//Get the basket for this user
				var place = order.distribution.place;
				var basket = db.Basket.get(user, order.distribution.multiDistrib);
				
				if( contract.group.hasPayments() ){
					var orders = basket.getOrders();
					//Check if it is the last order, if yes then delete the related operation
					if( orders.length == 1 && orders.first().id==order.id ){
						var operation = db.Operation.findVOrderOperation(basket.multiDistrib, user);
						if(operation!=null) operation.delete();
					}

				}

				order.delete();
			}
		}
		else {
			throw new Error( t._( "Deletion not possible: quantity is not zero." ) );
		}

	}

	/**
	 * Prepare a simple dataset, ready to be displayed
	 */
	public static function prepare(orders:Iterable<db.UserOrder>):Array<UserOrder> {
		var out = new Array<UserOrder>();
		var orders = Lambda.array(orders);
		var view = App.current.view;
		var t = sugoi.i18n.Locale.texts;

		for (o in orders) {
		
			var x : UserOrder = cast { };
			x.id = o.id;
			x.basketId = o.basket==null ? null : o.basket.id;
			x.userId = o.user.id;
			x.userName = o.user.getCoupleName();
			x.userEmail = o.user.email;
			
			//shared order
			if (o.user2 != null){
				x.userId2 = o.user2.id;
				x.userName2 = o.user2.getCoupleName();
				x.userEmail2 = o.user2.email;
			}
			
			//deprecated
			x.productId = o.product.id;
			x.productRef = o.product.ref;
			x.productQt = o.product.qt;
			x.productUnit = o.product.unitType;
			x.productPrice = o.productPrice;
			x.productImage = o.product.getImage();
			x.productHasFloatQt = o.product.hasFloatQt;
			x.productHasVariablePrice = o.product.variablePrice;
			//new way
			x.product = o.product.infos();
			x.product.price = o.productPrice;//do not use current price, but price of the order
			x.quantity = o.quantity;
			
			//smartQt
			if (x.quantity == 0.0){
				x.smartQt = t._("Canceled");
			}else if(x.productHasFloatQt || x.productHasVariablePrice || o.product.wholesale){
				x.smartQt = view.smartQt(x.quantity, x.productQt, x.productUnit);
			}else{
				x.smartQt = Std.string(x.quantity);
			}

			//product name.
			if ( x.productHasVariablePrice || x.productQt==null || x.productUnit==null ){
				x.productName = o.product.name;	
			}else{
				x.productName = o.product.name + " " + view.formatNum(x.productQt) +" "+ view.unit(x.productUnit,x.productQt>1);	
			}
			
			x.subTotal = o.quantity * o.productPrice;

			var c = o.product.catalog;
			
			if ( o.feesRate!=0 ) {
				
				x.fees = x.subTotal * (o.feesRate/100);
				x.percentageName = c.percentageName;
				x.percentageValue = o.feesRate;
				x.total = x.subTotal + x.fees;
				
			}else {
				x.total = x.subTotal;
			}
			
			//flags
			x.paid = o.paid;
			x.invertSharedOrder = o.flags.has(InvertSharedOrder);
			x.catalogId = c.id;
			x.catalogName = c.name;
			x.canModify = o.canModify(); 
			
			out.push(x);
		}
		
		return sort(out);
	}

	/**
		Record a temporary basket
	**/
	public static function makeTmpBasket(user:db.User,multiDistrib:db.MultiDistrib, tmpBasketData:TmpBasketData):db.TmpBasket {
		//basket with no products is allowed ( init an empty basket )
		if( tmpBasketData==null) throw new Error( "Basket is empty" );

		//generate basketRef
		var group = multiDistrib.getGroup();
		var ref = (user==null?0:user.id)+"-"+group.id+"-"+Date.now().toString().substr(0,10)+"-"+Std.random(1000);

		var tmp = new db.TmpBasket();
		tmp.user = user;
		tmp.multiDistrib = multiDistrib;
		tmp.data = tmpBasketData;
		tmp.ref = ref;
		tmp.insert();
		return tmp;
	}
	
	/**
	 * Confirms an order : create real orders from a temporary basket
	 * @param	order
	 */
	public static function confirmTmpBasket(tmpBasket:db.TmpBasket){
		var t = sugoi.i18n.Locale.texts;
		var orders = [];
		var user = tmpBasket.user;
		for (o in tmpBasket.data.products){
			var p = db.Product.manager.get(o.productId);

			//find related distrib
			var distrib = null;
			for( d in tmpBasket.multiDistrib.getDistributions()){
				if(d.catalog.id==p.catalog.id){
					distrib = d;
				}
			}

			//check that the distrib is still open.			
			if(!distrib.canOrderNow()){
				throw new Error( 500, t._( "Orders are closed for \"::contract::\", please modify your order.", { contract : distrib.catalog.name } ) );
			}

			orders.push( make(user, o.quantity, p, distrib.id ) );
		}
		
		App.current.event(MakeOrder(orders));
		tmpBasket.delete();
		
		return orders;
	}


	/**
	 *  Send an order-by-products report to the coordinator
	 */
	public static function sendOrdersByProductReport(d:db.Distribution){
		
		var m = new sugoi.mail.Mail();
		m.addRecipient(d.catalog.contact.email , d.catalog.contact.getName());
		m.setSender(App.config.get("default_email"),"Cagette.net");
		m.setSubject('[${d.catalog.group.name}] Distribution du ${App.current.view.dDate(d.date)} (${d.catalog.name})');
		var orders = service.ReportService.getOrdersByProduct(d);

		var html = App.current.processTemplate("mail/ordersByProduct.mtt", { 
			contract:d.catalog,
			distribution:d,
			orders:orders,
			formatNum:Formatting.formatNum,
			currency:App.current.view.currency,
			dDate:Formatting.dDate,
			hHour:Formatting.hHour,
			group:d.catalog.group
		} );
		
		m.setHtmlBody(html);
		App.sendMail(m);					

	}


	/**
	 *  Send Order summary for a member
	 *  WARNING : its for one distrib, not for a whole basket !
	 */
	public static function sendOrderSummaryToMembers(d:db.Distribution){

		var title = '[${d.catalog.group.name}] Votre commande pour le ${App.current.view.dDate(d.date)} (${d.catalog.name})';

		for( user in d.getUsers() ){

			var m = new sugoi.mail.Mail();
			m.addRecipient(user.email , user.getName(),user.id);
			if(user.email2!=null) m.addRecipient(user.email2 , user.getName(),user.id);
			m.setSender(App.config.get("default_email"),"Cagette.net");
			m.setSubject(title);
			var orders = prepare(d.catalog.getUserOrders(user,d));

			var html = App.current.processTemplate("mail/orderSummaryForMember.mtt", { 
				contract:d.catalog,
				distribution:d,
				orders:orders,
				formatNum:Formatting.formatNum,
				currency:App.current.view.currency,
				dDate:Formatting.dDate,
				hHour:Formatting.hHour,
				group:d.catalog.group
			} );
			
			m.setHtmlBody(html);
			App.sendMail(m);
		}
		
	}
	

	public static function sort(orders:Array<UserOrder>){
		//order by lastname (+lastname2 if exists), then contract
		orders.sort(function(a, b) {
			
			if (a.userName + a.userId + a.userName2 + a.userId2 + a.catalogId > b.userName + b.userId + b.userName2 + b.userId2 + b.catalogId ) {
				return 1;
			}
			if (a.userName + a.userId + a.userName2 + a.userId2 + a.catalogId < b.userName + b.userId + b.userName2 + b.userId2 + b.catalogId ) {
				return -1;
			}
			return 0;
		});
		return orders;
	}

	/**
		Returns tmp basket
	**/
	public static function getTmpBasket(user:db.User,group:db.Group):db.TmpBasket{
		for( b in db.TmpBasket.manager.search($user==user)){
			if(b.multiDistrib.group.id==group.id) return b;
		}
		return null;
	}

	/**
		Action triggered from controllers to check if we have a tmpBasket to validate
	**/
	public static function checkTmpBasket(user,group){
		//user can be null, if open group
		if(user==null) return;
		
		var tmpBasket = getTmpBasket(user,group);
		if(tmpBasket!=null){

			if(tmpBasket.data.products.length==0){
				tmpBasket.lock();
				tmpBasket.delete();
				return;
			}

			throw sugoi.ControllerAction.ControllerAction.RedirectAction("/transaction/tmpBasket/"+tmpBasket.id);
		}
	}

	/**
	 * get users orders for a distribution
	 */
	public static function getOrders( contract : db.Catalog, ?distribution : db.Distribution, ?csv = false) : Array<UserOrder> {

		var view = App.current.view;
		var orders = new Array<db.UserOrder>();
		orders = contract.getOrders(distribution);	
				
		var orders = prepare(orders);
		
		//CSV export
		if (csv) {
			var t = sugoi.i18n.Locale.texts;			
			var data = new Array<Dynamic>();
			
			for (o in orders) {
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
			
			var exportName = "";
			if (distribution != null){
				exportName = contract.group.name + " - " + t._("Delivery ::contractName:: ", {contractName:contract.name}) + distribution.date.toString().substr(0, 10);					
			}else{
				exportName = contract.group.name + " - " + contract.name;
			}
			
			sugoi.tools.Csv.printCsvDataFromObjects(data, ["name",  "productName", "price", "quantity", "fees", "total", "paid"], exportName+" - " + t._("Per member"));			
			return null;
		}else{
			return orders;
		}
		
	}


	// Get orders of a user for a multi distrib or a catalog
	public static function getUserOrders( user : db.User, ?catalog : db.Catalog, ?multiDistrib : db.MultiDistrib, ?subscription : db.Subscription ) : Array<db.UserOrder> {
	 
		var orders : Array<db.UserOrder>;
		if( catalog == null ) {

			//We edit a whole multidistrib, edit only var orders.
			orders = multiDistrib.getUserOrders(user , db.Catalog.TYPE_VARORDER);
		}
		else {
			
			//Edit a single catalog, may be CSA or variable
			var distrib = null;
			if( multiDistrib != null ) {

				distrib = multiDistrib.getDistributionForContract(catalog);
			}

			if ( catalog.type == db.Catalog.TYPE_VARORDER ) {

				orders = catalog.getUserOrders( user, distrib, false );
			}
			else {

				orders = SubscriptionService.getSubscriptionOrders( subscription );
			}
				
		}

		return orders;
		
	}

	// Create or update orders 
	public static function createOrUpdateOrders( user : db.User, multiDistrib : db.MultiDistrib, catalog : db.Catalog,
	ordersData : Array< { id : Int, productId : Int, qt : Float, paid : Bool, invertSharedOrder : Bool, userId2 : Int } > ) : Array<db.UserOrder> {
		
		if ( multiDistrib == null && catalog == null ) {

			throw new Error('You should provide at least a catalog or a multiDistrib');
		}

		var t = sugoi.i18n.Locale.texts;

		var orders : Array<db.UserOrder> = [];
		if ( multiDistrib == null && catalog.type == db.Catalog.TYPE_CONSTORDERS ) {

			var subscription = db.Subscription.manager.select( $user == user && $catalog == catalog, false );
			if ( subscription == null ) {
				
				throw TypedError.typed( "Il n\'y a pas de souscription à ce nom. Il faut d\'abord créer une souscription pour cette personne pour pouvoir ajouter des commandes.", SubscriptionService.SubscriptionServiceError.NoSubscription );
			}

			if ( SubscriptionService.hasPastDistribOrders( subscription ) ) {

				throw TypedError.typed( 'Il y a des commandes pour des distributions passées. Les commandes du passé ne pouvant être modifiées il faut modifier la date de fin de
				la souscription et en recréer une nouvelle pour la nouvelle période. Vous pourrez ensuite définir une nouvelle commande pour cette nouvelle souscription.', SubscriptionService.SubscriptionServiceError.PastOrders );
			}

			orders = SubscriptionService.createCSARecurrentOrders( subscription, ordersData );
		}
		else {

			// Find existing orders
			var existingOrders = [];
			if ( catalog == null ) {

				// Edit a whole multidistrib
				existingOrders = multiDistrib.getUserOrders( user );
			}
			else {

				// Edit a single catalog
				var distrib = null;
				if( multiDistrib != null ) {

					distrib = multiDistrib.getDistributionForContract( catalog );
				}
				existingOrders = catalog.getUserOrders( user, distrib );			
			}
					
			for ( order in ordersData ) {
				
				// Get product
				var product = db.Product.manager.get( order.productId, false );
				
				// Find existing order				
				var existingOrder = Lambda.find( existingOrders, function(x) return x.id == order.id );
				
				// Save order
				if ( existingOrder != null ) {

					// Edit existing order
					var updatedOrder = OrderService.edit( existingOrder, order.qt, order.paid );
					if ( updatedOrder != null ) orders.push( updatedOrder );
				}
				else {

					// Insert new order
					var distrib = null; //no need if csa catalog
					if( multiDistrib != null ) { 

						distrib = multiDistrib.getDistributionFromProduct( product );
					}
					
					var newOrder =  OrderService.make( user, order.qt , product, distrib == null ? null : distrib.id, order.paid );
					if ( newOrder != null ) orders.push( newOrder );
					
				}

			}

		}	

		App.current.event( MakeOrder( orders ) );
		db.Operation.onOrderConfirm( orders );

		return orders;
		
	}

	
}