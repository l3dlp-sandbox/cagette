package payment;

/**
 * Stripe connect payment type
 * @author fbarbut
 */
class Stripe extends payment.PaymentType
{
	public static var TYPE(default, never) = "stripe";

	public function new() 
	{
		this.onTheSpot = false;
		this.type = TYPE;
		this.icon = '<i class="icon icon-bank-card"></i>';
		this.name = "Paiement en ligne Stripe";
		this.link = null;
		this.adminDesc = "Paiement en ligne Stripe";
	}
	
}