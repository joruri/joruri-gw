function synchroDateSelectAndPicker(id) {
  (function($) {
    var id1 = id + '_1i';
    var id2 = id + '_2i';
    var id3 = id + '_3i';
    $([id1, id2, id3].join(',')).on('change', function() {
      var y = $(id1).val();
      var m = $(id2).val();
      var d = $(id3).val();
      $(id).datepicker("setDate", new Date(y, m-1, d));
    });
    $(id).datepicker("option", {
      onSelect: function(dateText) {
        var m = dateText.match(/(\d+)-(\d+)-(\d+)/);
        if (m) {
          $(id1).val(m[1]);
          $(id2).val(m[2].replace(/^0/, ''));
          $(id3).val(m[3].replace(/^0/, ''));
        }
      }
    });
  })(jQuery);
}

function synchroDatetimeSelectAndPicker(id) {
  (function($) {
    var id1 = id + '_1i';
    var id2 = id + '_2i';
    var id3 = id + '_3i';
    var id4 = id + '_4i';
    var id5 = id + '_5i';
    $([id1, id2, id3, id4, id5].join(',')).on('change', function() {
      var y = $(id1).val();
      var m = $(id2).val();
      var d = $(id3).val();
      var H = $(id4).val();
      var M = $(id5).val();
      $(id).datepicker("setDate", new Date(y, m-1, d, H, M));
    });
    $(id).datepicker("option", {
      onSelect: function(dateText) {
        var m = dateText.match(/(\d+)-(\d+)-(\d+) (\d+):(\d+)/);
        if (m) {
          $(id1).val(m[1]);
          $(id2).val(m[2].replace(/^0/, ''));
          $(id3).val(m[3].replace(/^0/, ''));
          $(id4).val(m[4]);
          $(id5).val(m[5]);
        }
      }
    });
  })(jQuery);
}
