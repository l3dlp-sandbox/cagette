package service;

import haxe.Json;
import tink.core.Error;
import db.Basket;

enum Place {
	SubmitOrder(tmpBasket:db.Basket); // the user submits an order
	UserLogsIn(tmpBasket:db.Basket); // the user should log in
	TimeSlotSelection(tmpBasket:db.Basket); // the user should select a time slot
	PaymentTypeSelection(tmpBasket:db.Basket); // the user shoud select a payment type
	Payment;
	PaymentConfirmation;
	PaymentError;
	PaymentCancel;
	ConfirmOrder(tmpBasket:db.Basket);
}


/**
	Order flow management.
	No data modification should be performed in this class.
	inspired by https://symfony.com/doc/current/components/workflow.html
**/
class OrderFlowService {
	public var place:Place;

	public function new() {}

	public function setPlace(p:Place) {
		this.place = p;
		return this;
	}

	public function getNextPlace(?p:Place):Place {
		if (p == null)
			p = place;
		switch (p) {
			case SubmitOrder(tmpBasket):
				var group = tmpBasket.multiDistrib.group;
				if (App.current.user == null || !App.current.user.isMemberOf(group)) {
					return UserLogsIn(tmpBasket);
				} else {
					return getNextPlace(UserLogsIn(tmpBasket));
				}

			case UserLogsIn(tmpBasket):
				var distrib = tmpBasket.multiDistrib;

				if (distrib.timeSlots != null) {
					var ts = new TimeSlotsService(distrib);
					var status = ts.userStatus(tmpBasket.user.id);
		

					if (!status.registered) {
						return TimeSlotSelection(tmpBasket);
					}
				}


				return getNextPlace(TimeSlotSelection(tmpBasket));

			case TimeSlotSelection(tmpBasket):
				var distrib = tmpBasket.multiDistrib;
				if (distrib.group.hasPayments()) {
					// Go to payments page
					return PaymentTypeSelection(tmpBasket);
				} else {
					// no payments, confirm directly
					return ConfirmOrder(tmpBasket);
				}

			default:
				return null;
		}
	}

	public function getPlaceUrl(p:Place):String {
		switch (p) {
			case null:
				throw new tink.core.Error(404, "Null place");
			case SubmitOrder(tmpBasket):
				return '/shop/validate/${tmpBasket.id}';
			case UserLogsIn(tmpBasket):
				return '/shop/login/${tmpBasket.id}';
			case PaymentTypeSelection(tmpBasket):
				return '/transaction/pay/${tmpBasket.id}';
			case TimeSlotSelection(tmpBasket):
				return '/distribution/selectTimeSlots/${tmpBasket.id}';
			case ConfirmOrder(tmpBasket):
				return '/shop/confirm/${tmpBasket.id}';
			default:
				return '/';
		}
	}
}
