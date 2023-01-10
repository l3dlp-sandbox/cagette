package controller;

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
        2023-01-10 enable payments for all shopMode groups
    **/
    public function doEnablepayments(){
        for(g in db.Group.manager.search( $flags.has(ShopMode) && !$flags.has(HasPayments) ,true) ){

            print(g.id+" - "+g.name);
            g.enablePayments();
        }
        
    }
}
