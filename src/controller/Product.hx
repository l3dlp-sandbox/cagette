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