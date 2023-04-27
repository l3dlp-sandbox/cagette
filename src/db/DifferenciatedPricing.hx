package db;
import sys.db.Object;
import sys.db.Types;
import Common;


class DifferenciatedPricing extends Object
{
	public var id : SId;
	public var name : SString<64>;
	public var description : SNull<SString<128>>;
	public var percentage : SInt;
    @:relation(cagetteProId) public var cagettePro : pro.db.CagettePro;
	
	public function new(){
		super();
	}
	
}