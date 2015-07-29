// Need Common Class.
if (!('Common' in this)) document.write('<script type="text/javascript" src="/_common/js/common.js"></script>');

/**
 * Styler.
 */
function Styler() {
  
  this.onLoad = function() {
    Styler.fontSize();
    Styler.theme();
  }
}

/**
 * Auto load values.
 */
function Styler_initialize(names) {
  var styler = new Styler();
  Common.addEvent(window, 'load', function(){ styler.onLoad() });
}
Styler.initialize = Styler_initialize;
Styler.setAutoLoad = Styler_initialize;

/**
 * Changes the style sheet.
 */
function Styler_theme(value) {
  name = 'styler_theme';
  if (value) {
    Common.setCookie(name, value);
  } else {
    value = Common.getCookie(name);
    if (!value) return false;
  }
  var links = document.getElementsByTagName('LINK');
  for (i = 0; i < links.length; i++) {
    if (links.item(i).title != '') links.item(i).disabled = true;
  }
  for (i = 0; i < links.length; i++) {
    if (links.item(i).title == value) links.item(i).disabled = false;
  }
  return false;
}
Styler.theme = Styler_theme;

/**
 * Changes the font size.
 */
function Styler_fontSize(value) {
  name = 'styler_font_size';
  if (value) {
    Common.setCookieMoment(name, value);
  } else {
    value = Common.getCookie(name);
    if (!value){
        document.getElementsByTagName("body")[0].style.fontSize = '0.80em';
		return false;
	}
  }
  document.getElementsByTagName("body")[0].style.fontSize = value;
  return false;
}
Styler.fontSize = Styler_fontSize;

/**
 * Change from present font size
 */
function Styler_sizeChangeB() {
  name = 'styler_font_size';
  value = Common.getCookie(name);
  
  if (!value){
	 value = '1.00em';
  }
  
  temp1 = value.slice(0, value.length-2);
  temp2 = value.slice(-2);
/*  temp1 = Number(temp1) + 0.05;
  
  temp1 = (temp1 < 0.8) ? 0.8 : temp1;
  temp1 = (temp1 > 1.2) ? 1.2 : temp1;
  value = temp1.toFixed(2) + temp2;*/
  value = 1.4 + temp2;
  
  document.getElementsByTagName("body")[0].style.fontSize = value;  
  Common.setCookieMoment(name, value);
	
  return false;
}
Styler.sizeChangeB = Styler_sizeChangeB;


/**
 * Change from present font size
 */
function Styler_sizeChangeS() {
  name = 'styler_font_size';
  value = Common.getCookie(name);
  
  if (!value){
	 value = '1.00em'
  }
  
  temp1 = value.slice(0, value.length-2);
  temp2 = value.slice(-2);
/*  temp1 = Number(temp1) - 0.05;
  
  temp1 = (temp1 < 0.8) ? 0.8 : temp1;
  temp1 = (temp1 > 1.2) ? 1.2 : temp1;
  value = temp1.toFixed(2) + temp2;*/
  value = 0.6 + temp2;
  
  document.getElementsByTagName("body")[0].style.fontSize = value;  
  Common.setCookieMoment(name, value);
	
  return false;
}
Styler.sizeChangeS = Styler_sizeChangeS;
