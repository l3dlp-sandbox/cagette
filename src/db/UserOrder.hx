package db;
import sys.db.Object;
import sys.db.Types;
import Common;

/**
 * a product order 
 */
class UserOrder extends Object
{
	public var id : SId;
	
	@formPopulate("populate") @:relation(userId)
	public var user : User;
	
	//shared order
	@formPopulate("populate") @:relation(userId2)
	public var user2 : SNull<User>;
	
	public var quantity : SFloat;
	
	@formPopulate("populateProducts") @:relation(productId)
	public var product : Product;
	
	//store price (1 unit price without fees) and fees (percentage not amount) rate when the order is done
	public var productPrice : SFloat;
	public var vatRate : SNull<SFloat>; // store vatRate
	
	@:relation(distributionId)
	public var distribution:db.Distribution;
	
	@:relation(basketId)
	public var basket:db.Basket;

	public var date : SDateTime;	
	public var flags : SFlags<OrderFlags>;
	
	public function new() 
	{
		super();
		quantity = 1;
		date = Date.now();
		flags = cast 0;
	}
	
	public function populate() {
		return App.current.user.getGroup().getMembersFormElementData();
	}
	
	override public function toString() {
		if(product==null) return quantity +"x produit inconnu";
		return user.getName()+" : "+tools.FloatTool.clean(quantity) + " x " + product.getName();
	}
	
	public function hasInvertSharedOrder():Bool{
		return flags.has(InvertSharedOrder);
	}
	
	/**
	 * On peut modifier si ça na pas deja été payé + commande encore ouvertes
	 */
	public function canModify():Bool {
	
		var can = false;
		if(this.distribution==null) return false;
		if (this.distribution.orderStartDate == null) {
			can = true;
		}else {
			var n = Date.now().getTime();
			can = n > this.distribution.orderStartDate.getTime() && n < this.distribution.orderEndDate.getTime();
		}
		
		return can;
	}
	
	function check(){
		if(quantity==null) quantity == 1;
	}

	override function update(){
		check();
		super.update();
	}

	override function insert(){
		check();
		super.insert();
	}
}
