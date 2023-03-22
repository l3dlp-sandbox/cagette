package db;
import haxe.io.Encoding;
import sugoi.form.ListData.FormData;
import sys.db.Object;
import sys.db.Types;

enum CatalogFlags {
	UsersCanOrder;  		//adhérents peuvent saisir eux meme la commande en ligne
	StockManagement; 		//gestion des commandes
}

@:index(startDate,endDate)
class Catalog extends Object
{
	public var id : SId;
	public var name : SString<64>;
	
	//responsable
	@formPopulate("populate") @:relation(userId) public var contact : SNull<User>;
	@formPopulate("populateVendor") @:relation(vendorId) public var vendor : Vendor;
	
	public var startDate:SDateTime;
	public var endDate :SDateTime;
	public var description:SNull<SText>;
	
	@hideInForms @:relation(groupId) public var group:db.Group;
	public var distributorNum:STinyInt;
	public var flags : SFlags<CatalogFlags>;
	
	public function new() 
	{
		super();
		flags = cast 0;
		distributorNum = 0;	
		flags.set(UsersCanOrder);		
	}	
	
	/**
	 * The products can be ordered currently ?
	 * 
	 * @deprecated it depends on distributions
	 */
	@:skip var userOrderAvailableCache:Bool;
	public function isUserOrderAvailable():Bool {
		
		if(userOrderAvailableCache!=null) return userOrderAvailableCache;
		
		var n = Date.now();			
		var d = db.Distribution.manager.count( $orderStartDate <= n && $orderEndDate >= n && $catalogId==this.id);
	
		userOrderAvailableCache = d>0 && isVisibleInShop();

		return userOrderAvailableCache;
		
	}

	/**
	 * The products can be displayed in a shop ?
	 */
	public function isVisibleInShop():Bool {
		
		//yes if the contract is active and the 'UsersCanOrder' flag is checked
		var n = Date.now().getTime();
		return flags.has(UsersCanOrder) && n < this.endDate.getTime() && n > this.startDate.getTime();
	}

	public function isActive():Bool{
		var n = Date.now().getTime();
		return n < this.endDate.getTime() && n > this.startDate.getTime();
	}
	
	/**
	 * is currently open to orders
	 */
	public function hasOpenOrders(){
		var now = Date.now();
		var contractOpen = flags.has(UsersCanOrder) && now.getTime() < this.endDate.getTime() && now.getTime() > this.startDate.getTime();
		var d = db.Distribution.manager.count( $orderStartDate <= now && $orderEndDate > now && $catalogId==this.id);
		return contractOpen && d > 0;
	}
		
	public function hasStockManagement():Bool {
		return flags.has(StockManagement);
	}

	public function check(){

		if( this.description!=null && !UnicodeString.validate( haxe.io.Bytes.ofString(this.description), Encoding.UTF8 )){
			App.current.session.addMessage('La description du catalogue est mal encodée et risque de poser des problèmes d\'affichage.',true);
		}

		for( p in getProducts(false)){
			if( p.ref!=null && !UnicodeString.validate( haxe.io.Bytes.ofString(p.ref), Encoding.UTF8 )){
				App.current.session.addMessage('La référence du produit "${p.ref}" est mal encodé et risque de poser des problèmes d\'affichage.',true);
			}

			if( p.name!=null && !UnicodeString.validate( haxe.io.Bytes.ofString(p.name), Encoding.UTF8 )){
				App.current.session.addMessage('Le nom du produit "${p.name}" est mal encodé et risque de poser des problèmes d\'affichage.',true);
			}
			if( p.desc!=null && !UnicodeString.validate( haxe.io.Bytes.ofString(p.desc), Encoding.UTF8 )){
				App.current.session.addMessage('La description du produit "${p.name}" est mal encodée et risque de poser des problèmes d\'affichage.',true);
			}
		}
	}
	
	/**
	 * Get active catalogs
	 * @param	large = false	Si true, montre les contrats terminés depuis moins d'un mois
	 * @param	lock = false
	 */
	public static function getActiveContracts(group:db.Group,?large = false, ?lock = false):List<db.Catalog> {
		var now = Date.now();
		var end = Date.now();	
		if (large) {
			end = DateTools.delta(end , -1000.0 * 60 * 60 * 24 * 30);
			return db.Catalog.manager.search($group == group && $endDate > end,{orderBy:-vendorId}, lock);	
		}else {
			return db.Catalog.manager.search($group == group && $endDate > now && $startDate < now,{orderBy:-vendorId}, lock);	
		}
	}
	
	/**
	 * get products in this contract
	 * @param	onlyActive = true
	 */
	public function getProducts(?onlyActive = true):List<Product> {
		if (onlyActive) {
			return Product.manager.search($catalog==this && $active==true,{orderBy:name},false);	
		}else {
			return Product.manager.search($catalog==this,{orderBy:name},false);	
		}
	}
	
