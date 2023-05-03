package service;
import sugoi.form.elements.IntInput;
import tools.DateTool;
import db.Catalog;
import tink.core.Error;

class CatalogService{


    public static function getForm( catalog:db.Catalog ) : sugoi.form.Form {

		if ( catalog.group == null || catalog.vendor == null ) {
			throw new tink.core.Error( "Un des éléments suivants est manquant : le marché ou le producteur." );
		}

		var t = sugoi.i18n.Locale.texts;

		var customMap = new form.CagetteForm.FieldTypeToElementMap();
		customMap["DDate"] = form.CagetteForm.renderDDate;
		customMap["DTimeStamp"] = form.CagetteForm.renderDDate;
		customMap["DDateTime"] = form.CagetteForm.renderDDate;

		var form = form.CagetteForm.fromSpod( catalog, customMap );
		
		form.removeElement(form.getElement("groupId") );
		form.removeElement(form.getElement("type"));
		form.removeElement(form.getElement("vendorId"));

		//For all types and modes
		if ( catalog.id != null ) {
			form.removeElement(form.getElement("distributorNum"));
		} else {

			form.getElement("name").value = "Commande " + catalog.vendor.name;
			form.getElement("startDate").value = Date.now();
			form.getElement("endDate").value = DateTools.delta( Date.now(), 365.25 * 24 * 60 * 60 * 1000 );
		}

		form.addElement( new sugoi.form.elements.Html( "vendorHtml", '<b>${catalog.vendor.name}</b> ( ${catalog.vendor.zipCode} ${catalog.vendor.city} )', t._( "Vendor" ) ), 3 );

		var contact = form.getElement("userId");
		form.removeElement( contact );
		form.addElement( contact, 4 );
		contact.required = true;

		return form;
    }
    
    /**
        Check input data when updating a catalog
    **/
    public static function checkFormData( catalog:db.Catalog, form:sugoi.form.Form ) {

        //distributions should always happen between catalog dates
        if(form.getElement("startDate")!=null){
            for( distribution in catalog.getDistribs(false)){
                //accept a distrib on the last day of catalog
                var endDate =  DateTool.setHourMinute(form.getValueOf("endDate"),23,59);

                if(distribution.date.getTime() < form.getValueOf("startDate").getTime()){
                    throw new Error("Il y a des distributions antérieures à la date de début du catalogue");
                }
                if(distribution.date.getTime()> endDate.getTime()){
                    throw new Error("Il y a des distributions postérieures à la date de fin du catalogue");
                }
            }
        }
	}

}