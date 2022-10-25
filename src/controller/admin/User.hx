package controller.admin;

class User extends controller.Controller
{

	public function new() {
		super();	
	}

	@admin
	function doView(u:db.User) {
        throw Redirect("/p/hosted/user/view/"+u.id);
	}

}