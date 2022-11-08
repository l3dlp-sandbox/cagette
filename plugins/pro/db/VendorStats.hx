package pro.db;
import sys.db.Types;
import service.BridgeService;

enum VendorType {
	VTCpro; 			// 0 Offre Pro formé
	VTFree; 			// 1 Gratuit
	VTInvited; 			// 2 Invité
	VTInvitedPro;   	// 3 Invité sur cpro
	VTCproTest; 		// 4 CPro test (COVID19 ou en attente de formation) @deprecated
	VTStudent; 			// 5 compte pro pédagogique
	VTDiscovery; 		// 6 Offre Découverte
	VTCproSubscriberMontlhy; 	// 7 Offre Pro abonné mensuel
	VTCproSubscriberYearly; 	// 8 Offre Pro abonné annuel
	VTMarketplace; 		//9 marketplace
}

/**
 * Stats on vendors for analytics
 * @author fbarbut
 */
@:index(type,active,ldate)
class VendorStats extends sys.db.Object
{
	public var id : SId;
	@:relation(vendorId) public var vendor : SNull<db.Vendor>;	
	public var type:SEnum<VendorType>;	//vendor type
	public var active:SBool;			//active or not
	public var referer:SNull<SString<256>>; // referer list
	public var turnover90days : SNull<SFloat>; //turnover of the last 90 days
	public var turnoverTotal : SNull<SFloat>; //turnover since the beginning
	public var marketTurnoverSinceFreemiumResetDate : SFloat; //market turnover since freemium reset date
	public var ldate : SDateTime; //last update date
	
	public function new(){
		super();
		active = false;
		type = VTInvited;
		ldate = Date.now();
	}

	public static function getOrCreate(vendor:db.Vendor):VendorStats{
		var vs = VendorStats.manager.select($vendor==vendor,true);
		if(vs==null){
			vs = new VendorStats();
			vs.vendor = vendor;
			vs.insert();			
		}
		return vs;
	}

	/**
		update stats of a vendor
	**/
	public static function updateStats(vendor:db.Vendor){

		//Find lat/lnt if not set
		if(vendor.lat==null && !vendor.isDisabled()){
			vendor.lock();

			var address = vendor.getAddress();
			
			try{
				var res = service.Mapbox.geocode(address);
	
				if(res!=null){
					if(res.geometry.coordinates[0]!=null){					
						vendor.lat = res.geometry.coordinates[1];
						vendor.lng = res.geometry.coordinates[0];
						vendor.update();
					}
				}else{
					vendor.lat = 0;
					vendor.lng = 0;
					vendor.update();
				}
			}catch(e:Dynamic){
				App.current.logError("Unable to geocode vendor #"+vendor.id+" : "+Std.string(e));
			}
		}

		var vs = getOrCreate(vendor);
		var cpro = pro.db.CagettePro.getFromVendor(vendor);

		//type
		if(cpro!=null){
trace(cpro.offer);
			//if(vendor.isTest){
			//	vs.type = VTCproTest;
			if(cpro.offer == Training){				
				vs.type = VTStudent;
			}else if(cpro.offer==Discovery){
				vs.type = VTDiscovery;
			}else if(cpro.offer==Member){
				vs.type = VTCpro;

			}else if(cpro.offer==Marketplace)	{
				vs.type = VTMarketplace;			
			}else if(cpro.offer==Pro){
				// Get subscription plan
				var result:Dynamic = BridgeService.call('/subscriptions/plan/${vendor.stripeCustomerId}');
				if (result!=null){
					if(result.plan=='year'){
						vs.type = VTCproSubscriberYearly;
					} else if(result.plan=='month'){
						vs.type = VTCproSubscriberMontlhy;
					}
				}else{
					throw "unable to get stripe subscription status";
				}
			}else if(cpro.offer==Marketplace){
				vs.type = VTMarketplace;
			}
			
		}else{

			if(PVendorCompany.manager.count($vendor ==vendor)>0){
				vs.type = VTInvitedPro;
			}else{
				vs.type = VTInvited;

				for( c in vendor.getActiveContracts() ){	
					if(c.contact==null)	continue;
					if ( c.contact.email==vendor.email ){
						vs.type = VTFree;
						break;
					}			
				}
			}
		}

		var now = Date.now();
		vs.ldate = now;
		
		//turnover 30 days
		var tf = new tools.Timeframe( DateTools.delta(now,-1000.0*60*60*24*90) , now , false );

		var cids = vendor.getContracts().array().map(v -> v.id);
		vs.turnover90days = 0.0;
		for( d in db.Distribution.manager.search($date > tf.from && $date < tf.to && ($catalogId in cids), false)){
			vs.turnover90days += d.getTurnOver();
		}
		vs.turnover90days = Math.round(vs.turnover90days);

		//turnover 3 months
		vs.turnoverTotal = 0.0;
		for( d in db.Distribution.manager.search( $catalogId in cids , false)){
			vs.turnoverTotal += d.getTurnOver();
		}
		vs.turnoverTotal = Math.round(vs.turnoverTotal);

		vs.active = vs.turnover90days > 0;

		//freemium turnover 
		var from = vendor.freemiumResetDate;
		vs.marketTurnoverSinceFreemiumResetDate = 0;
		var cids = vendor.getContracts().array().filter( cat -> cat.group.hasShopMode() ).map(c -> c.id);//only shopMode
		for( d in db.Distribution.manager.search($date > from && $date < now && ($catalogId in cids), false)){
			vs.marketTurnoverSinceFreemiumResetDate += d.getTurnOver();
		}

		//a trainee cannot be active
		if(cpro != null && cpro.offer == Training){
			vs.active = false;
		}

		vs.update();
		return vs;
	}

	
}