package hosted.controller;

import datetime.*;
import db.Vendor.DisabledReason;
import hosted.db.CompanyCourse;
import pro.db.CagettePro;
import pro.db.VendorStats;
import sys.db.Connection;

class Course extends sugoi.BaseController
{
	/**
		Courses Dashboard
	**/
	@tpl("plugin/pro/hosted/course/default.mtt")
	function doDefault(){
if (App.current.getSettings().noCourse==true) {
			throw Redirect("/");
		}

		var now :DateTime = Date.now();				
		var from = now.snap(Month(Down)).add(Day(-1)).snap(Month(Down)).getDate();			
		var to = now.snap(Month(Up)).snap(Month(Up)).add(Day(-1)).getDate();
		var timeframe = new tools.Timeframe(from,to);


		/*var stats = [];
		for( i in 0...5){
			var d = DateTools.delta(Date.now(),1000*60*60*24*30.5*(i-1));
			var month = Formatting.MONTHS[d.getMonth()];
			

			var students = 0;
			var courses = hosted.db.Course.manager.search($date >= from && $date<to);
			var courseIds = tools.ObjectListTool.getIds(courses);
			for( s in CompanyCourse.manager.search($courseId in courseIds) ){
				if(s.company.training) students++;
			}
			

			stats.push({month:month, students:students,courses:courses});
		}*/
		// view.stats = stats;
		view.timeframe = timeframe;
		view.courses = hosted.db.Course.manager.search($date >= timeframe.from && $date <= timeframe.to,{orderBy:-date},false);
	}

	/**
		View a course
	**/
	@tpl("plugin/pro/hosted/course/view.mtt")
	public function doView(course:hosted.db.Course){
		
		view.course = course;

		var total = 0;
		var actives = 0;
		
		/*for( cc in course.getCompanies()){
			var c = cc.company;
			if(c==null) continue;
			if(c.offer==Training) continue;
			total++;

			// var vs = VendorStats.getOrCreate(cc.company.vendor);

			// if(vs.active){
			// 	actives++;
			// 	Reflect.setProperty(c,"active",vs.active);
			// } 
		}*/
		// view.activeRate = total>0 ? actives/total*100 : 0;

		//emails
		var emails = new Map<String,String>();
		for( cc in course.getCompanies()){
			if(cc.company==null || cc.company.vendor==null || cc.company.vendor.email==null) continue;
			emails.set(cc.company.vendor.email,cc.company.vendor.email);
		}

		view.emails = Lambda.array(emails);
	}


	@tpl("form.mtt")
	public function doSwitch(c:pro.db.CagettePro){
		view.title = "Déplacer "+c.vendor.name+" sur une autre formation";
		var form = new sugoi.form.Form("addcompany");
		var companyCourse = CompanyCourse.manager.select($company==c,true);
		// var companyCourse = CompanyCourse.manager.select($company==c && $course ==companyCourse.course,true);

		var data = [];
		var from = DateTools.delta(Date.now(),-1000.0*60*60*24*30*1);
		var to =   DateTools.delta(Date.now(),1000.0*60*60*24*30*8);
		for( course in hosted.db.Course.manager.search($date>from && $date<to,{orderBy:date})){
			data.push({label:course.name,value:course.id});
		}
		form.addElement( new sugoi.form.elements.IntSelect("course","Formation",data) );


		if (form.isValid()){
			// var course = hosted.db.Course.manager.get(form.getValueOf("course"));
			// companyCourse.course = course;
			// companyCourse.company = c;
			// companyCourse.update();
			sys.db.Manager.cnx.request('update CompanyCourse set courseId=${form.getValueOf("course")} where courseId=${companyCourse.course.id} and companyId=${companyCourse.company.id}');
			
			throw Ok("/p/hosted/course/view/" + form.getValueOf("course") , c.vendor.name + " a bien été déplacé");
		}

		view.form = form;
	}

