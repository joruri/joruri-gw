/////
// gw.js
/////
// 汎用関数
var is_array = function (value) {
  // quoted from Javascript: The Good Parts isbn:9784873113913 p.71
  return value &&
    typeof value === 'object' &&
    typeof value.length === 'number' &&
    typeof value.splice === 'function' &&
    !(value.propertyIsEnumerable('length'));
}
var nz = function (value) {
  // @params: value, valueIfFalsy
  // falsy 値の場合、valueIfNull を返します
  // そうでなければ、そのまま value を返します
  var valueIfFalsy = (arguments.length == 1 ? '' : arguments[1]);
  return ( value == 0 || value == '' || value == '0' || value == false || value == undefined || value == null
    ? valueIfFalsy
    : value
  )
}
var rails_datetime_select_to_datetime_string = function(id_prefix) {
  return $(id_prefix + '_1i').value + '-' + $(id_prefix + '_2i').value + '-' + $(id_prefix + '_3i').value + ' ' + $(id_prefix + '_4i').value + ':' + $(id_prefix + '_5i').value
}
/////
// デバッグ用関数
var pp_one = function(obj) { document.getElementById('pp').appendChild(prettyPrint(obj)); }
//var pp = function() {
//  var i;
//  for (i = 0; i < arguments.length; i += 1) pp_one(arguments[i]);
//}
var pp = function() {
  var i, args = [];
  if (arguments.length == 1) {
    pp_one(arguments[0]);
  } else {
    for (i = 0; i < arguments.length; i += 1) args.push(arguments[i]);
    pp_one(args);
  }
}
/////
// DOM 操作関連関数
var gdbn = function(obj_name) { return document.getElementsByName(obj_name) }
var radio_selected = function(name) {
  var radios = gdbn(name)
  for (var i = 0; i < radios.length; i++) //全てのラジオボタンをスキャン
    if (radios[i].checked)            //チェックされていたら
      return i;
  return undefined;
}
/////
// Select - Option(リストボックス・コンボボックス) 操作関連関数
var select_options_update_by_html = function(elem, options_str) {
  // elem は select であることを想定
  // elem の Options(innerHTML) を上書きします。IE バグ対応つき。
  // @assumes Prototype >= 1.5.0
  elem.update(options_str);
}
var select_options_get_index_by_value = function(elem, v, title) {
  // elem は select であることを想定
  // elem に Options 配列の value=v である最初の添え字を返します
  for (var i = 0; i < elem.options.length; i++)
    if ((title == undefined) ? (elem.options[i].value == v) : (elem.options[i].value == v && elem.options[i].title == title)) return i;
  return undefined;
}
var select_options_push = function(elem, v, tx, title, permit_rep) {
  // elem は select であることを想定
  // elem に value=v, text=t で Options を追加。
  // premit_rep は既定で true, true だと重複登録を行わない(重複チェックは v, title で行う)
  var has_rep;
  // parse options
  permit_rep = (permit_rep != undefined);
  title = nz(title);
  // main
  has_rep = (undefined != select_options_get_index_by_value(elem, v, title));
  if (permit_rep || !has_rep) {
    var idx = elem.length;
    elem.options[idx] = new Option(tx, v); // 重複許可ありなら無条件追加
    elem.options[idx].title = title;
  }
}
var select_options_delete = function(elem, v) {
  // elem は select であることを想定
  // elem に value=v の Option があれば削除
  // parse options
  // main
  var idx = select_options_get_index_by_value(elem, v);
  if (idx != undefined) elem.options[idx] = null;
}
var select_options_delete_by_index = function(elem, idx) {
  // elem は select であることを想定
  // elem の index が idx である Option を削除
  // parse options
  // main
  if (idx != undefined) elem.options[idx] = null;
}
var select_options_selected_indexes = function(elem) {
  // elem は select-multiple であることを想定
  // elem に Options 配列の selected である index を配列にして返します
  var ret = [];
  for (var i = 0; i < elem.options.length; i++)
    if (elem.options[i].selected) ret.push(i);
  return ret;
}
var select_options_selected_elems = function(elem) {
  // elem は select-multiple であることを想定
  // elem に Options 配列の selected である elem を配列にして返します
  var ret = [];
  for (var i = 0; i < elem.options.length; i++)
    if (elem.options[i].selected) ret.push(elem.options[i]);
  return ret;
}
var select_options_selected_values = function(elem) {
  // elem は select-multiple であることを想定
  // elem に Options 配列の selected である value を配列にして返します
  var ret = [];
  for (var i = 0; i < elem.options.length; i++)
    if (elem.options[i].selected) ret.push(elem.options[i].value);
  return ret;
}
/////
// ajax リクエスト末尾用
var time_serial = function() {
  return encodeURI(new Date().getTime());
}
var ajax_request = function() {
  // parse options
  url = arguments[0];
  on_suc_func = arguments[1];
  method = (arguments.length <= 2) ? 'get': arguments[2];
  document.body.style.cursor = 'wait';
  new Ajax.Request(url, {method: method, onComplete: function(r){
    if (r.responseJSON !== null) {
      xha = r.responseJSON;
      switch (xha.length) {
      case 0:
        on_suc_func(r);
      default:
        on_suc_func(r);
      }
    }
    document.body.style.cursor = 'default';
  }, onFailure: function(r){
    document.body.style.cursor = 'default';
  }, onException: function(r, ex){
    document.body.style.cursor = 'default';
  }})
}
/////
// ブラウザ判別用
var is_ie = function() {
// JavaScriptによるブラウザの種類とバージョン判断
// http://www.mozilla-japan.org/docs/web-developer/sniffer/browser_type.html
  var agt = navigator.userAgent.toLowerCase();
  return ((agt.indexOf("msie") != -1) && (agt.indexOf("opera") == -1));
}
/////
// 日付関連
var dbdate_to_date = function(d) {
  // Y-m-d 形式文字列から Date オブジェクトに変換します
  return new Date(d.replace(/-/g, '/'));
}
var dbdate_to_format_date = function(d, format) {
  dd = new Date(d.replace(/-/g, '/'));
  var dateFormat = new DateFormat(format); 
  return dateFormat.format(dd);
}
var dbdate_to_date8 = function(d) {
  return dbdate_to_format_date(d, 'yyyyMMdd');
}
/////
// 日付関連 - date_picker6 JSセッター
var set_date_picker6 = function(form_name, name_partial, d) {
  name_prefix = form_name + '_' + name_partial
  mode = $('init_' + name_partial + '_mode').value;
  if (mode == 'datetime' || mode == 'date')
    ymd = dbdate_to_format_date(d, 'yyyy-M-d');
  if (mode == 'datetime' || mode == 'time')
    hn = dbdate_to_format_date(d, 'H:mm');
  switch(mode) {
  case 'datetime': ret = ymd + ' ' + hn; break;
  case 'date': ret = ymd; break;
  case 'time': ret = hn; break;
  }
  $(name_prefix).value = ret;
  eval('update_' + name_prefix + '_from_calendar();');
}
/////
// 個別
// 個別 - app/views/gw/public/schedules/_piece_header.html.erb
var calendar_schedule_redirect = function(d) {
  if (d) {
    location.href = $('my_url').value.replace(/%d/, dbdate_to_date8(d));
  }
}
