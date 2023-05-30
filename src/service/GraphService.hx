package service;
import db.Basket.BasketStatus;
import sugoi.apis.google.GeoCode.GeoCodingData;
import db.Operation;
import pro.payment.MangopayECPayment;
import db.Graph;
import pro.db.VendorStats;

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
                case "stripe" : service.GraphService.stripe(_from,_to);
                
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
        return getBasketIds(from,to).length;
    }

    public static  function turnover(from:Date,to:Date):Int{
        var mdIds:Array<Int> = sys.db.Manager.cnx.request('select id from MultiDistrib where distribStartDate >= "${from.toString()}" and distribStartDate < "${to.toString()}"').results().array().map(r -> Std.parseInt(r.id));
        if(mdIds.length==0) return 0;
        var tot = sys.db.Manager.cnx.request('select sum(total) as total from Basket where multiDistribId in (${mdIds.join(",")}) and (status="VALIDATED" or status="CONFIRMED")').getIntResult(0);
        return Math.round(tot);
    }

    public static  function mangopay(from:Date,to:Date):Int{        
        var basketIds = getBasketIds(from,to);
        var orderOps = Operation.manager.search($type==OperationType.VOrder && ($basketId in basketIds),false).map(o -> o.id);
        var paymentOps = Operation.manager.search($type==OperationType.Payment && ($relationId in orderOps),false);
		var value = 0.0;
		for( op in paymentOps){
			if(op.getPaymentType()==MangopayECPayment.TYPE) value += op.amount;
		}
		return Math.round(value);
    }

    public static function stripe(from:Date,to:Date):Int{       
       var basketIds = getBasketIds(from,to);
       var orderOps = Operation.manager.search($type==OperationType.VOrder && ($basketId in basketIds),false).map(o -> o.id);
       var paymentOps = Operation.manager.search($type==OperationType.Payment && ($relationId in orderOps),false);
       var value = 0.0;
       for( op in paymentOps){
           if(op.getPaymentType()==payment.Stripe.TYPE) value += op.amount;
       }
       return Math.round(value);
    }

    static function getBasketIds(from:Date,to:Date):Array<Int>{
        var mdIds:Array<Int> = sys.db.Manager.cnx.request('select id from MultiDistrib where distribStartDate >= "${from.toString()}" and distribStartDate < "${to.toString()}"').results().array().map(r -> Std.parseInt(r.id));
        if(mdIds.length==0) return [];
        var basketIds:Array<Int> = sys.db.Manager.cnx.request('select id from Basket where multiDistribId in (${mdIds.join(",")}) and (status="VALIDATED" or status="CONFIRMED")').results().array().map(r -> Std.parseInt(r.id));
        return basketIds;
    }

    /**
        compute global stats
    **/
    public static function global(from:Date,to:Date){

        var stats = {
            totalTurnoverMarket:0,
            invitedTurnoverMarket:0,
            cproInvitedTurnoverMarket:0,
            discoveryTurnoverMarket:0,
            proTurnoverMarket:0,
            memberTurnoverMarket:0,
            marketplaceTurnoverMarket:0,
        };

        var summaries = sys.db.Manager.cnx.request('select sum(turnoverMarket) as turnoverMarketSum , vendorId
        from vendorDailySummary 
        where date >= "${from.toString()}" and date < "${to.toString()}"
        and turnoverMarket > 0
        group by vendorId').results();

        var vendorIds:Array<Int> = summaries.array().map(s -> Std.parseInt(s.vendorId));
        var vendorStats = pro.db.VendorStats.manager.search($vendorId in vendorIds,false);
        var vendorStatsMap = new Map<Int,pro.db.VendorStats>();
        for( vs in vendorStats){
            vendorStatsMap.set(untyped vs.vendorId, vs);
        }

        for(summary in summaries){
            var vs = vendorStatsMap.get(summary.vendorId);
            if(vs==null) continue;

            switch (vs.type){
                case VendorType.VTCpro : 
                    stats.memberTurnoverMarket += summary.turnoverMarketSum;
                case VendorType.VTCproTest,VTStudent : null;
                case VendorType.VTFree,VendorType.VTInvited : 
                    stats.invitedTurnoverMarket += summary.turnoverMarketSum;
                case VendorType.VTCproSubscriberMontlhy, VendorType.VTCproSubscriberYearly : 
                    stats.proTurnoverMarket += summary.turnoverMarketSum;
                case VendorType.VTDiscovery : 
                    stats.discoveryTurnoverMarket += summary.turnoverMarketSum;
                case VendorType.VTInvitedPro : 
                    stats.cproInvitedTurnoverMarket += summary.turnoverMarketSum;
                case VendorType.VTMarketplace : 
                    stats.marketplaceTurnoverMarket += summary.turnoverMarketSum;
            }
            
            stats.totalTurnoverMarket += summary.turnoverMarketSum;
        }
        return stats;
    }

}