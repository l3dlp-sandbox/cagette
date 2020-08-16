package controller;
import sugoi.db.Cache;
import db.Catalog;
import service.SubscriptionService;
import tink.core.Error;
using Lambda;

class Subscriptions extends controller.Controller
{
	public function new()
	{
		super();		
	}

	
	/**
		View all the subscriptions for a catalog
	**/
	@tpl("contractadmin/subscriptions.mtt")
	function doDefault( catalog : db.Catalog ) {

		if ( !app.user.canManageContract( catalog ) ) throw Error( '/', t._('Access forbidden') );

		var catalogSubscriptions = SubscriptionService.getSubscriptions(catalog);
		//sort by validation, then username
		catalogSubscriptions.sort(function(a,b){
			if( (a.isValidated?"1":"0")+a.user.lastName > (b.isValidated?"1":"0")+b.user.lastName ){
				return 1;
			}else{
				return -1;
			}
		});
		
		view.catalog = catalog;
		view.c = catalog;
		view.subscriptions = catalogSubscriptions;
		view.validationsCount = catalogSubscriptions.count( function( subscription ) { return  !subscription.isValidated; } );
		view.dateToString = function( date : Date ) {

			return DateTools.format( date, "%d/%m/%Y");
		}
		view.subscriptionService = SubscriptionService;
		view.nav.push( 'subscriptions' );

		//generate a token
		checkToken();
	}
	
	public function doDelete( subscription : db.Subscription ) {
		
		if ( !app.user.canManageContract( subscription.catalog ) ) throw Error( '/', t._('Access forbidden') );
		
		var subscriptionUser = subscription.user;
		if ( checkToken() ) {

			try {
				SubscriptionService.deleteSubscription( subscription );
			}
			catch( error : Error ) {
				throw Error( '/contractAdmin/subscriptions/' + subscription.catalog.id, error.message );
			}
			throw Ok( '/contractAdmin/subscriptions/' + subscription.catalog.id, 'La souscription pour ' + subscriptionUser.getName() + ' a bien été supprimée.' );
		}
		throw Error( '/contractAdmin/subscriptions/' + subscription.catalog.id, t._("Token error") );
	}

