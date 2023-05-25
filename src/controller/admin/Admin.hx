package controller.admin;

import pro.db.CagettePro;
import db.Graph;
import haxe.Json;
import sugoi.form.elements.TextArea;
import Common;
import db.BufferedJsonMail;
import db.Catalog;
import db.MultiDistrib;
import db.TxpProduct;
import haxe.web.Dispatch;
import hosted.db.GroupStats;
import mangopay.db.MangopayGroupPayOut;
import pro.db.VendorStats;
import service.GraphService;
import sugoi.Web;
import sugoi.db.Variable;
import sys.FileSystem;
import tools.ObjectListTool;
import tools.Timeframe;

class Admin extends Controller {
	public function new() {
		super();
		view.category = 'admin';

		// trigger a "Nav" event
		var nav = new Array<Link>();
		var e = Nav(nav, "admin");
		app.event(e);
		view.nav = e.getParameters()[0];
		view.pageTitle = "Administration";
	}

	@tpl("admin/default.mtt")
	function doDefault() {
		view.now = Date.now();
		view.ip = Web.getClientIP();

		var groups = db.Group.manager.unsafeCount('SELECT COUNT(g.id) FROM `Group` g, GroupStats gs WHERE gs.groupId=g.id AND gs.active=1');
		var dispatchGroups = db.Group.manager.unsafeCount('SELECT COUNT(g.id) FROM `Group` g, GroupStats gs WHERE betaFlags & 4 != 0 AND gs.groupId=g.id AND gs.active=1');
		view.groups = groups;
		view.dispatchGroups = dispatchGroups;

		if (app.params.get("reloadSettings") == "1") {
			app.setSettings();
			app.setTheme();
			view.theme = app.getTheme();
			view.settings = app.getSettings();
			throw Ok('/admin', "Settings and theme reloaded");
		}
	}

	@tpl("form.mtt")
	function doTheme() {
		var f = new sugoi.form.Form("theme");

		f.addElement(new sugoi.form.elements.TextArea("theme", "theme", Json.stringify(app.getTheme()), true, null, "style='height:800px;'"));
		f.addElement(new sugoi.form.elements.Html("html", "<a href='https://www.jsonlint.com/' target='_blank'>jsonlint.com</a>"));

		if (f.isValid()) {
			var json:Theme = null;
			try {
				json = Json.parse(f.getValueOf("theme"));
				Variable.set("whiteLabel", Json.stringify(json));
			} catch (e:Dynamic) {
				throw Error('/admin/theme', "Erreur : " + Std.string(e));
			}

			throw Ok("/admin/", "Thème mis à jour");
		}

		view.form = f;
		view.title = "Modifier le thème";
	}

	@tpl('admin/basket.mtt')
	function doBasket(basket:db.Basket) {
		view.basket = basket;
	}

	@tpl("admin/emails.mtt")
	function doEmails(?args:{?reset:BufferedJsonMail}) {
		if (args != null && args.reset != null) {
			args.reset.lock();
			args.reset.tries = 0;
			args.reset.update();
		}

		var emails:Array<Dynamic> = service.BridgeService.call("/mail/getUnsentMails");

		var browse = function(index:Int, limit:Int) {
			var filtered = [];
			for (i in 0...limit) {
				if (i + index < emails.length) {
					filtered.push(emails[i + index]);
				}
			}
			return filtered;
		}

		var count = emails.length;
		view.browser = new sugoi.tools.ResultsBrowser(count, 10, browse);
		view.num = count;
	}

	function doVendor(d:haxe.web.Dispatch) {
		d.dispatch(new controller.admin.Vendor());
	}

	function doUser(d:haxe.web.Dispatch) {
		d.dispatch(new controller.admin.User());
	}

	function doGroup(d:haxe.web.Dispatch) {
		d.dispatch(new controller.admin.Group());
	}

	/**
		export taxo as CSV
	**/
	@tpl("admin/taxo.mtt")
	function doTaxo() {
		var categs = db.TxpCategory.manager.search(true, {orderBy: displayOrder});
		view.categ = categs;

		if (app.params.get("csv") == "1") {
			var data = new Array<Array<String>>();
			for (c in categs) {
				data.push([c.name]);
				for (c2 in c.getSubCategories()) {
					data.push(["", c2.name]);
					for (p in c2.getProducts()) {
						data.push(["", "", Std.string(p.id), p.name]);
					}
				}
			}
			sugoi.tools.Csv.printCsvDataFromStringArray(data, [], "categories.csv");
		}
	}

