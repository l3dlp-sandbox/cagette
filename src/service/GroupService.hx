package service;
using Lambda;
using tools.ObjectListTool;
/**
 * Service for managing groups
 * @author fbarbut
 */
class GroupService
{

	public function new() 
	{
		
	}
	
	/**
	 * copy groups.
	 * @param	g
	 */
	public static function duplicateGroup(g:db.Amap){
		
		var d = new db.Amap();
		d.name = g.name+" (copy)";
		d.contact = g.contact;
		d.txtIntro = g.txtIntro;
		d.txtHome = g.txtHome;
		d.txtDistrib = g.txtDistrib;
		d.extUrl = g.extUrl;
		d.membershipRenewalDate = g.membershipRenewalDate;
		d.membershipPrice = g.membershipPrice;
		d.vatRates = g.vatRates;
		d.flags = g.flags;
		d.groupType = g.groupType;
		d.image = g.image;
		d.regOption = g.regOption;
		d.currency = g.currency;
		d.currencyCode = g.currencyCode;
		d.allowedPaymentsType = g.allowedPaymentsType;
		d.checkOrder = g.checkOrder;
		d.IBAN = g.IBAN;		
		d.insert();
		
		//put me in the group
		
		return d;
	}
	
	static function duplicateCategories(from:db.Amap,to:db.Amap){
		
	}
	
	static function duplicateContract(){
		
	}

	/**
		Get users with rights in this group
	**/
	public static function getGroupMembersWithRights(group:db.Amap,?rights:Array<db.UserAmap.Right>):Array<db.User>{

		var membersWithAnyRights = db.UserAmap.manager.search($rights!=null && $amap==group,false).array();
		if(rights==null){
			return Lambda.map(membersWithAnyRights,function(ua) return ua.user).array();
		}else{
			var members = [];
			for( m in membersWithAnyRights){
				for(r in rights){
					if(m.hasRight(r)){
						members.push(m.user);
						break;
					}
				}
			}
			
			return members.deduplicate();
		}

		
	}
	
}