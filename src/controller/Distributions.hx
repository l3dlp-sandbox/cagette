package controller;
import service.VolunteerService;
import sugoi.form.elements.TextArea;
import sugoi.form.elements.IntSelect;

using Formatting;

class Distributions extends Controller {
	public function new() {
		super();
		view.category = "distribution";
	}

	function checkHasDistributionSectionAccess() {
		if (!app.user.canManageAllContracts())
			throw Error('/', t._('Forbidden action'));
	}

	@tpl('distribution/default.mtt')
	function doDefault() {		
		checkHasDistributionSectionAccess();
	}

		/**
		Members can view volunteers calendar for each role and multidistrib date.
		They can register or unregister to a volunteer role 
	**/
	@tpl('distribution/volunteersCalendar.mtt')
	function doVolunteersCalendar(?distrib:db.MultiDistrib, ?args:{?distrib:db.MultiDistrib,?role:db.VolunteerRole,?returnUrl:String}) {
		
		var user = app.user;
		var group = user.getGroup();

		var returnUrl = args.returnUrl != null ? args.returnUrl : '/distribution/volunteersCalendar';
		
		if (args != null && args.distrib != null && args.role != null) {
			// register to a role	
			try {
				service.VolunteerService.addUserToRole(user, args.distrib, args.role);
			} catch (e:tink.core.Error) {
				throw Error(returnUrl, e.message);
			}

			throw Ok(returnUrl, t._("You have been successfully assigned to the selected role."));
		}

		// duty periods user's participation		
		var timeframe = group.getMembershipTimeframe(Date.now());
		var multidistribs = db.MultiDistrib.getFromTimeRange(group, timeframe.from, timeframe.to);
		
		var uniqueRoles = VolunteerService.getUsedRolesInMultidistribs(multidistribs);
		var participation = VolunteerService.getUserParticipation([user],app.getCurrentGroup(),timeframe.from,timeframe.to).get(user.id);
		
		//needed at component init
		view.daysBeforeDutyPeriodsOpen = app.user.getGroup().daysBeforeDutyPeriodsOpen;
		view.toBeDone = participation.genericRolesToBeDone + participation.contractRolesToBeDone;
		view.done = participation.genericRolesDone + participation.contractRolesDone;
		view.timeframe = timeframe;
		if (distrib != null) {
			view.multiDistribId = distrib.id;
		}
	}

	/**
		Members can view volunteers planning for each role and multidistrib date
	**/
	@tpl('distribution/volunteersParticipation.mtt')
	function doVolunteersParticipation(?args:{?_from:Date, ?_to:Date}) {
		var from:Date = null;
		var to:Date = null;

		if (args != null && args._from != null && args._to != null) {
			from = args._from;
			to = args._to;
		} else {
			var timeframe = app.user.getGroup().getMembershipTimeframe(Date.now());
			from = timeframe.from;
			to = timeframe.to;
		}

		view.fromField = new form.CagetteDatePicker("from", "Date de début", from);
		view.toField = new form.CagetteDatePicker("to", "Date de fin", to);

		var multiDistribs = db.MultiDistrib.getFromTimeRange(app.getCurrentGroup(), from, to);
		var members = app.user.getGroup().getMembers().array();

		var participation = VolunteerService.getUserParticipation(members,app.getCurrentGroup(),from,to);
		view.participation = participation;
		view.members = members;
		view.multiDistribs = multiDistribs;

		var totalRolesDone = 0;
		var totalRolesToBeDone = 0;
		for(p in participation){
			totalRolesDone += p.genericRolesDone + p.contractRolesDone;
			totalRolesToBeDone += p.genericRolesToBeDone + p.contractRolesToBeDone;
		}
		view.totalRolesDone = totalRolesDone;
		view.totalRolesToBeDone = totalRolesToBeDone;

		view.from = from.toString().substr(0, 10);
		view.to = to.toString().substr(0, 10);
	}

