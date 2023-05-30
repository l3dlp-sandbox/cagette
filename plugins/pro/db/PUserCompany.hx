package pro.db;
import sys.db.Object;
import sys.db.Types;

/**
 * A user who's member of a company
 */
@:id(userId,companyId)
class PUserCompany extends Object
{
	@:relation(companyId) public var company : pro.db.CagettePro;
	@:relation(userId) public var user : db.User;
    @hideInForms public var legalRepresentative:SBool;
	public var salesRepresentative:SBool;
	// public var disabled:SBool;

	override public function new(){
		super();
		legalRepresentative = false;
	}

	static var CACHE = new Map<String,pro.db.PUserCompany>();
	
	public static function get(user:db.User, company:pro.db.CagettePro, ?lock = false) {
		//SPOD doesnt cache elements with double primary key, so lets do it manually
		var c = CACHE.get(user.id + "-" + company.id);
		if (c == null) {
			c = manager.select($user == user && $company == company, lock);		
			CACHE.set(user.id + "-" + company.id,c);
		}
		return c;	
	}

	public static function make(user:db.User,company:pro.db.CagettePro,?salesRep=false,?legalRep=false):PUserCompany{
		var uc = new pro.db.PUserCompany();
		uc.company = company;
		uc.user = user;
		if(salesRep) uc.salesRepresentative = true;
		if(legalRep) uc.legalRepresentative = true;
		uc.insert();
		return uc;
	}
	
	public static function getUsers(company:pro.db.CagettePro){
		return PUserCompany.manager.search($company == company, false);
	}
	
	public static function getCompanies(user:db.User) : Array<CagettePro> {
		return PUserCompany.manager.search($user == user, false).map(x-> x.company).array();
	}

	public static function getUserCompanies(user:db.User) : Array<PUserCompany> {
		return PUserCompany.manager.search($user == user, false).array();
	}
	
}