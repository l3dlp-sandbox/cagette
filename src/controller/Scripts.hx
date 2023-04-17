package controller;

import db.Group.RegOption;
import db.UserGroup;
import db.Operation;
import db.Membership;
import db.Catalog;
import db.MultiDistrib;
import service.PaymentService;
import payment.Check;
import payment.Cash;

class Scripts extends Controller
{
	var now : Date;

	public function new(){
		super();

        if (sugoi.Web.isModNeko){
            throw "CLI only";
        }
	}

    function print(s:String){
        Sys.println(s);
    }

    public static function printTitle(title){
		Sys.println("==== "+title+" ====");
	}

	public function doDefault(){}
	
    /**
        2023-01-06
    **/
	public function doRecomputeBasketTotal(from:Date,to:Date){
        // var from = Date.fromString(from);
        // var to = Date.fromString(to);
       
		printTitle("Recompute basket total from "+from.toString()+" to "+to.toString());
        for(g in db.Group.manager.search($id>0,false)){
            var dids = db.MultiDistrib.getFromTimeRange( g , from , to  ).map(d -> d.id);
            print("group "+g.id+" has "+dids.length+" mds");
            var baskets = db.Basket.manager.search( $multiDistribId in dids );
            
            for ( b in baskets){
                print('basket #${b.id}');
                b.lock();
                b.total = b.getOrdersTotal();
                b.update();
            }
        }
	}

    /**
        recompute payment ops
    **/
    public function doRecomputeOps(from:Date,to:Date){

		printTitle("Recompute ops from "+from.toString()+" to "+to.toString());
        for(g in db.Group.manager.search($id>0,false)){
            var dids = db.MultiDistrib.getFromTimeRange( g , from , to  ).map(d -> d.id);
            print("group "+g.id+" has "+dids.length+" mds");
            //get not validated baskets
            var baskets = db.Basket.manager.search( $multiDistribId in dids);
            baskets = baskets.filter( b -> b.status == "CONFIRMED");
            
            for ( b in baskets){
                print('basket #${b.id}');
                
                
                var orderOp = b.getOrderOperation(false);
                if(orderOp == null){
                    PaymentService.makeOrderOperation(b);
                }else{
                    PaymentService.updateOrderOperation(orderOp,b.getOrders(),b);
                }

                if(b.getPaymentsOperations().length==0){
			        service.PaymentService.makePaymentOperation(b.user,b.getGroup(), payment.OnTheSpotPayment.TYPE, b.total, "paiement", orderOp );	
                }

            }
        }
	}

    /**
        2023-01-10 ensure all cpro have legal rep
    **/
    public function doLegalRep(){

        for(cpro in pro.db.CagettePro.manager.all(false)){

            var ucs = cpro.getUserCompany();
            var hasLegalRep = ucs.find(x -> x.legalRepresentative) != null;
            if(!hasLegalRep && ucs.length>0){
                var u = ucs[0];
                u.lock();
                u.legalRepresentative = true;
                u.update();
                print(cpro.vendor.id+" - "+cpro.vendor.name);
            }
            
        }

    }

    /**
        2023-04-04 delete AMAPs datas : 
        supprime les UserOrder / basket / distributions multdistrib / operations / adhésions / catalog / products des AMAP.  On ne garde que Group/User/UserGroup
    **/
    function doDeleteAmapData(){

        for( g in db.Group.manager.search( $flags.has(__ShopMode)==false ,false)){

            print('delete data of #'+g.id+" "+g.name);

            db.MultiDistrib.manager.delete($groupId == g.id);
            db.Catalog.manager.delete($groupId == g.id);
            db.Membership.manager.delete($groupId == g.id);
            db.Operation.manager.delete($groupId == g.id);            
        }
    }


    /**
        2023-04-17 migrate VRAC groups to differentiated pricing

        targetGroup : the group we keep
        targetPricing : the pricing given to the members of targetGroup
        sourceGroup : the group we empty        
        sourcePricing : the pricing given to the members of sourceGroup        
    **/
    function doMigratePricing(sourceGroup:db.Group,sourcePrice:db.DifferenciatedPricing,targetGroup:db.Group,targetPrice:db.DifferenciatedPricing){

        //give targetPrice to targetGroup
        print("==== GIVE users from "+targetGroup.name+" price #"+targetPrice.id+"-"+targetPrice.name);

        for( userGroup in db.UserGroup.manager.search($groupId == targetGroup.id,true)){

            userGroup.differenciatedPricingId = targetPrice.id;
            userGroup.update();

            print("give "+userGroup.user.getName()+" price #"+targetPrice.id+"-"+targetPrice.name);
        }

        print("==== MOVE users from "+sourceGroup.name+" to "+targetGroup.name);

        for( userGroup in db.UserGroup.manager.search($group == sourceGroup,true)){

            //if user is group admin, keep it
            // if(userGroup.hasRight(GroupAdmin)) continue;

            //if already in target group, delete
            var already = db.UserGroup.get(userGroup.user,targetGroup,true);
            if(already!=null) already.delete();

            //move to target group
            // userGroup.group = targetGroup;
            // userGroup.differenciatedPricingId = sourcePrice.id;
            // userGroup.update();
            sys.db.Manager.cnx.request('update UserGroup set groupId=${targetGroup.id},differenciatedPricingId=${sourcePrice.id} where groupId=${sourceGroup.id} and userId=${userGroup.user.id}');

            print(userGroup.user.getName()+" moved and give price #"+sourcePrice.id+"-"+sourcePrice.name);            
        }

        //move memberships
        print("==== MOVE memberships from "+sourceGroup.name+" to "+targetGroup.name);

        for( m in db.Membership.manager.search($group == sourceGroup,false)){

            //note : linked distribution is not moved

            sys.db.Manager.cnx.request('update Membership set groupId=${targetGroup.id} where groupId=${m.group.id} and userId=${m.user.id} and year=${m.year}');

            // var n = db.Membership.get(m.user,m.group,m.year,true);
            // n.group = targetGroup;
            // n.update();

            if(m.operation!=null){

                //move membership debt op
                // var op = db.Operation.manager.get(n.operation.id,true);               
                // op.group = targetGroup;
                // n.update();
                sys.db.Manager.cnx.request('update Operation set groupId=${targetGroup.id} where id=${m.operation.id}');

                //move payment op
                var paymentOp = db.Operation.manager.select($relation == m.operation,true);
                if(paymentOp!=null){
                    // paymentOp.group = targetGroup;
                    // paymentOp.update();
                    sys.db.Manager.cnx.request('update Operation set groupId=${targetGroup.id} where id=${paymentOp.id}');
                }
            }
            
        }   

        //close source group
        sourceGroup.lock();
        sourceGroup.regOption = RegOption.Closed;
        // sourceGroup.disabled = 
        sourceGroup.update();

        print("END");
    }


    
}