		/**
		Remove current user from a volunteer role
	**/ 
	@tpl("form.mtt")
	function doUnsubscribeFromRole(distrib:db.MultiDistrib, role:db.VolunteerRole, ?args:{returnUrl:String, ?to:String}) {

		if (args != null && args.returnUrl != null) {
			var toArg = args.to != null ? "&to=" + args.to : "";
			App.current.session.data.volunteersReturnUrl = args.returnUrl + toArg;
		}

		var form = new sugoi.form.Form("unsubscribe");

		var returnUrl = App.current.session.data.volunteersReturnUrl != null ? App.current.session.data.volunteersReturnUrl : '/distribution/unsubscribeFromRole/'
			+ distrib.id
			+ '/'
			+ role.id;

		var volunteer = distrib.getVolunteerForRole(role);
		if (volunteer == null) {
			throw Error(returnUrl, t._("There is no volunteer to remove for this role!"));
		} else if (volunteer.user.id != app.user.id) {
			throw Error(returnUrl, t._("You can only remove yourself from a role."));
		}

		form.addElement(new TextArea("unsubscriptionreason", t._("Reason for leaving the role"), null, true, null, "style='width:500px;height:350px;'"));

		if (form.isValid()) {
			try {
				service.VolunteerService.removeUserFromRole(app.user, distrib, role, form.getValueOf("unsubscriptionreason"));
			} catch (e:tink.core.Error) {
				throw Error(returnUrl, e.message);
			}

			throw Ok(returnUrl, t._("You have been successfully removed from this role."));
		}

		view.title = 'Saisissez la raison pour laquelle vous vous désistez.';
		if (App.current.getSettings().unsubscribeVolunteerRoleReasonOnlyForAdmin==true){
			view.text = "La raison de votre désistement sera uniquement communiquée aux administrateurs de ce groupe";
		}
		view.form = form;
	}

		/**
		enable/disable volunteer roles for the specified multidistrib
	**/
	@tpl("form.mtt")
	function doVolunteerRoles(distrib:db.MultiDistrib) {
		var form = new sugoi.form.Form("volunteerroles");

		var roles = [];

		// Get all the volunteer roles for the group and for the selected contracts
		var allRoles = VolunteerService.getRolesFromGroup(distrib.getGroup());
		var generalRoles = allRoles.filter(role -> role.catalog == null);
		var checkedRoles = [];
		var roleIds:Array<Int> = distrib.volunteerRolesIds != null ? distrib.volunteerRolesIds.split(",").map(Std.parseInt) : [];

		// general roles
		for (role in generalRoles) {
			roles.push({label: role.name, value: Std.string(role.id)});
			if (Lambda.has(roleIds, role.id)) {
				checkedRoles.push(Std.string(role.id));
			}
		}

		// display roles linked to active contracts in this distrib
		for (distrib in distrib.getDistributions()) {
			var cid = distrib.catalog.id;
			var contractRoles = allRoles.filter(role -> role.catalog != null && role.catalog.id == cid);
			for (role in contractRoles) {
				roles.push({label: role.name + " - " + distrib.catalog.vendor.name, value: Std.string(role.id)});
				if (roleIds == null || Lambda.has(roleIds, role.id)) {
					checkedRoles.push(Std.string(role.id));
				}
			}
		}

		//display activated roles which should not be active
		var unactivatedRoleIds = roleIds.filter( rid -> {
			return checkedRoles.find(r -> r==Std.string(rid))==null;
		});
		for(rid in unactivatedRoleIds){
			var role = allRoles.find( r -> r.id==rid);
			if(role==null) continue;
			roles.push({label: role.name +" (?)", value: Std.string(role.id)});
			checkedRoles.push(Std.string(role.id));
		}

		var volunteerRolesCheckboxes = new sugoi.form.elements.CheckboxGroup("roles", "", roles, checkedRoles, true);
		form.addElement(volunteerRolesCheckboxes);

		if (form.isValid()) {
			try {
				var roleIds:Array<Int> = form.getValueOf("roles").map(Std.parseInt);
				service.VolunteerService.updateMultiDistribVolunteerRoles(distrib, roleIds);
			} catch (e:tink.core.Error) {
				throw Error("/distribution/volunteerRoles/" + distrib.id, e.message);
			}

			throw Ok("/distribution", t._("Volunteer Roles have been saved for this distribution"));
		}

		view.title = "Sélectionner les rôles nécéssaires à la distribution du " + view.hDate(distrib.getDate());
		view.form = form;
	}

