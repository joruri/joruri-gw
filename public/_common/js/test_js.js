/////
// testjs.js
/////
// Javascript 言語仕様調査関数
var myObject = {
  name : 'Herb the Mammal',
  get_name : function () {
    return this.name;
  },
  says : function () {
    return this.saying || '';
  }
};
var myArray = [];
var myHash = {};
var myFunc = function () {};
var myRegExp = /.?/;

var test_equal_undefined = function() {
  // == undefined をテスト
  var i, args;
  //var someObject = Object.create();
  //pp_one(someObject.prototype);
  //someObject.prototype = Object;
  //pp(someObject.prototype);
  // pp(typeof myMammal);   // => object
  // pp(is_array(myArray)); // => TRUE
  // pp(typeof myRegExp);   // => object
  args = 'myObject:undefined:null:0:"0":1:"1":-1:"-1":"":"a":myArray:myHash:myFunc:myRegExp'.split(':');
  for (i = 0; i < args.length; i++ ) test_equal_undefined_core(args[i] + ' == undefined')
}
var test_equal_undefined_core = function(ast) {
  pp(ast, eval(ast));
}
