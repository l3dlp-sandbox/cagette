package db;
import Common;
import pro.db.VendorStats;
import sugoi.form.validators.EmailValidator;
import sys.db.Object;
import sys.db.Types;

enum DisabledReason{
	IncompleteLegalInfos; 	//0 : incomplete legal infos
	NotCompliantWithPolicy; //1 : not compliant with policy (charte des producteurs)
	Banned; 				//2 : banned by network administrateurs
	TurnoverLimitReached; 	//3 : turnover limit reached
	MarketplaceNotActivated;//4 : a new marketplace vendor who has not yet activated his subscription
	MarketplaceDisabled; 	//5 : a marketplace vendor who did not pay, who removed his payment method, etc
	DisabledInvited;		//6 : invited,free,cproinvited are now disabled
}

/**
	infos from https://entreprise.data.gouv.fr/api/sirene/v3/etablissements/
**/
typedef SiretInfos = {
	date_creation:String,
	activite_principale:String,//code NAF
	geo_adresse:String,//adresse postale complete
	libelle_commune:String,
	libelle_voie:String,
	code_postal:String,
	type_voie:String,
	latitude:Float,
	longitude:Float,
	unite_legale:{
		categorie_juridique:Int,//code juridique de niveau III
	}
}

enum VendorBetaFlags{
	__Cagette2;		//BETA Cagette 2.0 @deprecated
	CanOpenStripeAccount; //Can Open Stripe Account
}

/**
 * Vendor (farmer/producer/vendor)
 */
@:index(stripeCustomerId)
@:index(companyNumber,companySubNumber,country,unique)
class Vendor extends Object
{
	public var id : SId;
	public var name : SString<128>;	//Business name 
	public var peopleName : SNull<SString<128>>; //Business owner(s) name
	
	//public var legalStatus : SNull<SEnum<LegalStatus>>;
	@hideInForms public var profession : SNull<SInt>;
	@hideInForms public var production2 : SNull<SInt>;
	@hideInForms public var production3 : SNull<SInt>;

	public var email:SNull<SString<128>>;
	public var phone:SNull<SString<19>>;
		
	public var address1:SNull<SString<64>>;
	public var address2:SNull<SString<64>>;
	public var zipCode:SString<32>;
	public var city:SString<25>;
	public var country:SNull<SString<64>>;
	
	public var desc : SNull<SText>;
	@hideInForms public var cdate : SNull<SDateTime>; // date de création
	@hideInForms public var freemiumResetDate : SDateTime;
	@hideInForms public var turnoverLimitReachedDistribsWhiteList : SSmallText;

	//legal infos
	@hideInForms public var companyNumber : SNull<SString<128>>; //SIRET
	@hideInForms public var companySubNumber : SNull<STinyInt>; 
	@hideInForms public var vatNumber : SNull<SString<128>>; //VAT number
	@hideInForms public var legalStatus : SNull<SInt>; //statut juridique
	@hideInForms public var companyCapital : SNull<SInt>; //capital social
	@hideInForms public var activityCode:SNull<SString<8>>;//code NAF (NAFRev2)
	
	@hideInForms public var tosVersion: SNull<SInt>; //CGV version checked
	
	public var linkText:SNull<SString<256>>;
	public var linkUrl:SNull<SString<256>>;

	@hideInForms public var directory 	: SBool;
	@hideInForms public var longDesc 	: SNull<SText>;
	@hideInForms public var offCagette 	: SNull<SText>;
	
	@hideInForms @:relation(imageId) 	public var image : SNull<sugoi.db.File>;
	@hideInForms @:relation(customizedTermsOfSaleFileId) 	public var customizedTermsOfSaleFile : SNull<sugoi.db.File>;
	
	@hideInForms public var status : SNull<SString<32>>; //temporaire , pour le dédoublonnage
	@hideInForms public var disabled : SNull<SEnum<DisabledReason>>; // vendor is disabled
	
	@hideInForms public var lat:SNull<SFloat>;
	@hideInForms public var lng:SNull<SFloat>;

	@hideInForms public var betaFlags:SFlags<VendorBetaFlags>;

	@hideInForms public var stripeCustomerId:SNull<SString<255>>;
	@hideInForms public var stripeAccountId:SNull<SString<255>>;

	public function new() 
	{
		super();
		directory = true;
		cdate = Date.now();
		freemiumResetDate = Date.now();
	}

	override function toString() {
		return name;
	}

	public function getContracts(){
		return db.Catalog.manager.search($vendor == this,{orderBy:-startDate}, false);
	}

