package db;
import pro.db.POffer;
import sys.db.Object;
import sys.db.Types;
import Common;
using tools.FloatTool;

/**
 * Product
 */
class Product extends Object
{
	public var id : SId;
	public var name : SString<128>;	
	public var ref : SNull<SString<32>>;	//référence produit
	
	@hideInForms  @:relation(catalogId) public var catalog : db.Catalog;
	
	public var price : SFloat;	
	public var vat : SFloat;			//VAT rate in percent
	
	public var desc : SNull<SText>;
	
	public var unitType : SNull<SEnum<Unit>>; // Kg / L / g / units
	public var qt : SNull<SFloat>;
	
	public var organic : SBool;
	public var variablePrice : Bool; 	//price can vary depending on weighting of the product
	public var multiWeight : Bool;		//product cannot be cumulated in one order record

	//https://docs.google.com/document/d/1IqHN8THT6zbKrLdHDClKZLWgKWeL0xw6cYOiFofw04I/edit
	@hideInForms public var wholesale : Bool;	//this product is a wholesale product (crate,bag,pallet)
	@hideInForms public var retail : Bool;		//this products is a fraction of a wholesale product
	public var bulk : Bool;		//(vrac) warn the customer this product is not packaged
	public var smallQt : SNull<SFloat>; //if bulk is true, a smallQt should be defined

	@hideInForms @:relation(imageId) public var image : SNull<sugoi.db.File>;
	@:relation(txpProductId) public var txpProduct : SNull<db.TxpProduct>; //taxonomy	
	@hideInForms @:relation(pOfferId) public var pOffer : SNull<POffer>;	
	
	public var active : SBool; 	//if false, product disabled, not visible on front office
	
	
	public function new() 
	{
		super();
		organic = false;
		active = true;
		variablePrice = false;
		multiWeight = false;
		wholesale = false;
		retail = false;
		bulk = false;
		vat = 5.5;
		unitType = Unit.Piece;
		qt = 1;
		
	}
	
	/**
	 * Returns product image URL
	 */
	public function getImage() {
		if (imageId == null) {
			if (txpProduct != null){				
				return "/img/taxo/grey/" + txpProduct.subCategory.category.image + ".png";
			}else{
				return "/img/taxo/grey/legumes.png";
			}			
		}else {
			return App.current.view.file(imageId);
		}
	}
	
	public function getName(){	
		if (unitType != null && qt != null && qt != 0){
			return name +" " + qt + " " + Formatting.unit(unitType);
		}else{
			return name;
		}
	}
	
	override function toString() {
		return getName();
	}
	
	/**
	 * get price including margins
	 */
	public function getPrice():Float{
		return price.clean();
	}

	public function getStock():Float{
		var off = this.pOffer;
		if(off!=null){
			if(off.stock==null){
				return null;
			}else{
				var orderedStock = off.orderedStock==null ? 0 : off.orderedStock;
				return off.stock - orderedStock;
			}
		}else{
			return null;
		}

	}
	
	/**
	   get product infos as an anonymous object 
	   @param	CategFromTaxo=false
	   @param	populateCategories=tru
	   @return
	**/
	public function infos(?categFromTaxo=false,?populateCategories=true,?distribution:db.Distribution):ProductInfo {
		var o :ProductInfo = {
			id : id,
			ref : ref,
			name : name,
			image : getImage(),
			price : getPrice(),
			vat : vat,
			vatValue: (vat != 0 && vat != null) ? (  this.price - (this.price / (vat/100+1))  )  : null,
			desc : App.current.view.nl2br(desc),
			categories : null,
			subcategories:null,
			orderable : this.catalog.isUserOrderAvailable(),
			qt:qt,
			unitType:unitType,
			organic:organic,
			variablePrice:variablePrice,
			wholesale:wholesale,
			bulk:bulk,
			active: active,
			distributionId : distribution==null ? null : distribution.id,
			catalogId : catalog.id,
			vendorId : catalog.vendor.id,
			multiWeight : multiWeight,
		}
		
		if(populateCategories){
			//custom categories 
			/*if (this.catalog.group.flags.has(CustomizedCategories)){

				o.categories = Lambda.array(Lambda.map(getCategories(), function(c) return c.id));
				o.subcategories = o.categories;
				
			}else{*/
				//standard categories
				if(txpProduct!=null){
					o.categories = [txpProduct.subCategory.category.id];
					o.subcategories = [txpProduct.subCategory.id];
				}else{
					//get the "Others" category
					var txpOther = db.TxpProduct.manager.get(679,false);
					if(txpOther!=null){
						o.categories = [txpOther.subCategory.category.id];
						o.subcategories = [txpOther.subCategory.id];
					}
				}				
			// }
		}

		App.current.event(ProductInfosEvent(o,distribution));
		
		return o;
	}
	
	/**
	 * general categs
	 */
	public function getFullCategorization(){
		if (txpProduct == null) return [];
		return txpProduct.getFullCategorization();
	}
	
	function check(){		
		//Fix values that will make mysql 5.7 scream
		if(this.vat==null) this.vat=0;
		if(this.name.length>128) this.name = this.name.substr(0,128);
		if(qt==0.0) qt = null;

		//remove strange characters
		for( s in ["",""]){
			if(name!=null) name = StringTools.replace(name,s,"");
			if(desc!=null) desc = StringTools.replace(desc,s,"");
		}
		
		//round like 0.00
		price = Formatting.roundTo(price,2);

		//Only Integers are allowed for consumers and float for coordinators
		if( this.multiWeight ) {
			this.variablePrice = true;
		}
	}

	override public function update(){
		check();
		super.update();
	}

	override public function insert(){
		check();
		super.insert();
	}

	public static function getLabels(){
		var t = sugoi.i18n.Locale.texts;
		return [
			"name" 				=> t._("Product name"),
			"ref" 				=> t._("Product ID"),
			"price" 			=> t._("Price"),
			"desc" 				=> t._("Description"),
			"stock" 			=> t._("Stock"),
			"unitType" 			=> t._("Base unit"),
			"qt" 				=> t._("Quantity"),			
			"hasFloatQt" 		=> t._("Allow fractional quantities"),			
			"active" 			=> t._("Available"),			
			"organic" 			=> t._("Organic agriculture"),			
			"vat" 				=> t._("VAT Rate"),			
			"variablePrice"		=> t._("Variable price based on weight"),			
			"multiWeight" 		=> t._("Multi-weighing"),	
			"bulk" 				=> "Vrac",
			"smallQt"			=> "Petite quantité (pour le vrac)",
		];
	}
	
}

