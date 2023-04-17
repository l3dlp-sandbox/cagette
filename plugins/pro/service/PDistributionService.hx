package pro.service;

/**
 * Service for CPro distributions/deliveries
 * @author fbarbut
 */
class PDistributionService
{
		
	var company : pro.db.CagettePro;

	public function new(company:pro.db.CagettePro) 
	{
		this.company = company;
	}

	/**
	 *  Send an order-by-products report to the farmer
	 */
	public function sendOrdersByProductReport(d:db.Distribution,rc:connector.db.RemoteCatalog){
		
		if(d==null) throw "distribution should not be null";
		if(company.vendor.email==null) return;
		var catalog = rc.getPCatalog();
		try{
			
			var m = new sugoi.mail.Mail();
			m.addRecipient(company.vendor.email , company.vendor.name);
			m.setSender(App.current.getTheme().email.senderEmail, App.current.getTheme().name);
			m.setSubject('[${d.catalog.group.name}] Livraison du ${App.current.view.dDate(d.date)} (${catalog.name})');
		
			var ordersObj = pro.service.ProReportService.getOrdersByProduct({distribution:d});

			var html = App.current.processTemplate("plugin/pro/mail/ordersByProduct.mtt", { 
				distribution:d,
				catalog:catalog,
				orders:ordersObj.orders,
				formatNum:Formatting.formatNum,
				currency:App.current.view.currency,
				dDate:Formatting.dDate,
				hHour:Formatting.hHour,
				group:d.catalog.group
			} );
			
			m.setHtmlBody(html);
			App.sendMail(m);

		}catch(e:Dynamic){
			App.current.logError(e);
		}
	}

	


}