	@tpl("form.mtt")
	public function doInsert(){
		view.title = "Créer une formation";
		var form = new sugoi.form.Form("course");
		/*var data = [];
		var teachersEmail = [			
			"sebastien@alilo.fr",
			"francois@alilo.fr",
			"paul@alilo.fr",
			"mhelene@alilo.fr"
		];
		for( teacher in teachersEmail){
			var u = db.User.manager.select($email==teacher,false);
			if(u==null) continue;
			data.push({label:u.getName(),value:u.id});
		}*/

		form.addElement( new sugoi.form.elements.StringInput("ref","Identifiant de la formation","") );
		// form.addElement( new sugoi.form.elements.IntSelect("teacher","Formateur",data) );
		form.addElement( new sugoi.form.elements.StringInput("course","Nom de la formation","") );
		form.addElement( new form.CagetteDatePicker("date","Date J1"));
		form.addElement( new form.CagetteDatePicker("end","Fin de la formation"));

		if (form.isValid()){
			
			var c = new hosted.db.Course();
			c.ref = form.getValueOf("ref");
			c.name = form.getValueOf("course");
			// c.teacher = db.User.manager.get(form.getValueOf("teacher"));
			c.date = form.getValueOf("date");
			c.end = form.getValueOf("end");
			c.insert();

			/*var group = new db.Group();
			group.name = "Les producteurs de la session "+c.ref+" - retrait au café";
			group.groupType = db.Group.GroupType.ProducerDrive;
			group.flags.unset(CagetteNetwork);
			group.insert();

			var place = new db.Place();
			place.name = "Place du marché";
			place.group = group;
			place.zipCode = "000";
			place.city = "St Martin de la Cagette";
			place.insert();

			var distrib = service.DistributionService.createMd(
				place,
				tools.DateTool.setHourMinute(c.end,16,0),//date de distrib le jour de la J2
				tools.DateTool.setHourMinute(c.end,18,0),
				tools.DateTool.setHourMinute(c.date,8,0),//ouverture de la J1 à J2-1
				tools.DateTool.setHourMinute(DateTools.delta(c.end,-1000.0*60*60*24),21,0),
				[],
				null
			);

			c.group = group;
			c.update();*/
			
			throw Ok("/p/hosted/course/", c.name +" a bien été créé");
		}

		view.form = form;
	}

	@tpl("form.mtt")
	public function doEdit(course:hosted.db.Course){
		view.title = "Modifier une formation";
		var form = new sugoi.form.Form("course");
		form.addElement( new sugoi.form.elements.StringInput("ref","Identifiant de la formation",course.ref) );
		form.addElement( new sugoi.form.elements.StringInput("course","Nom de la formation",course.name) );
		form.addElement( new form.CagetteDatePicker("date","Date J1",course.date));
		form.addElement( new form.CagetteDatePicker("end","Fin de la formation",course.end));

		if (form.isValid()){
			
			var c = course;
			c.lock();
			c.ref = form.getValueOf("ref");
			c.name = form.getValueOf("course");
			c.date = form.getValueOf("date");
			c.end = form.getValueOf("end");
			c.update();
			
			throw Ok("/p/hosted/course/view/"+c.id , c.name +" a bien été créé");
		}

		view.form = form;
	}

	/**
	 *  Créé des comptes cpro + génere des mots de passe pour Cagette et Moodle
	 */
	@admin @tpl('form.mtt')
	public function doIdentifiers(course:hosted.db.Course){

		var form = new sugoi.form.Form("moodle");
		form.addElement(new sugoi.form.elements.Html("html","Saisissez ci dessous un stagiaire par ligne avec ce format : <pre>Nom, Prénom, email</pre> (séparateur virgule ou tab)"));
		form.addElement(new sugoi.form.elements.TextArea("data","Stagiaires"));
		// form.addElement(new sugoi.form.elements.Checkbox("teacher","Donner accès au formateur aux Cpro",false,true));

		if(form.isValid()){
			var data = "lastName,firstName,email\n"+form.getValueOf("data");
			data  = StringTools.replace(data,"\t",",");
			var csv = new sugoi.tools.Csv();
			csv.setHeaders(["lastName","firstName","email"]);
			var data = csv.importDatasAsMap(data);

			//create group
			
			var group = course.group;
			var distrib = group==null ? null : db.MultiDistrib.manager.select($group==group,false);
			
			for(d in data){

				if (!sugoi.form.validators.EmailValidator.check(d["email"])) throw "L'email "+d["email"]+" est invalide";

				//create user
				var cagetteUser = d["email"];
				var cagettePass = null;
				var moodleUser = generateUsername(d["firstName"],d["lastName"]);
				var moodlePass = generatePassword();
				

				var u = db.User.manager.select($email == d["email"] || $email2 == d["email"], true);
				if (u == null){
					u = new db.User();
					u.firstName = d["firstName"];
					u.lastName = d["lastName"];
					u.email = d["email"];
					cagettePass = moodlePass;					
					u.setPass(moodlePass);		
					u.insert();
				}else{
					//password is unknown, user already exists
					cagettePass = null;
				}

				if(group!=null){
					u.makeMemberOf(group);
				}
				

				//create vendor + Company
				var v = new db.Vendor();
				v.name = "La ferme de "+u.firstName+" (formation)";
				v.zipCode = "000";
				v.status = "formation";
				v.email = u.email;
				v.insert();

				var c = new pro.db.CagettePro();				
				c.offer = Training; // training account
				c.vendor = v;
				c.insert();

				//bypass disabling because of missing legal infos
				v.disabled = null;
				v.update();

				VendorStats.getOrCreate(v);

				//create default catalog
				var catalog = new pro.db.PCatalog();
				catalog.company = c;
				catalog.name = "Mes produits en vente";
				catalog.startDate = new Date(2000,0,1,0,0,0);
				catalog.endDate = new Date(2030,0,1,0,0,0);
				catalog.insert();

				if(group!=null){
					var rc = pro.service.PCatalogService.linkCatalogToGroup(catalog, group, u.id);
					service.DistributionService.participate(distrib,rc.getContract());
				}

				//add user + teacher
				pro.db.PUserCompany.make(u,c,true,true);
				//if(form.getValueOf("teacher")==true) pro.db.PUserCompany.make(course.teacher,c);

				//add it to the course
				hosted.db.CompanyCourse.make(c,course,u, moodleUser, moodlePass, cagetteUser, cagettePass);				
			}

			// App.current.session.data.moodle = data;

			var msg = 'Les comptes ont été créés.';
			throw Ok("/p/hosted/course/view/"+course.id , msg );
		}
		view.title = "Identifiants pour "+course.name;
		view.form = form;
	}