	/**
		merge TxpProduct categs
	**/
	@admin @tpl('form.mtt')
	function doMergeCategs() {
		var f = new sugoi.form.Form("merge");
		var data = [];
		for (c in TxpProduct.manager.search(true, {orderBy: name})) {
			data.push({label: c.name + " #" + c.id, value: c.id});
		}
		f.addElement(new sugoi.form.elements.IntSelect("toreplace", "Fusionner", data));
		f.addElement(new sugoi.form.elements.IntSelect("by", "dans", data));
		f.addElement(new sugoi.form.elements.Checkbox("delete", "supprimer la première catégorie", true));

		if (f.isValid()) {
			var oldCateg = TxpProduct.manager.get(f.getValueOf("toreplace"));
			var newCateg = TxpProduct.manager.get(f.getValueOf("by"));

			for (p in db.Product.manager.search($txpProduct == oldCateg, true)) {
				p.txpProduct = newCateg;
				p.update();
			}

			for (p in pro.db.PProduct.manager.search($txpProduct == oldCateg, true)) {
				p.txpProduct = newCateg;
				p.update();
			}

			if (f.getValueOf("delete") == true && oldCateg.countProducts() == 0) {
				oldCateg.delete();
			}

			throw Ok("/admin/taxo", "Catégories fusionnées");
		}

		view.form = f;
		view.title = "Fusion de categories de niveau 3";
	}

	/**
	 *  Display errors logged in DB
	 */
	@tpl("admin/errors.mtt")
	function doErrors(args:{?user:Int, ?like:String, ?empty:Bool}) {
		view.now = Date.now();

		view.u = args.user != null ? db.User.manager.get(args.user, false) : null;
		view.like = args.like != null ? args.like : "";

		var sql = "";
		if (args.user != null)
			sql += " AND uid=" + args.user;
		// if( args.like!=null && args.like != "" ) sql += " AND error like "+sys.db.Manager.cnx.quote("%"+args.like+"%");
		if (args.empty) {
			sys.db.Manager.cnx.request("truncate table Error");
		}

		var errorsStats = sys.db.Manager.cnx.request("select count(id) as c, DATE_FORMAT(date,'%y-%m-%d') as day from Error where date > NOW()- INTERVAL 1 MONTH "
			+ sql
			+ " group by day order by day")
			.results();
		view.errorsStats = errorsStats;

		view.browser = new sugoi.tools.ResultsBrowser(sugoi.db.Error.manager.unsafeCount("SELECT count(*) FROM Error WHERE 1 " + sql), 20,
			function(start, limit) {
				return sugoi.db.Error.manager.unsafeObjects("SELECT * FROM Error WHERE 1 " + sql + " ORDER BY date DESC LIMIT " + start + "," + limit, false);
			});
	}

	@tpl("admin/graph.mtt")
	function doGraph(?key:String, ?month:Int, ?year:Int) {
		if (month == null) {
			var now = Date.now();
			year = now.getFullYear();
			month = now.getMonth();
		}

		if (key == null) {
			// display graphs index
			return;
		}

		var from = new Date(year, month, 1, 0, 0, 0);
		var to = new Date(year, month + 1, 0, 23, 59, 59);

		var data = GraphService.getRange(key, from, to);

		var averageValue = 0.0;
		var total = 0.0;
		var estimatedTotal = 0.0;

		for (d in data)
			total += d.value;
		averageValue = total / data.length;
		estimatedTotal = total + ((31 - data.length) * averageValue);

		view.data = data;
		view.averageValue = Formatting.formatNum(averageValue);
		view.total = Formatting.formatNum(total);
		view.estimatedTotal = Formatting.formatNum(estimatedTotal);
		view.key = key;
		view.year = year;
		view.month = month;
		view.from = from;
		view.to = to;
	}

	@tpl("admin/stats.mtt")
	function doStats() {
		var now = Date.now();

		var from = new Date(now.getFullYear(), now.getMonth(), now.getDate() - 1, 0, 0, 0);
		var to = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, 0, 0);

		// find previous monday
		while (from.getDay() != 1)
			from = DateTools.delta(from, -1000 * 60 * 60 * 24);

		// find next monday
		while (to.getDay() != 1)
			to = DateTools.delta(to, 1000 * 60 * 60 * 24);

		var tf = new Timeframe(from, to);
		view.tf = tf;

		from = tf.from;
		to = tf.to;

