// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require bootstrap-sprockets
//= require jquery_ujs
//= require jQuery.print
//= require js/notify/pnotify.core
//= require js/notify/pnotify.buttons
//= require dataTables/jquery.dataTables
//= require dataTables/extras/dataTables.responsive
//= require dataTables/jquery.dataTables
//= require dataTables/extras/dataTables.buttons
//= require turbolinks
//= require pickadate/lib/compressed/picker
//= require pickadate/lib/compressed/picker.date
//= require pickadate/lib/compressed/picker.time

    $BODY = $('body'),
    $MENU_TOGGLE = $('#menu_toggle'),
    $SIDEBAR_MENU = $('#sidebar-menu'),
    $SIDEBAR_FOOTER = $('.sidebar-footer'),
    $LEFT_COL = $('.left_col'),
    $RIGHT_COL = $('.right_col'),
    $NAV_MENU = $('.nav_menu'),
    $FOOTER = $('footer');

$(document).ready(function() {

	$(".data-table").contentChange(function(){
	   $RIGHT_COL.css('min-height', $(window).height());

        
	});



 });

jQuery.fn.contentChange = function(callback){
    var elms = jQuery(this);
    elms.each(
      function(i){
        var elm = jQuery(this);
        elm.data("lastContents", elm.html());
        window.watchContentChange = window.watchContentChange ? window.watchContentChange : [];
        window.watchContentChange.push({"element": elm, "callback": callback});
      }
    )
    return elms;
  }

  setInterval(function(){
    if(window.watchContentChange){
      for( i in window.watchContentChange){
        if(window.watchContentChange[i].element.data("lastContents") != window.watchContentChange[i].element.html()){
          window.watchContentChange[i].callback.apply(window.watchContentChange[i].element);
          window.watchContentChange[i].element.data("lastContents", window.watchContentChange[i].element.html())
        };
      }
    }
  },500);

$(document).on('change', '.data-table', function (event) {
    alert("hello");
});