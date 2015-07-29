function PopupMenu(id) {
  this.id = id; 
  this.elm = $(id);
}

PopupMenu.menus = null;

PopupMenu.init = function(ids) {
  PopupMenu.menus = {};
  for(var i = 0;i < ids.length;i++) {
    var popup = new PopupMenu(ids[i])
    popup.hide();
    PopupMenu.menus[ids[i]] = popup;
  }
};

PopupMenu.getMenu = function(id){
  return PopupMenu.menus[id];
};

PopupMenu.hideAllMenus = function () {
  PopupMenu.hideAllMenusExcept([]);
};

PopupMenu.hideAllMenusExcept = function(except) {
  for (var key in PopupMenu.menus) {
    var menu = PopupMenu.menus[key];
    if (except.indexOf(menu.id) < 0) menu.hide();
  }   
}
PopupMenu.prototype.show = function(left, top) {
  
  if (this.elm.visible()) {
    return;
  }
  this.elm.style.position = 'absolute';
  this.elm.style.top = top + 'px';
  this.elm.style.left = left + 'px';
  this.elm.show();
};

PopupMenu.prototype.hide = function() {
  if (this.elm.visible()) {
    this.elm.hide();
  }    
};