	@tpl("contractadmin/editsubscription.mtt")
	public function doInsert( catalog : db.Catalog ) {

		if ( !app.user.canManageContract( catalog ) ) throw Error( '/', t._('Access forbidden') );

		var catalogProducts = catalog.getProducts();

		var startDateDP = new form.CagetteDatePicker("startDate","Date de début",catalog.startDate.getTime() > Date.now().getTime() ? catalog.startDate : Date.now() );
		view.startDate = startDateDP;

		var endDateDP = new form.CagetteDatePicker("endDate","Date de fin",catalog.endDate);
		view.endDate = endDateDP;

		if ( checkToken() ) {

			try {
				
				var userId = Std.parseInt( app.params.get( "user" ) );
				if ( userId == null || userId == 0 ) {

					throw Error( '/contractAdmin/subscriptions/insert/' + catalog.id, 'Veuillez sélectionner un membre.' );
				}
				var user = db.User.manager.get( userId );
				if ( user == null ) {

					throw Error( '/contractAdmin/subscriptions/insert/' + catalog.id, t._( "Unable to find user #::num::", { num : userId } ) );
				}
				if ( !user.isMemberOf( catalog.group ) ) {

					throw Error( '/contractAdmin/subscriptions/insert/' + catalog.id, user + " ne fait pas partie de ce groupe" );
				}

				//var startDate = Date.fromString( app.params.get( "startdate" ) );
				//var endDate = Date.fromString( app.params.get( "enddate" ) );
				
				startDateDP.populate();
				endDateDP.populate();
				var startDate = startDateDP.getValue();
				var endDate = endDateDP.getValue();

				if ( startDate == null || endDate == null ) {
					throw Error( '/contractAdmin/subscriptions/insert/' + catalog.id, "Vous devez sélectionner une date de début et de fin pour la souscription." );
				}
				
				var ordersData = new Array< { productId : Int, quantity : Float, ?userId2 : Int, ?invertSharedOrder : Bool } >();
				for ( product in catalogProducts ) {

					var quantity : Float = Std.parseFloat( app.params.get( 'quantity' + product.id ) );
					var user2 : db.User = null;
					var userId2 : Int = null;
					if( catalog.type == Catalog.TYPE_CONSTORDERS ) {

						userId2 = Std.parseInt( app.params.get( 'user2' + product.id ) );
					}
					var invert = false;
					if ( userId2 != null && userId2 != 0 ) {

						user2 = db.User.manager.get( userId2 );
						if ( user2 == null ) {

							throw Error( '/contractAdmin/subscriptions/insert/' + catalog.id, t._( "Unable to find user #::num::", { num : userId2 } ) );
						}
						if ( !user2.isMemberOf( catalog.group ) ) {

							throw Error( '/contractAdmin/subscriptions/insert/' + catalog.id, user + " ne fait pas partie de ce groupe." );
						}
						if ( user.id == user2.id ) {
							
							throw Error( '/contractAdmin/subscriptions/insert/' + catalog.id, "Vous ne pouvez pas alterner avec la personne qui a la souscription." );
						}

						invert = app.params.get( 'invert' + product.id ) == "true";

					}

					if ( quantity != 0 ) {

						if( catalog.type == Catalog.TYPE_CONSTORDERS ) {

							ordersData.push( { productId : product.id, quantity : quantity, userId2 : userId2, invertSharedOrder : invert } );
						}
						else {

							ordersData.push( { productId : product.id, quantity : quantity } );
						}
						
					}
					
				}

				if ( ordersData.length == 0 ) {
					throw Error( '/contractAdmin/subscriptions/insert/' + catalog.id, "Vous devez entrer au moins une quantité pour un produit." );
				}

				var absencesNb = Std.parseInt( app.params.get( 'absencesNb' ) );
				SubscriptionService.createSubscription( user, catalog, ordersData, absencesNb, startDate, endDate );

				throw Ok( '/contractAdmin/subscriptions/' + catalog.id, 'La souscription pour ' + user.getName() + ' a bien été ajoutée.' );

			} catch( error : Error ) {
				throw Error( '/contractAdmin/subscriptions/insert/' + catalog.id, error.message );
			}

		}
	
		view.title = 'Nouvelle souscription';
		view.edit = false;
		view.canOrdersBeEdited = true;
		view.c = catalog;
		view.catalog = catalog;
		view.showmember = true;
		view.members = app.user.getGroup().getMembersFormElementData();
		view.products = catalogProducts;
		view.absencesDistribDates = Lambda.map( SubscriptionService.getCatalogAbsencesDistribsForSubscription( catalog ), function( distrib ) return Formatting.dDate( distrib.date ) );

		view.nav.push( 'subscriptions' );

	}

