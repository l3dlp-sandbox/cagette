package controller;
import sugoi.Web;
import Common;
import db.Basket.BasketStatus;
import service.OrderFlowService;
import service.OrderService;
import tools.ArrayTool;
import sugoi.Web;

class Shop extends Controller
{
	
	var distribs : List<db.Distribution>;
	var contracts : List<db.Catalog>;
	var tmpBasket : db.Basket;

	@tpl('shop/default.mtt')
	public function doDefault(md:db.MultiDistrib,?args:{continueShopping:Bool}) {
		
		if( app.getCurrentGroup()==null || app.getCurrentGroup().id != md.getGroup().id){
			
			app.session.data.amapId = md.getGroup().id;
			// throw  Redirect("/group/"+md.getGroup().id);
		}

		// If the session has been closed, Neko has been logged out while Nest might still be logged in
		if (app.user == null){
			var cookies = Web.getCookies();
			var authSidCookie = cookies["Auth_sid"];
			if (authSidCookie != null && authSidCookie != view.sid){
				throw Redirect('/user/logout');
			}
		}

		view.category = 'shop';
		view.md = md;
		view.tmpBasketId = app.session.data.tmpBasketId;
		view.user = app.user;
	}

	
	
	/**
	 * Get the available products list
	*/
	private function getProducts(md:db.MultiDistrib,?categsFromTaxo=false):Array<ProductInfo> {

		var date = md.getDate();
		var place = md.getPlace();

		contracts = db.Catalog.getActiveContracts(app.getCurrentGroup());
	
		for (c in Lambda.array(contracts)) {
			//only varying orders
			if (c.type != db.Catalog.TYPE_VARORDER) contracts.remove(c);
			
			if (!c.isVisibleInShop()) contracts.remove(c);
		}

		view.contracts = contracts;
		
		var now = Date.now();
		var cids = Lambda.map(contracts, function(c) return c.id);
		var d1 = new Date(date.getFullYear(), date.getMonth(), date.getDate(), 0, 0, 0);
		var d2 = new Date(date.getFullYear(), date.getMonth(), date.getDate(), 23, 59, 59);

		//distribs open to orders, and where distribDate is in the date given as parameter
		distribs = db.Distribution.manager.search(($catalogId in cids) && $orderStartDate <= now && $orderEndDate >= now && $date > d1 && $end < d2 && $place == place, false);
		var products = [];
		for ( d in distribs){
			for (p in d.catalog.getProducts(true)){
				products.push( p.infos(categsFromTaxo,null,d) );
			}
		}
		return products;

		/*var cids = Lambda.map(distribs, function(d) return d.contract.id);
		var products = db.Product.manager.search(($catalogId in cids) && $active==true, { orderBy:name }, false);

		return Lambda.array(Lambda.map(products, function(p) return p.infos(categsFromTaxo)));*/
	}
	
	/**
	 * Product infos popup used in many places
	*/
	@tpl('shop/productInfo.mtt')
	public function doProductInfo(p:db.Product,?args:{distribution:db.Distribution}) {
		var d = args!=null && args.distribution!=null ? args.distribution : null;
		view.p = p.infos(null,null,d);
		view.product = p;
		view.vendor = p.catalog.vendor;
	} 
	
	/**
	 * receive cart
	 */
	public function doSubmit(md:db.MultiDistrib) {
		
		var order : TmpBasketData = haxe.Json.parse(app.params.get("data"));
		var tmpBasket = OrderService.getOrCreateTmpBasket(app.user,md);	
		tmpBasket.lock();
		tmpBasket.setData(order);
		tmpBasket.update();

		app.session.data.tmpBasketId = null;
		Sys.print( haxe.Json.stringify( {success:true,tmpBasketId:tmpBasket.id} ) );
		
	}
	

	/**
		final confirmation of the basket
	**/
	function doConfirm(tmpBasket:db.Basket){
		if(tmpBasket!=null){
			
			if(tmpBasket.user==null){				
				tmpBasket.lock();
				tmpBasket.user = app.user;
				tmpBasket.update();
			}

			OrderService.confirmTmpBasket(tmpBasket);
			throw Ok("/contract", t._("Your order has been confirmed") );
		}else{
			throw Redirect("/contract");
		}
	}

	/**
		a user made an order but is not logeed in
		this page handles the login process
	**/
	@tpl('shop/needLogin.mtt')
	function doLogin(tmpBasket:db.Basket){

		//Login is needed : display a loginbox
		if (app.user == null) {

			app.session.data.tmpBasketId = tmpBasket.id;
			view.redirect = sugoi.Web.getURI();
			view.sid = App.current.session.sid;
			view.group = tmpBasket.multiDistrib.getGroup();
			view.register = true;
			view.message =  t._("In order to confirm your order, You need to authenticate.");
			view.tmpBasketId = tmpBasket.id;

		}else{
			tmpBasket.lock();

			//case where the user just logged in
			if(tmpBasket.user==null){
				tmpBasket.user = app.user;
				tmpBasket.update();
			}

			//Add the user to this group if needed
			var group = tmpBasket.multiDistrib.group;
			if (group.regOption == db.Group.RegOption.Open && db.UserGroup.get(app.user, group) == null){
				app.user.makeMemberOf( group );			
			}

			var flow = new OrderFlowService().setPlace(UserLogsIn(tmpBasket));
			throw Redirect(flow.getPlaceUrl(flow.getNextPlace()));
		}

		
	}

	public function doAddTmpBasketId(tmpBasketId:Int) {
		app.session.data.tmpBasketId = tmpBasketId;
	}

	public function doCheckTmpBasketId() {
		Sys.print( haxe.Json.stringify( { tmpBasketId: app.session.data.tmpBasketId } ) );		
	}

	/**
	 * Product infos popup used in many places
	*/
	@tpl('shop/basket.mtt')
	public function doBasket(basket:db.Basket) {
		var md = basket.multiDistrib;
		var group = md.group;
		if (app.session.data.amapId != group.id){
			app.session.data.amapId = group.id;
		}

		view.group = app.getCurrentGroup();
		view.basket = basket;
	} 

}
