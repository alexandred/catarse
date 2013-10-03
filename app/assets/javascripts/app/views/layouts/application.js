CATARSE.LayoutsApplicationView = Backbone.View.extend({

  initialize: function() {
    this.dropDownOpened = false;
    _.bindAll(this, "render", "flash", "currentUserDropDown")
    this.render();
  },

  events: {
    "submit .search": "search",
    "focus .form_login.bootstrap-form input":"markLoginForm",
    "focus .form_register.bootstrap-form input":"markRegisterForm",
  },

  markRegisterForm: function(e){
    rootElement = $(e.currentTarget).closest('.bootstrap-form')
    if(!rootElement.hasClass('actived')) {
      $('.bootstrap-form').removeClass('actived');
      rootElement.addClass('actived');
    }
  },

  markLoginForm: function(e){
    rootElement = $(e.currentTarget).closest('.bootstrap-form')
    if(!rootElement.hasClass('actived')) {
      $('.bootstrap-form').removeClass('actived');
      rootElement.addClass('actived');
    }
  },

  search: function(event) {
    var query = this.$(event.target).find("#search").val()
    if(!($('#main_content').data("controller-name") == "explore" && $('#main_content').data("action") == "index") && query.length > 0)
      location.href = "/explore#search/" + query
    return false
  },

  flash: function() {
    setTimeout( function(){ this.$('.flash').slideDown('slow') }, 100)
    if( ! this.$('.flash a').length) setTimeout( function(){ this.$('.flash').slideUp('slow') }, 16000)
    $(window).click(function(){ this.$('.flash').slideUp() })
  },

  currentUserDropDown: function(e) {
    e.preventDefault();
    $dropdown = this.$('.dropdown.user');
    if(!this.dropDownOpened) {
      $dropdown.show();
      this.dropDownOpened = true;
    } else {
      this.dropDownOpened = false;
      $dropdown.hide();
    }

  },

  
  submitDropDown: function(e) {
    e.preventDefault();
    $dropdown = this.$('.dropdown.submit-project');
    if(!this.dropDownOpened) {
      $dropdown.show();
      this.$('.dropdown.explore-projects').hide();
      this.dropDownOpened = true;
      this.exploreDropDownOpened = false;
 //   } else {
 //     this.dropDownOpened = false;
 //     $dropdown.hide();
    }

  },

  closesubmitDropDown: function(e) {
    e.preventDefault();
    $dropdown = this.$('.dropdown.submit-project');
    setInterval(function () {
    if(this.dropDownOpened) {
      this.dropDownOpened = false;
      $dropdown.hide();
    }
    },500);
  },

  exploreDropDown: function(e) {
    e.preventDefault();
    $dropdown = this.$('.dropdown.explore-projects');
    if(!this.exploreDropDownOpened) {
      $dropdown.show();
      this.$('.dropdown.submit-project').hide();
      this.exploreDropDownOpened = true;
      this.dropDownOpened = false;
    } else {
      this.exploreDropDownOpened = false;
      $dropdown.hide();
    }

  },
  
  render: function(){
    this.flash()
  }

})
