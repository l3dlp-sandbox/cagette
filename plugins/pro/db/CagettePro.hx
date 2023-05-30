package pro.db;
import Common;
import sys.db.Types;

enum CagetteProOffer {
	Discovery;	//0
	Member;		//1
	Pro;		//2
	Training;	//3
	Marketplace;//4
}

/**
 * Vendor Account
 */
class CagettePro extends sys.db.Object
{
	public var id : SId;
	@hideInForms @:relation(vendorId) public var vendor : db.Vendor;
	@hideInForms @:relation(demoCatalogId) public var demoCatalog : SNull<pro.db.PCatalog>;//catalog used for public page
	@hideInForms public var vatRates : SNull<SSmallText>;	
	@hideInForms public var network:SBool;	//enable network management features
	@hideInForms public var captiveGroups:SBool;	//the groups are a captive network
	@hideInForms public var networkGroupIds:SNull<SString<512>>; //network groups, ints separated by comas
	@hideInForms public var cdate:SNull<SDateTime>; //date when vendor became cpro
	@hideInForms public var offer:SEnum<CagetteProOffer>;
	
	public function new(){
		super();
		setVatRates([
			{label:"Non assujeti à TVA", value:0},
			{label:"TVA alimentaire 5,5%",value:5.5},
			{label:"TVA 10%",value:10},			
			{label:"TVA 20%",value:20},						
		]);
		offer = Discovery;
		network = false;		
		cdate = Date.now();
	}

	public static function getFromVendor(vendor:db.Vendor){
		return manager.select($vendor==vendor,false);
	}
	
	public function getProducts(){
		return pro.db.PProduct.manager.search($company == this,{orderBy:name},false).array();
	}
	
	public function getCatalogs(){
		return pro.db.PCatalog.manager.search($company == this, {orderBy:name}, false);
	}


	public function getActiveCatalogs(){
		var now = Date.now();
		return pro.db.PCatalog.manager.search($company == this && $startDate < now && $endDate > now, {orderBy:name}, false);
	}

	public function getActiveVisibleCatalogs(){
		var now = Date.now();
		return pro.db.PCatalog.manager.search($company == this && $visible==true && $startDate < now && $endDate > now, {orderBy:name}, false);
	}
	
	public function getOffers(){
		var out = [];
		for ( p in getProducts()){
			for ( o in p.getOffers()){
				out.push(o)	;
			}
			
		}
		return out;
	}

	public function setVatRates(rates:Array<{value:Float,label:String}>){
		vatRates = haxe.Json.stringify(rates);
	}

	public function getVatRates():Array<{value:Float,label:String}>{
		try{
			return haxe.Json.parse(vatRates);
		}catch(e:Dynamic){
			var rates = [{label:"TVA alimentaire 5,5%",value:5.5},{label:"TVA 20%",value:20},{label:"Non assujeti à TVA", value:0}];
			this.lock();
			setVatRates(rates);
			this.update();
			return rates;
		}
	}
	
	/**
	 *  Get users who have access to this company (cpro account)
	 */
	public function getUsers():Array<db.User>{
		return pro.db.PUserCompany.getUsers(this).array().map(x -> x.user);
	}

	public function getUserCompany():Array<pro.db.PUserCompany>{
		return pro.db.PUserCompany.getUsers(this).array();
	}

	public function getMainContact():db.User{
		var ucs = getUserCompany();
		var uc = ucs.filter(x -> x.legalRepresentative)[0];
		if(uc==null){
			return ucs[0].user;
		}else{
			return uc.user;
		}
	}

	public function getSalesContact():db.User{
		var ucs = getUserCompany();
		if (ucs.length==0) return null;
		var uc = ucs.filter(x -> x.salesRepresentative)[0];
		if(uc==null){
			return ucs[0].user;
		}else{
			return uc.user;
		}
	}

	/**
	 * Check if a new reference is not already taken in this company's products
	 * @param	ref
	 * @deprecated
	 */
	public function refExists(ref:String,?excludeProduct:pro.db.PProduct,?excludeOffer:pro.db.POffer):Bool{
		
		var prods = pro.db.PProduct.manager.search($ref == ref && $company == this, false);
		var pids = Lambda.map(getProducts(), function(x) return x.id);
		var offers = pro.db.POffer.manager.search($ref == ref && $productId in pids, false);
		
		//exclusions
		if (excludeProduct != null){
			for (p in Lambda.array(prods)){
				if ( p.id ==  excludeProduct.id ) prods.remove(p);
			}
		}
		
		if (excludeOffer != null){
			for (o in Lambda.array(offers)){
				if ( o.id ==  excludeOffer.id ) offers.remove(o);
			}
		}
		
		if ( prods.length > 0 || offers.length > 0){
			return true;
		}else{
			return false;
		}
		
	}
	
	public function getClients():Array<db.Group>{

		var remoteCatalogs = connector.db.RemoteCatalog.manager.search($remoteCatalogId in Lambda.map(this.getCatalogs(), function(x) return x.id), false); 
		var clients = [];
		for ( rc in Lambda.array(remoteCatalogs)){
			var contract = rc.getContract();
			if (contract != null) {
				clients.push(contract.group);
			}
		}
		//sort by group name
		var clients = Lambda.array(clients);
		clients = tools.ObjectListTool.deduplicate(clients);

		clients.sort(function(b, a) {
			return (a.name.toUpperCase() < b.name.toUpperCase())?1:-1;
		});

		return clients;
	}

	/**
		can this user acces this vendor/cpro account ?
	**/
	public static function canLogIn(user:db.User,company:pro.db.CagettePro){
		if(company==null) return false;
		if(user.isAdmin()) return true;
		
		if(company!=null){
			return pro.db.PUserCompany.manager.select($user==user && $company==company,false)!=null;
		}else{
			return false;
		}
	}

	public function getGroups(){
		var remoteCatalogs = connector.db.RemoteCatalog.manager.search($remoteCatalogId in Lambda.map(this.getCatalogs(), function(x) return x.id), false); 
		var groups = [];
		for ( rc in Lambda.array(remoteCatalogs)){
			var contract = rc.getContract();
			if(contract==null || contract.group==null) continue;
			groups.push(contract.group);			
		}
		return tools.ObjectListTool.deduplicate(groups);
	}

	public function setNetworkGroupIds(_groupIds:Array<Int>){
		this.lock();
		this.networkGroupIds = _groupIds.join(",");
		this.update();
	}

	public function getNetworkGroupIds():Array<Int>{
		if(this.networkGroupIds==null) return [];
		return this.networkGroupIds.split(",").map(Std.parseInt);
	}

	public function getNetworkGroups():Array<db.Group>{
		return getNetworkGroupIds().map(function(id) return db.Group.manager.get(id)).filter( function(g) return g!=null );
	}

	public function infos(): CagetteProInfo {
		return vendor.getInfos();
	}

	
	public static function getLabels(){
		var t = sugoi.i18n.Locale.texts;
		return [
			"name" 		=> /*t._("Company name")*/"Nom de votre structure",
			"email" 	=> t._("Email"),
			"phone"		=> t._("Phone"),
			"address1" 	=> t._("Address 1"),			
			"address2"	=> t._("Address 2"),			
			"zipCode" 	=> t._("Zip code"),			
			"city" 		=> t._("City"),			
			"desc" 		=> t._("Description"),			
			"linkText" 	=> /*t._("Website Label")*/"Nom du site Web",			
			"linkUrl" 	=> /*t._("Website URL")*/"URL du site web",			
			"freeCpro" 	=> "Accès gratuit a l'espace producteur (stagiaire formation)",		
		];
	}
}