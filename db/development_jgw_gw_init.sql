
SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

--
-- データベース: `development_jgw_gw`
--

--
-- テーブルのデータをダンプしています `digitallibrary_adms`
--


--
-- テーブルのデータをダンプしています `digitallibrary_controls`
--


--
-- テーブルのデータをダンプしています `digitallibrary_roles`
--


--
-- テーブルのデータをダンプしています `doclibrary_adms`
--


--
-- テーブルのデータをダンプしています `doclibrary_controls`
--


--
-- テーブルのデータをダンプしています `doclibrary_roles`
--


--
-- テーブルのデータをダンプしています `enquete_answers`
--


--
-- テーブルのデータをダンプしています `enquete_base_users`
--

INSERT INTO `enquete_base_users` (`id`, `unid`, `created_at`, `updated_at`, `base_user_code`, `base_user_name`) VALUES
(1, NULL, '2011-05-23 21:39:43', '2011-05-23 21:39:43', 'admin', 'システム管理者');

--
-- テーブルのデータをダンプしています `gwbbs_adms`
--

INSERT INTO `gwbbs_adms` (`id`, `unid`, `content_id`, `created_at`, `title_id`, `user_id`, `user_code`, `user_name`, `group_id`, `group_code`, `group_name`) VALUES
(2, NULL, NULL, '2011-05-23 00:01:21', 1, 0, NULL, NULL, 698, '001002', '秘書広報課');

--
-- テーブルのデータをダンプしています `gwbbs_controls`
--

INSERT INTO `gwbbs_controls` (`id`, `unid`, `content_id`, `state`, `created_at`, `updated_at`, `recognized_at`, `published_at`, `default_published`, `doc_body_size_capacity`, `doc_body_size_currently`, `upload_graphic_file_size_capacity`, `upload_graphic_file_size_capacity_unit`, `upload_document_file_size_capacity`, `upload_document_file_size_capacity_unit`, `upload_graphic_file_size_max`, `upload_document_file_size_max`, `upload_graphic_file_size_currently`, `upload_document_file_size_currently`, `create_section`, `create_section_flag`, `addnew_forbidden`, `edit_forbidden`, `draft_forbidden`, `delete_forbidden`, `attachfile_index_use`, `importance`, `form_name`, `banner`, `banner_position`, `left_banner`, `left_menu`, `left_index_use`, `left_index_pattern`, `left_index_bg_color`, `default_mode`, `other_system_link`, `preview_mode`, `wallpaper_id`, `wallpaper`, `css`, `font_color`, `icon_id`, `icon`, `sort_no`, `caption`, `view_hide`, `categoey_view`, `categoey_view_line`, `monthly_view`, `monthly_view_line`, `group_view`, `one_line_use`, `notification`, `restrict_access`, `upload_system`, `limit_date`, `name`, `title`, `category`, `category1_name`, `category2_name`, `category3_name`, `recognize`, `createdate`, `createrdivision_id`, `createrdivision`, `creater_id`, `creater`, `editdate`, `editordivision_id`, `editordivision`, `editor_id`, `editor`, `default_limit`, `dbname`, `admingrps`, `admingrps_json`, `adms`, `adms_json`, `dsp_admin_name`, `editors`, `editors_json`, `readers`, `readers_json`, `sueditors`, `sueditors_json`, `sureaders`, `sureaders_json`, `help_display`, `help_url`, `help_admin_url`, `notes_field01`, `notes_field02`, `notes_field03`, `notes_field04`, `notes_field05`, `notes_field06`, `notes_field07`, `notes_field08`, `notes_field09`, `notes_field10`, `docslast_updated_at`) VALUES
(1, NULL, NULL, 'public', '2011-05-23 00:01:21', '2011-05-23 00:01:21', NULL, NULL, 3, 30, 0, 10, 'MB', 30, 'MB', 3, 10, 0, 0, NULL, 'section_code', 0, 0, 0, 0, NULL, 1, 'form001', NULL, '', NULL, NULL, '1', 0, NULL, '', '', 1, NULL, NULL, NULL, NULL, NULL, NULL, 0, '', 1, 1, 0, 1, 6, 1, 1, 1, 0, 3, 'none', NULL, '全庁掲示板', 1, '分類', NULL, NULL, 2, '2011-05-23 00:01', '001002', '秘書広報課', 'admin', 'システム管理者', NULL, '001002', NULL, 'admin', NULL, 10, 'development_jgw_bbs_000001', '--- !map:HashWithIndifferentAccess \ngid: "696"\nuid: \n- "698"\n', '[["", "698", "秘書広報課"]]', '--- !map:HashWithIndifferentAccess \ngid: "698"\n', '[]', '秘書広報課', '--- !map:HashWithIndifferentAccess \ngid: "696"\nuid: \n- "698"\n', '[["", "", ""], ["", "698", "秘書広報課"]]', '--- !map:HashWithIndifferentAccess \ngid: "0"\nuid: \n- "0"\n', '[["", "", ""], ["", "0", "制限なし"]]', '--- !map:HashWithIndifferentAccess \ngid: "698"\n', '[]', '--- !map:HashWithIndifferentAccess \ngid: "698"\n', '[]', '1', '', '', '', '', '', '', '', '', '', '', '', '', NULL);

--
-- テーブルのデータをダンプしています `gwbbs_itemdeletes`
--

INSERT INTO `gwbbs_itemdeletes` VALUES (1, NULL, 0, '2012-05-21 13:05:41', '2012-05-21 13:05:41', 'admin', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '24.months', NULL);
--
-- テーブルのデータをダンプしています `gwbbs_roles`
--

INSERT INTO `gwbbs_roles` (`id`, `unid`, `content_id`, `created_at`, `title_id`, `role_code`, `user_id`, `user_code`, `user_name`, `group_id`, `group_code`, `group_name`) VALUES
(3, NULL, NULL, '2011-05-23 00:01:21', 1, 'w', NULL, NULL, NULL, 698, '001002', '秘書広報課'),
(4, NULL, NULL, '2011-05-23 00:01:21', 1, 'r', NULL, NULL, NULL, 0, '0', '制限なし');

--
-- テーブルのデータをダンプしています `gwbbs_themes`
--


--
-- テーブルのデータをダンプしています `gwboard_bgcolors`
--


--
-- テーブルのデータをダンプしています `gwboard_images`
--


--
-- テーブルのデータをダンプしています `gwboard_maps`
--


--
-- テーブルのデータをダンプしています `gwboard_renewal_groups`
--


--
-- テーブルのデータをダンプしています `gwboard_syntheses`
--


--
-- テーブルのデータをダンプしています `gwboard_synthesetups`
--


--
-- テーブルのデータをダンプしています `gwboard_themes`
--


--
-- テーブルのデータをダンプしています `gwcircular_adms`
--


--
-- テーブルのデータをダンプしています `gwcircular_controls`
--

