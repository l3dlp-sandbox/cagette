package controller;
import pro.db.PCatalog;
import Common;
import db.Catalog;
import db.MultiDistrib;
import db.UserOrder;
import db.VolunteerRole;
import form.CagetteDatePicker;
import form.CagetteForm;
import plugin.Tutorial;
import service.CatalogService;
import service.OrderService;
import service.VendorService;
import sugoi.Web;
import sugoi.form.Form;
import sugoi.form.elements.Checkbox;
import sugoi.form.elements.Input;
import sugoi.form.elements.IntInput;
import sugoi.form.elements.Selectbox;
import tink.core.Error;
import tools.DateTool;

class Contract extends Controller
{

	public function new() 
	{
		super();
		view.nav = ["contractadmin"];
	}
	
	//retrocompat
	@logged
	public function doDefault(){
		throw Redirect("/history");
	}

	/**
		view catalog infos for shop mode groups
	**/
	@tpl("contract/view.mtt")
	public function doView( catalog : db.Catalog ) {

		view.category = 'market';
		view.catalog = catalog;
	
		view.visibleDocuments = catalog.getVisibleDocuments( app.user );
	}
	
	/**
		Search a vendor
	**/
	@logged @tpl("contractadmin/searchVendor.mtt")
	function doSearchVendor(){
		if (!app.user.canManageAllContracts()) throw Error('/', t._("Forbidden action"));
		

		var f = new sugoi.form.Form("defVendor");
		f.submitButtonLabel = "Rechercher";
		f.addElement(new sugoi.form.elements.StringInput("name",t._("Vendor or farm name"),null,false));
		// f.addElement(new sugoi.form.elements.StringInput("email","Email du producteur",null,false));
		var place = app.getCurrentGroup().getMainPlace();
		if(place!=null){
			f.addElement(new sugoi.form.elements.Checkbox('geoloc','A proximité de "${place.name}" ',true,false));
		}

		//profession
		var professions = service.VendorService.getVendorProfessions();
		var el = new sugoi.form.elements.IntSelect('profession',t._("Profession"),sugoi.form.ListData.fromSpod(professions),null,false);
		el.nullMessage = "Toutes";
		f.addElement(el);

		// populate form from request
		f.isValid();

		// if(f.getValueOf('name')==null && (f.getElement("geoloc")==null || f.getValueOf("geoloc")==false) && f.getValueOf("profession")==null){
		// 	throw Error('/contract/searchVendor/','Vous devez au moins rechercher par nom ou par profession');
		// }
		
		//look for identical names
		var vendors = service.VendorService.findVendors( {
			name:f.getValueOf('name'),
			geoloc : f.getElement("geoloc")==null ? false : f.getValueOf("geoloc"),
			profession:f.getValueOf("profession"),
			fromLng: if(place!=null) place.lng else null, 
			fromLat: if(place!=null) place.lat else null,				
		});

		view.vendors = vendors;
		view.name = f.getValueOf('name');	
		view.form = f;
	}

	/**
	  invite a vendor
	*/
	@logged @tpl("contractadmin/inviteVendor.mtt")
	public function doInviteVendor() {
		if (App.current.getSettings().noVendorSignup==true) {
			throw Redirect("/");
		}
		view.groupId = app.user.getGroup().id;
		// if(vendor!=null) view.vendor = vendor;
	}

	/**
	* Edit var orders for shop mode without payments.
	*/
	@logged @tpl("contract/editVarOrders.mtt")
	function doEditVarOrders(distrib:db.MultiDistrib) {
		var basket = distrib.getUserBasket(app.user);
		if ( app.user.getGroup().isDispatch() || basket.hasOnlinePayment()) {
			//when this basket has been payed online, the user cannot modify his/her order
			throw Redirect("/");
		}
		
		// cannot edit order if date is in the past
		if (Date.now().getTime() > distrib.getDate().getTime()) {
			
			var msg = t._("This delivery has already taken place, you can no longer modify the order.");
			if (app.user.isContractManager()) msg += t._("<br/>As the manager of the catalog you can modify the order from this page: <a href='/contractAdmin'>Catalog management</a>");
			
			throw Error("/account", msg);
		}
		
		var orders = basket.getOrders();
		view.orders = service.OrderService.prepare(orders);
		view.date = distrib.getDate();
		view.md = distrib;
		view.basket = basket;
	}

	function doSearchCatalog(cid:Int){
		var pCatalog = PCatalog.manager.get(cid,false);
		if(pCatalog==null) throw Error('/contractAdmin','Ce catalogue n\'existe pas');
		throw Redirect(pCatalog.getURL());
	}
}
