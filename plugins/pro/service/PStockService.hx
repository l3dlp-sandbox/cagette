package pro.service;
using tools.ObjectListTool;

/**
	Stock Management in CPRO.

	A central stock is managed in CPRO.
	Each POffer can have a stock : offer.stock is the real physical stock at the farm.
	
	Updating the central stock updates the stock property in groups.  
	This property is slightly different : it's the stock available to orders.
	updateStockInGroups() do this update : availableStock = centralStock - undeliveredOrders

	When someone buys a product, a StockEvent is triggered, and updates the central stock.
	This also synchs the availableStock in groups.

	When a distribution ends, the central stock is definitely decreased.
	( MinutelyCron in ProPlugin )

**/
class PStockService{

	var cpro:pro.db.CagettePro;

	public function new(cpro:pro.db.CagettePro){
		this.cpro = cpro;
	}

	/**
		update available stock in groups.		
	**/
	/*var remoteProductsList:Array<db.Product>;

    public function updateStockInGroups(offer:pro.db.POffer){

		//cached list is not set, populate it
		if(remoteProductsList==null){
			remoteProductsList=[];
			//get all linkages, to cover also products which are not in catalogs anymore
			var catalogIds:Array<Int> = cpro.getActiveCatalogs().getIds();
			for ( rc in connector.db.RemoteCatalog.manager.search($remoteCatalogId in catalogIds, false)){
				
				var contract = rc.getContract();
				if (contract == null) continue;
				contract.getProducts(false).map( p -> remoteProductsList.push(p) );
			}		
		}
		
			
		//manage stocks for ALL products, including disabled ones			
		for( product in remoteProductsList.filter(x -> return x.ref==offer.ref)){
			product.lock();
			product.stock = getStocks(offer).availableStock;
			product.update();
		}
	}*/

	public static function getStocks(offer:pro.db.POffer):{centralStock:Float,undeliveredOrders:Float,availableStock:Float}{
		var out = {centralStock:null,undeliveredOrders:null,availableStock:null};
		if (offer.stock == null){
			return out;
		}else{
			var noNegative = function(f:Float) return (f<0) ? 0 : f;

			out.centralStock = noNegative(offer.stock);
			out.undeliveredOrders = noNegative(offer.countCurrentUndeliveredOrders());
			out.availableStock = noNegative(out.centralStock - out.undeliveredOrders);

			return out;
		}
	}

	/**
		update stocks in groups when the stock of a product is modified
	
    public static function updateStockInGroupsByProduct(product:pro.db.PProduct){
		
		var undeliveredOrders = product.countCurrentUndeliveredOrders();
		var baseStock = Math.floor(product.stock - undeliveredOrders);

		//get the amount of stock to dispatch among offers
		var offers = new Map<String,Int>();
		for( off in product.getOffers()) offers[off.ref] = Math.floor(off.quantity);
		var dispatch = tools.StockTool.dispatchOffers(baseStock,offers);
		
		//get all contracts involving this product
		for( offer in product.getOffers()){
			var catalogs = Lambda.map(offer.getCatalogOffers(), function(x) return x.catalog).deduplicate();
			for ( c in catalogs){			
				for ( rc in connector.db.RemoteCatalog.getFromPCatalog(c) ){
					
					var contract = rc.getContract();
					if (contract == null) continue;
					
					//manage stocks for ALL products, including disabled ones
					for ( p in contract.getProducts(false)){
						if (p.ref == offer.ref){						
							p.lock();
							if (product.stock == null){
								p.stock = null;
							}else{
								p.stock = dispatch[offer.ref];
								if (p.stock < 0) p.stock = 0;
							}
							p.update();
							break;
						}
						
					}
				}
			}
		}
		
	}**/

}