package controller;
import service.ProductService;
import sys.db.RecordInfos;
import neko.Utf8;
import haxe.io.Encoding;
import haxe.io.Bytes;
import sugoi.form.Form;
import Common;
import sugoi.form.ListData.FormData;
import sugoi.form.elements.FloatInput;
import sugoi.form.elements.FloatSelect;
import sugoi.form.elements.IntSelect;
using Std;

class Product extends Controller
{
	public function new()
	{
		super();
		view.nav = ["contractadmin","products"];
	}
	
	@tpl('form.mtt')
	function doEdit(product:db.Product) {
		
		if (!app.user.canManageContract(product.catalog)) throw t._("Forbidden access");
		
		var f = ProductService.getForm(product);		
		
		if (f.isValid()) {

			f.toSpod(product);

			try{
				ProductService.check(product);
			}catch(e:tink.core.Error){
				throw Error(sugoi.Web.getURI(),e.message);
			}

			app.event(EditProduct(product));
			product.update();
			throw Ok('/contractAdmin/products/'+product.catalog.id, t._("The product has been updated"));
		} else {
			app.event(PreEditProduct(product));
		}
		
		view.form = f;
		view.title = t._("Modify a product");
	}
	
	@tpl("form.mtt")
	public function doInsert(contract:db.Catalog ) {
		
		if (!app.user.isContractManager(contract)) throw Error("/", t._("Forbidden action")); 
		
		var product = new db.Product();
		var f = ProductService.getForm(null,contract);
	
		if (f.isValid()) {

			f.toSpod(product);
			product.catalog = contract;

			try{
				ProductService.check(product);
			}catch(e:tink.core.Error){
				throw Error(sugoi.Web.getURI(),e.message);
			}
			
			app.event(NewProduct(product));
			product.insert();
			throw Ok('/contractAdmin/products/'+product.catalog.id, t._("The product has been saved"));
		}
		else {

			app.event(PreNewProduct(contract));
		}
		
		view.form = f;
		view.title = t._("Key-in a new product");
	}
	
	public function doDelete(p:db.Product) {
		
		if (!app.user.canManageContract(p.catalog)) throw t._("Forbidden access");
		
		if (checkToken()) {
			
			app.event(DeleteProduct(p));
			
			var orders = db.UserOrder.manager.search($productId == p.id, false);
			if (orders.length > 0) {
				throw Error("/contractAdmin", t._("Not possible to delete this product because some orders are referencing it"));
			}
			var cid = p.catalog.id;
			p.lock();
			p.delete();
			
			throw Ok("/contractAdmin/products/"+cid, t._("Product deleted"));
		}
		throw Error("/contractAdmin", t._("Token error"));
	}
	
	public function doExport(c:db.Catalog){

		var data = new Array<Dynamic>();
		for (p in c.getProducts(false)) {
			data.push({
				"id": p.id,
				"name": p.name,
				"ref": p.ref,
				"price": p.price,
				"vat": p.vat,
				"catalogId": c.id,
				"vendorId": c.vendor.id,
				"unit": p.unitType,
				"quantity": p.qt,
				"active": p.active,
				"image": "https://"+App.config.HOST+p.getImage(),
			});
		}

		sugoi.tools.Csv.printCsvDataFromObjects(data, [
			"id", "name", "ref", "price", "vat", "catalogId", "vendorId", "unit", "quantity", "active", "image"], "Export-produits-" + c.name + "-Cagette");
		return;
		
	}
	
	
	
}