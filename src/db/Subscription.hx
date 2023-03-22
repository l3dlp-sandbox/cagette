package db;
import Common;
import db.Operation.OperationType;
import sys.db.Object;
import sys.db.Types;
import tink.core.Error;

class Subscription extends Object {

	public var id : SId;
	@formPopulate("populate") @:relation(userId) public var user : db.User;
	@hideInForms @:relation(userId2) public var user2 : SNull<db.User>;
	@:relation(catalogId) public var catalog : db.Catalog;
	public var startDate : SDateTime;
	public var endDate : SDateTime;
	// @hideInForms public var isPaid : SBool;
	public var defaultOrders : SNull<SText>;
	public var absentDistribIds : SNull<SText>;

}