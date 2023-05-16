package pro.controller;
import pro.service.PStockService;
import sugoi.form.Form;
import Common;
using Std;

class Stock extends controller.Controller
{
	
	var company : pro.db.CagettePro;
	var vendor : db.Vendor;
	
	public function new(company:pro.db.CagettePro) 
	{
		super();
		view.company = this.company = company;
		view.vendor = this.vendor = company.vendor;
		view.category = "stock";		
	}
	
    /**
	 * stock mgmt page
	 */
	@tpl("plugin/pro/offer/stock.mtt")
	public function doDefault(){
	}
	
}