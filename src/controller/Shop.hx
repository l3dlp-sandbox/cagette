package controller;
import sugoi.Web;
import Common;

class Shop extends Controller
{
	
	@tpl('shop/default.mtt')
	public function doDefault(md:db.MultiDistrib,?args:{continueShopping:Bool}) {
		
		if( app.getCurrentGroup()==null || app.getCurrentGroup().id != md.getGroup().id){
			app.session.data.amapId = md.getGroup().id;
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
		view.user = app.user;
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
