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
            if(!g.hasShopMode()) continue; //no AMAPs
            if(!g.hasPayments()) continue;
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
        2023-01-10 enable payments for all shopMode groups
    **/
    public function doEnablepayments(){
        for(g in db.Group.manager.search( $flags.has(ShopMode) && !$flags.has(HasPayments) ,true) ){
            print(g.id+" - "+g.name);
            g.enablePayments();
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
        2023-02-01 enable massively cagette2 option + remove percentage on catalogs
    **/
    /*function doCagette2(){

		var groups = 0;
		var groupsWithPercentage = 0;

		//shopmode groups with no cagette2 flag, limit 500
		for( g in db.Group.manager.search($betaFlags.has(Cagette2)==false && $flags.has(ShopMode)==true,{limit:500})){

			groups++;

			//no percentage on catalogs			
			// if( g.getActiveContracts().count(c -> c.percentageValue>0) > 0){
			// 	groupsWithPercentage++;
			// 	continue;
			// }

            for( c in g.getActiveContracts().filter(c -> c.percentageValue>0)){
                c.lock();
                c.flags.unset(PercentageOnOrders);
                c.percentageName = null;
                c.percentageValue = null;
                c.update();
            }

			g.lock();
			g.betaFlags.set(Cagette2);
			g.update();

			print(g.id+" - "+g.name+" migrated to cagette2");

		}

		print("groups : "+groups+"");
		print("groupsWithPercentage : "+groupsWithPercentage+"");

        for( g in db.Group.manager.search( $flags.has(ShopMode)==false )){

            if(g.betaFlags.has(Cagette2)){
                print("AMAP group should not have cagette2 : "+g.id+" - "+g.name);
                g.lock();
                g.betaFlags.unset(Cagette2);
                g.update();
            }
        }
	}*/

     /**
        2023-02-01 no more MoneyPot payment
    **/
    function doMoneypot(){

        for( g in db.Group.manager.search( $flags.has(ShopMode) )){
            var paymentTypes = g.getAllowedPaymentTypes();
            if( paymentTypes.has("moneypot") ){
                paymentTypes.remove("moneypot");
                if(paymentTypes.length==0){                    
                    g.lock();
                    paymentTypes = [Cash.TYPE,Check.TYPE];
                    g.setAllowedPaymentTypes(paymentTypes);
                    g.update();                    
                }
                print("remove Moneypot : "+g.id+" - "+g.name);

            }
        }

    }

    /**
        2023-02-15 redirect AMAPs to camap.alilo.fr
    **/
    function doRedirectamaps(){

        for( g in db.Group.manager.search( $flags.has(ShopMode)==false ,true)){

            g.disabled = "MOVED";
            g.extUrl = "https://camap.alilo.fr/group/"+g.id;
            g.update();

            print('Redirects #'+g.id+" "+g.name);

            //break linkage
            for( cat in g.getContracts() ){
                var rc = connector.db.RemoteCatalog.getFromContract(cat,true);
		        if(rc != null ){                    
                    rc.delete();
                }
            }

        }

    }
}