	/**
	 * get a few products to display
	 * @param	limit = 6
	 */
	public function getProductsPreview(?limit = 6){
		return Product.manager.search($catalog==this && $active==true,{limit:limit,orderBy:-id},false);	
	}
	
		
	/**
	 *  get users who have orders in this contract ( including user2 )
	 *  @return Array<db.User>
	 */
	public function getUsers():Array<db.User> {
		var pids = getProducts().map(function(x) return x.id);
		var ucs = db.UserOrder.manager.search($productId in pids, false);
		var ucs2 = [];
		for( uc in ucs) {
			ucs2.push(uc.user);
			if(uc.user2!=null) ucs2.push(uc.user2);
		}
		
		//comme un user peut avoir plusieurs produits au sein d'un contrat, il faut dédupliquer cette liste
		var out = new Map<Int,db.User>();
		for (u in ucs2) {
			out.set(u.id, u);
		}
		
		return Lambda.array(out);
	}
	
	/**
	 * Get all orders of this contract
	 * @param	d	A delivery is needed for varying orders contract
	 * @return
	 */
	public function getOrders( distribution : db.Distribution ) : Array<db.UserOrder> {

		if ( distribution == null ) throw "This type of contract must have a delivery";
		
		//get product ids, some of the products may have been disabled but we keep the order
		var productIds = getProducts(false).map( function( product ) return product.id );

		var orders = new List<db.UserOrder>();
		orders = db.UserOrder.manager.search( ( $productId in productIds ) && $distribution == distribution, {orderBy:userId}, false );	
	
		return Lambda.array(orders);
	}

	/**
	 * Get orders for a user in a distrib.
	 */
	public function getUserOrders(u:db.User,d:db.Distribution,?includeUser2=true):Array<db.UserOrder> {
		if(includeUser2){
			return db.UserOrder.manager.search( $distribution==d && ($user==u || $user2==u ), false).array();
		}else{
			return db.UserOrder.manager.search( $distribution==d && ($user==u), false).array();
		}		
	}

	public function getDistribs(excludeOld = true,?limit=999):List<Distribution> {
		if (excludeOld) {
			//still include deliveries which just expired in last 24h
			return Distribution.manager.search($end > DateTools.delta(Date.now(), -1000.0 * 60 * 60 * 24) && $catalog == this, { orderBy:date,limit:limit },false);
		}else{
			return Distribution.manager.search( $catalog == this, { orderBy:date,limit:limit } ,false);
		}
	}

	public function getVisibleDocuments( user : db.User ) : List<sugoi.db.EntityFile> {

		if ( user != null && user.isMemberOf(group) ) {

			return sugoi.db.EntityFile.manager.search( $entityType == 'catalog' && $entityId == this.id && $documentType == 'document' && $data != 'subscribers', false);
		}
		
		return sugoi.db.EntityFile.manager.search( $entityType == 'catalog' && $entityId == this.id && $documentType == 'document' && $data == 'public', false);

	}

	public function isDemoCatalog():Bool{
		return this.vendor.email == 'jean@cagette.net' || this.vendor.email == 'galinette@cagette.net';
	}
	
	override function toString() {
		return name+" du "+this.startDate.toString().substr(0,10)+" au "+this.endDate.toString().substr(0,10);
	}
	
	public function populate() {
		return App.current.user.getGroup().getMembersFormElementData();
	}

	override public function update(){
		startDate 	= new Date( startDate.getFullYear(), startDate.getMonth(), startDate.getDate()	, 0, 0, 0 );
		endDate 	= new Date( endDate.getFullYear(),   endDate.getMonth(),   endDate.getDate()	, 23, 59, 59 );
		super.update();
	}

	override public function insert(){
		startDate 	= new Date( startDate.getFullYear(), startDate.getMonth(), startDate.getDate()	, 0, 0, 0 );
		endDate 	= new Date( endDate.getFullYear(),   endDate.getMonth(),   endDate.getDate()	, 23, 59, 59 );
		super.insert();
	}
	
	/**
	 * get a vendor list as form data
	 * @return
	 */
	public function populateVendor():FormData<Int>{
		if(this.group==null) return [];
		var vendors = this.group.getVendors();
		var out = [];
		for (v in vendors) {
			out.push({label:v.name, value:v.id });
		}
		return out;
	}
	
	public static function getLabels() {

		var t = sugoi.i18n.Locale.texts;
	
		return [
			"name" 				=> t._("Catalog name"),
			"startDate" 		=> t._("Start date"),
			"endDate" 			=> t._("End date"),
			"description" 		=> t._("Description"),
			"distributorNum" 	=> t._("Number of required volunteers during a distribution"),
			"flags" 			=> t._("Options"),
			"contact" 			=> t._("Contact"),
			"vendor" 			=> t._("Farmer"),
			"hasPayements" 					=> "Gestion des paiements",
		];
	}
	
	
}