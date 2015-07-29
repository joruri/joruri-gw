Date.prototype.getAMPMHour = function() {
  hour = Date.padded2(this.getHours());
  return (hour == null) ? 00 : (hour > 24 ? hour - 24 : hour )
}
Date.prototype.getAMPM = function() {
  return (this.getHours() < 12) ? "" : "";
}
Date.prototype.toFormattedString = function(include_time) {
  str = this.getFullYear() + '/' + Date.padded2(this.getMonth() + 1) + '/' +Date.padded2(this.getDate());
  if (include_time) {
    hour = this.getHours(); str += " " + this.getAMPMHour() + ":" + this.getPaddedMinutes()
  }
  return str;
}
Date.parseFormattedString = function(string) {
  var regexp = "([0-9]{4}\/[0-1]?[0-9]\/[0-3]?[0-9]) ([0-9]{2}:[0-9]{2})";
  var d = string.match(new RegExp(regexp, "i"));
  if (d == null) {
    regexp = "([0-9]{4}\/[0-1]?[0-9]\/[0-3]?[0-9])";
    d = string.match(new RegExp(regexp, "i"));
    if (d == null) {
      return Date.parse(string); // Give javascript a chance to parse it.
    }
  }
  ymd = d[1].split('/');
  hrs = 0;
  mts = 0;
  if(d[2] != null) {
    hrs = parseInt(d[2].split(':')[0], 10);
    mts = parseInt(d[2].split(':')[1], 10);
  }
  return new Date(ymd[0], parseInt(ymd[1], 10)-1, ymd[2], hrs, mts, 0);
}
