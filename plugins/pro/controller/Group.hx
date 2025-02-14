package pro.controller;
import haxe.macro.Expr.Catch;
import sugoi.form.Form;
using Std;

class Group extends controller.Controller
{

	var company : pro.db.CagettePro;
	var vendor : db.Vendor;
	
	public function new(company:pro.db.CagettePro) 
	{
		super();
		view.company = this.company = company;
		view.vendor = this.vendor = company.vendor;
	}
	
	@tpl('plugin/pro/group/view.mtt')
	function doDefault(g:db.Group) {
		
		view.group = g;
		var linkages = [];
		
		for ( cat in company.getCatalogs()){
			for ( rc in connector.db.RemoteCatalog.getFromPCatalog(cat)){
				if (rc.getContract().group.id == g.id) linkages.push(rc);
			}
		}		
		
		view.linkages = linkages;
		checkToken();
	}

	/**
		Remove a group and all its linkages
	**/
	@tpl('plugin/pro/form.mtt')
	function doRemoveGroup(){

		var form = new sugoi.form.Form("removeGroup");

		var data = [];
		for ( g in company.getClients()){			
			data.push( {id:g.id , label:g.name , value:g.id} );
		}
		
		form.addElement( new sugoi.form.elements.IntSelect("group", App.current.getTheme().groupWordingShort+" à retirer de mon espace producteur", cast data, true) );
		// form.addElement( new sugoi.form.elements.Checkbox("stayMember","Rester membre ce "+App.current.getTheme().groupWordingShort,false) );
		// form.addElement( new sugoi.form.elements.Checkbox("deleteDistribs","Supprimer les distributions futures",true) );
		form.addElement( new sugoi.form.elements.Checkbox("check","Je suis sûr(e) de vouloir quitter ce marché",true) );

		if(form.isValid()){

			var group = db.Group.manager.get(form.getValueOf("group"),false);

				for( rc in connector.db.RemoteCatalog.getFromGroup(company, group)){
				var c = rc.getContract(true);
				c.endDate = Date.now();
				c.update();
				
				rc.lock();
				rc.delete();

				for( distrib in c.getDistribs(true) ){
					try{
						service.DistributionService.cancelParticipation(distrib,false);
					}catch(e:tink.core.Error){
						throw Error(sugoi.Web.getURI(),e.message);
					}
				}
			}

			throw Ok(vendor.getURL(),"Vous avez quitté le "+App.current.getTheme().groupWordingShort+".");
		}
		view.form = form;
		view.title = "Quitter un "+App.current.getTheme().groupWordingShort;
		view.text = "En quittant un "+App.current.getTheme().groupWordingShort+", vous faites le choix de ne plus pouvoir y vendre vos produits.";
	}
	
	@tpl('plugin/pro/form.mtt')
	function doDuplicate(){
		
		var f = new sugoi.form.Form("g");
		
		//get client list
		var data = [];
		var remoteCatalogs = connector.db.RemoteCatalog.manager.search($remoteCatalogId in Lambda.map(company.getCatalogs(), function(x) return x.id), false); 		
		for ( rc in Lambda.array(remoteCatalogs)){
			var contract = rc.getContract();
			data.push( {id:contract.group.id,label:contract.group.name,value:contract.group.id} );
		}
		var data = tools.ObjectListTool.deduplicate(data);

		
		f.addElement( new sugoi.form.elements.IntSelect("group", "Choisissez un "+App.current.getTheme().groupWordingShort+" à dupliquer", cast data, true) );
		f.addElement( new sugoi.form.elements.StringInput("name", "Nom du nouveau "+App.current.getTheme().groupWordingShort, null, true) );
		f.addElement( new sugoi.form.elements.StringInput("place", "Nom du nouveau lieu de livraison", null, true) );
		
		if (f.isValid()){
			try{
				var s = new pro.service.ProGroupService(this.company);
				s.duplicateGroup( db.Group.manager.get(f.getValueOf("group")) ,false, f.getValueOf("name"),f.getValueOf("place"));
				
			}catch(e:tink.core.Error){
				throw Error(sugoi.Web.getURI(),e.message);
			}
			
			throw Ok(vendor.getURL(), view.fluc(App.current.getTheme().groupWordingShort)+" dupliqué");
		}
		
		view.form = f;
		view.title = "Dupliquer un "+App.current.getTheme().groupWordingShort;
	}
}