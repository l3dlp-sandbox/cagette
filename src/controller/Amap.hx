package controller;
import service.PaymentService;
import sugoi.form.elements.Html;
import sugoi.form.elements.StringInput;
import sugoi.form.elements.Checkbox;
import db.UserOrder;
import sugoi.form.Form;

class Amap extends Controller
{

	public function new() 
	{
		super();
	}
	
	@tpl("amap/default.mtt")
	function doDefault() {
		var group = app.user.getGroup();
		var contracts = db.Catalog.getActiveContracts(group, true, false).array();
		for ( c in contracts.copy()) {
			if( c.endDate.getTime() < Date.now().getTime() ) contracts.remove(c);
			if( c.vendor.isDisabled()  ) contracts.remove(c);
		}
		view.contracts = contracts;
		view.group = app.user.getGroup();
	}
	
	@tpl("form.mtt")
	function doEdit() {
		
		if (!app.user.isAmapManager()) throw t._("You don't have access to this section");
		
		var group = app.user.getGroup();
		
		var form = form.CagetteForm.fromSpod(group);

		form.removeElementByName("betaFlags");
		// var flags = form.getElement("betaFlags");
		// untyped flags.excluded = [0];

		//remove "membership", "shop mode", "marge a la place des %", "unused" from flags
		var flags = form.getElement("flags");
		untyped flags.excluded = [0,1,2,3,5,9];

		//group mode
		var mode ="Mode Marché";
		var html = new sugoi.form.elements.Html("mode",mode,"Mode de commande");
		html.docLink = "https://wiki.cagette.net/admin:admin_boutique";
		form.addElement(html ,7);
	
		//payment help
		var html = new sugoi.form.elements.Html("payments","<p class='desc'><a href='https://formation.alilo.fr/mod/page/view.php?id=821' target='_blank'><i class=\"icon icon-info\"></i> En savoir plus sur la gestion des paiements</a></p>","");
		form.addElement(html ,9);

		if (form.checkToken()) {
			
			if(form.getValueOf("id") != app.user.getGroup().id) {
				var editedGroup = db.Group.manager.get(form.getValueOf("id"),false);
				throw Error("/amap/edit",'Erreur, vous êtes en train de modifier "${editedGroup.name}" alors que vous êtes connecté à "${app.user.getGroup().name}"');
			}
			
			form.toSpod(group);

			if (group.extUrl != null){
				if ( group.extUrl.indexOf("http://") ==-1 &&  group.extUrl.indexOf("https://") ==-1 ){
					group.extUrl = "http://" + group.extUrl;
				}
			}
			
			group.update();
			throw Ok("/amapadmin", t._("The group has been updated."));
		}
		
		view.form = form;
	}

}