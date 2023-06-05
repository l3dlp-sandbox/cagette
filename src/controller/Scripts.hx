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
        2023-04-17 migrate VRAC groups to differentiated pricing

        sourceGroup : the group we empty        
        sourcePricing : the pricing given to the members of sourceGroup        
        targetGroup : the group we keep
        targetPricing : the pricing given to the members of targetGroup
        
    **/
    function doMigratePricing(sourceGroup:db.Group,sourcePrice:db.DifferenciatedPricing,targetGroup:db.Group,targetPrice:db.DifferenciatedPricing){

        //give targetPrice to targetGroup
        print("==== GIVE users from "+targetGroup.name+" price #"+targetPrice.id+"-"+targetPrice.name);

        for( userGroup in db.UserGroup.manager.search($groupId == targetGroup.id && $differenciatedPricingId==null,true)){

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

            //delete membership if already exist in target group
            var already = db.Membership.get(m.user,targetGroup,m.year,true);
            if(already!=null) {
                if(already.operation!=null){
                    for(op in already.operation.getRelatedPayments()){
                        op.delete();
                    }
                    already.operation.delete();
                }
                already.delete();
            }

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

    /**
        2023-06-01 : certains découvertes passent en Marketplace
    **/
    public function doDiscoveryExpiration(){

        var vendors = db.Vendor.manager.unsafeObjects("SELECT v.* FROM Vendor v
            INNER JOIN CagettePro cp ON cp.vendorId = v.id 
            WHERE
            offer = 0
            and freemiumResetDate < '2023-01-09 00:00:00'
            and freemiumResetDate > '2022-10-18 00:00:00'",true);

        for(v in vendors){
            
            var cpro = v.getCpro();
            if(cpro==null) continue;
            if(cpro.offer!=pro.db.CagettePro.CagetteProOffer.Discovery) continue;

            cpro.lock();
            cpro.offer = pro.db.CagettePro.CagetteProOffer.Marketplace;
            cpro.update();

            if(v.disabled==db.Vendor.DisabledReason.TurnoverLimitReached){
                v.disabled = null;           
            }

            //need to block if has future distrib
            var cids:Array<Int> = v.getActiveContracts().array().map(c->c.id);
            var blocked = db.Distribution.manager.count(($catalogId in cids) && $date > Date.now())  > 0;

            if(blocked){
                if(v.disabled==null){
                    v.disabled = db.Vendor.DisabledReason.MarketplaceDisabled;
                    v.update();
                }                
            }


            print(v.id+";"+v.name+";"+v.email+";"+blocked);

        }
    }
    


    
}
