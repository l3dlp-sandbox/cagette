package db;
import sys.db.Object;
import sys.db.Types;


/**
 * Tool to Graph daily values
 */
@:id(key,date)
class Graph extends Object{

	public var key:SString<128>;
	public var date:SDateTime; //the day for wich the value is computed
	
	public var value:SFloat; //for single values
	public var data:SString<4096>; //json data

	/**
	 *  record a value
	 */
	public static function record(key:String,value:Float,?date:Date){
		if(date==null) date = Date.now();
		date = new Date(date.getFullYear(),date.getMonth(),date.getDate(),0,0,0);
		var o = manager.select($key==key && $date==date,true);
		if(o == null){
			o = new Graph();
			o.date = date;
			o.key = key;
			o.value = value;
			o.insert();
		}else{
			o.value = value;
			o.update();
		}
		return o;
	}

	public static function recordData(key:String,data:Dynamic,date:Date){
		date = new Date(date.getFullYear(),date.getMonth(),date.getDate(),0,0,0);
		var o = manager.select($key==key && $date==date,true);
		if(o == null){
			o = new Graph();
			o.date = date;
			o.key = key;
			o.data = haxe.Json.stringify(data);
			o.insert();
		}else{
			o.data = haxe.Json.stringify(data);
			o.update();
		}
		return o;
	}

	/**
	 *  Get a list of records in a time frame
	 */
	public static function getRange(key:String,from:Date,to:Date):Array<db.Graph>{
		return Lambda.array(manager.search($key==key && $date>=from && $date<=to, false));
	}


	public static function getData(key:String,date:Date){
		var g = manager.select($key==key && $date==date, false);
		if(g==null) return null;
		return haxe.Json.parse(g.data);
	}


	


}