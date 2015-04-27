(function($) {
  $(function() {
    $('div.tooltip').tooltip({
      show: 100, hide: 100,
      content: function() {
        return $(this).attr('title');
      }
    });
  });
})(jQuery);
