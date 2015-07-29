// Need Common Class.
if (!('Common' in this)) document.write('<script type="text/javascript" src="/_common/js/common.js"></script>');

/**
 * Navigator
 */
function Navigator(ids) {
  
  if (ids['ruby']) {
    this.ruby = new NavigatorRuby(ids['ruby']);
  }
  if (ids['speaker']) {
    this.speaker = new NavigatorSpeaker(ids['speaker']);
  }
  
  this.onLoad = function() {
    if (this.ruby) {
      this.ruby.onLoad();
    }
    if (this.speaker) {
      this.speaker.onLoad();
    }
  }
}

function Navigator_initialize(ids) {
  var nav = new Navigator(ids);
  Common.addEvent(window, 'load', function(){ nav.onLoad() });
}
Navigator.initialize = Navigator_initialize;

/**
 * Navigator Ruby.
 */
function NavigatorRuby(id) {
  
  this.elementId = id;
  this.cookie    = 'navigator_ruby';
  
  this.onLoad = function() {
    this.render();
    var _this = this;
    Common.addEvent(document.getElementById(this.elementId), 'click', function(){
      return _this.changeRuby();
    });
  }
  
  this.changeRuby = function(id) {
    if (Common.getCookie(this.cookie) == 'on') {
      Common.setCookie(this.cookie, 'off');
    } else {
      Common.setCookie(this.cookie, 'on');
    }
    location.reload();
    return false;
  }
  
  this.render = function() {
    if (Common.getCookie(this.cookie) == 'on') {
      document.getElementById(this.elementId).className += ' rubyOn';
    } else {
      document.getElementById(this.elementId).className += ' rubyOff';
    }
  }
}

/**
 * Navigator Speaker.
 */
function NavigatorSpeaker(id) {
  
  this.elementId = id;
  
  this.onLoad = function() {
    var _this = this;
    Common.addEvent(document.getElementById(this.elementId), 'click', function(){
      return _this.speak();
    });
  }
  
  this.speak = function() {
    location.href = '/_tool/talks' + location.pathname;
    return false;
  }
}
