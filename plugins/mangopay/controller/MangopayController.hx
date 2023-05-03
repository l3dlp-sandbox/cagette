package mangopay.controller;
import Common;
import pro.payment.*;
import mangopay.*;
import mangopay.db.*;
import mangopay.Types;
import sugoi.form.elements.*;
import sugoi.form.elements.NativeDatePicker.NativeDatePickerType;
import sugoi.tools.Utils;
import haxe.crypto.Base64;
import db.Operation;
import db.Basket;
using tools.ObjectListTool;


/**
 * Mangopay payment controller
 * @author web-wizard,fbarbut
 */
class MangopayController extends controller.Controller
{
	/**
		Mangopay payment entry point	
	 */
	@tpl("plugin/pro/transaction/mangopay/pay.mtt")
	public function doDefault(type:String, tmpBasket:db.Basket){

		if(tmpBasket.status!=Std.string(BasketStatus.OPEN)) throw "basket should be OPEN";
		
		// throw Error("/","Les paiements en ligne par Mangopay sont fermés pour une période indéterminée (panne chez Mangopay). ");

		var url = sugoi.Web.getURI();
		
		//check
		var product = db.Product.manager.get(tmpBasket.getData().products[0].productId,false);
		if( product.catalog.group.id != app.getCurrentGroup().id ) throw "Cette commande ne correspond pas au marché dans lequel vous êtes actuellement.";
		
		var user = App.current.user;
		if(user==null) throw "Vous devez être connecté pour continuer";
		
		if(tmpBasket.user==null){
			tmpBasket.lock();
			tmpBasket.user = user;
			tmpBasket.update();
		}
		

		//If one of these fields is null ask the user to specify them for Mangopay requirements
		if(user.birthDate == null || user.nationality == null || user.countryOfResidence == null || user.tosVersion==null)
		{
			var bd = if(user.birthDate==null) new Date(1970,0,1,0,0,0) else user.birthDate;

			var form = new sugoi.form.Form("mangopaydata");
			form.addElement(new form.CagetteDatePicker("birthday", "Date de naissance", bd, true,"","year"));
			form.addElement(new StringSelect("nationality", "Nationalité", db.User.getNationalities(), user.nationality, true));
			form.addElement(new StringSelect("countryOfResidence", "Pays de résidence", db.Place.getCountries(), user.countryOfResidence, true));
			var tosMsg = "J'accepte les <a href='/cgu' target='_blank'>conditions générales d'utilisation</a> 
			de Cagette.net et de <a href='/mgp' target='_blank'>Mangopay</a>";
			form.addElement(new Checkbox("tos", tosMsg, user.tosVersion!=null, true));

			if (form.isValid()) {

				//Check that the user is at least 18 years old
				if(!service.UserService.isBirthdayValid(form.getValueOf("birthday"))) {
					throw Error(url, "Merci de bien vouloir rentrer votre date de naissance. Vous devez avoir au moins 18 ans.");
				}

				if(form.getValueOf("tos")!=true){
					throw Error(url, "Vous devez accepter les conditions générales d'utilisation.");
				}
			
				app.user.lock();
				app.user.birthDate = form.getValueOf("birthday");
				app.user.nationality = form.getValueOf("nationality");
				app.user.countryOfResidence = form.getValueOf("countryOfResidence");
				app.user.tosVersion = sugoi.db.Variable.getInt("tosVersion");
				app.user.update();
				throw Ok(url, t._("Your account has been updated"));
			}

			view.form = form;
			return;
		}

		//If the user doesn't exist already in the mapping table it means that 
		//we haven't created yet a natural user in Mangopay
		var mangopayUser = MangopayUser.get(user);
		var naturalUserId:String = null;
		if(mangopayUser == null) {
			try{
				naturalUserId = Mangopay.createNaturalUser(user).Id;	
			}catch(e:tink.core.Error){
				throw Error("/shop/basket/"+tmpBasket.id, "Erreur de création de compte Mangopay. "+e.message);
			}		
		} else {
			naturalUserId = mangopayUser.mangopayUserId;
		}

		//Create a wallet for this group if there is none for it
		var wallet : Wallet = null;
		if(type==pro.payment.MangopayECPayment.TYPE){
			//e-commerce : we put the money directly in the group wallet
			var legalUserId = MangopayPlugin.getGroupLegalUserId(app.user.getGroup());
			wallet = Mangopay.getOrCreateGroupWallet(legalUserId, user.getGroup());
		/*}else if (type==pro.payment.MangopayMPPayment.TYPE){
			//marketplace : we put the money in a user-group wallet
			wallet = Mangopay.getOrCreateUserWallet(naturalUserId, user.getGroup());*/
		}else{
			throw new tink.core.Error("payment type should be either mangopay-ec or mangopay-mp");
		}
		
		// Creating a Card Web PayIn for the buyer
		var group = app.user.getGroup();
		var conf = MangopayPlugin.getGroupConfig(group);
		var amount = MangopayPlugin.getAmountAndFees( tmpBasket.getTmpTotal() , conf);
		var host = App.config.DEBUG ? "http://" + App.config.HOST : "https://" + App.config.HOST;

		var payIn : CardWebPayIn = {
			Tag: Std.string(tmpBasket.id),
			StatementDescriptor : Mangopay.getStatment(group.name),
			DebitedFunds: {
				Currency: 	Euro,
				Amount: 	Math.round(amount.amount * 100),
			},
			Fees: {
				Currency: 	Euro,
				Amount: 	Math.round(amount.fees * 100),
			},
			CreditedWalletId: wallet.Id,
			AuthorId: naturalUserId,
			ReturnURL: host+"/p/pro/transaction/mangopay/return/"+type+"/"+tmpBasket.id,
			CardType: "CB_VISA_MASTERCARD",
			Culture: "FR",
			SecureMode:"DEFAULT",
			Requested3DSVersion:"V2_1"
		};
		var cardWebPayIn : CardWebPayIn = Mangopay.createCardWebPayIn(payIn);
		throw Redirect(cardWebPayIn.RedirectURL);

	}

	/**
	 * Return/success URL
	 */
	@tpl("plugin/pro/transaction/mangopay/status.mtt")
	public function doReturn(type:String,tmpBasket:db.Basket, args:{transactionId:String}){

		// if(App.config.DEBUG) throw "DEBUG : fake mangopay error";

		//Lock tmpBasket from the start ! otherwise there is a risk of double operation in Cagette.
		tmpBasket.lock();

		var payIn : CardWebPayIn = null;
		view.tmpBasket = tmpBasket;
		
		try{

			payIn = Mangopay.getPayIn(args.transactionId);

		}catch(e:tink.core.Error){

			//errors will be notified thru exceptions
			view.status = "error";
			payIn = e.data;
			view.errormessage = Mangopay.parsePayInError(payIn);
			return;
		}

		if (payIn.Status == Succeeded){
			view.status = "success";
			var orders = MangopayPlugin.processOrder(tmpBasket,payIn,type);

			//go to confirmation screen
			if(orders.length>0){
				var basket = orders[0].basket;
				throw Redirect('/shop/basket/${basket.id}/#/confirmed?payment-completed=1');
			}
			
		}else{
			view.status = "error";
			view.errormessage = Mangopay.parsePayInError(payIn);			
		}
	}

	function doGroup(d:haxe.web.Dispatch){
		d.dispatch(new mangopay.controller.MangopayGroupController());
	}

	function print(txt:String){
		Sys.println(txt+"<br/>");
	}
}