	@tpl("contractadmin/editsubscription.mtt")
	public function doEdit( subscription : db.Subscription ) {

		if ( !app.user.canManageContract( subscription.catalog ) ) throw Error( '/', t._('Access forbidden') );

		var catalogProducts = subscription.catalog.getProducts();

		var canOrdersBeEdited = !SubscriptionService.hasPastDistribOrders( subscription );

		var startDateDP = new form.CagetteDatePicker("startDate","Date de début",subscription.startDate);
		var endDateDP = new form.CagetteDatePicker("endDate","Date de fin",subscription.endDate);
		view.endDate = endDateDP;
		view.startDate = startDateDP;

		if ( checkToken() ) {

			try {

				/*var startDate = Date.fromString( app.params.get( "startdate" ) );
				var endDate = Date.fromString( app.params.get( "enddate" ) );*/
				
				startDateDP.populate();
				endDateDP.populate();
				var startDate = startDateDP.getValue();
				var endDate = endDateDP.getValue();

				if ( startDate == null || endDate == null ) {
					throw Error( '/contractAdmin/subscriptions/edit/' + subscription.id, "Vous devez sélectionner une date de début et de fin pour la souscription." );
				}

				var ordersData = new Array< { productId : Int, quantity : Float, ?userId2 : Int, ?invertSharedOrder : Bool } >();
				
				if ( canOrdersBeEdited ) {

					for ( product in catalogProducts ) {

						var quantity : Float = Std.parseFloat( app.params.get( 'quantity' + product.id ) );
						var user2 : db.User = null;
						var userId2 : Int = null;
						if( subscription.catalog.type == Catalog.TYPE_CONSTORDERS ) {
							
							userId2 = Std.parseInt( app.params.get( 'user2' + product.id ) );
						}
						var invert = false;
						if ( userId2 != null && userId2 != 0 ) {

							user2 = db.User.manager.get( userId2 );
							if ( user2 == null ) {

								throw Error( '/contractAdmin/subscriptions/edit/' + subscription.id, t._( "Unable to find user #::num::", { num : userId2 } ) );
							}
							if ( !user2.isMemberOf( subscription.catalog.group ) ) {

								throw Error( '/contractAdmin/subscriptions/edit/' + subscription.id, subscription.user + " ne fait pas partie de ce groupe." );
							}
							if ( subscription.user.id == user2.id ) {
								
								throw Error( '/contractAdmin/subscriptions/edit/' + subscription.id, "Vous ne pouvez pas alterner avec la personne qui a la souscription." );
							}

							invert = app.params.get( 'invert' + product.id ) == "true";

						}

						if ( quantity != 0 ) {

							if( subscription.catalog.type == Catalog.TYPE_CONSTORDERS ) {

								ordersData.push( { productId : product.id, quantity : quantity, userId2 : userId2, invertSharedOrder : invert } );
							}
							else {
	
								ordersData.push( { productId : product.id, quantity : quantity } );
							}

						}
						
					}

					if ( ordersData.length == 0 ) {

						throw Error( '/contractAdmin/subscriptions/edit/' + subscription.id, "Vous devez entrer au moins une quantité pour un produit." );
					}
				}

				if ( !subscription.isValidated ) {

					var absencesNb = Std.parseInt( app.params.get( 'absencesNb' ) );
					SubscriptionService.updateSubscription( subscription, startDate, endDate, ordersData, null, absencesNb );
				}
				else {

					var absentDistribIds = new Array<Int>();
					for ( i in 0...subscription.getAbsencesNb() ) {
					
						absentDistribIds.push( Std.parseInt( app.params.get( 'absence' + i ) ) );
					}
					SubscriptionService.updateSubscription( subscription, startDate, endDate, ordersData, absentDistribIds );
				}

			} catch( error : Error ) {
				
				throw Error( '/contractAdmin/subscriptions/edit/' + subscription.id, error.message );
			}

			throw Ok( '/contractAdmin/subscriptions/' + subscription.catalog.id, 'La souscription pour ' + subscription.user.getName() + ' a bien été mise à jour.' );
		}

		view.title = 'Modification de la souscription pour ' + subscription.user.getName();
		view.edit = true;
		view.canOrdersBeEdited = canOrdersBeEdited;
		view.c = subscription.catalog;
		view.catalog = subscription.catalog;
		view.showmember = false;
		view.members = app.user.getGroup().getMembersFormElementData();
		view.products = catalogProducts;
		view.getProductOrder = function( productId : Int ) {
		
			return SubscriptionService.getCSARecurrentOrders( subscription, null ).find( function( order ) return order.product.id == productId );
		};
		view.startdate = subscription.startDate;
		view.enddate = subscription.endDate;
		view.subscription = subscription;
		view.nav.push( 'subscriptions' );
		view.absencesDistribs = Lambda.map( SubscriptionService.getCatalogAbsencesDistribsForSubscription( subscription.catalog, subscription ), function( distrib ) return { label : Formatting.hDate( distrib.date, true ), value : distrib.id } );
		view.canAbsencesBeEdited = SubscriptionService.canAbsencesBeEdited( subscription.catalog );
		view.absentDistribs = subscription.getAbsentDistribs();
		if( !subscription.isValidated ) {
			view.absencesDistribDates = Lambda.map( SubscriptionService.getCatalogAbsencesDistribsForSubscription( subscription.catalog ), function( distrib ) return Formatting.dDate( distrib.date ) );
		}

	}


