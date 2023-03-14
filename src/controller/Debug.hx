package controller;

import sugoi.helper.Table;
import sys.db.Manager;

class Debug extends Controller {


	public function doDefault(){

		var res = Manager.cnx.request("SHOW VARIABLES LIKE 'character_set%'").results().array();

		var t = new Table();
 		t.title = "SHOW VARIABLES LIKE 'character_set%'";
 		
		
		Sys.println(t.toString(res));

	}
    
    /*@tpl('debug/neo.mtt')
	public function doNeo() {
		return "";
	}*/
}
