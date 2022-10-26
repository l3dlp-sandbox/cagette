package controller;

class Distributions extends Controller {
	public function new() {
		super();
		view.category = "distribution";
	}

	function checkHasDistributionSectionAccess() {
		if (!app.user.canManageAllContracts())
			throw Error('/', t._('Forbidden action'));
	}

	@tpl('distribution/default2.mtt')
	function doDefault() {
		if (!app.getCurrentGroup().hasCagette2()){
			throw Redirect('/distribution');
		}
		checkHasDistributionSectionAccess();
	}

}