	@tpl("plugin/pro/hosted/credentialsSheet.mtt")
	function doCredentialsSheet(course:hosted.db.Course){
		
		view.data = course;
	}

	/**
	 *  EXport a CSV for Moodle
	 */
	function doMoodleCsv(course:hosted.db.Course){
		var headers = ["username","password","firstname","lastname","email","course1","group1"];
		var data = [];
		for( d in course.getCompanies()) {			
			data.push([d.moodleUser, d.moodlePass, d.user.firstName, d.user.lastName, d.cagetteUser, "Développer ses ventes en ligne - 2022/2023",course.name ]);
		}

		sugoi.tools.Csv.printCsvDataFromStringArray( data , headers , "Feuille identifiants.csv" );

		view.data = data;
	}

	function doIdMail(company:pro.db.CagettePro,course:hosted.db.Course){
		var companyCourse = CompanyCourse.manager.select($company==company && $course==course,false);
		if(companyCourse==null) throw Error("/p/hosted/course/view/"+course.id,"Ce producteur ne participe pas à cette formation");
		if(companyCourse.moodleUser==null) throw Error("/p/hosted/course/view/"+course.id,"Erreur : impossible d'envoyer le mail car le mot de passe Moodle n'a pas été sauvegardé");

		var m = new sugoi.mail.Mail();
		m.setSender(App.current.getTheme().email.senderEmail, App.current.getTheme().name);
		m.setRecipient(companyCourse.user.email);
		m.setReplyTo("deborah@alilo.fr", "Deborag REYT");							
		m.setSubject("Formation Cagette - La formation commence maintenant" );		
		m.setHtmlBody( app.processTemplate("plugin/pro/mail/sendIdToStudent.mtt", {companyCourse:companyCourse,hDate:Formatting.hDate} ) );
		App.sendMail(m);	

		throw Ok("/p/hosted/course/view/"+course.id,"Identifiants envoyés à "+companyCourse.user.getName());
	}

	private function generatePassword():String{
		var letters = "abcdefghijklmnopqrstuvwxyz";
		var upperCaseLetters = letters.toUpperCase();
		var specials = "_-.#";
		var pass  = new StringBuf();
		for(i in 0...8){

			if(i<=3){
				if(i%2==0){
					pass.add(letters.charAt(Std.random(letters.length)));
				}else{
					pass.add(upperCaseLetters.charAt(Std.random(upperCaseLetters.length)));
				}				
			}else if(i == 4){
				pass.add(specials.charAt(Std.random(specials.length)));
			} else {
				pass.add(Std.random(10));
			}
		}
		return  pass.toString();
	}

	private function generateUsername(first:String,last:String):String{
		var s = cleanString(first).substr(0, 64) +"."+ cleanString(last).substr(0,64);
		return s.toLowerCase();
	}

	function cleanString(str:String):String{
		str = StringTools.replace(str, " ", "");
		str = StringTools.replace(str, "'", "");
		str = StringTools.replace(str, "é", "e");
		str = StringTools.replace(str, "è", "e");
		str = StringTools.replace(str, "ê", "e");
		str = StringTools.replace(str, "ç", "c");
		str = StringTools.replace(str, "à", "a");
		str = StringTools.replace(str, "â", "a");
		return str;
		
	}