		view.newVendors = db.Vendor.manager.count($cdate >= from && $cdate < to);
		view.newVendorsByType = sys.db.Manager.cnx.request('SELECT count(v.id) as count, vs.type
		FROM Vendor v, VendorStats vs 
		WHERE vs.vendorId=v.id AND cdate >= "${from.toString()}" and cdate < "${to.toString()}"
		group by vs.type
		order by type')
			.results();

		view.activeVendors = sys.db.Manager.cnx.request("SELECT count(v.id) FROM Vendor v, VendorStats vs where vs.vendorId=v.id and vs.active=1")
			.getIntResult(0);

		view.activeVendorsByType = sys.db.Manager.cnx.request('SELECT count(v.id) as count, vs.type
		FROM Vendor v, VendorStats vs 
		WHERE vs.vendorId=v.id AND active=1
		group by vs.type
		order by type')
			.results();

		view.activeGroups = GroupStats.manager.count($active);
		view.activeUsers = sys.db.Manager.cnx.request('SELECT sum(gs.membersNum) FROM `Group` g, GroupStats gs where gs.groupId=g.id and gs.active=1')
			.getIntResult(0);
		view.newUsers = sys.db.Manager.cnx.request('SELECT count(id) FROM `User` where cdate >= "${from.toString()}" and cdate < "${to.toString()}"')
			.getIntResult(0);

		view.newGroups = db.Group.manager.count($cdate >= from && $cdate < to);

		view.newGroupsByAdmin = sys.db.Manager.cnx.request('SELECT count(gs.contactType) as count,gs.contactType FROM `Group` g, GroupStats gs 
		where gs.groupId=g.id 
		and g.cdate >= "${from.toString()}" and g.cdate < "${to.toString()}"
		group by contactType
		order by count desc')
			.results();

		view.activeGroupsByAdmin = sys.db.Manager.cnx.request('SELECT count(gs.contactType) as count,gs.contactType FROM `Group` g, GroupStats gs 
		where gs.groupId=g.id 
		and gs.active=1
		group by contactType
		order by count desc')
			.results();

		// global stats
		var stats = Graph.getData("global", from);
		if (stats == null){
			if(to.getTime() > Date.now().getTime()){
				stats = {};
			}else{
				stats = GraphService.global(from,to);
				Graph.recordData("global",stats,from);
			}
			
		}
			
		view.stats = stats;
	}

	public static function addUserToGroup(email:String, group:db.Group) {
		var user = db.User.manager.search($email == email).first();
		if (user != null) {
			var usergroup = new db.UserGroup();
			usergroup.user = user;
			usergroup.group = group;
			usergroup.insert();
		}
	}

	/**
		edit general messages on homepage
	**/
	@tpl('form.mtt')
	function doMessages() {
		var homeVendorMessage = Variable.get("homeVendorMessage");
		var homeGroupAdminMessage = Variable.get("homeGroupAdminMessage");

		var f = new sugoi.form.Form("msg");
		f.addElement(new sugoi.form.elements.TextArea("homeVendorMessage", "Accueil producteurs", homeVendorMessage));
		f.addElement(new sugoi.form.elements.TextArea("homeGroupAdminMessage", "Accueil admin de "+App.current.getTheme().groupWordingShort_plural, homeGroupAdminMessage));

		if (f.isValid()) {
			Variable.set("homeVendorMessage", f.getValueOf("homeVendorMessage"));
			Variable.set("homeGroupAdminMessage", f.getValueOf("homeGroupAdminMessage"));
			throw Ok("/admin/messages", "Messages mis à jour");
		}

		view.title = "Messages";
		view.form = f;
	}


	@tpl('admin/news.mtt')
	function doNews() {}

	function doTestMails(?args:{tpl:String}) {
		// list existing mail templates
		var dirs = [
			Web.getCwd() + "/../lang/master/tpl/mail/",
			Web.getCwd() + "/../lang/master/tpl/plugin/pro/who/mail/",
			Web.getCwd() + "/../lang/master/tpl/plugin/pro/mail/"
		];
		var tpls = [];

		for (dir in dirs) {
			var files = FileSystem.readDirectory(dir);
			for (file in files)
				tpls.push(dir + file);
		}

		Sys.print("<ul>");
		for (tpl in tpls) {
			var i = tpl.indexOf("/lang/master/tpl/") + "/lang/master/tpl/".length;
			tpl = tpl.substr(i);
			Sys.print('<li><a href="/admin/testMails?tpl=$tpl">$tpl</a></li>');
		}
		Sys.print("</ul>");

		var group = db.Group.manager.select(true, false);
		var user = db.User.manager.select(true, false);
		var d = db.Distribution.manager.select(true, false);
		var contract = d.catalog;
		var catalog = d.catalog;

		if (args != null && args.tpl != null) {
			var res = App.current.processTemplate(args.tpl, {
				group:group,
				user:user,
				d:d,
				distribution:d,
				catalog:catalog,
				contract:contract,
				text:"Lorem Ipsum",
				orders:[]
			} );
			Sys.print(res);
		}
	}

	@tpl('admin/settings.mtt')
	function doSettings() {}

	@tpl('admin/superadmins.mtt')
	function doSuperadmins() {
		view.superadmins = db.User.manager.search($rights.has(Admin), false);
	}

	@tpl('admin/stripe.mtt')
	function doStripe(){
	}

	@tpl('admin/showcase.mtt')
	function doShowcase(){
	}

	/**
		export des distribs pour Charlotte
	**/
	@tpl('admin/exportDistribs.mtt')
	function doExportDistribs(){

		var now = Date.now();
		var year = now.getFullYear();
		var month = now.getMonth();

		var from = new Date(year, month-1, 1, 0, 0, 0);
		var to 	 = new Date(year, month  , 1, 0, 0, 0);
		var tf = new tools.Timeframe(from,to);

		view.tf = tf;

		if(app.params.get("export")=="1"){
			var data = [];
			for(md in db.MultiDistrib.manager.search($distribStartDate > tf.from && $distribStartDate <= tf.to,false)){

				var group = md.group;

				var contactType = "";
				if(group.contact!=null){
					var cpros = service.VendorService.getCagetteProFromUser(group.contact);
					if(cpros.length>0){
						var vendor = cpros.find(cpro -> cpro.offer!=Training);				
						contactType = vendor==null ? "USER" : Std.string(vendor.offer).toUpperCase();
					} else {
						contactType = "USER";
					}
				}else{
					contactType = "NONE";
				}

				var baskets = md.getBaskets();
				var turnover = 0.0;
				
				for( d in md.getDistributions()){

					var v = d.catalog.vendor;
					var cpro = v.getCpro();
					var vendorStatus = cpro==null ? "Invited" : Std.string(cpro.offer);

					data.push({
						distributionId: md.id,
						marketId : group.id,
						url : "https://app.cagette.net/admin/group/view/"+group.id,
						vendorId : v.id,
						vendorName : v.name,
						vendorProfession : v.getProfession(),
						vendorStatus : vendorStatus,
						
						contactType : contactType,
						membersNum : group.getMembersNum(),
						
						day : md.distribStartDate.getDate(),
						month : md.distribStartDate.getMonth()+1,
						year : md.distribStartDate.getFullYear(),

						zipCode : md.place.zipCode.substr(0,2),
						address : md.place.address1,
						city : md.place.city,
						turnover : Math.round(d.getTurnOver()),
						basketNums : baskets.length,
						vendorsInGroup : group.getActiveVendors().length,						
					});

				}

				baskets = [];
				
			}
			var headers = ["distributionId","marketId","url","vendorId","vendorName","vendorStatus","vendorProfession","basketNums","contactType","membersNum","day","month","year","zipCode","address","city","turnover"];
			sugoi.tools.Csv.printCsvDataFromObjects(data, headers, "Distributions");
		}
	}

	/**
		Stats sur les groupes actifs
	**/
	function doGroupStats() {
		
		var sql = "SELECT g.id as marketId,g.name as marketName,g.userId,u.firstName,u.lastName,u.email,
		v.id as vendorId,v.name as vendorName,v.zipCode
		FROM `Group` g
		inner join GroupStats gs on g.id=gs.groupId
		inner join User u on g.userId=u.id
		left join Vendor v on v.email=u.email 
		where gs.active = 1 and gs.mode = \"MARKET\"
		order by g.id";

		var groups = sys.db.Manager.cnx.request(sql).results();
		var data = [];
		var now = Date.now();
		for (g in groups) {
			// var catalogs = g.getActiveContracts();
			// var cids = catalogs.map(c -> c.id);
			// var vendors = tools.ObjectListTool.deduplicate(catalogs.map(c -> c.vendor));
			// var from = DateTools.delta(now, -1000.0 * 60 * 60 * 24 * 365);
			// var to = now;
			// var distributions = MultiDistrib.getFromTimeRange(g, from, to);		
			var vendor = db.Vendor.manager.get(g.vendorId);
			var cpro = CagettePro.manager.select($vendor == vendor,false);

			data.push({
				marketId: g.marketId,
				marketName: g.marketName,
				userId: g.userId,
				firstName : g.firstName,
				lastName : g.lastName,
				email : g.email,
				vendorId : g.vendorId,
				vendorName : g.vendorName,
				zipCode : g.zipCode,
				vendorStatus : cpro==null ? null : Std.string(cpro.offer),
				vendorProfession : cpro==null ? null : vendor.getProfession(),
				// membersNum: untyped g.membersNum,
				// inscriptions: Std.string(g.regOption),
				// productNum: db.Product.manager.count($catalogId in cids),
				// vendorNum: vendors.length,
				// cproCatalogNum: untyped g.cproContractNum,
				// catalogNum: untyped g.contractNum,
				// turnover12months:Math.round(turnOver),
				// distribNum12months: distributions.length,
				// payments: g.allowedPaymentsType
			});
		}
		var headers = Reflect.fields(data[0]);
		sugoi.tools.Csv.printCsvDataFromObjects(data, headers, "stats_"+App.current.getTheme().groupWordingShort_plural);

	}
}
