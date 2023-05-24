package pro.controller;
import form.CagetteForm;
import sugoi.form.elements.*;
using tools.DateTool;
using tools.ObjectListTool;
import datetime.DateTime;
import service.DistributionService;

class Sales extends controller.Controller
{

    var baseUrl : String;
	var company : pro.db.CagettePro;
	var vendor : db.Vendor;
	
	public function new(company:pro.db.CagettePro) 
	{
		super();
		view.company = this.company = company;
		view.vendor = this.vendor = company.vendor;
		view.nav = ["delivery"];
        baseUrl = vendor.getURL()+"/sales";
	}
	
	@tpl('plugin/pro/sales/default.mtt')
	public function doDefault(){

        if(company.captiveGroups) throw Redirect(vendor.getURL()+"/delivery");
		
		var now = Date.now();
		var today = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, 0, 0);
		var sixMonth = DateTool.deltaDays(Date.now(), Math.round(30.5 * 6));

        //get multidistribs 
        var distribs = [];
		var groups = company.getClients();
        for( group in groups){
            for( md in db.MultiDistrib.getFromTimeRange(group, today,sixMonth) ){
                distribs.push(md);
            }
        }
        //sort by date
        distribs.sort(function(a,b){
            return Math.round(a.distribStartDate.getTime()/1000) - Math.round(b.distribStartDate.getTime()/1000);
		});
		
		//export form		
		var form = new sugoi.form.Form("exportCpro");
		var data = [
			{label:"Par produits", value :"products"},
			{label:"Par membres", value :"members"},
			{label:"Par "+App.current.getTheme().groupWordingShort.toUpperCase()+"-produits (CSV)", value :"groups"},
		];
		form.addElement(new sugoi.form.elements.RadioGroup("type","Type",data,data[0].value));
		var now = DateTime.now();	
		// last month timeframe
		var from = now.snap(Week(Down,Monday));
		var to = now.snap(Week(Up,Sunday));
		form.addElement( new form.CagetteDatePicker("startDate","Du", from.getDate() ) );
		form.addElement( new form.CagetteDatePicker("endDate","au", to.getDate() ) );
		if(form.isValid()){

			var startDate:Date = form.getValueOf("startDate");
			var endDate:Date = form.getValueOf("endDate");
			endDate = new Date(endDate.getFullYear(),endDate.getMonth(),endDate.getDate(),23,59,0);
			switch(form.getValueOf("type")){
				case "products":
					throw Redirect(vendor.getURL()+'/delivery/exportByProducts/?startDate=${startDate}&endDate=${endDate}');
				case "members" : 
					throw Redirect(vendor.getURL()+'/delivery/exportByMembers/?startDate=${startDate}&endDate=${endDate}');
				case "groups" : 
					throw Redirect(vendor.getURL()+'delivery/exportByGroups/?startDate=${startDate}&endDate=${endDate}');
				default :
					throw Error(vendor.getURL()+'/delivery', "type d'export inconnu");
				
			}
		}
		view.form = form;

		view.groups = groups;
        view.distribs = distribs;
        view.getFromGroup = connector.db.RemoteCatalog.getFromGroup;

		checkToken();

	}

    function doParticipate(md:db.MultiDistrib,contract:db.Catalog){
		try{
			service.DistributionService.participate(md,contract);
		}catch(e:tink.core.Error){
			throw Error(baseUrl,e.message);
		}		
		throw Ok(baseUrl,"Vous participez maintenant à la distribution du "+view.hDate(md.getDate()));
	}

    /**
		Delete a distribution
	**/
	function doDelete(d:db.Distribution) {
		
		try {
			service.DistributionService.cancelParticipation(d,false);
		} catch(e:tink.core.Error){
			throw Error(baseUrl, e.message);
		}		
		throw Ok(baseUrl, "Vous ne participez plus à la distribution du "+view.hDate(d.date) );
	}

    /**
		Edit order opening and closing dates
	 */
	@tpl('plugin/pro/sales/dates.mtt')
	function doEdit(d:db.Distribution) {
		
		var form = CagetteForm.fromSpod(d);
		form.removeElementByName("placeId");
		form.removeElementByName("date");
		form.removeElementByName("end");
		form.removeElement(form.getElement("contractId"));		
		form.removeElement(form.getElement("distributionCycleId"));
		form.addElement(new form.CagetteDateTimePicker("orderStartDate", "Date d'ouverture des commandes", d.orderStartDate));	
		form.addElement(new form.CagetteDateTimePicker("orderEndDate", "Date de clôture des commandes", d.orderEndDate));
		
		if (form.isValid()) {

			var orderStartDate = null;
			var orderEndDate = null;
			try{

				orderStartDate = form.getValueOf("orderStartDate");
				orderEndDate = form.getValueOf("orderEndDate");

				//do not launch event, avoid notifs for now
				d = DistributionService.editAttendance(d,orderStartDate,orderEndDate,false);							

			} catch(e:tink.core.Error){
				throw Error(vendor.getURL()+'/sales' , e.message);
			}
			
			throw Ok(vendor.getURL()+'/sales', "Votre participation à cette distribution a été mise à jour" );
			
		} else {
			app.event(PreEditDistrib(d));
		}
		
		view.form = form;
        view.distribution = d;
        var ua = db.UserGroup.get(app.user,d.catalog.group);
        view.groupAdmin = ua!=null && (ua.isGroupManager() || ua.canManageAllContracts());
		view.title = 'Participation de ${d.catalog.vendor.name} à la distribution du ${view.dDate(d.date)}';
	}
	
}