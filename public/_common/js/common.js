/**
 * Common JavaScripts
 */
function Common() {
  var included = true;
}

/**
 * Adds in the event handler.
 */
function Common_addEvent(element, listener, func){
  try {
    element.addEventListener(listener, func, false);
  } catch (e) {
    element.attachEvent('on' + listener, func);
  }
}
Common.addEvent = Common_addEvent;

/**
 * Returns the cookie value.
 */
function Common_getCookie(name) {
  var tmp = document.cookie + ';';
  var index1 = tmp.indexOf(name, 0);
  if(index1 != -1){
    tmp = tmp.substring(index1,tmp.length);
    var index2 = tmp.indexOf('=',0) + 1;
    var index3 = tmp.indexOf(';',index2);
    return(unescape(tmp.substring(index2,index3)));
  }
  return '';
}
Common.getCookie = Common_getCookie;

/**
 * Sets the cookie value.
 */
function Common_setCookie(name, value, expire, path) {
  if (1 || days) {
    var d = new Date();
    d.setDate(d.getDate() + 7);
  }
  if (!path) path = '/';
  
  var cookie = name + '=' + escape(value) + ';';
  cookie += 'expires=' + d.toGMTString() + ';';
  cookie += 'path=' + path + ';';
  document.cookie = cookie;
}
Common.setCookie = Common_setCookie;


/**
 * Sets the cookie value.
 * Until the window is shut.
 */
function Common_setCookieMoment(name, value, expire, path) {
  if (1 || days) {
    var d = new Date();
    d.setDate(d.getDate() + 7);
  }
  if (!path) path = '/';
  
  var cookie = name + '=' + escape(value) + ';';
  cookie += 'path=' + path + ';';
  document.cookie = cookie;
}
Common.setCookieMoment = Common_setCookieMoment;

