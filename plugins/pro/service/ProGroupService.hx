package pro.service;
import Common;
import db.UserGroup;

/**
 * Service for managing groups
 */
class ProGroupService
{
	var company : pro.db.CagettePro;

	public function new(?company:pro.db.CagettePro){
		if(company!=null) this.company = company;
	}	
	
	/**
	 * copy groups.
	 * @param	g
	 */
	public function duplicateGroup(g:db.Group,?fullCopy=false,name:String,place:String){
		
		var d = new db.Group();
		d.name = name;
		d.contact = g.contact;
		d.txtIntro = g.txtIntro;
		d.txtHome = g.txtHome;
		d.txtDistrib = g.txtDistrib;
		d.extUrl = g.extUrl;
		d.membershipRenewalDate = g.membershipRenewalDate;
		d.membershipFee = g.membershipFee;
		d.flags = g.flags;
		d.image = g.image;
		d.regOption = g.regOption;
		d.currency = g.currency;
		d.currencyCode =  g.currencyCode;
		d.setAllowedPaymentTypes(g.getAllowedPaymentTypes());
		d.checkOrder = g.checkOrder;
		d.IBAN = g.IBAN;		
		d.insert();

		var p = new db.Place();
		p.name = place;
		p.group = d;
		p.city = "";
		p.zipCode = "";
		p.insert();
		
		//put my team in the group
		if (company != null){
			for ( u in company.getUsers()){
				var x = db.UserGroup.getOrCreate(u, d);
				x.giveRight(Right.GroupAdmin);
				x.giveRight(Right.ContractAdmin());
				x.giveRight(Right.Membership);
				x.giveRight(Right.Messages);
				x.update();
			}	
		}
		
		// var mapping = duplicateCategories(g,d);
		
		//copy contracts
		if (App.current.user.isAdmin() && fullCopy){
			//copy EVERY cpro contract
			
			for ( c in g.getActiveContracts() ){
				var rc = connector.db.RemoteCatalog.getFromContract(c);
				if (rc == null) continue;
				//copy contract
				var rc = pro.service.PCatalogService.linkCatalogToGroup(rc.getPCatalog(), d, App.current.user.id);
				var ct = rc.getContract();
									
				//need to sync categories
				// syncCatgories(c, ct, mapping);
				
				//add cpro members to group
				if (this.company == null){
					for (u in rc.getPCatalog().company.getUsers()) u.makeMemberOf(d);
				}
			}
			
		}else{
			//copy my cpro contracts
			var rcs = new Array<connector.db.RemoteCatalog>();
			for ( c in company.getCatalogs() ){
				for (rc in connector.db.RemoteCatalog.getFromPCatalog(c)){
					rcs.push(rc);
				}
			}
			for ( rc in rcs){
				var c = rc.getContract();
				if ( c.group.id == g.id) {
					//copy contract
					var rc = pro.service.PCatalogService.linkCatalogToGroup(rc.getPCatalog(), d, App.current.user.id);
					var ct = rc.getContract();
					
					//need to sync categories
					// syncCatgories(c, ct, mapping);					
				}
			}
		}
		
		return d;
	}
	
}