	public function doValidate( subscription : db.Subscription ) {

		if ( !app.user.canManageContract( subscription.catalog ) ) throw Error( '/', t._('Access forbidden') );

		try {

			SubscriptionService.updateValidation( subscription );			

		}
		catch( error : Error ) {

			throw Error( '/contractAdmin/subscriptions/' + subscription.catalog.id, error.message );
		}

		throw Ok( '/contractAdmin/subscriptions/' + subscription.catalog.id, 'La souscription de ' + subscription.user.getName() + ' a bien été validée.' );
		
	}

	@admin
	public function doUnvalidate( subscription : db.Subscription ) {

		if( checkToken() ) {

			SubscriptionService.updateValidation( subscription, false );
			throw Ok( '/contractAdmin/subscriptions/' + subscription.catalog.id, 'Souscription dévalidée' );
		}

	}

	@logged @tpl("form.mtt")
	function doAbsences( subscription : db.Subscription, ?args: { returnUrl: String } ) {

		if( subscription.catalog.group.hasShopMode() ) throw Redirect( "/contract/view/" + subscription.catalog.id );

		if ( args != null && args.returnUrl != null ) {

			App.current.session.data.absencesReturnUrl = args.returnUrl;
		}
		
		var absencesNb = subscription.getAbsencesNb();

		if( !SubscriptionService.canAbsencesBeEdited( subscription.catalog ) || absencesNb == 0 ) {

			throw Redirect( App.current.session.data.absencesReturnUrl );
		}

		//TODO GET SUBSCRIPTION FOR THE ABSENCES PERIOD
		view.subscription = subscription;
		view.subscriptionService = SubscriptionService;
		view.catalog = subscription.catalog;
		view.absentDistribsMaxNb = subscription.catalog.absentDistribsMaxNb;
		view.absencesDistribs = SubscriptionService.getCatalogAbsencesDistribsForSubscription( subscription.catalog, subscription );

		var form = new sugoi.form.Form("subscriptionAbsences");
		var absencesDistribs = Lambda.map( SubscriptionService.getCatalogAbsencesDistribsForSubscription( subscription.catalog, subscription ), function( distrib ) return { label : Formatting.hDate( distrib.date, true ), value : distrib.id } );
		var absentDistribIds = subscription.getAbsentDistribIds();
		for ( i in 0...absencesNb ) {

			form.addElement(new sugoi.form.elements.IntSelect( "absentDistrib" + i, "Je ne pourrai pas venir le :", absencesDistribs.array(), absentDistribIds[i], true ));
		}
		view.form = form;
		
		if ( form.checkToken() ) {

			try {

				var absentDistribIds = new Array<Int>();
				for ( i in 0...absencesNb ) {
				
					absentDistribIds.push( Std.parseInt( form.getValueOf( 'absentDistrib' + i ) ) );
				}
				SubscriptionService.updateAbsencesDates( subscription, absentDistribIds );
				
			
			}
			catch( error : Error ) {
			
				throw Error( '/subscriptions/absences/' + subscription.id, error.message );
			}

			throw Ok( App.current.session.data.absencesReturnUrl, 'Vos dates d\'absences ont bien été mises à jour.' );

		}

	}

}