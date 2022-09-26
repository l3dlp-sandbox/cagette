package controller;
import db.Basket.BasketStatus;
import db.Operation.OperationType;
using Lambda;
import Common;
import sugoi.form.elements.NativeDatePicker.NativeDatePickerType;

/**
 * Distribution validation
 * @author fbarbut
 */
class Validate extends controller.Controller
{
	public var basket : db.Basket;
	public var multiDistrib : db.MultiDistrib;
	public var user : db.User;
	
	/**
		Validate a distrib
	**/
	@tpl('validate/user.mtt')
	public function doDefault(){
		if (multiDistrib.getGroup().hasCagette2()) {
			throw Redirect('/distribution/cagette2#/'+multiDistrib.id+'/'+basket.id);
		}

		if(basket.status==Std.string(OPEN)) throw "basket is OPEN";

		view.member = user;
		var place = multiDistrib.getPlace();
		var date = multiDistrib.getDate();
		
		var ug = db.UserGroup.get(user, place.group);
		view.balance = ug==null ? null : ug.balance;
		view.orders = service.OrderService.prepare(basket.getOrders());
		view.place = place;
		view.date = date;
		view.basket = basket;
		view.onTheSpotAllowedPaymentTypes = service.PaymentService.getOnTheSpotAllowedPaymentTypes(app.user.getGroup());
		view.md = multiDistrib;
		view.distribution = multiDistrib;
		view.userGroup = ug;
		view.abs = Math.abs;
		
		checkToken();
	}
	
	/**
		Delete a payment operation
	**/
	public function doDeleteOp(op:db.Operation){
		if (checkToken()){
			
			op.lock();
			op.delete();
			
			service.PaymentService.updateUserBalance(user, app.user.getGroup());
			
			throw Ok("/validate/" + basket.id, t._("Operation deleted"));
		}
	}
	
	public function doValidateOp(operation: db.Operation) 
	{
		if (checkToken()) 
		{
			operation.lock();
			operation.pending = false;
			if (app.params.exists("type")){
				operation.setPaymentData({type:app.params.get("type")}); 				
			}			
			operation.update();
			
			service.PaymentService.updateUserBalance(user, app.user.getGroup());
			
			throw Ok("/validate/"+basket.id, t._("Operation validated"));
		}
	}
	
	@tpl('form.mtt')
	public function doAddRefund() {

		if(basket.isValidated()){
			throw Error("/validate/" + basket.id, "Cette commande a déjà été validée, vous ne pouvez plus effectuer de remboursement.");
		}

		//Refund amount
		var refundAmount = basket.getTotalPaid() - basket.getOrdersTotal();		
		if(refundAmount <= 0) {
			//There is nothing to refund
			throw Error("/validate/" + basket.id, t._("There is nothing to refund"));
		}
		
		if (!app.user.isContractManager()) throw t._("Forbidden access");
		
		var operation = new db.Operation();
		operation.user = user;
		operation.date = Date.now();
		
	
		var orderOperation = basket.getOrderOperation(false);
		if(orderOperation == null) throw "unable to find related order operation";
		
		var f = new sugoi.form.Form(t._("payment"), "/validate/" + basket.id + "/addRefund");
		f.addElement(new sugoi.form.elements.StringInput("name", t._("Label"), t._("Refund"), true));		
		f.addElement(new sugoi.form.elements.FloatInput("amount", t._("Amount"), refundAmount, true));
		f.addElement(new form.CagetteDatePicker("date", "Date", Date.now(), NativeDatePickerType.date, true));
		var paymentTypes = service.PaymentService.getPaymentTypes(PCManualEntry, app.user.getGroup());
		var out = [];
		for (paymentType in paymentTypes){
			out.push({label: paymentType.name, value: paymentType.type});
		}
		f.addElement(new sugoi.form.elements.StringSelect("Mtype", t._("Payment type"), out, null, true));

		//broadcast event
		var event = PreRefund(f,basket,refundAmount);
		App.current.event(event);
		f = event.getParameters()[0];
		
		if (f.isValid()) {
			
			f.toSpod(operation);
			operation.type = db.Operation.OperationType.Payment;
			operation.setPaymentData({type:f.getValueOf("Mtype")});
			operation.group = app.user.getGroup();
			operation.user = user;
			operation.relation = orderOperation;
			operation.amount = 0 - Math.abs(operation.amount);
			operation.insert();
			
			App.current.event(NewOperation(operation));
			App.current.event(Refund(operation,basket));
			service.PaymentService.updateUserBalance(user, app.user.getGroup());
						
			throw Ok("/validate/"+basket.id, t._("Refund saved"));
		}
		
		view.title = t._("Key-in a refund for ::user::",{user:user.getCoupleName()});
		view.form = f;		
	}
	
	@tpl('form.mtt')
	public function doAddPayment(){
			
		if (!app.user.isContractManager()) throw Error("/",t._("Forbidden access"));
		
		var o = new db.Operation();
		o.user = user;
		o.date = Date.now();

		if( basket.isValidated() ){
			throw Error("/validate/" +basket.id, "Cette commande a déjà été validée, vous ne pouvez plus effectuer de remboursement.");
		}

		var paymentAmount = basket.getOrdersTotal() - basket.getTotalPaid();
		
		var f = new sugoi.form.Form("payment");
		f.addElement(new sugoi.form.elements.StringInput("name", t._("Label"), t._("Additional payment"), true));
		f.addElement(new sugoi.form.elements.FloatInput("amount", t._("Amount"), paymentAmount > 0 ? paymentAmount : null, true));
		f.addElement(new form.CagetteDatePicker("date", t._("Date"), Date.now(), NativeDatePickerType.date, true));
		var paymentTypes = service.PaymentService.getPaymentTypes(PCManualEntry, app.user.getGroup());
		var out = [];
		for (paymentType in paymentTypes){
			out.push({label: paymentType.name, value: paymentType.type});
		}
		f.addElement(new sugoi.form.elements.StringSelect("Mtype", t._("Payment type"), out, null, true));
		
	
		if(basket.isValidated()){
			throw Error("/validate/" + basket.id, "Cette commande a déjà été validée, vous ne pouvez plus effectuer de remboursement.");
		}

		var op = basket.getOrderOperation(false);
		if(op==null) throw "unable to find related order operation";
		
		if (f.isValid()){
			f.toSpod(o);
			o.type = db.Operation.OperationType.Payment;
			o.setPaymentData({type:f.getValueOf("Mtype")});
			o.group = app.user.getGroup();
			o.user = user;
			o.relation = op;			
			o.insert();
			
			service.PaymentService.updateUserBalance(user, app.user.getGroup());
			
			throw Ok("/validate/"+basket.id, t._("Payment saved"));
		}
		
		view.title = t._("Key-in a payment for ::user::",{user:user.getCoupleName()});
		view.form = f;	
	}
	
	/**
		Validate a user's basket
	**/
	public function doValidate(){
		
		if (checkToken()) {
			try{
				service.PaymentService.validateBasket(basket);
			} catch(e:tink.core.Error) {
				throw Error("/validate/" + basket.id, e.message);
			}
			throw Ok("/distribution/validate/" + multiDistrib.id , t._("Order validated"));			
		}
	}

}