	public function getActiveContracts(){
		var now = Date.now();
		return db.Catalog.manager.search($vendor == this && $startDate < now && $endDate > now ,{orderBy:-startDate}, false);
	}

	public function getImage():String{
		if (imageId == null) {
			return "/img/vendor.png";
		}else {
			return App.current.view.file(imageId);
		}
	}

	public function getImages(){

		var out = {
			logo:null,
			portrait:null,
			banner:null,
			farm1:null,				
			farm2:null,				
			farm3:null,				
			farm4:null,				
		};

		var files = sugoi.db.EntityFile.getByEntity("vendor",this.id);
		for( f in files ){
			switch(f.documentType){				
				case "logo" 	: out.logo 		= f.getFileId();
				case "portrait" : out.portrait 	= f.getFileId();
				case "banner" 	: out.banner 	= f.getFileId();
				case "farm1" 	: out.farm1 	= f.getFileId();
				case "farm2" 	: out.farm2 	= f.getFileId();
				case "farm3" 	: out.farm3 	= f.getFileId();
				case "farm4" 	: out.farm4 	= f.getFileId();
			}
		}

		if(out.logo==null) out.logo = this.imageId;

		return out;
	}

	public function getInfos(?withImages=false):VendorInfos{

		var file = function(fId: Int){
			return if(fId==null)  null else App.current.view.file(fId);
		}
		var vendor = this;
		var out : VendorInfos = {
			id : id,
			name : vendor.name,
			profession:null,
			email:vendor.email,
			offCagette:offCagette,
			image : file(vendor.imageId),
			images : cast {},
			address1: vendor.address1,
			address2: vendor.address2,
			zipCode : vendor.zipCode,
			city : vendor.city,
			linkText:vendor.linkText,
			linkUrl:vendor.linkUrl,
			desc:vendor.desc,
			longDesc:vendor.longDesc,
			vendorPage: vendor.getLink(),
			companyNumber: vendor.companyNumber,
			legalStatus: vendor.getLegalStatus(true)
		};

		if(this.profession!=null){
			out.profession = getProfession();
		}

		if(withImages){
			var images = getImages();
			out.images.logo = file(images.logo);
			out.images.portrait = file(images.portrait);
			out.images.banner = file(images.banner);
			out.images.farm1 = file(images.farm1);
			out.images.farm2 = file(images.farm2);
			out.images.farm3 = file(images.farm3);
			out.images.farm4 = file(images.farm4);
		}
		return out;
	}

	public function getProfession():String {
		if(this.profession==null) return null;
		var p = service.VendorService.getVendorProfessions().find(x -> x.id==this.profession);
		if(p==null) throw new tink.core.Error("Vendor #"+this.id+" has invalid profession code : "+this.profession);
		return p.name;
	}

	public function getProfessions():Array<String>{
		var out = [];
		var profs = service.VendorService.getVendorProfessions();
		if(this.profession!=null) out.push(profs.find(x -> x.id==this.profession).name);
		if(this.production2!=null) out.push(profs.find(x -> x.id==this.production2).name);
		if(this.production3!=null) out.push(profs.find(x -> x.id==this.production3).name);
		return out;
	}

	public function getGroups():Array<db.Group>{
		var contracts = getActiveContracts();
		var groups = Lambda.map(contracts,function(c) return c.group);
		return tools.ObjectListTool.deduplicate(groups);
	}

	public static function get(email:String,status:String){
		return manager.select($email==email && $status==status,false);
	}

	#if plugins
	public function getCpro(){
		return pro.db.CagettePro.getFromVendor(this);
	}
	#end	
	
	public static function getLabels(){
		var t = sugoi.i18n.Locale.texts;
		return [
			"name" 				=> "Nom de votre ferme/entreprise",
			"peopleName" 		=> "Nom de l'exploitant(e)",	
			"desc" 				=> t._("Description"),
			"email" 			=> t._("Email pro"),
			"legalStatus"		=> t._("Legal status"),
			"phone" 			=> t._("Phone"),
			"address1" 			=> t._("Address 1"),
			"address2" 			=> t._("Address 2"),
			"zipCode" 			=> t._("Zip code"),
			"city" 				=> t._("City"),			
			"linkText" 			=> t._("Link text"),			
			"linkUrl" 			=> t._("Link URL"),			
			"companyNumber" 	=> "Numéro SIRET (14 chiffres)",	
		];
	}

	/**
		Public vendor page link
	**/
	public function getLink():String{		
		var permalink = sugoi.db.Permalink.getByEntity(this.id,"vendor");
		return permalink==null ? "/vendor/"+id : "/"+permalink.link;		
	}

