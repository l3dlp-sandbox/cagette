package pro.controller;
import pro.service.PStockService;
import sugoi.form.Form;
import Common;
using Std;

class Stock extends controller.Controller
{
	
	public function new()
	{
		super();
		view.category = "stock";		
	}
	
    /**
	 * stock mgmt page
	 */
	@tpl("plugin/pro/offer/stock.mtt")
	public function doDefault(){
		view.vendor = pro.db.CagettePro.getCurrentVendor();
	}
	
}