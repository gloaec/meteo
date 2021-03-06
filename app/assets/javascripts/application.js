// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require underscore
//= require turbolinks
//= require bootstrap
//= require bootstrap-timepicker
//= require dataTables/jquery.dataTables
//= require dataTables/bootstrap/3/jquery.dataTables.bootstrap
//= require moment
//= require_tree .

jQuery.fn.outerHTML = function(s) {
  return (s)
  ? this.before(s).remove()
  : jQuery("<p>").append(this.eq(0).clone()).html();
}

function remove_fields(link) {
  $(link).parent().parent().find("input[type=hidden]").attr('value', true);
  $(link).parents(".fields").hide();
}

function add_fields(link, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g")
  $(content.replace(regexp, new_id)).insertBefore($(link));
}

(function(){

  "use strict";

  $(document).on('page:change', function(){

    $('.time').each(function(){
      var datetime = new Date($(this).data('datetime'));
      $(this).text(moment(datetime).format('HH:MM:SS'));
    });

    $('.timeago').each(function(){
      var datetime = new Date($(this).data('datetime'));
      $(this).text(moment(datetime).fromNow());
    });

    $('.date').each(function(){
      var datetime = new Date($(this).data('datetime'));
      $(this).text(moment(datetime).format('LL'));
    });

  });
}(jQuery));