	/**
		Assign volunteer to roles for the specified multidistrib
	**/
	@tpl("form.mtt")
	function doVolunteers(distrib:db.MultiDistrib) {
		var form = new sugoi.form.Form("volunteers");

		var volunteerRoles = distrib.getVolunteerRoles();
		var volunteers = distrib.getVolunteers();
		

		if (volunteerRoles == null) {
			throw Error('/distribution/volunteerRoles/${distrib.id}', t._("You need to first select the volunteer roles for this distribution"));
		}

		var members = app.user.getGroup().getMembers().array().map(user -> {label: user.getName(), value: user.id});
		for (role in volunteerRoles) {			
			var selectedVolunteer = distrib.getVolunteerForRole(role);
			var selectedUserId = selectedVolunteer != null ? selectedVolunteer.user.id : null;
			form.addElement(new IntSelect(Std.string(role.id), role.name, members, selectedUserId, false, t._("No volunteer assigned")));
		}

		if (form.isValid()) {
			try {
				var roleIdsToUserIds = new Map<Int, Int>();
				var datas = form.getData();
				for (k in datas.keys())
					roleIdsToUserIds[Std.parseInt(k)] = datas[k];
				service.VolunteerService.updateVolunteers(distrib, roleIdsToUserIds);
			} catch (e:tink.core.Error) {
				throw Error("/distribution/volunteers/" + distrib.id, e.message);
			}

			throw Ok("/distribution", t._("Volunteers have been assigned to roles for this distribution"));
		}

		view.title = t._("Select a volunteer for each role for this multidistrib");
		view.form = form;
	}

	/**
		Counter management
	**/
	@tpl('distribution/counter.mtt')
	function doCounter(distribution:db.MultiDistrib) {
		checkHasDistributionSectionAccess();

		if (app.params.get("counterBeforeDistrib") != null) {
			distribution.lock();
			distribution.counterBeforeDistrib = Std.parseFloat(app.params.get("counterBeforeDistrib"));
			distribution.update();
		}
		view.distribution = distribution;

		#if plugins
		var sales = mangopay.MangopayPlugin.getMultiDistribDetailsForGroup(distribution);
		view.sales = sales;
		#end

		// memberships
		var membershipAmount = 0.0;
		var membershipNum = 0;
		if (distribution.group.hasMembership) {
			// membership num

			var ms = new service.MembershipService(distribution.group);
			var memberships = ms.getMembershipsFromDistrib(distribution);
			membershipNum = memberships.length;
			view.membershipNum = membershipNum;

			// membership amount

			for (m in memberships) {
				membershipAmount += m.operation.amount;
			}
			view.membershipAmount = membershipAmount;
			view.memberships = memberships;
		}

		// orders total by VAT rate
		var ordersByVat = service.ReportService.getOrdersByVAT(distribution);
		view.ordersByVat = ordersByVat;

		// user who have not paid / paid too much / partially paid
		var notPaid = new Array<{user:db.User, amount:Float}>();
		var partiallyPaid = new Array<{user:db.User, amount:Float}>();
		var paidTooMuch = new Array<{user:db.User, amount:Float}>();

		for (basket in distribution.getBaskets()) {
			var orderOp = basket.getOrderOperation(false);
			if (orderOp == null)
				continue;
			var ops = basket.getPaymentsOperations();
			var paid = 0.0;
			var order = Math.abs(orderOp.amount);

			if (ops.length == 0 && order > 0) {
				notPaid.push({user: basket.getUser(), amount: basket.getOrdersTotal()});
			} else {
				for (o in ops)
					paid += o.amount;
				if (paid.roundTo(2) > order.roundTo(2)) {
					paidTooMuch.push({user: basket.getUser(), amount: paid - order});
				}
				if (paid.roundTo(2) < order.roundTo(2)) {
					partiallyPaid.push({user: basket.getUser(), amount: order - paid});
				}
			}
		}

		if (app.params.get("csv") == "1") {
			var out = new Array<Array<String>>();
			out.push(['Fond de caisse avant distribution', distribution.counterBeforeDistrib.string()]);
			#if plugins
			out.push(['Encaissements en liquide', sales.cashTurnover.ttc.string()]);
			out.push([
				'La caisse doit contenir',
				(distribution.counterBeforeDistrib + sales.cashTurnover.ttc)
				.string()
			]);
			out.push(['Encaissements en chèque', sales.checkTurnover.ttc.string()]);
			out.push(['Encaissements en virement', sales.transferTurnover.ttc.string()]);
			#end
			out.push([]);
			out.push(['Total commande par taux de TVA', 'HT', 'TTC']);
			for (k in ordersByVat.keys()) {
				out.push([
					(k / 100) + "%",
					Formatting.formatNum(ordersByVat[k].ht),
					Formatting.formatNum(ordersByVat[k].ttc)
				]);
			}
			out.push([]);
			out.push(['Commandes non payées']);
			out.push(['Membre', 'Montant impayé']);
			for (u in notPaid)
				out.push([u.user.getName(), Formatting.formatNum(u.amount)]);
			out.push([]);
			out.push(['Commandes payées partiellement']);
			out.push(['Membre', 'Montant manquant']);
			for (u in partiallyPaid)
				out.push([u.user.getName(), Formatting.formatNum(u.amount)]);
			out.push([]);
			out.push(['Avoirs']);
			out.push(['Membre', 'Montant avoir']);
			for (u in paidTooMuch)
				out.push([u.user.getName(), Formatting.formatNum(u.amount)]);
			out.push([]);
			out.push(['Nombre de cotisations saisies', Formatting.formatNum(membershipNum)]);
			out.push(['Montant des cotisations', Formatting.formatNum(membershipAmount)]);

			app.setTemplate(null);
			sugoi.tools.Csv.printCsvDataFromStringArray(out, [], "Encaissements " + view.hDate(distribution.distribStartDate) + ".csv");
		}

		view.notPaid = notPaid;
		view.paidTooMuch = paidTooMuch;
		view.partiallyPaid = partiallyPaid;
	}

