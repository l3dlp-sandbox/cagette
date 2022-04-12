package service;
import sugoi.apis.google.GeoCode.GeoCodingData;
import db.Operation;
import pro.payment.MangopayECPayment;
import db.Graph;

using tools.DateTool;

class GraphService{

    public static function getAllGraphKeys() {
        return ["basket","turnover","mangopay"];
        
    }

    public static function getRange(key:String,from:Date,to:Date):Array<db.Graph> {
        var year = from.getFullYear();
        var month = from.getMonth();
        var out = [];
        for( d in from.getDate()...to.getDate()+1){
            
            var g = getDay(key,new Date(year,month,d,0,0,0));
            if(g!=null) out.push(g);
            
        }

        return out;
        
    }

    public static function getDay(key:String,date:Date){
        var year = date.getFullYear();
        var month = date.getMonth();
        var day = date.getDate();
        var _from = new Date(year,month,day,0,0,0);
        var _to = new Date(year,month,day,23,59,59);

        //do not record stats for today or in the future
        if(_from.getTime()>Date.now().getTime()) return null;
        if(_from.toString().substr(0,10)==Date.now().toString().substr(0,10)) return null;

        var g = Graph.manager.select($key==key && $date==_from,false);

        if(g==null){
            var value = switch(key){
                case "basket"   : service.GraphService.baskets(_from,_to);
                case "turnover" : service.GraphService.turnover(_from,_to);
                case "mangopay" : service.GraphService.mangopay(_from,_to);
                
                default : throw "unknown graph key";
            }           
            g = db.Graph.record(key,value, _from );
        }

        return g;
    }


    /**
        compute basket numbers by period
    **/
    public static function baskets(from:Date,to:Date):Int {
        
		return db.Basket.manager.count($cdate>=from && $cdate<=to);
        
    }

    public static  function turnover(from:Date,to:Date):Int{
        var baskets = db.Basket.manager.search($cdate>=from && $cdate<=to);
		var value = 0.0;
		for( b in baskets){
            var t  =  b.getOrdersTotal();
            if(b.total==null){
                b.lock();
                b.total = t;
			    b.update();
            }

			value += t;
		}
		return Math.round(value);
    }

    public static  function mangopay(from:Date,to:Date):Int{
        
        var ops = Operation.manager.search($type==OperationType.Payment && $date>=from && $date<to);
		var value = 0.0;
		for( op in ops){
			if(op.getPaymentType()==MangopayECPayment.TYPE) value += op.amount;
		}
		return Math.round(value);
    }




}