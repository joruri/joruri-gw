/////
// gw_schedules.js
/////
var select_group_link = function(fr_id, s_date) {
  // fr_id = 'item_schedule_users_user_type_id';
  var fr = $(fr_id);
  var genre = fr.options[fr.selectedIndex].value;
  var url='';

  var today = new Date(); // 本日の日付
  var year = today.getFullYear();
  var month = today.getMonth() + 1;
  var day = today.getDate();

  event_week_date = compute_week_date(year, month, day, 7);
  event_month_date = compute_month_date(year, month, day, 1);

  event_week_day = event_week_date.getFullYear() + ("0" + (event_week_date.getMonth() + 1)).slice(-2) + ("0" + event_week_date.getDate()).slice(-2);
  event_month_day =  event_month_date.getFullYear() + ("0" + (event_month_date.getMonth() + 1)).slice(-2) + ("0" + event_month_date.getDate()).slice(-2);

  switch (genre) {
    case '':
	case '-':
      break;
    case 'login':
      url = '/gw/schedules?s_date='+s_date;
      break;
    case 'login_group':
      url = '/gw/schedules?gid=me&s_date='+s_date;
      break;
    case 'leader': // 幹部予定
      url = '/gw/schedules?gid=644&s_date='+s_date;
      break;
    case 'all_user': // ユーザー検索
      url = '/gw/schedules?uid=all&s_date='+s_date;
      break;
    case 'all_group': // 組織検索
      ////myMenu.render();
      ////myMenu.show();
      //oMenu.render();
      //oMenu.show();
      url = '/gw/schedules/search';
      break;
    case 'event_week':
      url = '/gw/schedules/event_week?s_date=' + event_week_day;
      break;
    case 'event_month':
      url = '/gw/schedules/event_month?s_date=' + event_month_day;
      break;
    case 'meetings_guide':
      url = '/gw/meetings/guide?s_date=' + s_date;
      break;
    case 'meetings_month_guide':
      url = '/gw/meetings/?s_date=' + s_date;
      break;
    default:
      if (match_result = genre.match(/^custom_group_(\d+)$/)) {
        url = '/gw/schedules?cgid='+match_result[1]+'&s_date='+s_date;
        break;
      } else if (match_result = genre.match(/^group_(\d+)$/)) {
        url = '/gw/schedules?gid='+match_result[1]+'&s_date='+s_date;
        break;
      } else if (match_result = genre.match(/^prop_other_(\d+)$/)) {
        url = '/gw/schedule_props/show_week?s_genre=other&cls=other&type_id='+match_result[1]+'&s_date='+s_date;
        break;
      } else {
        alert('実装されていません。')
        // do nothing
      }
  }
  if (url != '')
    document.location = url;
}

var compute_week_date = function(year, month, day, add_days) {
    var date = new Date(year, month - 1, day);
    var base_time = date.getTime();
    var add_time = add_days * 86400000;//日数 * 1日のミリ秒数
    var total_time = base_time + add_time;
    date.setTime(total_time);
    return date;
}

var compute_month_date = function(year, month, day, add_month) {
    month += add_month;
    var end_date = new Date(year, month, 0);
    end_day = end_date.getDate();
    if (day > end_day) day = end_day;
    var date = new Date(year, month - 1, day);
    return date;
}