	/**
	 *  copy to def accounts + Remove access to old accounts
	 */
	function doDisable(company:pro.db.CagettePro){

		if(company.offer!=Training) throw "ce compte producteur n'est pas un compte pédagogique !";
		var cc = hosted.db.CompanyCourse.manager.select($company==company);

		//remove access to this cpro
		var users = [];
		for( uc in pro.db.PUserCompany.getUsers(company)){
			uc.lock();
			users.push(uc.user);
			uc.delete();
		}
		
		//no user have access to this vendor
		var v = company.vendor;
		v.lock();
		v.disabled = DisabledReason.Banned;
		v.update();

		//remove access to groups linked to this cpro + remove future distribs
		for( cat in company.getCatalogs()){
			for( rc in connector.db.RemoteCatalog.getFromPCatalog(cat,true)){

				//remove membership
				var contract = rc.getContract();
				if(contract==null){
					rc.delete();
					continue;
				}
				var group = contract.group;				
				for( u in users){
					var ua = db.UserGroup.get(u,group,true);
					if(ua!=null) ua.delete();
				}
				
				group.lock();
				group.regOption = db.Group.RegOption.Closed;
				group.update();

				//delete distribs wich happen 24h after end of course				
				for (d in contract.getDistribs(true)){
					if(d.date.getTime() > cc.course.end.getTime() + (1000*60*60*24) ){
						try{
							service.DistributionService.cancelParticipation(d);
						}catch(e:Dynamic){ }
					}
				}
			}
		}
		
		if( cc!=null && cc.course!=null){
			throw Ok("/p/hosted/course/view/"+cc.course.id,"Accès retiré pour "+company.vendor.name);
		} else{
			throw Ok("/p/hosted/course/");
		}
	}


	/**
		link discovery account to course
	**/
	@admin @tpl("plugin/pro/hosted/course/linkDiscovery.mtt")
	function doLinkDiscovery(trainingCpro:pro.db.CagettePro,course:hosted.db.Course){

		view.cpro = trainingCpro;

		//try to detect doubles
		var vendors = db.Vendor.manager.search($email==trainingCpro.vendor.email && $id!=trainingCpro.vendor.id);
		view.getVS = function (vendor) return VendorStats.getOrCreate(vendor);
		view.getCpro = function(vendor) return CagettePro.getFromVendor(vendor);
		
		if(vendors.length>0){

			view.vendors = vendors;

			if(app.params.get("vendor")!=null){
				var vendor = db.Vendor.manager.get(app.params.get('vendor').parseInt(),false);

				hosted.service.CourseService.attachDiscoveryAccountToCourse(trainingCpro,vendor,course);

				throw Ok("/p/hosted/course/view/"+course.id,"Compte rattaché à la formation");
				
			}

		}else{

			/*hosted.service.CourseService.attachDiscoveryAccountToCourse(cpro,null,course);

			//final message
			var cc = hosted.db.CompanyCourse.manager.select($company==cpro);
			if( cc!=null && cc.course!=null){
				throw Ok("/p/hosted/course/view/"+cc.course.id,"Compte définitif créé pour : "+cpro.vendor.name);
			} else{
				throw Ok("/p/hosted/course/");
			}*/

			throw Error("/p/hosted/course/view/"+course.id,"Impossible de trouver un compte producteur Découverte ou Pro avec le même email !
			Le producteur doit obligatoirement ouvrir un compte découverte pour faire la formation");
		}
		
		
	}
	

	/**
		switch to Member offer
	**/
	@admin 
	function doCproDef(cpro:pro.db.CagettePro,course:hosted.db.Course){

		var vendor = cpro.vendor;
		cpro.lock();
		cpro.offer = Member;
		cpro.update();

		// Cancel running subscription
		try {
			service.BridgeService.call('/subscriptions/cancel/${vendor.id}');
		} catch (e: Dynamic) {
			Sys.println(e);
		}

		//Do not disable
		vendor.lock();		
		switch(vendor.disabled){
			case DisabledReason.TurnoverLimitReached : vendor.disabled = null;
			case DisabledReason.DisabledInvited : vendor.disabled = null;
			case DisabledReason.MarketplaceNotActivated : vendor.disabled = null;
			case DisabledReason.MarketplaceDisabled : vendor.disabled = null;
			default:
		}
		vendor.update();

		//refresh stats
        VendorStats.updateStats(vendor);

		throw Ok("/p/hosted/course/view/"+course.id,"Compte passé en formule Membre");
	}

	
	
}