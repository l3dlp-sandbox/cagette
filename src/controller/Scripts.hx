package controller;

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

}
