jQuery(function () {
  var body, controllerClass, controllerName, action;

  body = $('#main_content');
  controllerClass = body.data( "controller-class" );
  controllerName = body.data( "controller-name" );
  action = body.data( "action" );

  function exec(controllerClass, controllerName, action) {
    var ns, railsNS;

    ns = CATARSE;
    railsNS = controllerClass ? controllerClass.split("::").slice(0, -1) : [];

    _.each(railsNS, function(name){
      if(ns) {
        ns = ns[name];
      }
    });

    if ( ns && controllerName && controllerName !== "" ) {
      if(ns[controllerName] && _.isFunction(ns[controllerName][action])) {
        var view = window.view = new ns[controllerName][action]();
      }
    }
  }

  function exec_filter(filterName){
    if(CATARSE.Common && _.isFunction(CATARSE.Common[filterName])){
      CATARSE.Common[filterName]();
    }
  }

  exec_filter('init');
  exec( controllerClass, controllerName, action );
  exec_filter('finish');
  if($("#md-slider-1").length){
    $("#md-slider-1").mdSlider({fullwidth:true,transitions:"fade",width:980,height:365,responsive:true,slideShowDelay:6e3,slideShow:true,loop:true,showLoading:false,showArrow:1,showBullet:1,posBullet:2,showThumb:false,enableDrag:true})
  }
});
