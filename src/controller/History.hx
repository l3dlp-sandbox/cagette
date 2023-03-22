package controller;
import Common;
import db.MultiDistrib;
import db.Operation;
import service.OrderService;
import sugoi.form.Form;
import sugoi.form.elements.StringSelect;

using Std;
// import plugin.Tutorial;

class History extends Controller
{

	public function new()
	{
		super();
	}
	
	/**
	 * history page
	 */
	@logged
	@tpl("history/default.mtt")
	function doDefault() {
		
		var ua = db.UserGroup.get(app.user, app.user.getGroup());
		if (ua == null) throw Error("/", t._("You are not a member of this group"));
		
		var varOrders = new Map<String,Array<db.UserOrder>>();
		
		var group = App.current.user.getGroup();		
		var from  = DateTools.delta(Date.now(), -1000.0 * 60 * 60 * 24 * 30);
		var to 	  = DateTools.delta(Date.now(), 1000.0 * 60 * 60 * 24 * 30 * 6);
		
		//variable orders, grouped by date
		var distribs = MultiDistrib.getFromTimeRange( group , from , to  );
		//sort by date desc
		distribs.sort(function(a,b){
			return Math.round(b.distribStartDate.getTime()/1000) - Math.round(a.distribStartDate.getTime()/1000);
		});
		view.distribs = distribs;
		view.prepare = OrderService.prepare;
		
		checkToken();
		view.userGroup = ua;
	}


	/**
		View a basket in a popup
	**/
	@logged
	@tpl('history/basket.mtt')
	function doBasket(basket : db.Basket, ?type:Int){
		view.basket = basket;
		view.orders = service.OrderService.prepare(basket.getOrders(type));
		view.print = app.params["print"]!=null;
	}
	
	/**
	 * user payments history -----> a quel moment c'est utilisé ça ?
	 */
	@logged
	@tpl('history/payments.mtt')
	function doPayments(){
		var m = app.user;
		var browse:Int->Int->List<Dynamic>;
		
		//default display
		browse = function(index:Int, limit:Int) {
			return db.Operation.getOperationsWithIndex(m,app.user.getGroup(),index,limit,true);
		}
		
		var count = db.Operation.countOperations(m,app.user.getGroup());
		var rb = new sugoi.tools.ResultsBrowser(count, 10, browse);
		view.rb = rb;
		view.member = m;
		view.balance = db.UserGroup.get(m,app.user.getGroup()).balance;
	}

}