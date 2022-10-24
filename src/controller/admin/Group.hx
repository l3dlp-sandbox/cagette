package controller.admin;

class Group extends controller.Controller
{

	public function new() {
		super();	
	}

	@admin
	function doView(g:db.Group) {
        throw Redirect("/p/hosted/group/"+g.id);
	}

}