INSERT INTO `gwcircular_controls` (`id`, `unid`, `content_id`, `state`, `created_at`, `updated_at`, `recognized_at`, `published_at`, `default_published`, `doc_body_size_capacity`, `doc_body_size_currently`, `upload_graphic_file_size_capacity`, `upload_graphic_file_size_capacity_unit`, `upload_document_file_size_capacity`, `upload_document_file_size_capacity_unit`, `upload_graphic_file_size_max`, `upload_document_file_size_max`, `upload_graphic_file_size_currently`, `upload_document_file_size_currently`, `commission_limit`, `create_section`, `create_section_flag`, `addnew_forbidden`, `edit_forbidden`, `draft_forbidden`, `delete_forbidden`, `attachfile_index_use`, `importance`, `form_name`, `banner`, `banner_position`, `left_banner`, `left_menu`, `left_index_use`, `left_index_pattern`, `left_index_bg_color`, `default_mode`, `other_system_link`, `preview_mode`, `wallpaper_id`, `wallpaper`, `css`, `font_color`, `icon_id`, `icon`, `sort_no`, `caption`, `view_hide`, `categoey_view`, `categoey_view_line`, `monthly_view`, `monthly_view_line`, `group_view`, `one_line_use`, `notification`, `restrict_access`, `upload_system`, `limit_date`, `name`, `title`, `category`, `category1_name`, `category2_name`, `category3_name`, `recognize`, `createdate`, `createrdivision_id`, `createrdivision`, `creater_id`, `creater`, `editdate`, `editordivision_id`, `editordivision`, `editor_id`, `editor`, `default_limit`, `dbname`, `admingrps`, `admingrps_json`, `adms`, `adms_json`, `dsp_admin_name`, `editors`, `editors_json`, `readers`, `readers_json`, `sueditors`, `sueditors_json`, `sureaders`, `sureaders_json`, `help_display`, `help_url`, `help_admin_url`, `notes_field01`, `notes_field02`, `notes_field03`, `notes_field04`, `notes_field05`, `notes_field06`, `notes_field07`, `notes_field08`, `notes_field09`, `notes_field10`, `docslast_updated_at`) VALUES
(1, NULL, NULL, 'public', '2010-11-19 10:55:30', '2010-11-25 17:13:21', NULL, NULL, 7, 100, 0, 10, 'GB', 10, 'GB', 5, 5, 0, 0, 200, NULL, '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1', NULL, NULL, NULL, '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '', 1, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 3, 'none', NULL, '回覧板', NULL, NULL, NULL, NULL, 0, '2010-11-19 10:55', '698', '秘書広報課', 'gwbbs', 'admin', '2010-11-25 17:13', '698', '秘書広報課', 'gwbbs', 'admin', 200, NULL, '--- !map:HashWithIndifferentAccess \ngid: "3"\n', '[]', '--- !map:HashWithIndifferentAccess \ngid: "36"\n', '[]', '', '--- !map:HashWithIndifferentAccess \ngid: "3"\n', '[["", "0", "制限なし"]]', '--- !map:HashWithIndifferentAccess \ngid: "0"\n', '[["", "0", "制限なし"]]', '--- !map:HashWithIndifferentAccess \ngid: "36"\n', '[]', '--- !map:HashWithIndifferentAccess \ngid: "36"\n', '[]', '1', '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

--
-- テーブルのデータをダンプしています `gwcircular_custom_groups`
--


--
-- テーブルのデータをダンプしています `gwcircular_docs`
--


--
-- テーブルのデータをダンプしています `gwcircular_files`
--


--
-- テーブルのデータをダンプしています `gwcircular_itemdeletes`
--

INSERT INTO `gwcircular_itemdeletes` VALUES (1, NULL, 0, '2012-05-21 13:07:14', '2012-05-21 13:07:19', 'admin', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '24.months', NULL);
--
-- テーブルのデータをダンプしています `gwcircular_roles`
--

INSERT INTO `gwcircular_roles` (`id`, `unid`, `content_id`, `created_at`, `title_id`, `role_code`, `user_id`, `user_code`, `user_name`, `group_id`, `group_code`, `group_name`) VALUES
(1, NULL, NULL, '2011-05-07 23:07:49', 1, 'w', NULL, NULL, NULL, 0, '0', '制限なし'),
(2, NULL, NULL, '2011-05-07 23:07:49', 1, 'r', NULL, NULL, NULL, 0, '0', '制限なし');

--
-- テーブルのデータをダンプしています `gwfaq_adms`
--


--
-- テーブルのデータをダンプしています `gwfaq_controls`
--


--
-- テーブルのデータをダンプしています `gwfaq_recognizers`
--


--
-- テーブルのデータをダンプしています `gwfaq_roles`
--


--
-- テーブルのデータをダンプしています `gwmonitor_base_files`
--


--
-- テーブルのデータをダンプしています `gwmonitor_controls`
--


--
-- テーブルのデータをダンプしています `gwmonitor_custom_groups`
--


--
-- テーブルのデータをダンプしています `gwmonitor_custom_user_groups`
--


--
-- テーブルのデータをダンプしています `gwmonitor_docs`
--


--
-- テーブルのデータをダンプしています `gwmonitor_files`
--


--
-- テーブルのデータをダンプしています `gwmonitor_forms`
--

INSERT INTO `gwmonitor_forms` (`id`, `unid`, `state`, `created_at`, `updated_at`, `sort_no`, `level_no`, `form_name`, `form_caption`) VALUES
(1, NULL, NULL, '2011-05-12 20:38:54', '2011-05-12 20:38:54', 0, 0, 'form001', '回答欄及び添付ファイル');

--
-- テーブルのデータをダンプしています `gwmonitor_itemdeletes`
--

INSERT INTO `gwmonitor_itemdeletes` VALUES (1, NULL, 0, '2012-05-21 13:07:49', '2012-05-21 13:07:54', 'admin', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '24.months', NULL);

--
-- テーブルのデータをダンプしています `gwqa_adms`
--


--
-- テーブルのデータをダンプしています `gwqa_controls`
--


--
-- テーブルのデータをダンプしています `gwqa_recognizers`
--


--
-- テーブルのデータをダンプしています `gwqa_roles`
--


--
-- テーブルのデータをダンプしています `gw_admin_check_extensions`
--

INSERT INTO `gw_admin_check_extensions` (`id`, `state`, `sort_no`, `extension`, `remark`, `deleted_at`, `deleted_uid`, `deleted_gid`, `updated_at`, `updated_uid`, `updated_gid`, `created_at`, `created_uid`, `created_gid`) VALUES
(1, 'enabled', 10, 'jtd', '一太郎', NULL, NULL, NULL, '2011-08-19 10:32:08', NULL, NULL, '2011-08-19 10:32:08', NULL, NULL),
(2, 'enabled', 20, 'xls', 'Excel', NULL, NULL, NULL, '2011-08-19 10:32:17', NULL, NULL, '2011-08-19 10:32:17', NULL, NULL),
(3, 'enabled', 30, 'xlsx', 'Excel 2007', NULL, NULL, NULL, '2011-08-19 10:32:26', NULL, NULL, '2011-08-19 10:32:26', NULL, NULL),
(4, 'enabled', 40, 'doc', 'Word', NULL, NULL, NULL, '2011-08-19 10:32:33', NULL, NULL, '2011-08-19 10:32:33', NULL, NULL),
(5, 'enabled', 50, 'docx', 'Word 2007', NULL, NULL, NULL, '2011-08-19 10:33:10', NULL, NULL, '2011-08-19 10:33:10', NULL, NULL),
(6, 'enabled', 60, 'ppt', 'PowerPoint', NULL, NULL, NULL, '2011-08-19 10:33:19', NULL, NULL, '2011-08-19 10:33:19', NULL, NULL),
(7, 'enabled', 70, 'pptx', 'PowerPoint 2007', NULL, NULL, NULL, '2011-08-19 10:33:28', NULL, NULL, '2011-08-19 10:33:28', NULL, NULL),
(8, 'enabled', 80, 'jac', '三四郎', NULL, NULL, NULL, '2011-08-19 10:33:36', NULL, NULL, '2011-08-19 10:33:36', NULL, NULL),
(9, 'enabled', 90, 'jsd', '三四郎', NULL, NULL, NULL, '2011-08-19 10:33:43', NULL, NULL, '2011-08-19 10:33:43', NULL, NULL),
(10, 'deleted', NULL, 'odt', 'オープンオフィス 文書', '2011-08-24 11:52:08', 8, 36, '2011-08-24 11:52:08', 8, 36, '2011-08-24 10:58:05', 8, 36),
(11, 'deleted', NULL, 'odg', 'オープンオフィス 図形', '2011-08-24 11:19:57', 8, 36, '2011-08-24 11:19:57', NULL, NULL, '2011-08-24 11:19:20', 8, 36);

--
-- テーブルのデータをダンプしています `gw_admin_messages`
--


--
-- テーブルのデータをダンプしています `gw_blog_parts`
--


--
-- テーブルのデータをダンプしています `gw_circulars`
--


--
-- テーブルのデータをダンプしています `gw_edit_link_pieces`
--

INSERT INTO `gw_edit_link_pieces` (`id`, `uid`, `class_created`, `published`, `state`, `mode`, `level_no`, `parent_id`, `name`, `sort_no`, `tab_keys`, `display_auth_priv`, `role_name_id`, `display_auth`, `block_icon_id`, `block_css_id`, `link_url`, `remark`, `icon_path`, `link_div_class`, `class_external`, `ssoid`, `class_sso`, `field_account`, `field_pass`, `css_id`, `deleted_at`, `deleted_user`, `deleted_group`, `updated_at`, `updated_user`, `updated_group`, `created_at`, `created_user`, `created_group`) VALUES
(1,NULL,1,'opened','enabled',1,1,0,'TOP',10,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,1,NULL,NULL,0,NULL,'admin','秘書広報課','2010-10-22 17:21:35','admin','秘書広報課','2010-10-22 17:21:35','admin','秘書広報課'),
(2,NULL,1,'opened','enabled',1,2,1,'ポータル左　リンクピース',10,10,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,1,NULL,NULL,0,NULL,'admin','秘書広報課','2010-11-10 21:18:27','admin','秘書広報課','2010-10-22 17:32:27','admin','秘書広報課'),
(15,NULL,1,'opened','enabled',1,3,2,'掲示板',70,0,1,NULL,NULL,4,9,'/gwbbs',NULL,'',NULL,1,NULL,1,'','',0,NULL,'admin','秘書広報課','2011-05-12 23:00:43','admin','秘書広報課','2010-10-22 18:10:17','admin','秘書広報課'),
(19,NULL,1,'opened','enabled',1,3,2,'施設予約',80,0,1,NULL,'',5,9,'/gw/schedule_props/show_week?s_genre=other&cls=other&type_id=200',NULL,'',NULL,1,NULL,1,'','',0,NULL,'admin','秘書広報課','2011-05-12 23:00:38','admin','秘書広報課','2010-10-22 18:11:41','admin','秘書広報課'),
(24,NULL,1,'opened','enabled',1,3,2,'質問管理',90,0,1,NULL,NULL,6,9,'/gwfaq',NULL,'',NULL,1,NULL,1,'','',0,NULL,'admin','秘書広報課','2011-05-12 23:00:32','admin','秘書広報課','2010-10-22 18:15:45','admin','秘書広報課'),
(28,NULL,1,'opened','enabled',1,3,2,'リンク',100,0,1,NULL,'',7,9,'',NULL,'',NULL,1,NULL,1,'','',0,NULL,'admin','秘書広報課','2011-05-12 23:00:28','admin','秘書広報課','2010-10-22 18:17:14','admin','秘書広報課'),
(61,NULL,1,'opened','enabled',1,2,1,'ポータルヘッダ　アイコンメニュー',30,30,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,1,NULL,NULL,0,NULL,'admin','秘書広報課','2010-11-10 21:19:29','admin','秘書広報課','2010-10-27 16:01:12','admin','秘書広報課'),
(62,NULL,1,'opened','enabled',1,3,61,'ポータル',10,0,1,NULL,NULL,NULL,NULL,'/',NULL,'',NULL,1,NULL,1,'','',0,NULL,'admin','秘書広報課','2010-10-27 16:06:49','admin','秘書広報課','2010-10-27 16:06:49','admin','秘書広報課'),
(63,NULL,1,'opened','enabled',1,4,62,'ポータル',10,0,1,NULL,NULL,NULL,NULL,'/',NULL,'/_common/themes/gw/files/menu/ic_home.gif',NULL,1,NULL,1,'','',0,NULL,'admin','秘書広報課','2010-10-27 16:07:28','admin','秘書広報課','2010-10-27 16:07:28','admin','秘書広報課'),
(64,NULL,1,'opened','enabled',1,3,61,'メール',20,0,1,NULL,'',NULL,12,'demo.webmail.joruri.org',NULL,'',NULL,2,NULL,2,'account','password',0,NULL,'admin','秘書広報課','2011-05-22 21:39:21','admin','秘書広報課','2010-10-27 16:08:19','admin','秘書広報課'),
(65,NULL,1,'opened','enabled',1,4,64,'メール',10,0,1,NULL,'',NULL,NULL,'demo.webmail.joruri.org',NULL,'/_common/themes/gw/files/menu/ic_mailer.gif',NULL,2,NULL,2,'account','password',0,NULL,'admin','秘書広報課','2011-03-30 16:52:28','admin','秘書広報課','2010-10-27 16:09:08','admin','秘書広報課'),
(66,NULL,1,'opened','enabled',1,3,61,'スケジュール',40,0,1,NULL,'',NULL,13,'/gw/schedules/show_month',NULL,'',NULL,1,NULL,1,'','',0,NULL,'admin','秘書広報課','2011-03-04 15:44:37','admin','秘書広報課','2010-10-27 16:10:08','admin','秘書広報課'),
(67,NULL,1,'opened','enabled',1,4,66,'スケジュール',10,0,1,NULL,NULL,NULL,NULL,'/gw/schedules/show_month',NULL,'/_common/themes/gw/files/menu/ic_schedule.gif',NULL,1,NULL,1,'','',0,NULL,'admin','秘書広報課','2010-10-27 16:11:33','admin','秘書広報課','2010-10-27 16:11:33','admin','秘書広報課'),
(68,NULL,1,'opened','enabled',1,4,66,'新規作成',20,0,1,NULL,NULL,NULL,16,'/gw/schedules/new',NULL,'/_common/themes/gw/files/schedule/ic_add.gif',NULL,1,NULL,1,'','',0,NULL,'admin','秘書広報課','2010-10-27 16:12:41','admin','秘書広報課','2010-10-27 16:12:41','admin','秘書広報課'),
(69,NULL,1,'opened','enabled',1,3,61,'ToDo',50,0,1,NULL,'',NULL,14,'/gw/todos',NULL,'',NULL,1,NULL,1,'','',0,NULL,'admin','秘書広報課','2011-04-11 22:27:23','admin','秘書広報課','2010-10-27 16:13:30','admin','秘書広報課'),
(70,NULL,1,'opened','enabled',1,4,69,'ToDo',10,0,1,NULL,NULL,NULL,NULL,'/gw/todos',NULL,'/_common/themes/gw/files/menu/ic_todo.gif',NULL,1,NULL,1,'','',0,NULL,'admin','秘書広報課','2010-10-27 16:14:05','admin','秘書広報課','2010-10-27 16:14:05','admin','秘書広報課'),
(71,NULL,1,'opened','enabled',1,4,69,'新規作成',20,0,1,NULL,NULL,NULL,16,'/gw/todos/new',NULL,'/_common/themes/gw/files/schedule/ic_add.gif',NULL,1,NULL,1,'','',0,NULL,'admin','秘書広報課','2010-10-27 16:14:40','admin','秘書広報課','2010-10-27 16:14:40','admin','秘書広報課'),
(72,NULL,1,'opened','enabled',1,3,61,'連絡メモ',60,0,1,NULL,NULL,NULL,15,'/gw/memos',NULL,'',NULL,1,NULL,1,'','',0,NULL,'admin','秘書広報課','2010-11-19 17:16:20','admin','秘書広報課','2010-10-27 16:15:20','admin','秘書広報課'),
(73,NULL,1,'opened','enabled',1,4,72,'連絡メモ',10,0,1,NULL,NULL,NULL,NULL,'/gw/memos',NULL,'/_common/themes/gw/files/menu/ic_memo.gif',NULL,1,NULL,1,'','',0,NULL,'admin','秘書広報課','2010-10-27 16:15:44','admin','秘書広報課','2010-10-27 16:15:44','admin','秘書広報課'),
(74,NULL,1,'opened','enabled',1,4,72,'新規作成',20,0,1,NULL,NULL,NULL,16,'/gw/memos/new',NULL,'/_common/themes/gw/files/schedule/ic_add.gif',NULL,1,NULL,1,'','',0,NULL,'admin','秘書広報課','2010-10-27 16:16:09','admin','秘書広報課','2010-10-27 16:16:09','admin','秘書広報課'),
(77,NULL,1,'opened','enabled',1,3,61,'掲示板',90,0,1,NULL,'',NULL,NULL,'/gwbbs',NULL,'',NULL,1,NULL,1,'','',0,NULL,'admin','秘書広報課','2011-01-26 19:49:40','admin','秘書広報課','2010-10-27 16:18:43','admin','秘書広報課'),
(78,NULL,1,'opened','enabled',1,4,77,'掲示板',10,0,1,NULL,NULL,NULL,NULL,'/gwbbs',NULL,'/_common/themes/gw/files/menu/ic_board.gif',NULL,1,NULL,1,'','',0,NULL,'admin','秘書広報課','2010-10-27 16:19:05','admin','秘書広報課','2010-10-27 16:19:05','admin','秘書広報課'),
(79,NULL,1,'opened','enabled',1,3,61,'質問管理',100,0,1,NULL,NULL,NULL,NULL,'/gwfaq',NULL,'',NULL,1,NULL,1,'','',0,NULL,'admin','秘書広報課','2011-01-26 19:49:52','admin','秘書広報課','2010-10-27 16:19:32','admin','秘書広報課'),
(80,NULL,1,'opened','enabled',1,4,79,'質問管理',10,0,1,NULL,NULL,NULL,NULL,'/gwfaq',NULL,'/_common/themes/gw/files/menu/ic_qa-admin.gif',NULL,1,NULL,1,'','',0,NULL,'admin','秘書広報課','2010-10-27 16:19:59','admin','秘書広報課','2010-10-27 16:19:59','admin','秘書広報課'),
(81,NULL,1,'opened','enabled',1,3,61,'書庫',110,0,1,NULL,NULL,NULL,NULL,'/doclibrary',NULL,'',NULL,1,NULL,1,'','',0,NULL,'admin','秘書広報課','2011-01-26 19:49:52','admin','秘書広報課','2010-10-27 16:20:29','admin','秘書広報課'),
(82,NULL,1,'opened','enabled',1,4,81,'書庫',10,0,1,NULL,NULL,NULL,NULL,'/doclibrary',NULL,'/_common/themes/gw/files/menu/ic_library.gif',NULL,1,NULL,1,'','',0,NULL,'admin','秘書広報課','2010-10-27 16:20:53','admin','秘書広報課','2010-10-27 16:20:53','admin','秘書広報課'),
(83,NULL,1,'opened','enabled',1,3,61,'電子図書',120,0,1,NULL,'',NULL,NULL,'/digitallibrary',NULL,'/digitallibrary',NULL,1,NULL,1,'','',0,NULL,'admin','秘書広報課','2011-01-26 19:48:25','admin','秘書広報課','2010-10-27 16:21:18','admin','秘書広報課'),
(84,NULL,1,'opened','enabled',1,4,83,'電子図書',10,0,1,NULL,NULL,NULL,NULL,'/digitallibrary',NULL,'/_common/themes/gw/files/menu/ic_electronic-book.gif',NULL,1,NULL,1,'','',0,NULL,'admin','秘書広報課','2010-10-27 16:21:51','admin','秘書広報課','2010-10-27 16:21:51','admin','秘書広報課'),
(85,NULL,1,'opened','enabled',1,3,61,'設定',130,0,0,21,'',NULL,NULL,'/gw/config_settings',NULL,'',NULL,1,NULL,1,'','',0,NULL,'admin','秘書広報課','2011-02-02 15:34:36','admin','秘書広報課','2010-10-27 16:23:22','admin','秘書広報課'),
(86,NULL,1,'opened','enabled',1,4,85,'設定',10,0,1,NULL,'',NULL,NULL,'/gw/config_settings',NULL,'/_common/themes/gw/files/menu/ic_system.gif',NULL,1,NULL,1,'','',0,NULL,'admin','秘書広報課','2011-02-02 15:34:50','admin','秘書広報課','2010-10-27 16:23:57','admin','秘書広報課'),
(87,NULL,1,'opened','enabled',1,3,61,'DECO Drive',140,0,1,NULL,'',NULL,18,'http://drive.deco-project.org/',NULL,'',NULL,2,NULL,1,'','',0,NULL,'admin','秘書広報課','2011-05-13 13:45:19','admin','秘書広報課','2010-10-27 16:25:09','admin','秘書広報課'),
(88,NULL,1,'opened','enabled',1,4,87,'DECO Drive',10,0,1,NULL,'',NULL,NULL,'http://drive.deco-project.org/',NULL,'/_common/themes/gw/files/menu/ic_deco.gif',NULL,2,NULL,1,'','',0,NULL,'admin','秘書広報課','2011-05-13 13:44:33','admin','秘書広報課','2010-10-27 16:26:26','admin','秘書広報課'),
(89,NULL,1,'opened','enabled',1,3,61,'回覧板',70,0,1,NULL,'',NULL,15,'/gwcircular',NULL,'',NULL,1,NULL,1,'','',0,NULL,'admin','秘書広報課','2010-11-19 17:22:53','admin','秘書広報課','2010-11-05 10:04:32','admin','秘書広報課'),
(90,NULL,1,'opened','enabled',1,4,89,'回覧板',10,0,1,NULL,'',NULL,NULL,'/gwcircular',NULL,'/_common/themes/gw/files/menu/ic_circulation.gif',NULL,1,NULL,1,'','',0,NULL,'admin','秘書広報課','2010-11-09 11:54:32','admin','秘書広報課','2010-11-09 11:53:00','admin','秘書広報課'),
(91,NULL,1,'opened','enabled',1,4,89,'新規作成',20,0,NULL,NULL,'',NULL,16,'/gwcircular/new',NULL,'/_common/themes/gw/files/schedule/ic_add.gif',NULL,1,NULL,1,'','',0,NULL,'admin','秘書広報課','2010-11-19 17:13:59','admin','秘書広報課','2010-11-19 17:13:59','admin','秘書広報課'),
(773,NULL,1,'opened','enabled',1,3,2,'照会・回答',60,0,NULL,NULL,'',17,9,'/gwmonitor',NULL,'',NULL,1,NULL,1,'','',0,NULL,'admin','秘書広報課','2011-05-12 23:00:47','admin','秘書広報課','2010-12-27 13:35:55','admin','秘書広報課'),
(1215,NULL,1,'opened','enabled',1,3,61,'照会・回答',80,0,NULL,NULL,'',NULL,15,'/gwmonitor',NULL,NULL,NULL,1,NULL,1,'','',0,NULL,'admin','秘書広報課','2011-02-02 15:43:14','admin','秘書広報課','2011-01-26 19:46:55','admin','秘書広報課'),
(1216,NULL,1,'opened','enabled',1,4,1215,'照会・回答システム',10,0,NULL,NULL,'',17,NULL,'/gwmonitor',NULL,'/_common/themes/gw/files/menu/ic_dennshisyoukai.gif',NULL,1,NULL,1,'','',0,NULL,'admin','秘書広報課','2011-01-26 20:05:50','admin','秘書広報課','2011-01-26 19:52:52','admin','秘書広報課'),
(1217,NULL,1,'opened','enabled',1,4,1215,'新規作成',20,0,NULL,NULL,'',NULL,16,'/gwmonitor/builders/new',NULL,'/_common/themes/gw/files/schedule/ic_add.gif',NULL,1,NULL,1,'','',0,NULL,'admin','秘書広報課','2011-01-26 20:14:10','admin','秘書広報課','2011-01-26 20:08:04','admin','秘書広報課'),
(1481,NULL,1,'opened','enabled',1,3,2,'総務事務システム',30,0,NULL,NULL,'',1,8,'#',NULL,'',NULL,1,NULL,1,'','',0,NULL,'admin','秘書広報課','2011-05-13 14:15:51','admin','秘書広報課','2011-05-12 22:45:48','admin','秘書広報課'),
(1485,NULL,1,'opened','enabled',1,3,2,'電子決裁・文書管理',50,0,NULL,NULL,'',2,9,'#',NULL,'',NULL,1,NULL,1,'','',0,NULL,'admin','秘書広報課','2011-05-13 14:16:11','admin','秘書広報課','2011-05-12 23:00:16','admin','秘書広報課'),
(1496,NULL,1,'opened','enabled',1,4,773,'照会・回答システム',10,0,NULL,NULL,'',17,9,'/gwmonitor',NULL,'',NULL,1,NULL,1,'','',0,NULL,NULL,NULL,'2011-05-23 21:30:46',NULL,NULL,'2011-05-23 21:30:46','システム管理者','秘書広報課'),
(1497,NULL,1,'opened','enabled',1,4,773,'アンケート集計システム',20,0,NULL,NULL,'',NULL,NULL,'/enquete/',NULL,'',NULL,1,NULL,1,'','',0,NULL,NULL,NULL,'2011-05-23 21:31:26',NULL,NULL,'2011-05-23 21:31:26','システム管理者','秘書広報課'),
(1498,NULL,1,'opened','enabled',1,4,15,'全庁掲示板',10,0,NULL,NULL,'',NULL,NULL,'/gwbbs/docs?title_id=1&limit=10',NULL,'',NULL,1,NULL,1,'','',0,NULL,NULL,NULL,'2011-05-23 21:34:40',NULL,NULL,'2011-05-23 21:34:40','システム管理者','秘書広報課'),
(1499,NULL,1,'opened','enabled',1,4,19,'公用車予約',10,0,NULL,NULL,'',NULL,NULL,'/gw/schedule_props/show_week?s_genre=other&cls=other&type_id=100',NULL,'',NULL,1,NULL,1,'','',0,NULL,NULL,NULL,'2011-05-23 21:36:58',NULL,NULL,'2011-05-23 21:36:58','システム管理者','秘書広報課'),
(1500,NULL,1,'opened','enabled',1,4,19,'会議室予約',20,0,NULL,NULL,'',NULL,NULL,'/gw/schedule_props/show_week?s_genre=other&cls=other&type_id=200',NULL,'',NULL,1,NULL,1,'','',0,NULL,NULL,NULL,'2011-05-23 21:37:19',NULL,NULL,'2011-05-23 21:37:19','システム管理者','秘書広報課'),
(1501,NULL,1,'opened','enabled',1,4,19,'一般備品',30,0,NULL,NULL,'',NULL,NULL,'/gw/schedule_props/show_week?s_genre=other&cls=other&type_id=300',NULL,'',NULL,1,NULL,1,'','',0,NULL,NULL,NULL,'2011-05-23 21:37:41',NULL,NULL,'2011-05-23 21:37:41','システム管理者','秘書広報課'),
(1502,NULL,1,'opened','enabled',1,4,28,'Joruri公式サイト',10,0,NULL,NULL,'',NULL,NULL,'http://joruri.org/',NULL,'',NULL,2,NULL,1,'','',0,NULL,NULL,NULL,'2011-05-23 21:40:59',NULL,NULL,'2011-05-23 21:40:59','システム管理者','秘書広報課'),
(1503, NULL, 1, 'opened', 'enabled',1, 4, 773, '研修等申込・受付システム', 30, 0, NULL, NULL, '', NULL, NULL, '/gwsub/sb01/sb01_training_entries', NULL, '', NULL, 1, NULL, 1, '', '', 0, NULL, NULL, NULL, '2012-05-11 14:04:47', NULL, NULL, '2012-05-11 14:04:47', 'システム管理者', '秘書広報課'),
(1504, NULL, 1, 'opened', 'enabled',1, 3, 2, '職員名簿', 70, 0, NULL, NULL, '', 3, 9, '', NULL, '', NULL, 1, NULL, 1, '', '', 0, NULL, NULL, NULL, '2012-05-16 11:37:03', 'システム管理者', '秘書広報課', '2012-05-16 11:36:39', 'システム管理者', '秘書広報課'),
(1505, NULL, 1, 'opened', 'enabled',1, 4, 1504, '電子職員録', 10, 0, NULL, NULL, '', NULL, NULL, '/gwsub/sb04/01/sb04stafflistview', NULL, '', NULL, 1, NULL, 1, '', '', 0, NULL, NULL, NULL, '2012-05-16 11:38:19', NULL, NULL, '2012-05-16 11:38:19', 'システム管理者', '秘書広報課'),
(1506, NULL, 1, 'opened', 'enabled',1, 4, 1504, '電子事務分掌表', 20, 0, NULL, NULL, '', NULL, NULL, '/gwsub/sb04/02/sb04divideduties', NULL, '', NULL, 1, NULL, 1, '', '', 0, NULL, NULL, NULL, '2012-05-16 11:38:50', NULL, NULL, '2012-05-16 11:38:50', 'システム管理者', '秘書広報課'),
(1507, NULL, 1, 'opened', 'enabled',1, 4, 1485, 'ワークフロー',     10, 0, NULL, NULL, '', 2,    NULL, '/gwworkflow',                     NULL, '', NULL, 1, NULL, 1, '', '', 0, NULL, NULL, NULL, '2013-05-27 17:27:50', NULL, NULL, '2013-05-27 17:27:50', 'システム管理者', '秘書広報課');

--
-- テーブルのデータをダンプしています `gw_edit_link_piece_csses`
--

INSERT INTO `gw_edit_link_piece_csses` (`id`, `state`, `css_name`, `css_sort_no`, `css_class`, `css_type`, `deleted_at`, `deleted_user`, `deleted_group`, `updated_at`, `updated_user`, `updated_group`, `created_at`, `created_user`, `created_group`) VALUES
(1, 'enabled', '総務事務システム', 10, 'soumu', 2, NULL, NULL, NULL, NULL, 'admin', '秘書広報課', '2010-10-21 18:42:01', 'admin', '秘書広報課'),
(2, 'enabled', '電子決済・文書管理', 20, 'denshiKessai', 2, NULL, NULL, NULL, NULL, 'admin', '秘書広報課', '2010-10-21 18:56:49', 'admin', '秘書広報課'),
(3, 'enabled', '職員名簿', 30, 'directory', 2, NULL, NULL, NULL, NULL, 'admin', '秘書広報課', '2010-10-21 18:56:49', 'admin', '秘書広報課'),
(4, 'enabled', '掲示板', 40, 'bbs', 2, NULL, NULL, NULL, NULL, 'admin', '秘書広報課', '2010-10-21 18:56:49', 'admin', '秘書広報課'),
(5, 'enabled', '施設予約', 50, 'props', 2, NULL, NULL, NULL, NULL, 'admin', '秘書広報課', '2010-10-21 18:56:49', 'admin', '秘書広報課'),
(6, 'enabled', '質問管理', 60, 'qa', 2, NULL, NULL, NULL, NULL, 'admin', '秘書広報課', '2010-10-21 18:56:49', 'admin', '秘書広報課'),
(7, 'enabled', 'リンク', 70, 'fq', 2, NULL, NULL, NULL, NULL, 'admin', '秘書広報課', '2010-10-21 18:56:49', 'admin', '秘書広報課'),
(8, 'enabled', '繰返し１件目', 10, 'head2', 1, NULL, NULL, NULL, NULL, 'admin', '秘書広報課', '2010-10-21 19:04:10', 'admin', '秘書広報課'),
(9, 'enabled', '繰返し２件目以降', 20, 'head', 1, NULL, NULL, NULL, NULL, 'admin', '秘書広報課', '2010-10-21 19:04:10', 'admin', '秘書広報課'),
(10, 'enabled', '電子図書，マニュアル', 80, 'ebook', 2, NULL, NULL, NULL, '2010-10-22 18:14:25', 'admin', '秘書広報課', '2010-10-22 18:14:25', 'admin', '秘書広報課'),
(11, 'enabled', '書庫', 90, 'library', 2, NULL, NULL, NULL, '2010-10-22 18:14:41', 'admin', '秘書広報課', '2010-10-22 18:14:41', 'admin', '秘書広報課'),
(12, 'enabled', 'メーラー', 100, 'menu_mailer', 1, NULL, NULL, NULL, '2010-10-27 16:03:33', 'admin', '秘書広報課', '2010-10-27 16:03:33', 'admin', '秘書広報課'),
(13, 'enabled', 'スケジュール', 110, 'menu_schedules', 1, NULL, NULL, NULL, '2010-10-27 16:03:58', 'admin', '秘書広報課', '2010-10-27 16:03:58', 'admin', '秘書広報課'),
(14, 'enabled', 'Todo', 120, 'menu_todo', 1, NULL, NULL, NULL, '2010-10-27 16:04:18', 'admin', '秘書広報課', '2010-10-27 16:04:18', 'admin', '秘書広報課'),
(15, 'enabled', '連絡メモ', 130, 'menu_memo', 1, NULL, NULL, NULL, '2010-10-27 16:04:45', 'admin', '秘書広報課', '2010-10-27 16:04:45', 'admin', '秘書広報課'),
(16, 'enabled', '新規作成', 140, 'menu_new', 1, NULL, NULL, NULL, '2010-10-27 16:12:09', 'admin', '秘書広報課', '2010-10-27 16:12:09', 'admin', '秘書広報課'),
(17, 'enabled', '照会・回答システム', 150, 'monitor', 2, NULL, NULL, NULL, '2011-02-24 22:54:28', 'admin', '秘書広報課', '2010-12-27 13:36:51', 'admin', '秘書広報課'),
(18, 'enabled', 'DECO', 160, 'menuDeco', 1, NULL, NULL, NULL, '2011-03-30 14:18:44', 'admin', '秘書広報課', '2011-03-30 13:56:32', 'admin', '秘書広報課'),
(19, 'enabled', 'DECOクラウド版', 170, 'menuDecoCloud', 1, NULL, NULL, NULL, '2011-03-30 14:19:14', 'admin', '秘書広報課', '2011-03-30 14:11:27', 'admin', '秘書広報課'),
(20, 'enabled', 'DECO県版', 180, 'menuDecoPref', 1, NULL, NULL, NULL, '2011-03-30 14:19:51', 'admin', '秘書広報課', '2011-03-30 14:12:02', 'admin', '秘書広報課');

--
-- テーブルのデータをダンプしています `gw_edit_tabs`
--

INSERT INTO `gw_edit_tabs` (`id`, `class_created`, `published`, `state`, `level_no`, `parent_id`, `name`, `sort_no`, `tab_keys`, `display_auth`, `other_controller_use`, `other_controller_url`, `link_url`, `icon_path`, `link_div_class`, `class_external`, `class_sso`, `field_account`, `field_pass`, `css_id`, `is_public`, `deleted_at`, `deleted_user`, `deleted_group`, `updated_at`, `updated_user`, `updated_group`, `created_at`, `created_user`, `created_group`) VALUES
(1, 1, 'opened', 'enabled', 1, 0, 'TOP', 10, 0, NULL, 2, NULL, NULL, NULL, NULL, 1, 1, NULL, NULL, 0, 0, NULL, 'admin', '秘書広報課', NULL, 'admin', '秘書広報課', '2010-10-18 17:04:40', 'admin', '秘書広報課'),
(4, 1, 'opened', 'enabled', 2, 1, '個別業務', 50, 80, NULL, 2, NULL, NULL, NULL, NULL, 1, 1, NULL, NULL, 0, 0, NULL, 'admin', '秘書広報課', '2011-05-12 22:30:52', 'admin', '秘書広報課', '2010-10-18 22:22:01', 'admin', '秘書広報課'),
(11, 1, 'opened', 'enabled', 3, 4, '個別システム', 10, 0, NULL, 2, NULL, NULL, NULL, NULL, 1, 1, NULL, NULL, 0, 0, NULL, 'admin', '秘書広報課', NULL, 'admin', '秘書広報課', '2010-10-19 11:27:41', 'admin', '秘書広報課'),
(84, 1, 'opened', 'enabled', 2, 1, 'ポータル', 10, 1, NULL, 1, '/', NULL, NULL, NULL, 1, 1, NULL, NULL, 0, 0, NULL, 'admin', '秘書広報課', '2011-05-12 22:30:52', 'admin', '秘書広報課', '2010-10-20 13:45:40', 'admin', '秘書広報課'),
(158, 1, 'opened', 'enabled', 2, 1, '便利リンク', 60, 3, NULL, 2, '', NULL, NULL, NULL, 0, 1, NULL, NULL, 0, 0, NULL, 'admin', '秘書広報課', '2011-05-12 14:16:23', 'admin', '秘書広報課', '2011-05-12 11:50:48', 'admin', '秘書広報課'),
(159, 1, 'opened', 'enabled', 3, 158, '便利リンク', 10, 0, NULL, 2, '', NULL, NULL, NULL, 0, 1, NULL, NULL, 0, 0, NULL, 'admin', '秘書広報課', '2011-05-12 11:51:34', 'admin', '秘書広報課', '2011-05-12 11:51:34', 'admin', '秘書広報課'),
(173, 1, 'opened', 'enabled', 4, 11, 'アンケート集計システム', 30, 0, NULL, 2, '', '/questionnaire/', '', NULL, 1, 1, '', '', 0, 0, NULL, 'admin', '秘書広報課', '2011-05-22 22:35:37', 'admin', '秘書広報課', '2011-05-13 16:37:20', 'admin', '秘書広報課'),
(174, 1, 'opened', 'enabled', 4, 11, '議員表示　管理者用UI', 40, 0, 'Gw::PrefAssemblyMember.editable?', 2, '', '/gw/pref_assembly_member_admins', '', NULL, 1, 1, '', '', 0, 2, NULL, NULL, NULL, '2011-05-23 20:56:57', NULL, NULL, '2011-05-23 20:56:57', 'システム管理者', '秘書広報課'),
(175, 1, 'opened', 'enabled', 4, 11, '全庁幹部在庁表示　管理者用UI', 50, 0, 'Gw::PrefExecutive.is_admin?', 2, '', '	/gw/pref_executive_admins', '', NULL, 1, 1, '', '', 0, 2, NULL, NULL, NULL, '2011-05-23 22:50:43', 'システム管理者', '秘書広報課', '2011-05-23 20:57:52', 'システム管理者', '秘書広報課'),
(176, 1, 'opened', 'enabled', 4, 11, '部課長在庁表示　管理者用UI', 60, 0, 'Gw::PrefDirector.is_admin?', 2, '', '/gw/pref_director_admins', '', NULL, 1, 1, '', '', 0, 2, NULL, NULL, NULL, '2011-05-23 22:51:12', 'システム管理者', '秘書広報課', '2011-05-23 20:58:54', 'システム管理者', '秘書広報課'),
(177, 1, 'opened', 'enabled', 4, 11, '電子職員録', 70, 0, NULL, 2, '', '/gwsub/sb04/01/sb04stafflistview', '', NULL, 1, 1, '', '', 0, 0, NULL, NULL, NULL, '2012-05-21 11:25:27', 'システム管理者', '秘書広報課', '2012-05-16 11:41:02', 'システム管理者', '秘書広報課'),
(178, 1, 'opened', 'enabled', 4, 11, '研修等申込・受付システム', 80, 0, NULL, 2, '', '/gwsub/sb01/sb01_training_entries', '', NULL, 1, 1, '', '', 0, 0, NULL, NULL, NULL, '2012-05-21 11:25:27', 'システム管理者', '秘書広報課', '2012-05-16 15:09:34', 'システム管理者', '秘書広報課');

--
-- テーブルのデータをダンプしています `gw_edit_tab_public_roles`
--


--
-- テーブルのデータをダンプしています `gw_holidays`
--

INSERT INTO `gw_holidays` (`id`, `creator_uid`, `creator_ucode`, `creator_uname`, `creator_gid`, `creator_gcode`, `creator_gname`, `title_category_id`, `title`, `is_public`, `memo`, `schedule_repeat_id`, `dirty_repeat_id`, `no_time_id`, `st_at`, `ed_at`, `created_at`, `updated_at`) VALUES
(1, 5194, 'admin', 'admin', 698, '001002', '秘書広報課', NULL, '元日', 1, '', NULL, NULL, 1, '2010-01-01 00:00:00', '2010-01-01 00:00:00', '2010-03-10 17:20:00', '2010-06-15 13:43:39'),
(2, 5194, 'admin', 'admin', 698, '001002', '秘書広報課', NULL, '成人の日', 1, '', NULL, NULL, 1, '2010-01-11 00:00:00', '2010-01-02 00:00:00', '2010-03-10 17:20:00', '2010-06-15 11:56:44'),
(3, 5194, 'admin', 'admin', 698, '001002', '秘書広報課', NULL, '建国記念の日', 1, '', NULL, NULL, 1, '2010-02-11 00:00:00', '2010-02-11 00:00:00', '2010-03-10 17:20:00', '2010-03-10 17:20:00'),
(4, 5194, 'admin', 'admin', 698, '001002', '秘書広報課', NULL, '春分の日', 1, '', NULL, NULL, 1, '2010-03-21 00:00:00', '2010-03-21 00:00:00', '2010-03-10 17:20:00', '2010-03-10 17:20:00'),
(5, 5194, 'admin', 'admin', 698, '001002', '秘書広報課', NULL, '振替休日', 1, '', NULL, NULL, 1, '2010-03-22 00:00:00', '2010-03-22 00:00:00', '2010-03-10 17:20:00', '2010-03-10 17:20:00'),
(6, 5194, 'admin', 'admin', 698, '001002', '秘書広報課', NULL, '昭和の日', 1, '', NULL, NULL, 1, '2010-04-29 00:00:00', '2010-04-29 00:00:00', '2010-03-10 17:20:00', '2010-03-10 17:20:00'),
(7, 5194, 'admin', 'admin', 698, '001002', '秘書広報課', NULL, '憲法記念日', 1, '', NULL, NULL, 1, '2010-05-03 00:00:00', '2010-05-03 00:00:00', '2010-03-10 17:20:00', '2010-03-10 17:20:00'),
(8, 5194, 'admin', 'admin', 698, '001002', '秘書広報課', NULL, 'みどりの日', 1, '', NULL, NULL, 1, '2010-05-04 00:00:00', '2010-05-04 00:00:00', '2010-03-10 17:20:00', '2010-03-10 17:20:00'),
(9, 5194, 'admin', 'admin', 698, '001002', '秘書広報課', NULL, 'こどもの日', 1, '', NULL, NULL, 1, '2010-05-05 00:00:00', '2010-05-05 00:00:00', '2010-03-10 17:20:00', '2010-03-10 17:20:00'),
(10, 5194, 'admin', 'admin', 698, '001002', '秘書広報課', NULL, '海の日', 1, '', NULL, NULL, 1, '2010-07-19 00:00:00', '2010-07-19 00:00:00', '2010-03-10 17:20:00', '2010-03-10 17:20:00'),
(11, 5194, 'admin', 'admin', 698, '001002', '秘書広報課', NULL, '敬老の日', 1, '', NULL, NULL, 1, '2010-09-20 00:00:00', '2010-09-20 00:00:00', '2010-03-10 17:20:00', '2010-03-10 17:20:00'),
(12, 5194, 'admin', 'admin', 698, '001002', '秘書広報課', NULL, '秋分の日', 1, '', NULL, NULL, 1, '2010-09-23 00:00:00', '2010-09-23 00:00:00', '2010-03-10 17:20:00', '2010-03-10 17:20:00'),
(13, 5194, 'admin', 'admin', 698, '001002', '秘書広報課', NULL, '体育の日', 1, '', NULL, NULL, 1, '2010-10-11 00:00:00', '2010-10-11 00:00:00', '2010-03-10 17:20:00', '2010-03-10 17:20:00'),
(14, 5194, 'admin', 'admin', 698, '001002', '秘書広報課', NULL, '文化の日', 1, '', NULL, NULL, 1, '2010-11-03 00:00:00', '2010-11-03 00:00:00', '2010-03-10 17:20:00', '2010-03-10 17:20:00'),
(15, 5194, 'admin', 'admin', 698, '001002', '秘書広報課', NULL, '勤労感謝の日', 1, '', NULL, NULL, 1, '2010-11-23 00:00:00', '2010-11-23 00:00:00', '2010-03-10 17:20:00', '2010-03-10 17:20:00'),
(16, 5194, 'admin', 'admin', 698, '001002', '秘書広報課', NULL, '天皇誕生日', 1, '', NULL, NULL, 1, '2010-12-23 00:00:00', '2010-12-23 00:00:00', '2010-03-10 17:20:00', '2010-03-10 17:20:00'),
(24, 5194, 'admin', 'admin', 698, '001002', '秘書広報課', 2, '停電', 1, NULL, NULL, NULL, 1, '2010-06-16 00:00:00', '2010-06-16 00:00:00', '2010-06-16 18:40:21', '2010-06-16 18:40:21'),
(25, 5194, 'admin', 'admin', 698, '001002', '秘書広報課', 3, '休みです。', 1, NULL, NULL, NULL, 1, '2010-06-17 00:00:00', '2010-06-17 00:00:00', '2010-06-16 18:41:08', '2010-06-16 18:41:08'),
(26, 5194, 'admin', 'admin', 698, '001002', '秘書広報課', 1, '元日', 1, NULL, NULL, NULL, 1, '2011-01-01 00:00:00', '2011-01-01 00:00:00', '2010-08-27 16:53:38', '2010-08-27 16:53:38'),
(27, 5194, 'admin', 'admin', 698, '001002', '秘書広報課', NULL, '成人の日', 1, '', NULL, NULL, 1, '2011-01-10 00:00:00', '2011-01-10 00:00:00', '2010-03-10 17:20:00', '2010-06-15 11:56:44'),
(28, 5194, 'admin', 'admin', 698, '001002', '秘書広報課', NULL, '建国記念の日', 1, '', NULL, NULL, 1, '2011-02-11 00:00:00', '2011-02-11 00:00:00', '2010-03-10 17:20:00', '2010-03-10 17:20:00'),
(29, 5194, 'admin', 'admin', 698, '001002', '秘書広報課', NULL, '春分の日', 1, '', NULL, NULL, 1, '2011-03-21 00:00:00', '2011-03-21 00:00:00', '2010-03-10 17:20:00', '2010-03-10 17:20:00'),
(31, 5194, 'admin', 'admin', 698, '001002', '秘書広報課', NULL, '昭和の日', 1, '', NULL, NULL, 1, '2011-04-29 00:00:00', '2011-04-29 00:00:00', '2010-03-10 17:20:00', '2010-03-10 17:20:00'),
(32, 5194, 'admin', 'admin', 698, '001002', '秘書広報課', NULL, '憲法記念日', 1, '', NULL, NULL, 1, '2011-05-03 00:00:00', '2011-05-03 00:00:00', '2010-03-10 17:20:00', '2010-03-10 17:20:00'),
(33, 5194, 'admin', 'admin', 698, '001002', '秘書広報課', NULL, 'みどりの日', 1, '', NULL, NULL, 1, '2011-05-04 00:00:00', '2011-05-04 00:00:00', '2010-03-10 17:20:00', '2010-03-10 17:20:00'),
(34, 5194, 'admin', 'admin', 698, '001002', '秘書広報課', NULL, 'こどもの日', 1, '', NULL, NULL, 1, '2011-05-05 00:00:00', '2011-05-05 00:00:00', '2010-03-10 17:20:00', '2010-03-10 17:20:00'),
(35, 5194, 'admin', 'admin', 698, '001002', '秘書広報課', NULL, '海の日', 1, '', NULL, NULL, 1, '2011-07-18 00:00:00', '2011-07-18 00:00:00', '2010-03-10 17:20:00', '2010-03-10 17:20:00'),
(36, 5194, 'admin', 'admin', 698, '001002', '秘書広報課', NULL, '敬老の日', 1, '', NULL, NULL, 1, '2011-09-19 00:00:00', '2011-09-19 00:00:00', '2010-03-10 17:20:00', '2010-03-10 17:20:00'),
(37, 5194, 'admin', 'admin', 698, '001002', '秘書広報課', NULL, '秋分の日', 1, '', NULL, NULL, 1, '2011-09-23 00:00:00', '2011-09-23 00:00:00', '2010-03-10 17:20:00', '2010-03-10 17:20:00'),
(38, 5194, 'admin', 'admin', 698, '001002', '秘書広報課', NULL, '体育の日', 1, '', NULL, NULL, 1, '2011-10-10 00:00:00', '2011-10-11 00:00:00', '2010-03-10 17:20:00', '2010-03-10 17:20:00'),
(39, 5194, 'admin', 'admin', 698, '001002', '秘書広報課', NULL, '文化の日', 1, '', NULL, NULL, 1, '2011-11-03 00:00:00', '2011-11-03 00:00:00', '2010-03-10 17:20:00', '2010-03-10 17:20:00'),
(40, 5194, 'admin', 'admin', 698, '001002', '秘書広報課', NULL, '勤労感謝の日', 1, '', NULL, NULL, 1, '2011-11-23 00:00:00', '2011-11-23 00:00:00', '2010-03-10 17:20:00', '2010-03-10 17:20:00'),
(41, 5194, 'admin', 'admin', 698, '001002', '秘書広報課', NULL, '天皇誕生日', 1, '', NULL, NULL, 1, '2011-12-23 00:00:00', '2011-12-23 00:00:00', '2010-03-10 17:20:00', '2010-03-10 17:20:00');

--
-- テーブルのデータをダンプしています `gw_icons`
--


--
-- テーブルのデータをダンプしています `gw_icon_groups`
--


--
-- テーブルのデータをダンプしています `gw_ind_portal_pieces`
--


--
-- テーブルのデータをダンプしています `gw_infos`
--


--
-- テーブルのデータをダンプしています `gw_memos`
--


--
-- テーブルのデータをダンプしています `gw_memo_mobiles`
--

INSERT INTO `gw_memo_mobiles` (`id`, `domain`, `created_at`, `updated_at`) VALUES
(1, 'docomo.ne.jp', '2010-12-07 13:49:52', '2010-12-07 13:49:52'),
(2, 'ezweb.ne.jp', '2010-12-07 13:49:52', '2010-12-07 13:49:52'),
(3, 'softbank.ne.jp', '2010-12-07 13:49:52', '2010-12-07 13:49:52'),
(4, 'd.vodafone.ne.jp', '2010-12-07 13:49:52', '2010-12-07 13:49:52'),
(5, 'h.vodafone.ne.jp', '2010-12-07 13:49:52', '2010-12-07 13:49:52'),
(6, 't.vodafone.ne.jp', '2010-12-07 13:49:52', '2010-12-07 13:49:52'),
(7, 'c.vodafone.ne.jp', '2010-12-07 13:49:52', '2010-12-07 13:49:52'),
(8, 'r.vodafone.ne.jp', '2010-12-07 13:49:52', '2010-12-07 13:49:52'),
(9, 'k.vodafone.ne.jp', '2010-12-07 13:49:52', '2010-12-07 13:49:52'),
(10, 'n.vodafone.ne.jp', '2010-12-07 13:49:52', '2010-12-07 13:49:52'),
(11, 's.vodafone.ne.jp', '2010-12-07 13:49:52', '2010-12-07 13:49:52'),
(12, 'q.vodafone.ne.jp', '2010-12-07 13:49:52', '2010-12-07 13:49:52'),
(13, 'pdx.ne.jp', '2010-12-08 20:16:06', '2010-12-08 20:16:06');

--
-- テーブルのデータをダンプしています `gw_memo_users`
--


--
-- テーブルのデータをダンプしています `gw_monitor_reminders`
--


--
-- テーブルのデータをダンプしています `gw_notes`
--


--
-- テーブルのデータをダンプしています `gw_portal_adds`
--


--
-- テーブルのデータをダンプしています `gw_portal_user_settings`
--


--
-- テーブルのデータをダンプしています `gw_pref_assembly_members`
--


--
-- テーブルのデータをダンプしています `gw_pref_directors`
--


--
-- テーブルのデータをダンプしています `gw_pref_executives`
--


--
-- テーブルのデータをダンプしています `gw_prop_others`
--

INSERT INTO `gw_user_properties` (`class_id`, `uid`, `name`, `type_name`, `options`, `created_at`, `updated_at`) VALUES
( 3, '0', 'enquete', 'help_link', '[[""], [""], [""], [""], [""], [""], [""]]', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP());

INSERT INTO `gw_user_properties` (`class_id`, `uid`, `name`, `type_name`, `options`, `created_at`, `updated_at`) VALUES
( 3, '0', 'gwmonitor', 'help_link', '[[""], [""]]', CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP());

--
-- テーブルのデータをダンプしています `gw_prop_other_images`
--


--
-- テーブルのデータをダンプしています `gw_prop_other_limits`
--

INSERT INTO `gw_prop_other_limits` (`id`, `sort_no`, `state`, `gid`, `limit`, `created_at`, `updated_at`) VALUES
(1, 20, 'enabled', 697, 20, '2011-05-23 20:42:46', '2011-05-23 20:42:46'),
(2, 30, 'enabled', 698, 20, '2011-05-23 20:42:46', '2011-05-23 20:42:46'),
(3, 40, 'enabled', 699, 20, '2011-05-23 20:42:46', '2011-05-23 20:42:46'),
(4, 50, 'enabled', 700, 20, '2011-05-23 20:42:46', '2011-05-23 20:42:46'),
(5, 60, 'enabled', 701, 20, '2011-05-23 20:42:46', '2011-05-23 20:42:46'),
(6, 90, 'enabled', 703, 20, '2011-05-23 20:42:46', '2011-05-23 20:42:46'),
(7, 100, 'enabled', 704, 20, '2011-05-23 20:42:46', '2011-05-23 20:42:46'),
(8, 110, 'enabled', 705, 20, '2011-05-23 20:42:46', '2011-05-23 20:42:46'),
(9, 120, 'enabled', 706, 20, '2011-05-23 20:42:46', '2011-05-23 20:42:46'),
(10, 130, 'enabled', 707, 20, '2011-05-23 20:42:46', '2011-05-23 20:42:46'),
(11, 140, 'enabled', 708, 20, '2011-05-23 20:42:46', '2011-05-23 20:42:46'),
(12, 150, 'enabled', 709, 20, '2011-05-23 20:42:46', '2011-05-23 20:42:46');

--
-- テーブルのデータをダンプしています `gw_prop_other_roles`
--


--
-- テーブルのデータをダンプしています `gw_prop_types`
--


INSERT INTO `gw_prop_types` (`id`, `state`, `name`, `sort_no`, `created_at`, `updated_at`, `deleted_at`) VALUES
(100, 'public', '公用車', 100, NULL, NULL, NULL),
(200, 'public', '会議室', 200, NULL, NULL, NULL),
(300, 'public', '一般備品', 300, NULL, NULL, NULL);


--
-- テーブルのデータをダンプしています `gw_rss_caches`
--


--
-- テーブルのデータをダンプしています `gw_rss_readers`
--


--
-- テーブルのデータをダンプしています `gw_rss_reader_caches`
--


--
-- テーブルのデータをダンプしています `gw_schedules`
--


--
-- テーブルのデータをダンプしています `gw_schedule_props`
--


--
-- テーブルのデータをダンプしています `gw_schedule_public_roles`
--


--
-- テーブルのデータをダンプしています `gw_schedule_repeats`
--


--
-- テーブルのデータをダンプしています `gw_schedule_users`
--


--
-- テーブルのデータをダンプしています `gw_section_admin_masters`
--


--
-- テーブルのデータをダンプしています `gw_todos`
--


--
-- テーブルのデータをダンプしています `gw_user_properties`
--


--
-- テーブルのデータをダンプしています `gw_year_fiscal_jps`
--

INSERT INTO `gw_year_fiscal_jps` (`id`, `start_at`, `end_at`, `fyear`, `fyear_f`, `markjp`, `markjp_f`, `namejp`, `namejp_f`, `updated_at`, `updated_user`, `updated_group`, `created_at`, `created_user`, `created_group`) VALUES
(1, '1869-04-01 00:00:00', '1870-03-31 23:59:59', '1869', '1869年度', 'M2', 'M2年度', '明治2', '明治2年度', '2009-12-09 10:56:12', NULL, NULL, '2009-12-09 10:56:12', NULL, NULL),
(2, '1870-04-01 00:00:00', '1871-03-31 23:59:59', '1870', '1870年度', 'M3', 'M3年度', '明治3', '明治3年度', '2009-12-09 10:56:12', NULL, NULL, '2009-12-09 10:56:12', NULL, NULL),
(3, '1871-04-01 00:00:00', '1872-03-31 23:59:59', '1871', '1871年度', 'M4', 'M4年度', '明治4', '明治4年度', '2009-12-09 10:56:12', NULL, NULL, '2009-12-09 10:56:12', NULL, NULL),
(4, '1872-04-01 00:00:00', '1873-03-31 23:59:59', '1872', '1872年度', 'M5', 'M5年度', '明治5', '明治5年度', '2009-12-09 10:56:12', NULL, NULL, '2009-12-09 10:56:12', NULL, NULL),
(5, '1873-04-01 00:00:00', '1874-03-31 23:59:59', '1873', '1873年度', 'M6', 'M6年度', '明治6', '明治6年度', '2009-12-09 10:56:12', NULL, NULL, '2009-12-09 10:56:12', NULL, NULL),
(6, '1874-04-01 00:00:00', '1875-03-31 23:59:59', '1874', '1874年度', 'M7', 'M7年度', '明治7', '明治7年度', '2009-12-09 10:56:12', NULL, NULL, '2009-12-09 10:56:12', NULL, NULL),
(7, '1875-04-01 00:00:00', '1876-03-31 23:59:59', '1875', '1875年度', 'M8', 'M8年度', '明治8', '明治8年度', '2009-12-09 10:56:12', NULL, NULL, '2009-12-09 10:56:12', NULL, NULL),
(8, '1876-04-01 00:00:00', '1877-03-31 23:59:59', '1876', '1876年度', 'M9', 'M9年度', '明治9', '明治9年度', '2009-12-09 10:56:12', NULL, NULL, '2009-12-09 10:56:12', NULL, NULL),
(9, '1877-04-01 00:00:00', '1878-03-31 23:59:59', '1877', '1877年度', 'M10', 'M10年度', '明治10', '明治10年度', '2009-12-09 10:56:12', NULL, NULL, '2009-12-09 10:56:12', NULL, NULL),
(10, '1878-04-01 00:00:00', '1879-03-31 23:59:59', '1878', '1878年度', 'M11', 'M11年度', '明治11', '明治11年度', '2009-12-09 10:56:12', NULL, NULL, '2009-12-09 10:56:12', NULL, NULL),
(11, '1879-04-01 00:00:00', '1880-03-31 23:59:59', '1879', '1879年度', 'M12', 'M12年度', '明治12', '明治12年度', '2009-12-09 10:56:12', NULL, NULL, '2009-12-09 10:56:12', NULL, NULL),
(12, '1880-04-01 00:00:00', '1881-03-31 23:59:59', '1880', '1880年度', 'M13', 'M13年度', '明治13', '明治13年度', '2009-12-09 10:56:12', NULL, NULL, '2009-12-09 10:56:12', NULL, NULL),
(13, '1881-04-01 00:00:00', '1882-03-31 23:59:59', '1881', '1881年度', 'M14', 'M14年度', '明治14', '明治14年度', '2009-12-09 10:56:13', NULL, NULL, '2009-12-09 10:56:13', NULL, NULL),
(14, '1882-04-01 00:00:00', '1883-03-31 23:59:59', '1882', '1882年度', 'M15', 'M15年度', '明治15', '明治15年度', '2009-12-09 10:56:13', NULL, NULL, '2009-12-09 10:56:13', NULL, NULL),
(15, '1883-04-01 00:00:00', '1884-03-31 23:59:59', '1883', '1883年度', 'M16', 'M16年度', '明治16', '明治16年度', '2009-12-09 10:56:13', NULL, NULL, '2009-12-09 10:56:13', NULL, NULL),
(16, '1884-04-01 00:00:00', '1885-03-31 23:59:59', '1884', '1884年度', 'M17', 'M17年度', '明治17', '明治17年度', '2009-12-09 10:56:13', NULL, NULL, '2009-12-09 10:56:13', NULL, NULL),
(17, '1885-04-01 00:00:00', '1886-03-31 23:59:59', '1885', '1885年度', 'M18', 'M18年度', '明治18', '明治18年度', '2009-12-09 10:56:13', NULL, NULL, '2009-12-09 10:56:13', NULL, NULL),
(18, '1886-04-01 00:00:00', '1887-03-31 23:59:59', '1886', '1886年度', 'M19', 'M19年度', '明治19', '明治19年度', '2009-12-09 10:56:13', NULL, NULL, '2009-12-09 10:56:13', NULL, NULL),
(19, '1887-04-01 00:00:00', '1888-03-31 23:59:59', '1887', '1887年度', 'M20', 'M20年度', '明治20', '明治20年度', '2009-12-09 10:56:13', NULL, NULL, '2009-12-09 10:56:13', NULL, NULL),
(20, '1888-04-01 00:00:00', '1889-03-31 23:59:59', '1888', '1888年度', 'M21', 'M21年度', '明治21', '明治21年度', '2009-12-09 10:56:13', NULL, NULL, '2009-12-09 10:56:13', NULL, NULL),
(21, '1889-04-01 00:00:00', '1890-03-31 23:59:59', '1889', '1889年度', 'M22', 'M22年度', '明治22', '明治22年度', '2009-12-09 10:56:13', NULL, NULL, '2009-12-09 10:56:13', NULL, NULL),
(22, '1890-04-01 00:00:00', '1891-03-31 23:59:59', '1890', '1890年度', 'M23', 'M23年度', '明治23', '明治23年度', '2009-12-09 10:56:13', NULL, NULL, '2009-12-09 10:56:13', NULL, NULL),
(23, '1891-04-01 00:00:00', '1892-03-31 23:59:59', '1891', '1891年度', 'M24', 'M24年度', '明治24', '明治24年度', '2009-12-09 10:56:13', NULL, NULL, '2009-12-09 10:56:13', NULL, NULL),
(24, '1892-04-01 00:00:00', '1893-03-31 23:59:59', '1892', '1892年度', 'M25', 'M25年度', '明治25', '明治25年度', '2009-12-09 10:56:13', NULL, NULL, '2009-12-09 10:56:13', NULL, NULL),
(25, '1893-04-01 00:00:00', '1894-03-31 23:59:59', '1893', '1893年度', 'M26', 'M26年度', '明治26', '明治26年度', '2009-12-09 10:56:13', NULL, NULL, '2009-12-09 10:56:13', NULL, NULL),
(26, '1894-04-01 00:00:00', '1895-03-31 23:59:59', '1894', '1894年度', 'M27', 'M27年度', '明治27', '明治27年度', '2009-12-09 10:56:13', NULL, NULL, '2009-12-09 10:56:13', NULL, NULL),
(27, '1895-04-01 00:00:00', '1896-03-31 23:59:59', '1895', '1895年度', 'M28', 'M28年度', '明治28', '明治28年度', '2009-12-09 10:56:13', NULL, NULL, '2009-12-09 10:56:13', NULL, NULL),
(28, '1896-04-01 00:00:00', '1897-03-31 23:59:59', '1896', '1896年度', 'M29', 'M29年度', '明治29', '明治29年度', '2009-12-09 10:56:13', NULL, NULL, '2009-12-09 10:56:13', NULL, NULL),
(29, '1897-04-01 00:00:00', '1898-03-31 23:59:59', '1897', '1897年度', 'M30', 'M30年度', '明治30', '明治30年度', '2009-12-09 10:56:13', NULL, NULL, '2009-12-09 10:56:13', NULL, NULL),
(30, '1898-04-01 00:00:00', '1899-03-31 23:59:59', '1898', '1898年度', 'M31', 'M31年度', '明治31', '明治31年度', '2009-12-09 10:56:13', NULL, NULL, '2009-12-09 10:56:13', NULL, NULL),
(31, '1899-04-01 00:00:00', '1900-03-31 23:59:59', '1899', '1899年度', 'M32', 'M32年度', '明治32', '明治32年度', '2009-12-09 10:56:13', NULL, NULL, '2009-12-09 10:56:13', NULL, NULL),
(32, '1900-04-01 00:00:00', '1901-03-31 23:59:59', '1900', '1900年度', 'M33', 'M33年度', '明治33', '明治33年度', '2009-12-09 10:56:13', NULL, NULL, '2009-12-09 10:56:13', NULL, NULL),
(33, '1901-04-01 00:00:00', '1902-03-31 23:59:59', '1901', '1901年度', 'M34', 'M34年度', '明治34', '明治34年度', '2009-12-09 10:56:13', NULL, NULL, '2009-12-09 10:56:13', NULL, NULL),
(34, '1902-04-01 00:00:00', '1903-03-31 23:59:59', '1902', '1902年度', 'M35', 'M35年度', '明治35', '明治35年度', '2009-12-09 10:56:13', NULL, NULL, '2009-12-09 10:56:13', NULL, NULL),
(35, '1903-04-01 00:00:00', '1904-03-31 23:59:59', '1903', '1903年度', 'M36', 'M36年度', '明治36', '明治36年度', '2009-12-09 10:56:13', NULL, NULL, '2009-12-09 10:56:13', NULL, NULL),
(36, '1904-04-01 00:00:00', '1905-03-31 23:59:59', '1904', '1904年度', 'M37', 'M37年度', '明治37', '明治37年度', '2009-12-09 10:56:14', NULL, NULL, '2009-12-09 10:56:14', NULL, NULL),
(37, '1905-04-01 00:00:00', '1906-03-31 23:59:59', '1905', '1905年度', 'M38', 'M38年度', '明治38', '明治38年度', '2009-12-09 10:56:14', NULL, NULL, '2009-12-09 10:56:14', NULL, NULL),
(38, '1906-04-01 00:00:00', '1907-03-31 23:59:59', '1906', '1906年度', 'M39', 'M39年度', '明治39', '明治39年度', '2009-12-09 10:56:14', NULL, NULL, '2009-12-09 10:56:14', NULL, NULL),
(39, '1907-04-01 00:00:00', '1908-03-31 23:59:59', '1907', '1907年度', 'M40', 'M40年度', '明治40', '明治40年度', '2009-12-09 10:56:14', NULL, NULL, '2009-12-09 10:56:14', NULL, NULL),
(40, '1908-04-01 00:00:00', '1909-03-31 23:59:59', '1908', '1908年度', 'M41', 'M41年度', '明治41', '明治41年度', '2009-12-09 10:56:14', NULL, NULL, '2009-12-09 10:56:14', NULL, NULL),
(41, '1909-04-01 00:00:00', '1910-03-31 23:59:59', '1909', '1909年度', 'M42', 'M42年度', '明治42', '明治42年度', '2009-12-09 10:56:14', NULL, NULL, '2009-12-09 10:56:14', NULL, NULL),
(42, '1910-04-01 00:00:00', '1911-03-31 23:59:59', '1910', '1910年度', 'M43', 'M43年度', '明治43', '明治43年度', '2009-12-09 10:56:14', NULL, NULL, '2009-12-09 10:56:14', NULL, NULL),
(43, '1911-04-01 00:00:00', '1912-03-31 23:59:59', '1911', '1911年度', 'M44', 'M44年度', '明治44', '明治44年度', '2009-12-09 10:56:14', NULL, NULL, '2009-12-09 10:56:14', NULL, NULL),
(44, '1912-04-01 00:00:00', '1913-03-31 23:59:59', '1912', '1912年度', 'M45', 'M45年度', '明治45', '明治45年度', '2009-12-09 10:56:14', NULL, NULL, '2009-12-09 10:56:14', NULL, NULL),
(45, '1913-04-01 00:00:00', '1914-03-31 23:59:59', '1913', '1913年度', 'T2', 'T2年度', '大正2', '大正2年度', '2009-12-09 10:56:14', NULL, NULL, '2009-12-09 10:56:14', NULL, NULL),
(46, '1914-04-01 00:00:00', '1915-03-31 23:59:59', '1914', '1914年度', 'T3', 'T3年度', '大正3', '大正3年度', '2009-12-09 10:56:14', NULL, NULL, '2009-12-09 10:56:14', NULL, NULL),
(47, '1915-04-01 00:00:00', '1916-03-31 23:59:59', '1915', '1915年度', 'T4', 'T4年度', '大正4', '大正4年度', '2009-12-09 10:56:14', NULL, NULL, '2009-12-09 10:56:14', NULL, NULL),
(48, '1916-04-01 00:00:00', '1917-03-31 23:59:59', '1916', '1916年度', 'T5', 'T5年度', '大正5', '大正5年度', '2009-12-09 10:56:14', NULL, NULL, '2009-12-09 10:56:14', NULL, NULL),
(49, '1917-04-01 00:00:00', '1918-03-31 23:59:59', '1917', '1917年度', 'T6', 'T6年度', '大正6', '大正6年度', '2009-12-09 10:56:14', NULL, NULL, '2009-12-09 10:56:14', NULL, NULL),
(50, '1918-04-01 00:00:00', '1919-03-31 23:59:59', '1918', '1918年度', 'T7', 'T7年度', '大正7', '大正7年度', '2009-12-09 10:56:14', NULL, NULL, '2009-12-09 10:56:14', NULL, NULL),
(51, '1919-04-01 00:00:00', '1920-03-31 23:59:59', '1919', '1919年度', 'T8', 'T8年度', '大正8', '大正8年度', '2009-12-09 10:56:14', NULL, NULL, '2009-12-09 10:56:14', NULL, NULL),
(52, '1920-04-01 00:00:00', '1921-03-31 23:59:59', '1920', '1920年度', 'T9', 'T9年度', '大正9', '大正9年度', '2009-12-09 10:56:14', NULL, NULL, '2009-12-09 10:56:14', NULL, NULL),
(53, '1921-04-01 00:00:00', '1922-03-31 23:59:59', '1921', '1921年度', 'T10', 'T10年度', '大正10', '大正10年度', '2009-12-09 10:56:14', NULL, NULL, '2009-12-09 10:56:14', NULL, NULL),
(54, '1922-04-01 00:00:00', '1923-03-31 23:59:59', '1922', '1922年度', 'T11', 'T11年度', '大正11', '大正11年度', '2009-12-09 10:56:14', NULL, NULL, '2009-12-09 10:56:14', NULL, NULL),
(55, '1923-04-01 00:00:00', '1924-03-31 23:59:59', '1923', '1923年度', 'T12', 'T12年度', '大正12', '大正12年度', '2009-12-09 10:56:14', NULL, NULL, '2009-12-09 10:56:14', NULL, NULL),
(56, '1924-04-01 00:00:00', '1925-03-31 23:59:59', '1924', '1924年度', 'T13', 'T13年度', '大正13', '大正13年度', '2009-12-09 10:56:14', NULL, NULL, '2009-12-09 10:56:14', NULL, NULL),
(57, '1925-04-01 00:00:00', '1926-03-31 23:59:59', '1925', '1925年度', 'T14', 'T14年度', '大正14', '大正14年度', '2009-12-09 10:56:14', NULL, NULL, '2009-12-09 10:56:14', NULL, NULL),
(58, '1926-04-01 00:00:00', '1927-03-31 23:59:59', '1926', '1926年度', 'T15', 'T15年度', '大正15', '大正15年度', '2009-12-09 10:56:14', NULL, NULL, '2009-12-09 10:56:14', NULL, NULL),
(59, '1927-04-01 00:00:00', '1928-03-31 23:59:59', '1927', '1927年度', 'S2', 'S2年度', '昭和2', '昭和2年度', '2009-12-09 10:56:15', NULL, NULL, '2009-12-09 10:56:15', NULL, NULL),
(60, '1928-04-01 00:00:00', '1929-03-31 23:59:59', '1928', '1928年度', 'S3', 'S3年度', '昭和3', '昭和3年度', '2009-12-09 10:56:15', NULL, NULL, '2009-12-09 10:56:15', NULL, NULL),
(61, '1929-04-01 00:00:00', '1930-03-31 23:59:59', '1929', '1929年度', 'S4', 'S4年度', '昭和4', '昭和4年度', '2009-12-09 10:56:15', NULL, NULL, '2009-12-09 10:56:15', NULL, NULL),
(62, '1930-04-01 00:00:00', '1931-03-31 23:59:59', '1930', '1930年度', 'S5', 'S5年度', '昭和5', '昭和5年度', '2009-12-09 10:56:15', NULL, NULL, '2009-12-09 10:56:15', NULL, NULL),
(63, '1931-04-01 00:00:00', '1932-03-31 23:59:59', '1931', '1931年度', 'S6', 'S6年度', '昭和6', '昭和6年度', '2009-12-09 10:56:15', NULL, NULL, '2009-12-09 10:56:15', NULL, NULL),
(64, '1932-04-01 00:00:00', '1933-03-31 23:59:59', '1932', '1932年度', 'S7', 'S7年度', '昭和7', '昭和7年度', '2009-12-09 10:56:15', NULL, NULL, '2009-12-09 10:56:15', NULL, NULL),
(65, '1933-04-01 00:00:00', '1934-03-31 23:59:59', '1933', '1933年度', 'S8', 'S8年度', '昭和8', '昭和8年度', '2009-12-09 10:56:15', NULL, NULL, '2009-12-09 10:56:15', NULL, NULL),
(66, '1934-04-01 00:00:00', '1935-03-31 23:59:59', '1934', '1934年度', 'S9', 'S9年度', '昭和9', '昭和9年度', '2009-12-09 10:56:15', NULL, NULL, '2009-12-09 10:56:15', NULL, NULL),
(67, '1935-04-01 00:00:00', '1936-03-31 23:59:59', '1935', '1935年度', 'S10', 'S10年度', '昭和10', '昭和10年度', '2009-12-09 10:56:15', NULL, NULL, '2009-12-09 10:56:15', NULL, NULL),
(68, '1936-04-01 00:00:00', '1937-03-31 23:59:59', '1936', '1936年度', 'S11', 'S11年度', '昭和11', '昭和11年度', '2009-12-09 10:56:15', NULL, NULL, '2009-12-09 10:56:15', NULL, NULL),
(69, '1937-04-01 00:00:00', '1938-03-31 23:59:59', '1937', '1937年度', 'S12', 'S12年度', '昭和12', '昭和12年度', '2009-12-09 10:56:15', NULL, NULL, '2009-12-09 10:56:15', NULL, NULL),
(70, '1938-04-01 00:00:00', '1939-03-31 23:59:59', '1938', '1938年度', 'S13', 'S13年度', '昭和13', '昭和13年度', '2009-12-09 10:56:15', NULL, NULL, '2009-12-09 10:56:15', NULL, NULL),
(71, '1939-04-01 00:00:00', '1940-03-31 23:59:59', '1939', '1939年度', 'S14', 'S14年度', '昭和14', '昭和14年度', '2009-12-09 10:56:15', NULL, NULL, '2009-12-09 10:56:15', NULL, NULL),
(72, '1940-04-01 00:00:00', '1941-03-31 23:59:59', '1940', '1940年度', 'S15', 'S15年度', '昭和15', '昭和15年度', '2009-12-09 10:56:15', NULL, NULL, '2009-12-09 10:56:15', NULL, NULL),
(73, '1941-04-01 00:00:00', '1942-03-31 23:59:59', '1941', '1941年度', 'S16', 'S16年度', '昭和16', '昭和16年度', '2009-12-09 10:56:15', NULL, NULL, '2009-12-09 10:56:15', NULL, NULL),
(74, '1942-04-01 00:00:00', '1943-03-31 23:59:59', '1942', '1942年度', 'S17', 'S17年度', '昭和17', '昭和17年度', '2009-12-09 10:56:15', NULL, NULL, '2009-12-09 10:56:15', NULL, NULL),
(75, '1943-04-01 00:00:00', '1944-03-31 23:59:59', '1943', '1943年度', 'S18', 'S18年度', '昭和18', '昭和18年度', '2009-12-09 10:56:15', NULL, NULL, '2009-12-09 10:56:15', NULL, NULL),
(76, '1944-04-01 00:00:00', '1945-03-31 23:59:59', '1944', '1944年度', 'S19', 'S19年度', '昭和19', '昭和19年度', '2009-12-09 10:56:15', NULL, NULL, '2009-12-09 10:56:15', NULL, NULL),
(77, '1945-04-01 00:00:00', '1946-03-31 23:59:59', '1945', '1945年度', 'S20', 'S20年度', '昭和20', '昭和20年度', '2009-12-09 10:56:15', NULL, NULL, '2009-12-09 10:56:15', NULL, NULL),
(78, '1946-04-01 00:00:00', '1947-03-31 23:59:59', '1946', '1946年度', 'S21', 'S21年度', '昭和21', '昭和21年度', '2009-12-09 10:56:15', NULL, NULL, '2009-12-09 10:56:15', NULL, NULL),
(79, '1947-04-01 00:00:00', '1948-03-31 23:59:59', '1947', '1947年度', 'S22', 'S22年度', '昭和22', '昭和22年度', '2009-12-09 10:56:15', NULL, NULL, '2009-12-09 10:56:15', NULL, NULL),
(80, '1948-04-01 00:00:00', '1949-03-31 23:59:59', '1948', '1948年度', 'S23', 'S23年度', '昭和23', '昭和23年度', '2009-12-09 10:56:15', NULL, NULL, '2009-12-09 10:56:15', NULL, NULL),
(81, '1949-04-01 00:00:00', '1950-03-31 23:59:59', '1949', '1949年度', 'S24', 'S24年度', '昭和24', '昭和24年度', '2009-12-09 10:56:16', NULL, NULL, '2009-12-09 10:56:16', NULL, NULL),
(82, '1950-04-01 00:00:00', '1951-03-31 23:59:59', '1950', '1950年度', 'S25', 'S25年度', '昭和25', '昭和25年度', '2009-12-09 10:56:16', NULL, NULL, '2009-12-09 10:56:16', NULL, NULL),
(83, '1951-04-01 00:00:00', '1952-03-31 23:59:59', '1951', '1951年度', 'S26', 'S26年度', '昭和26', '昭和26年度', '2009-12-09 10:56:16', NULL, NULL, '2009-12-09 10:56:16', NULL, NULL),
(84, '1952-04-01 00:00:00', '1953-03-31 23:59:59', '1952', '1952年度', 'S27', 'S27年度', '昭和27', '昭和27年度', '2009-12-09 10:56:16', NULL, NULL, '2009-12-09 10:56:16', NULL, NULL),
(85, '1953-04-01 00:00:00', '1954-03-31 23:59:59', '1953', '1953年度', 'S28', 'S28年度', '昭和28', '昭和28年度', '2009-12-09 10:56:16', NULL, NULL, '2009-12-09 10:56:16', NULL, NULL),
(86, '1954-04-01 00:00:00', '1955-03-31 23:59:59', '1954', '1954年度', 'S29', 'S29年度', '昭和29', '昭和29年度', '2009-12-09 10:56:16', NULL, NULL, '2009-12-09 10:56:16', NULL, NULL),
(87, '1955-04-01 00:00:00', '1956-03-31 23:59:59', '1955', '1955年度', 'S30', 'S30年度', '昭和30', '昭和30年度', '2009-12-09 10:56:16', NULL, NULL, '2009-12-09 10:56:16', NULL, NULL),
(88, '1956-04-01 00:00:00', '1957-03-31 23:59:59', '1956', '1956年度', 'S31', 'S31年度', '昭和31', '昭和31年度', '2009-12-09 10:56:16', NULL, NULL, '2009-12-09 10:56:16', NULL, NULL),
(89, '1957-04-01 00:00:00', '1958-03-31 23:59:59', '1957', '1957年度', 'S32', 'S32年度', '昭和32', '昭和32年度', '2009-12-09 10:56:16', NULL, NULL, '2009-12-09 10:56:16', NULL, NULL),
(90, '1958-04-01 00:00:00', '1959-03-31 23:59:59', '1958', '1958年度', 'S33', 'S33年度', '昭和33', '昭和33年度', '2009-12-09 10:56:16', NULL, NULL, '2009-12-09 10:56:16', NULL, NULL),
(91, '1959-04-01 00:00:00', '1960-03-31 23:59:59', '1959', '1959年度', 'S34', 'S34年度', '昭和34', '昭和34年度', '2009-12-09 10:56:16', NULL, NULL, '2009-12-09 10:56:16', NULL, NULL),
(92, '1960-04-01 00:00:00', '1961-03-31 23:59:59', '1960', '1960年度', 'S35', 'S35年度', '昭和35', '昭和35年度', '2009-12-09 10:56:16', NULL, NULL, '2009-12-09 10:56:16', NULL, NULL),
(93, '1961-04-01 00:00:00', '1962-03-31 23:59:59', '1961', '1961年度', 'S36', 'S36年度', '昭和36', '昭和36年度', '2009-12-09 10:56:16', NULL, NULL, '2009-12-09 10:56:16', NULL, NULL),
(94, '1962-04-01 00:00:00', '1963-03-31 23:59:59', '1962', '1962年度', 'S37', 'S37年度', '昭和37', '昭和37年度', '2009-12-09 10:56:16', NULL, NULL, '2009-12-09 10:56:16', NULL, NULL),
(95, '1963-04-01 00:00:00', '1964-03-31 23:59:59', '1963', '1963年度', 'S38', 'S38年度', '昭和38', '昭和38年度', '2009-12-09 10:56:16', NULL, NULL, '2009-12-09 10:56:16', NULL, NULL),
(96, '1964-04-01 00:00:00', '1965-03-31 23:59:59', '1964', '1964年度', 'S39', 'S39年度', '昭和39', '昭和39年度', '2009-12-09 10:56:16', NULL, NULL, '2009-12-09 10:56:16', NULL, NULL),
(97, '1965-04-01 00:00:00', '1966-03-31 23:59:59', '1965', '1965年度', 'S40', 'S40年度', '昭和40', '昭和40年度', '2009-12-09 10:56:16', NULL, NULL, '2009-12-09 10:56:16', NULL, NULL),
(98, '1966-04-01 00:00:00', '1967-03-31 23:59:59', '1966', '1966年度', 'S41', 'S41年度', '昭和41', '昭和41年度', '2009-12-09 10:56:16', NULL, NULL, '2009-12-09 10:56:16', NULL, NULL),
(99, '1967-04-01 00:00:00', '1968-03-31 23:59:59', '1967', '1967年度', 'S42', 'S42年度', '昭和42', '昭和42年度', '2009-12-09 10:56:16', NULL, NULL, '2009-12-09 10:56:16', NULL, NULL),
(100, '1968-04-01 00:00:00', '1969-03-31 23:59:59', '1968', '1968年度', 'S43', 'S43年度', '昭和43', '昭和43年度', '2009-12-09 10:56:16', NULL, NULL, '2009-12-09 10:56:16', NULL, NULL),
(101, '1969-04-01 00:00:00', '1970-03-31 23:59:59', '1969', '1969年度', 'S44', 'S44年度', '昭和44', '昭和44年度', '2009-12-09 10:56:16', NULL, NULL, '2009-12-09 10:56:16', NULL, NULL),
(102, '1970-04-01 00:00:00', '1971-03-31 23:59:59', '1970', '1970年度', 'S45', 'S45年度', '昭和45', '昭和45年度', '2009-12-09 10:56:16', NULL, NULL, '2009-12-09 10:56:16', NULL, NULL),
(103, '1971-04-01 00:00:00', '1972-03-31 23:59:59', '1971', '1971年度', 'S46', 'S46年度', '昭和46', '昭和46年度', '2009-12-09 10:56:17', NULL, NULL, '2009-12-09 10:56:17', NULL, NULL),
(104, '1972-04-01 00:00:00', '1973-03-31 23:59:59', '1972', '1972年度', 'S47', 'S47年度', '昭和47', '昭和47年度', '2009-12-09 10:56:17', NULL, NULL, '2009-12-09 10:56:17', NULL, NULL),
(105, '1973-04-01 00:00:00', '1974-03-31 23:59:59', '1973', '1973年度', 'S48', 'S48年度', '昭和48', '昭和48年度', '2009-12-09 10:56:17', NULL, NULL, '2009-12-09 10:56:17', NULL, NULL),
(106, '1974-04-01 00:00:00', '1975-03-31 23:59:59', '1974', '1974年度', 'S49', 'S49年度', '昭和49', '昭和49年度', '2009-12-09 10:56:17', NULL, NULL, '2009-12-09 10:56:17', NULL, NULL),
(107, '1975-04-01 00:00:00', '1976-03-31 23:59:59', '1975', '1975年度', 'S50', 'S50年度', '昭和50', '昭和50年度', '2009-12-09 10:56:17', NULL, NULL, '2009-12-09 10:56:17', NULL, NULL),
(108, '1976-04-01 00:00:00', '1977-03-31 23:59:59', '1976', '1976年度', 'S51', 'S51年度', '昭和51', '昭和51年度', '2009-12-09 10:56:17', NULL, NULL, '2009-12-09 10:56:17', NULL, NULL),
(109, '1977-04-01 00:00:00', '1978-03-31 23:59:59', '1977', '1977年度', 'S52', 'S52年度', '昭和52', '昭和52年度', '2009-12-09 10:56:17', NULL, NULL, '2009-12-09 10:56:17', NULL, NULL),
(110, '1978-04-01 00:00:00', '1979-03-31 23:59:59', '1978', '1978年度', 'S53', 'S53年度', '昭和53', '昭和53年度', '2009-12-09 10:56:17', NULL, NULL, '2009-12-09 10:56:17', NULL, NULL),
(111, '1979-04-01 00:00:00', '1980-03-31 23:59:59', '1979', '1979年度', 'S54', 'S54年度', '昭和54', '昭和54年度', '2009-12-09 10:56:17', NULL, NULL, '2009-12-09 10:56:17', NULL, NULL),
(112, '1980-04-01 00:00:00', '1981-03-31 23:59:59', '1980', '1980年度', 'S55', 'S55年度', '昭和55', '昭和55年度', '2009-12-09 10:56:17', NULL, NULL, '2009-12-09 10:56:17', NULL, NULL),
(113, '1981-04-01 00:00:00', '1982-03-31 23:59:59', '1981', '1981年度', 'S56', 'S56年度', '昭和56', '昭和56年度', '2009-12-09 10:56:17', NULL, NULL, '2009-12-09 10:56:17', NULL, NULL),
(114, '1982-04-01 00:00:00', '1983-03-31 23:59:59', '1982', '1982年度', 'S57', 'S57年度', '昭和57', '昭和57年度', '2009-12-09 10:56:17', NULL, NULL, '2009-12-09 10:56:17', NULL, NULL),
(115, '1983-04-01 00:00:00', '1984-03-31 23:59:59', '1983', '1983年度', 'S58', 'S58年度', '昭和58', '昭和58年度', '2009-12-09 10:56:17', NULL, NULL, '2009-12-09 10:56:17', NULL, NULL),
(116, '1984-04-01 00:00:00', '1985-03-31 23:59:59', '1984', '1984年度', 'S59', 'S59年度', '昭和59', '昭和59年度', '2009-12-09 10:56:17', NULL, NULL, '2009-12-09 10:56:17', NULL, NULL),
(117, '1985-04-01 00:00:00', '1986-03-31 23:59:59', '1985', '1985年度', 'S60', 'S60年度', '昭和60', '昭和60年度', '2009-12-09 10:56:17', NULL, NULL, '2009-12-09 10:56:17', NULL, NULL),
(118, '1986-04-01 00:00:00', '1987-03-31 23:59:59', '1986', '1986年度', 'S61', 'S61年度', '昭和61', '昭和61年度', '2009-12-09 10:56:17', NULL, NULL, '2009-12-09 10:56:17', NULL, NULL),
(119, '1987-04-01 00:00:00', '1988-03-31 23:59:59', '1987', '1987年度', 'S62', 'S62年度', '昭和62', '昭和62年度', '2009-12-09 10:56:17', NULL, NULL, '2009-12-09 10:56:17', NULL, NULL),
(120, '1988-04-01 00:00:00', '1989-03-31 23:59:59', '1988', '1988年度', 'S63', 'S63年度', '昭和63', '昭和63年度', '2009-12-09 10:56:17', NULL, NULL, '2009-12-09 10:56:17', NULL, NULL),
(121, '1989-04-01 00:00:00', '1990-03-31 23:59:59', '1989', '1989年度', 'H1', 'H1年度', '平成1', '平成1年度', '2009-12-09 10:56:17', NULL, NULL, '2009-12-09 10:56:17', NULL, NULL),
(122, '1990-04-01 00:00:00', '1991-03-31 23:59:59', '1990', '1990年度', 'H2', 'H2年度', '平成2', '平成2年度', '2009-12-09 10:56:17', NULL, NULL, '2009-12-09 10:56:17', NULL, NULL),
(123, '1991-04-01 00:00:00', '1992-03-31 23:59:59', '1991', '1991年度', 'H3', 'H3年度', '平成3', '平成3年度', '2009-12-09 10:56:17', NULL, NULL, '2009-12-09 10:56:17', NULL, NULL),
(124, '1992-04-01 00:00:00', '1993-03-31 23:59:59', '1992', '1992年度', 'H4', 'H4年度', '平成4', '平成4年度', '2009-12-09 10:56:17', NULL, NULL, '2009-12-09 10:56:17', NULL, NULL),
(125, '1993-04-01 00:00:00', '1994-03-31 23:59:59', '1993', '1993年度', 'H5', 'H5年度', '平成5', '平成5年度', '2009-12-09 10:56:17', NULL, NULL, '2009-12-09 10:56:17', NULL, NULL),
(126, '1994-04-01 00:00:00', '1995-03-31 23:59:59', '1994', '1994年度', 'H6', 'H6年度', '平成6', '平成6年度', '2009-12-09 10:56:17', NULL, NULL, '2009-12-09 10:56:17', NULL, NULL),
(127, '1995-04-01 00:00:00', '1996-03-31 23:59:59', '1995', '1995年度', 'H7', 'H7年度', '平成7', '平成7年度', '2009-12-09 10:56:17', NULL, NULL, '2009-12-09 10:56:17', NULL, NULL),
(128, '1996-04-01 00:00:00', '1997-03-31 23:59:59', '1996', '1996年度', 'H8', 'H8年度', '平成8', '平成8年度', '2009-12-09 10:56:18', NULL, NULL, '2009-12-09 10:56:18', NULL, NULL),
(129, '1997-04-01 00:00:00', '1998-03-31 23:59:59', '1997', '1997年度', 'H9', 'H9年度', '平成9', '平成9年度', '2009-12-09 10:56:18', NULL, NULL, '2009-12-09 10:56:18', NULL, NULL),
(130, '1998-04-01 00:00:00', '1999-03-31 23:59:59', '1998', '1998年度', 'H10', 'H10年度', '平成10', '平成10年度', '2009-12-09 10:56:18', NULL, NULL, '2009-12-09 10:56:18', NULL, NULL),
(131, '1999-04-01 00:00:00', '2000-03-31 23:59:59', '1999', '1999年度', 'H11', 'H11年度', '平成11', '平成11年度', '2009-12-09 10:56:18', NULL, NULL, '2009-12-09 10:56:18', NULL, NULL),
(132, '2000-04-01 00:00:00', '2001-03-31 23:59:59', '2000', '2000年度', 'H12', 'H12年度', '平成12', '平成12年度', '2009-12-09 10:56:18', NULL, NULL, '2009-12-09 10:56:18', NULL, NULL),
(133, '2001-04-01 00:00:00', '2002-03-31 23:59:59', '2001', '2001年度', 'H13', 'H13年度', '平成13', '平成13年度', '2009-12-09 10:56:18', NULL, NULL, '2009-12-09 10:56:18', NULL, NULL),
(134, '2002-04-01 00:00:00', '2003-03-31 23:59:59', '2002', '2002年度', 'H14', 'H14年度', '平成14', '平成14年度', '2009-12-09 10:56:18', NULL, NULL, '2009-12-09 10:56:18', NULL, NULL),
(135, '2003-04-01 00:00:00', '2004-03-31 23:59:59', '2003', '2003年度', 'H15', 'H15年度', '平成15', '平成15年度', '2009-12-09 10:56:18', NULL, NULL, '2009-12-09 10:56:18', NULL, NULL),
(136, '2004-04-01 00:00:00', '2005-03-31 23:59:59', '2004', '2004年度', 'H16', 'H16年度', '平成16', '平成16年度', '2009-12-09 10:56:18', NULL, NULL, '2009-12-09 10:56:18', NULL, NULL),
(137, '2005-04-01 00:00:00', '2006-03-31 23:59:59', '2005', '2005年度', 'H17', 'H17年度', '平成17', '平成17年度', '2009-12-09 10:56:18', NULL, NULL, '2009-12-09 10:56:18', NULL, NULL),
(138, '2006-04-01 00:00:00', '2007-03-31 23:59:59', '2006', '2006年度', 'H18', 'H18年度', '平成18', '平成18年度', '2009-12-09 10:56:18', NULL, NULL, '2009-12-09 10:56:18', NULL, NULL),
(139, '2007-04-01 00:00:00', '2008-03-31 23:59:59', '2007', '2007年度', 'H19', 'H19年度', '平成19', '平成19年度', '2009-12-09 10:56:18', NULL, NULL, '2009-12-09 10:56:18', NULL, NULL),
(140, '2008-04-01 00:00:00', '2009-03-31 23:59:59', '2008', '2008年度', 'H20', 'H20年度', '平成20', '平成20年度', '2009-12-09 10:56:18', NULL, NULL, '2009-12-09 10:56:18', NULL, NULL),
(141, '2009-04-01 00:00:00', '2010-03-31 23:59:59', '2009', '2009年度', 'H21', 'H21年度', '平成21', '平成21年度', '2009-12-09 10:56:18', NULL, NULL, '2009-12-09 10:56:18', NULL, NULL),
(142, '2010-04-01 00:00:00', '2011-03-31 23:59:59', '2010', '2010年度', 'H22', 'H22年度', '平成22', '平成22年度', '2009-12-09 11:06:08', NULL, NULL, '2009-12-09 11:06:08', NULL, NULL),
(143, '2011-04-01 00:00:00', '2012-03-31 23:59:59', '2011', '2011年度', 'H23', 'H23年度', '平成23', '平成23年度', '2010-10-07 13:02:06', NULL, NULL, '2010-06-10 13:35:27', NULL, NULL),
(145, '2012-04-01 00:00:00', '2013-03-31 23:59:59', '2012', '2012年度', 'H24', 'H24年度', '平成24', '平成24年度', '2012-05-15 17:51:17', NULL, NULL, '2012-05-15 17:51:17', NULL, NULL);

--
-- テーブルのデータをダンプしています `gw_year_mark_jps`
--

INSERT INTO `gw_year_mark_jps` (`id`, `name`, `mark`, `start_at`, `updated_at`, `updated_user`, `updated_group`, `created_at`, `created_user`, `created_group`) VALUES
(1, '明治', 'M', '1868-09-08 00:00:00', '2009-09-25 09:19:53', '', '', '2009-09-22 11:57:19', '', ''),
(2, '大正', 'T', '1912-07-30 00:00:00', '2009-09-25 09:19:53', '', '', '2009-09-22 11:57:19', '', ''),
(3, '昭和', 'S', '1926-12-25 00:00:00', '2010-10-07 17:48:22', '', '', '2009-09-22 11:57:19', '', ''),
(4, '平成', 'H', '1989-01-08 00:00:00', '2010-10-07 19:32:11', '', '', '2009-09-22 11:57:19', '', '');

--
-- テーブルのデータをダンプしています `questionnaire_bases`
--


--
-- テーブルのデータをダンプしています `questionnaire_field_options`
--


--
-- テーブルのデータをダンプしています `questionnaire_form_fields`
--


--
-- テーブルのデータをダンプしています `questionnaire_itemdeletes`
--

INSERT INTO `questionnaire_itemdeletes` (`id`, `content_id`, `created_at`, `updated_at`, `admin_code`, `limit_date`) VALUES
(1, 0, '2010-11-22 11:22:42', '2012-05-21 13:08:28', 'admin', '24.months');

--
-- テーブルのデータをダンプしています `questionnaire_previews`
--


--
-- テーブルのデータをダンプしています `questionnaire_results`
--


--
-- テーブルのデータをダンプしています `questionnaire_template_bases`
--


--
-- テーブルのデータをダンプしています `questionnaire_template_field_options`
--


--
-- テーブルのデータをダンプしています `questionnaire_template_form_fields`
--


--
-- テーブルのデータをダンプしています `questionnaire_template_previews`
--


--
-- テーブルのデータをダンプしています `questionnaire_temporaries`
--

--
-- テーブルのデータをダンプしています `gw_workflow_controls`
--

INSERT INTO `gw_workflow_controls` (`id`, `unid`, `content_id`, `state`, `created_at`, `updated_at`, `recognized_at`, `published_at`, `default_published`, `doc_body_size_capacity`, `doc_body_size_currently`, `upload_graphic_file_size_capacity`, `upload_graphic_file_size_capacity_unit`, `upload_document_file_size_capacity`, `upload_document_file_size_capacity_unit`, `upload_graphic_file_size_max`, `upload_document_file_size_max`, `upload_graphic_file_size_currently`, `upload_document_file_size_currently`, `commission_limit`, `create_section`, `create_section_flag`, `addnew_forbidden`, `edit_forbidden`, `draft_forbidden`, `delete_forbidden`, `attachfile_index_use`, `importance`, `form_name`, `banner`, `banner_position`, `left_banner`, `left_menu`, `left_index_use`, `left_index_pattern`, `left_index_bg_color`, `default_mode`, `other_system_link`, `preview_mode`, `wallpaper_id`, `wallpaper`, `css`, `font_color`, `icon_id`, `icon`, `sort_no`, `caption`, `view_hide`, `categoey_view`, `categoey_view_line`, `monthly_view`, `monthly_view_line`, `group_view`, `one_line_use`, `notification`, `restrict_access`, `upload_system`, `limit_date`, `name`, `title`, `category`, `category1_name`, `category2_name`, `category3_name`, `recognize`, `createdate`, `createrdivision_id`, `createrdivision`, `creater_id`, `creater`, `editdate`, `editordivision_id`, `editordivision`, `editor_id`, `editor`, `default_limit`, `dbname`, `admingrps`, `admingrps_json`, `adms`, `adms_json`, `dsp_admin_name`, `editors`, `editors_json`, `readers`, `readers_json`, `sueditors`, `sueditors_json`, `sureaders`, `sureaders_json`, `help_display`, `help_url`, `help_admin_url`, `notes_field01`, `notes_field02`, `notes_field03`, `notes_field04`, `notes_field05`, `notes_field06`, `notes_field07`, `notes_field08`, `notes_field09`, `notes_field10`, `docslast_updated_at`) VALUES
(1, NULL, NULL, 'public', '2013-05-20 10:00:00', '2013-05-20 10:00:00', NULL, NULL, 7, 100, 0, 10, 'GB', 10, 'GB', 5, 5, 0, 0, 200, NULL, '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1', NULL, NULL, NULL, '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '', 1, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 3, 'use', NULL, 'ワークフロー', NULL, NULL, NULL, NULL, 0, '2010-11-19 10:55', '698', '秘書広報課', 'gwbbs', 'admin', '2010-11-25 17:13', '698', '秘書広報課', 'gwbbs', 'admin', 200, NULL, '--- !map:HashWithIndifferentAccess \ngid: "3"\n', '[]', '--- !map:HashWithIndifferentAccess \ngid: "36"\n', '[]', '', '--- !map:HashWithIndifferentAccess \ngid: "3"\n', '[["", "0", "制限なし"]]', '--- !map:HashWithIndifferentAccess \ngid: "0"\n', '[["", "0", "制限なし"]]', '--- !map:HashWithIndifferentAccess \ngid: "36"\n', '[]', '--- !map:HashWithIndifferentAccess \ngid: "36"\n', '[]', '1', '', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