	/**
		cpro URL
	**/
	public function getURL(){
		return "/pro/"+this.id;
	}

	public function getAddress(){
		var str = new StringBuf();
		if(address1!=null) str.add(address1);
		if(address2!=null) str.add(", "+address2);
		if(zipCode!=null) str.add(", "+zipCode);
		if(city!=null) str.add(" "+city);
		if(country!=null) str.add(", "+country);
		return str.toString();
	}

	public function isDisabled(){
		if(email=="galinette@cagette.net" || email=="jean@cagette.net") return false;
		return disabled!=null;
	}

	public function getDisabledReason():Null<String>{
		return switch(this.disabled){
			case null : null;
			case DisabledReason.IncompleteLegalInfos : "Informations légales incomplètes. Complétez vos informations légales pour débloquer le compte. (SIRET,capital social,numéro de TVA)";
			case DisabledReason.NotCompliantWithPolicy : "Producteur incompatible avec la charte producteur de Cagette.net";
			case DisabledReason.Banned : "Producteur bloqué par les administrateurs";
			case DisabledReason.TurnoverLimitReached : "Ce producteur a atteint sa limite de chiffre d'affaires annuel";
			case DisabledReason.MarketplaceDisabled : "Ce producteur est en défaut de paiement";
			case DisabledReason.MarketplaceNotActivated : "Ce producteur n'a pas encore activé son compte";
			case DisabledReason.DisabledInvited : "Les producteurs invités ne sont plus autorisés et doivent <a href='https://www.cagette.net/producteurs' target='_blank'>ouvrir un espace Producteur</a>";
		};
	}

	/**
		like "GAEC au capital de 5000€"
	**/
	public function getLegalStatus(?full=true){

		var str = "";

		//legal status
		for ( c in service.VendorService.getLegalStatuses()){
			if(Std.string(c.id) == Std.string(this.legalStatus)) {
				str += c.name;
				break;
			}
		}
		if(str=="") str = "Statut juridique inconnu";

		if(full){
			//capital
			if(this.companyCapital!=null) str += " au capital de "+companyCapital+" €";

			//VAT
			if(vatNumber!=null){
				str += ". Numéro de TVA : "+vatNumber;
			}else{
				str += ". Entreprise non assujetie à TVA";
			}
		}
		
		return str;
	}

	/**NAF**/
	function getActivity():{id:String,name:String}{
		if (activityCode==null) return null;
		var naf = activityCode.split(".").join("");
		return service.VendorService.getActivityCodes().find(p -> Std.string(p.id) == naf);
	}

	function check(){
		if(this.email==null){
			throw new tink.core.Error("Vous devez obligatoirement saisir un email pour ce producteur.");
		}

		if(this.email!=null && !EmailValidator.check(this.email) ) {
			throw new tink.core.Error('Email du producteur ${this.id} invalide.');
		}

		//disable if missing legal infos		
		var cpro = pro.db.CagettePro.getFromVendor(this);
		if(companyNumber==null){
			if(cpro!=null && cpro.offer==Training){
				//do not disable training accounts
			}else if(App.config.DEBUG){
				//do not disable vendor in dev env
			}else{
				disabled = DisabledReason.IncompleteLegalInfos;
			}			
		}
	}

	override function insert(){
		check();
		super.insert();
	}
	
	override function update(){
		check();
		super.update();
	}

	public function getStats():VendorStats{
		return VendorStats.getOrCreate(this);
	}

	public function getImageId(){
        return this.imageId;
    }

	/**
		has a valid Stripe account
	**/
	public function isDispatchReady():Bool{
	
		if(stripeAccountId==null) return false;
		return sys.db.Manager.cnx.request('SELECT count(id) FROM stripeAccount where id="${this.stripeAccountId}" and details_submitted=1 and charges_enabled=1').getIntResult(0) > 0;

	}

	public function getStripeConnectStatus(){

		var out = {account_open:false,details_submitted:false,charges_enabled:false};

		if(stripeAccountId==null) {
			return out;
		}else{
			out.account_open=true;
		}

		var res = sys.db.Manager.cnx.request('SELECT * FROM stripeAccount where id="${this.stripeAccountId}" and details_submitted=1 and charges_enabled=1').results().first();
		if(res!=null){
			out.details_submitted = res.details_submitted==1;
			out.charges_enabled = res.charges_enabled==1;
		}

		return out;
	}

	public function canOpenStripeAccount():Bool{
		// return betaFlags.has(CanOpenStripeAccount);
		return true;
	}

	
}