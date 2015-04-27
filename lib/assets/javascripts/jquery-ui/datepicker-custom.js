(function($) {
  $(function() {
    $.datepicker.regional['ja'] = {
      buttonImage: '/_common/themes/gw/files/icon/ic_act_calendar.gif',
      buttonText: 'カレンダー',
      buttonImageOnly: true,
      changeYear: true,
      changeMonth: true,
      dateFormat: 'yy-mm-dd',
      showAnim: false,
      showButtonPanel: true,
      showOn: 'button',
      yearRange: "c-5:c+5:"
    };
    $.datepicker.setDefaults($.datepicker.regional['ja']);

    $.timepicker.regional['ja'] = {
      currentText: '現在',
      closeText: '閉じる',
      timeOnlyTitle: '時間選択',
      timeText: '時間',
      hourText: '時',
      minuteText: '分',
      secondText: '秒',
      millisecText: 'ミリ秒',
      microsecText: 'マイクロ秒',
      timezoneText: 'タイムゾーン',
      stepMinute: 5,
      hourGrid: 6,
      minuteGrid: 15//,
      //addSliderAccess: true,
      //sliderAccessArgs: { touchonly: false }
    };
    $.timepicker.setDefaults($.timepicker.regional['ja']);
  });
})(jQuery);
