package hosted.controller;
import mangopay.Types.Wallet;
import payment.Check;
import mangopay.MangopayPlugin;
import mangopay.Mangopay;
import mangopay.db.MangopayLegalUserGroup;
import payment.Cash;
import service.ProductService;
import pro.payment.MangopayECPayment;
import service.GroupService;
import tools.ObjectListTool;
import Common;
import db.Operation;
import hosted.HostedPlugIn;
import hosted.db.GroupStats;
import pro.db.VendorStats;
import service.BridgeService;
import sugoi.form.elements.StringInput;
import tools.Timeframe;

/**
 * Main controller of HOSTED plugin
 */
class Main extends controller.Controller
{

	public function new() 
	{
		super();
		view.category = "admin";

		//trigger a "Nav" event
		var nav = new Array<Link>();
		var e = Nav(nav,"admin");
		app.event(e);
		view.nav = e.getParameters()[0];
	}
	
	/**
	 * view a transaction detail in a pop-in window 
	 * @param	t
	 */
	@tpl("transaction/view.mtt")
	public function doOperation(op:db.Operation){
		view.op = op ;
	}
	
	
	
	function doUser(d:haxe.web.Dispatch) {
		d.dispatch(new hosted.controller.User());
	}

	/**
	 * infos sur le membre d'un marché
	 */
	@admin @tpl("plugin/pro/hosted/usergroup.mtt")
	public function doUserGroup(u:db.User, g:db.Group){
		var ua = db.UserGroup.get(u, g, false);
		
		view.member = ua.user;
		view.ua = ua;
		view.operations = db.Operation.getLastOperations(u, g);

		view.getAllBaskets = function(user:db.User,md:db.MultiDistrib){
			return db.Basket.manager.search($multiDistrib==md && $user==user,false).array();
		};

		var timeframe = new Timeframe( DateTools.delta(Date.now() ,-1000.0*60*60*24*30.5*3) , DateTools.delta(Date.now() , 1000.0*60*60*24*30.5*3) );
		var mds = db.MultiDistrib.getFromTimeRange(g,timeframe.from,timeframe.to);
		mds.reverse();
		view.mds = mds;
		view.timeframe = timeframe;

	}

	//check bug de brigitte
	function doCheckBasket(b:db.Basket){

		var orders = MangopayPlugin.checkTmpBasket(b);
		if(orders!=null) {
			throw Ok("/p/hosted/userGroup/"+b.user.id+"/"+b.multiDistrib.group.id,"basket #"+b.id+" confirmed !");
		}else{
			throw Ok("/p/hosted/userGroup/"+b.user.id+"/"+b.multiDistrib.group.id,"pas de bug de brigitte pour basket #"+b.id);
		}

	}

	@admin
	function doCourse(d:haxe.web.Dispatch){
		if (App.current.getSettings().noCourse!=true) {
			d.dispatch(new hosted.controller.Course());
		}
	}

	@admin
	function doSeo(d:haxe.web.Dispatch){
		d.dispatch(new hosted.controller.Seo());
	}

	/**
		Empty MGP WALLETS
	**/
	@admin
	@tpl("plugin/pro/mangopay/group/lugs.mtt")
	function doEmptyWallets(){

		var count = MangopayLegalUserGroup.manager.count(true);

		var browse = function(index:Int, limit:Int) {
			//return db.Vendor.manager.search($id > index && $amap==app.user.getGroup(), { limit:limit, orderBy:-id }, false);

			var lugs = MangopayLegalUserGroup.manager.search(true,{limit:[index,limit]},false);
			for( lug in lugs ){

				if(lug.walletId!=null){
					var wallet:Wallet = Mangopay.callService("wallets/"+lug.walletId, "GET");
					untyped lug.amount = wallet.Balance.Amount/100;
				}
			}
			return lugs;
		}

		var rb = new sugoi.tools.ResultsBrowser(count,50,browse);
		view.rb = rb;
		view.count = count;
	}
	
}