//日付入力補助用カレンダー

  YAHOO.util.Event.onDOMReady(function(){
    var bodyObj = document.getElementsByTagName('body');
    bodyObj[0].className = bodyObj[0].className + " yui-skin-sam";
  });

  var yEvent = YAHOO.util.Event,
    Dom = YAHOO.util.Dom,
    dialogs = new Array,
    calendars = new Array,
    boxI = 0;

    function showCalendar(buttonId, formId, changeFunc) {
      var showBtn = Dom.get(buttonId);

      if (!dialogs[formId]) {
        yEvent.on(document, "click", function(e) {
          var el = yEvent.getTarget(e);
          var dialogEl = dialogs[formId].element;
          if (el != dialogEl && !Dom.isAncestor(dialogEl, el) && el != showBtn && !Dom.isAncestor(showBtn, el)) {
            dialogs[formId].hide();
          }
        });
        function resetHandler() {
          var selDates = calendars[formId].getSelectedDates();
          var resetDate;
        
          if (selDates.length > 0) {
            resetDate = selDates[0];
          } else {
            resetDate = calendars[formId].today;
          }
        
          calendars[formId].cfg.setProperty("pagedate", resetDate);
          calendars[formId].render();
        }
        
        function closeHandler() {
            dialogs[formId].hide();
        }

        dialogs[formId] = new YAHOO.widget.Dialog("container" + boxI, {
          visible:false,
          context:[buttonId, "tl", "bl"],
          buttons:[ ],

          draggable:false,
          close:true
          
        });
        dialogs[formId].setHeader('日付を選択してください');
        dialogs[formId].setBody('<div id="cal' + boxI + '" style="border:none;padding:1em;"></div>');
        dialogs[formId].render(document.body);

        dialogs[formId].showEvent.subscribe(function() {
          if (YAHOO.env.ua.ie) {
            dialogs[formId].fireEvent("changeContent");
          }
        });
        var contObj = document.getElementById("container" + boxI);
        contObj.className = contObj.className + " cal-container";
    }

    if (!calendars[formId]) {
        calendars[formId] = new YAHOO.widget.Calendar("cal" + boxI, {
          iframe:false,
          hide_blank_weeks:true
        });
        boxI++;
        // Correct formats for Japan: yyyy/mm/dd, mm/dd, yyyy/mm

        calendars[formId].cfg.setProperty("MDY_YEAR_POSITION", 1);
        calendars[formId].cfg.setProperty("MDY_MONTH_POSITION", 2);
        calendars[formId].cfg.setProperty("MDY_DAY_POSITION", 3);

        calendars[formId].cfg.setProperty("MY_YEAR_POSITION", 1);
        calendars[formId].cfg.setProperty("MY_MONTH_POSITION", 2);

        // Date labels for Japanese locale
        calendars[formId].cfg.setProperty("MONTHS_SHORT",   ["1\u6708", "2\u6708", "3\u6708", "4\u6708", "5\u6708", "6\u6708", "7\u6708", "8\u6708", "9\u6708", "10\u6708", "11\u6708", "12\u6708"]);
        calendars[formId].cfg.setProperty("MONTHS_LONG",    ["1\u6708", "2\u6708", "3\u6708", "4\u6708", "5\u6708", "6\u6708", "7\u6708", "8\u6708", "9\u6708", "10\u6708", "11\u6708", "12\u6708"]);
        calendars[formId].cfg.setProperty("WEEKDAYS_1CHAR", ["\u65E5", "\u6708", "\u706B", "\u6C34", "\u6728", "\u91D1", "\u571F"]);
        calendars[formId].cfg.setProperty("WEEKDAYS_SHORT", ["\u65E5", "\u6708", "\u706B", "\u6C34", "\u6728", "\u91D1", "\u571F"]);
        calendars[formId].cfg.setProperty("WEEKDAYS_MEDIUM",["\u65E5", "\u6708", "\u706B", "\u6C34", "\u6728", "\u91D1", "\u571F"]);
        calendars[formId].cfg.setProperty("WEEKDAYS_LONG",  ["\u65E5", "\u6708", "\u706B", "\u6C34", "\u6728", "\u91D1", "\u571F"]);

        // Month/Year label format for Japan
        calendars[formId].cfg.setProperty("MY_LABEL_YEAR_POSITION",  1);
        calendars[formId].cfg.setProperty("MY_LABEL_MONTH_POSITION",  2);
        calendars[formId].cfg.setProperty("MY_LABEL_YEAR_SUFFIX",  "\u5E74");
        calendars[formId].cfg.setProperty("MY_LABEL_MONTH_SUFFIX",  "");

        calendars[formId].render();
        calendars[formId].selectEvent.subscribe(function() {
          if (calendars[formId].getSelectedDates().length > 0) {
            var selDate = calendars[formId].getSelectedDates()[0];
            var dStr = selDate.getDate();
            var mStr = selDate.getMonth() + 1;
            var yStr = selDate.getFullYear();
            
            var dateStr = yStr + "-" + mStr + "-" + dStr;
          } else {
            var dateStr = "";
          }
          Dom.get(formId).value = dateStr;
          if (changeFunc != null) {
            changeFunc();
          }
          dialogs[formId].hide();
        });

        calendars[formId].renderEvent.subscribe(function() {
          dialogs[formId].fireEvent("changeContent");
      });
    }

    var seldate = calendars[formId].getSelectedDates();

    if (seldate.length > 0) {
      calendars[formId].cfg.setProperty("pagedate", seldate[0]);
      calendars[formId].render();
    }
    dialogs[formId].show();
  }

