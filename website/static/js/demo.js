/**
 * AdminLTE Demo Menu
 * ------------------
 * You should not use this file in production.
 * This file is for demo purposes only.
 */

/* eslint-disable camelcase */

(function ($) {
  'use strict'

  // Onclick function for moon icon
  $('#moon').on("click", function() {
    var clicks = $(this).data('clicks');
    if (clicks) {
       // odd clicks
       $('body').removeClass('dark-mode')
    } else {
       // even clicks
       $('body').addClass('dark-mode')
    }
    $(this).data("clicks", !clicks);
  });

})(jQuery)
