//
// npm dependencies library
//
(function (scope) {
  "use-strict";
  scope.__registry__ = Object.assign({}, scope.__registry__, {
    //
    // list npm modules required in Haxe
    //
    "bootstrap.native": require("bootstrap.native"),
  });

  /*if (process.env.NODE_ENV !== 'production') {
      // enable React hot-reload
      require('haxe-modular');
    }*/
})(typeof $hx_scope != "undefined" ? $hx_scope : ($hx_scope = {}));