	/**
		Cagette 2 distribution attendance sheet and export page
	**/
	@tpl('distribution/export.mtt')
	function doExport(multiDistrib: db.MultiDistrib) {
		checkHasDistributionSectionAccess();
		view.multiDistribId = multiDistrib.id;
	}

	/**
		Change a price in orders.
	**/
	@tpl('form.mtt')
	function doChangePrice(distrib:db.MultiDistrib) {
		checkHasDistributionSectionAccess();
		var form = new sugoi.form.Form("changePrice");

		var datas = [];
		for (d in distrib.getDistributions()) {
			datas.push({label: d.catalog.name.toUpperCase(), value: null});
			for (p in d.catalog.getProducts(false)) {
				datas.push({label: "---- " + p.getName() + " : " + p.getPrice() + view.currency(), value: p.id});
			}
		}

		form.addElement(new sugoi.form.elements.IntSelect("product", t._("Product which price has changed"), datas, null, true));
		form.addElement(new sugoi.form.elements.FloatInput("price", t._("New price"), 0, true));

		if (form.isValid()) {
			var pid = form.getValueOf("product");
			var product = db.Product.manager.get(pid, false);
			if (pid == null || pid == 0 || product == null) {
				throw Error(sugoi.Web.getURI(), t._("Please select a product"));
			}
			var price:Float = form.getValueOf("price");

			var count = 0;
			for (order in distrib.getOrders()) {
				if (product.id == order.product.id) {
					// change price
					order.lock();
					order.productPrice = price;
					order.update();

					service.PaymentService.onOrderConfirm([order]); // updates payments
					count++;
				}
			}
			var productName = product.getName();
			var priceStr = price + view.currency();
			throw Ok("/distribution/validate/" + distrib.id,
				t._("The price of ::product:: has been modified to ::price:: in orders.", {product: productName, price: priceStr}));
		}

		view.form = form;
		view.title = t._("Change the price of a product in orders");
		view.text = "Attention, cette opération met à jour le prix d'un produit dans les commandes de cette distribution, mais ne change pas le prix du produit dans le catalogue.";
	}

	/**
		Remove a product from orders.
	**/
	@tpl('form.mtt')
	function doMissingProduct(distrib:db.MultiDistrib) {
		checkHasDistributionSectionAccess();

		var form = new sugoi.form.Form("missingProduct");

		var datas = [];
		for (d in distrib.getDistributions()) {
			datas.push({label: d.catalog.name.toUpperCase(), value: null});
			for (p in d.catalog.getProducts(false)) {
				datas.push({label: "---- " + p.getName() + " : " + p.getPrice() + view.currency(), value: p.id});
			}
		}

		form.addElement(new sugoi.form.elements.IntSelect("product", t._("Undelivered product"), datas, null, true));

		if (form.isValid()) {
			var pid = form.getValueOf("product");
			var product = db.Product.manager.get(pid, false);
			if (pid == null || pid == 0 || product == null) {
				throw Error(sugoi.Web.getURI(), t._("Please select a product"));
			}
			var count = 0;
			for (order in distrib.getOrders()) {
				if (product.id == order.product.id) {
					// set qt to 0
					service.OrderService.edit(order, 0);
					service.PaymentService.onOrderConfirm([order]); // updates payments
					count++;
				}
			}
			throw Ok("/distribution/validate/" + distrib.id, t._("The undelivered product has been removed from ::n:: orders.", {n: count}));
		}

		view.form = form;
		view.title = t._("Remove an undelivered product from orders");
	}

}
