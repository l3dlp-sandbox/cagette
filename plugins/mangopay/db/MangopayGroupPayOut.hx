package mangopay.db;
import sys.db.Types;
import mangopay.Types;

/**
	Stores Payout Ids for a group 
**/
//@:id(payOutId, multiDistribId)
class MangopayGroupPayOut extends sys.db.Object
{
    public var id : SId;
    @:relation(multiDistribId) public var multiDistrib     : db.MultiDistrib;
	public var payOutId         : SString<64>; //payout ID in mangopay
    // public var cachedDatas      : SNull<SData<PayOut>>; // @deprecated
    public var data : SString<1024>; //payout data stored from Mangopay API

	public static function get(md:db.MultiDistrib,?lock=false){

        var payout = manager.select($multiDistrib == md, lock);		
        if(payout!=null){
            payout.refreshDatas();
        } 
        return payout;
	}

    /**
        Get payout datas from Mangopay API
    **/
    function refreshDatas():Void{
        if(this.payOutId==null || this.payOutId=="") return;
        if(this.data==null || this.data=="" || getData().Status!=Succeeded){
            this.lock();
            this.setData( mangopay.Mangopay.getPayOut(this.payOutId) );
            this.update();
        }
    }

    public function hasSucceeded():Bool{
        // if(this.payOutId==0) return true;
        return this.data!=null && getData().Status==Succeeded;
    }

    public function getAmount():Float{
        if(this.payOutId==null || this.payOutId=="") return 0.0;
        return getData().DebitedFunds.Amount/100;
    }

    public function setData(data:PayOut){
		this.data = haxe.Json.stringify(data);
	}

	public function getData():PayOut{
        if(this.data==null || this.data=="") refreshDatas();
		return haxe.Json.parse(this.data);
	}

}