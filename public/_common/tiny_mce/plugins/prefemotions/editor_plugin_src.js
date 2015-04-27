/**
 * editor_plugin_src.js
 *
 * Copyright 2009, Moxiecode Systems AB
 * Released under LGPL License.
 *
 * License: http://tinymce.moxiecode.com/license
 * Contributing: http://tinymce.moxiecode.com/contributing
 * 
 * Modified for Joruri
 */

(function(tinymce) {
	tinymce.create('tinymce.plugins.PrefEmotionsPlugin', {
		init : function(ed, url) {
			// Register commands
			ed.addCommand('mceEmotion', function() {
				ed.windowManager.open({
					file : url + '/emotions.htm',
					width : 300 + parseInt(ed.getLang('emotions.delta_width', 0)),
					height : 200 + parseInt(ed.getLang('emotions.delta_height', 0)),
					inline : 1
				}, {
					plugin_url : url
				});
			});

			// Register buttons
			ed.addButton('prefemotions', {title : 'emotions.emotions_desc', cmd : 'mceEmotion', image : '/_common/tiny_mce/plugins/prefemotions/img/ic_s-sudachikun.gif',
});
		},

		getInfo : function() {
			return {
				longname : 'Emotions',
				author : 'Moxiecode Systems AB',
				authorurl : 'http://tinymce.moxiecode.com',
				infourl : 'http://wiki.moxiecode.com/index.php/TinyMCE:Plugins/emotions',
				version : tinymce.majorVersion + "." + tinymce.minorVersion
			};
		}
	});

	// Register plugin
	tinymce.PluginManager.add('prefemotions', tinymce.plugins.PrefEmotionsPlugin);
})(tinymce);