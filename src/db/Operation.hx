package db;
import sys.db.Types;
import tink.core.Error;

enum OperationType{
	VOrder; 	// 0 order on a variable order (debt)
	COrder;		// 1 order on a CSA contract	(debt)
	Payment;	// 2 payment of a debt	
	Membership;	// 3 membership (debt)
}

typedef PaymentInfos = {
	type : String, 			//payment type (PSP)
	?remoteOpId : String,	//PSP operation ID 
	/*?netAmount:Float,		//amount paid less fees
	?fixedFees:Float,		//PSP fixed fees
	?variableFees:Float,	//PSP variable fees*/
}; 

typedef VOrderInfos = {basketId:Int};
typedef COrderInfos = {contractId:Int};
typedef MembershipInfos = {year:Int};

/**
 * Payment operation 
 * 
 * @author fbarbut
 */
class Operation extends sys.db.Object
{
	public var id : SId;
	public var name : SString<128>;
	public var amount : SFloat;
	public var date : SDateTime;
	public var type : SEnum<OperationType>;
	@hideInForms @:relation(relationId) public var relation : SNull<db.Operation>; //linked to another operation : ie a payment pays an order	
	@formPopulate("populate") @:relation(userId) public var user : db.User;
	@hideInForms @:relation(groupId) public var group : db.Group;
	public var pending : SBool; //a pending payment means the payment has not been confirmed, a pending order means the ordre can still change before closing.

	//deprecated
	public var data : SData<Dynamic>;

	//new fields
	@hideInForms @:relation(basketId) public var basket : SNull<db.Basket>; 	//relation to basket for variable orders
	@hideInForms @:relation(contractId) public var contract : SNull<Catalog>; 	//relation to contract for CSA orders
	@hideInForms public var data2 : SNull<SString<256>>; 						//json data

	
	public function getTypeIndex(){
		var e : OperationType = type;		
		return e.getIndex();
	}
	
	public function new(){
		super();
		pending = false;
	}
	
	/**
	 * if operation is a payment, give the payment type
	 */
	public function getPaymentType():String{
		switch(type){
			case Payment: 
				var x : PaymentInfos = this.data;
				if (data == null){
					return null;
				}else{
					return x.type;
				}				
			default : return null;
		}		
	}
	
	/**
	 * get translated payment type name
	 */
	public function getPaymentTypeName(){
		var t = getPaymentType();		
		if (t == null) return null;
		for ( pt in service.PaymentService.getPaymentTypes(PCAll)){
			if (pt.type == t) return pt.name;
		}
		return t;
	}
	
	/**
	 * get payments linked to this order operation
	 */
	public function getRelatedPayments(){
		return db.Operation.manager.search($relation == this && $type == Payment, false);
	}
	
	public function getOrderInfos(){
		return switch(type){
			case COrder, VOrder : this.data;				
			default : null;
		}
	}
	
	public function getPaymentInfos():PaymentInfos{
		return switch(type){
			case Payment : this.data;
			default : null;
		}
	}

	public static function countOperations(user:db.User, group:db.Group):Int{	
		return manager.count($user == user && $group == group);		
	}
	
	/**
	 *  get all  user operations
	 *  @param user - 
	 *  @param group - 
	 *  @param reverse=false - 
	 */
	public static function getOperations(user:db.User, group:db.Group,?reverse=false ){
		if(reverse) {
			return manager.search($user == user && $group == group,{orderBy:-date},false);	
		}		
		return manager.search($user == user && $group == group,{orderBy:date},false);		
	}

	public static function getOperationsWithIndex(user:db.User, group:db.Group,index:Int,limit:Int,?reverse=false ){
		if(reverse) {
			return manager.search($user == user && $group == group, { limit:[index,limit], orderBy:-date }, false);	
		}		
		return manager.search($user == user && $group == group, { limit:[index,limit], orderBy:date },false);		
	}
	
	/*public static function getOrder_Operations(user:db.User, group:db.Group,?limit=50 ){		
		//return manager.search($user == user && $group == group && $type!=Payment,{orderBy:date},false);		
		//return manager.search($user == user && $group == group && $relation==null,{orderBy:date},false);		
		return manager.search($user == user && $group == group,{orderBy:date,limit:limit},false);		
	}*/
	
	public static function getLastOperations(user:db.User, group:db.Group, ?limit = 50){
		
		var c = manager.count($user == user && $group == group);
		c -= limit;
		if (c < 0) c = 0;
		return manager.search($user == user && $group == group,{orderBy:date,limit:[c,limit]},false);	
	}
	
	
	
	public function populate(){
		return App.current.user.getGroup().getMembersFormElementData();
	}
	

	
}