
SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

--
-- データベース: `development_jgw_gw`
--

-- --------------------------------------------------------

--
-- テーブルの構造 `digitallibrary_adms`
--

DROP TABLE IF EXISTS `digitallibrary_adms`;
CREATE TABLE IF NOT EXISTS `digitallibrary_adms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `title_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `user_code` varchar(255) DEFAULT NULL,
  `user_name` text,
  `group_id` int(11) DEFAULT NULL,
  `group_code` varchar(255) DEFAULT NULL,
  `group_name` text,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `digitallibrary_controls`
--

DROP TABLE IF EXISTS `digitallibrary_controls`;
CREATE TABLE IF NOT EXISTS `digitallibrary_controls` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `recognized_at` datetime DEFAULT NULL,
  `published_at` datetime DEFAULT NULL,
  `default_published` int(11) DEFAULT NULL,
  `upload_graphic_file_size_capacity` int(11) DEFAULT NULL,
  `upload_graphic_file_size_capacity_unit` varchar(255) DEFAULT NULL,
  `upload_document_file_size_capacity` int(11) DEFAULT NULL,
  `upload_document_file_size_capacity_unit` varchar(255) DEFAULT NULL,
  `upload_graphic_file_size_max` int(11) DEFAULT NULL,
  `upload_document_file_size_max` int(11) DEFAULT NULL,
  `upload_graphic_file_size_currently` decimal(17,0) DEFAULT NULL,
  `upload_document_file_size_currently` decimal(17,0) DEFAULT NULL,
  `create_section` varchar(255) DEFAULT NULL,
  `addnew_forbidden` int(11) DEFAULT NULL,
  `draft_forbidden` int(11) DEFAULT NULL,
  `delete_forbidden` int(11) DEFAULT NULL,
  `importance` int(11) DEFAULT NULL,
  `form_name` varchar(255) DEFAULT NULL,
  `banner` text,
  `banner_position` varchar(255) DEFAULT NULL,
  `left_banner` text,
  `left_menu` text,
  `left_index_use` varchar(1) DEFAULT NULL,
  `left_index_bg_color` varchar(255) DEFAULT NULL,
  `default_folder` varchar(255) DEFAULT NULL,
  `other_system_link` text,
  `wallpaper` text,
  `css` text,
  `sort_no` int(11) DEFAULT NULL,
  `caption` text,
  `view_hide` tinyint(1) DEFAULT NULL,
  `categoey_view` tinyint(1) DEFAULT NULL,
  `categoey_view_line` int(11) DEFAULT NULL,
  `monthly_view` tinyint(1) DEFAULT NULL,
  `monthly_view_line` int(11) DEFAULT NULL,
  `notification` int(11) DEFAULT NULL,
  `upload_system` int(11) DEFAULT NULL,
  `limit_date` varchar(255) DEFAULT NULL,
  `separator_str1` varchar(255) DEFAULT NULL,
  `separator_str2` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `category` int(11) DEFAULT NULL,
  `category1_name` varchar(255) DEFAULT NULL,
  `category2_name` varchar(255) DEFAULT NULL,
  `category3_name` varchar(255) DEFAULT NULL,
  `recognize` int(11) DEFAULT NULL,
  `createdate` text,
  `createrdivision_id` varchar(20) DEFAULT NULL,
  `createrdivision` text,
  `creater_id` varchar(20) DEFAULT NULL,
  `creater` text,
  `editdate` text,
  `editordivision_id` varchar(20) DEFAULT NULL,
  `editordivision` text,
  `editor_id` varchar(20) DEFAULT NULL,
  `editor` text,
  `default_limit` int(11) DEFAULT NULL,
  `dbname` varchar(255) DEFAULT NULL,
  `admingrps` text,
  `admingrps_json` text,
  `adms` text,
  `adms_json` text,
  `dsp_admin_name` text,
  `editors` text,
  `editors_json` text,
  `readers` text,
  `readers_json` text,
  `sueditors` text,
  `sueditors_json` text,
  `sureaders` text,
  `sureaders_json` text,
  `help_display` text,
  `help_url` text,
  `help_admin_url` text,
  `docslast_updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `digitallibrary_roles`
--

DROP TABLE IF EXISTS `digitallibrary_roles`;
CREATE TABLE IF NOT EXISTS `digitallibrary_roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `title_id` int(11) DEFAULT NULL,
  `role_code` varchar(255) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `user_code` varchar(255) DEFAULT NULL,
  `user_name` text,
  `group_id` int(11) DEFAULT NULL,
  `group_code` varchar(255) DEFAULT NULL,
  `group_name` text,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `doclibrary_adms`
--

DROP TABLE IF EXISTS `doclibrary_adms`;
CREATE TABLE IF NOT EXISTS `doclibrary_adms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `title_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `user_code` varchar(255) DEFAULT NULL,
  `user_name` text,
  `group_id` int(11) DEFAULT NULL,
  `group_code` varchar(255) DEFAULT NULL,
  `group_name` text,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `doclibrary_controls`
--

DROP TABLE IF EXISTS `doclibrary_controls`;
CREATE TABLE IF NOT EXISTS `doclibrary_controls` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `recognized_at` datetime DEFAULT NULL,
  `published_at` datetime DEFAULT NULL,
  `default_published` int(11) DEFAULT NULL,
  `upload_graphic_file_size_capacity` int(11) DEFAULT NULL,
  `upload_graphic_file_size_capacity_unit` varchar(255) DEFAULT NULL,
  `upload_document_file_size_capacity` int(11) DEFAULT NULL,
  `upload_document_file_size_capacity_unit` varchar(255) DEFAULT NULL,
  `upload_graphic_file_size_max` int(11) DEFAULT NULL,
  `upload_document_file_size_max` int(11) DEFAULT NULL,
  `upload_graphic_file_size_currently` decimal(17,0) DEFAULT NULL,
  `upload_document_file_size_currently` decimal(17,0) DEFAULT NULL,
  `create_section` varchar(255) DEFAULT NULL,
  `addnew_forbidden` int(11) DEFAULT NULL,
  `draft_forbidden` int(11) DEFAULT NULL,
  `delete_forbidden` int(11) DEFAULT NULL,
  `importance` int(11) DEFAULT NULL,
  `form_name` varchar(255) DEFAULT NULL,
  `banner` text,
  `banner_position` varchar(255) DEFAULT NULL,
  `left_banner` text,
  `left_menu` text,
  `left_index_use` varchar(1) DEFAULT NULL,
  `left_index_bg_color` varchar(255) DEFAULT NULL,
  `default_folder` varchar(255) DEFAULT NULL,
  `other_system_link` text,
  `wallpaper` text,
  `css` text,
  `sort_no` int(11) DEFAULT NULL,
  `caption` text,
  `view_hide` tinyint(1) DEFAULT NULL,
  `categoey_view` tinyint(1) DEFAULT NULL,
  `categoey_view_line` int(11) DEFAULT NULL,
  `monthly_view` tinyint(1) DEFAULT NULL,
  `monthly_view_line` int(11) DEFAULT NULL,
  `notification` int(11) DEFAULT NULL,
  `upload_system` int(11) DEFAULT NULL,
  `limit_date` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `category` int(11) DEFAULT NULL,
  `category1_name` varchar(255) DEFAULT NULL,
  `category2_name` varchar(255) DEFAULT NULL,
  `category3_name` varchar(255) DEFAULT NULL,
  `recognize` int(11) DEFAULT NULL,
  `createdate` text,
  `createrdivision_id` varchar(20) DEFAULT NULL,
  `createrdivision` text,
  `creater_id` varchar(20) DEFAULT NULL,
  `creater` text,
  `editdate` text,
  `editordivision_id` varchar(20) DEFAULT NULL,
  `editordivision` text,
  `editor_id` varchar(20) DEFAULT NULL,
  `editor` text,
  `default_limit` int(11) DEFAULT NULL,
  `dbname` varchar(255) DEFAULT NULL,
  `admingrps` text,
  `admingrps_json` text,
  `adms` text,
  `adms_json` text,
  `dsp_admin_name` text,
  `editors` text,
  `editors_json` text,
  `readers` text,
  `readers_json` text,
  `sueditors` text,
  `sueditors_json` text,
  `sureaders` text,
  `sureaders_json` text,
  `help_display` text,
  `help_url` text,
  `help_admin_url` text,
  `special_link` text,
  `docslast_updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `doclibrary_roles`
--

DROP TABLE IF EXISTS `doclibrary_roles`;
CREATE TABLE IF NOT EXISTS `doclibrary_roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `title_id` int(11) DEFAULT NULL,
  `role_code` varchar(255) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `user_code` varchar(255) DEFAULT NULL,
  `user_name` text,
  `group_id` int(11) DEFAULT NULL,
  `group_code` varchar(255) DEFAULT NULL,
  `group_name` text,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `enquete_answers`
--

DROP TABLE IF EXISTS `enquete_answers`;
CREATE TABLE IF NOT EXISTS `enquete_answers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `latest_updated_at` datetime DEFAULT NULL,
  `enquete_division` tinyint(1) DEFAULT NULL,
  `title_id` int(11) DEFAULT NULL,
  `user_code` varchar(255) DEFAULT NULL,
  `user_name` text,
  `l2_section_code` varchar(255) DEFAULT NULL,
  `section_code` varchar(255) DEFAULT NULL,
  `section_name` text,
  `section_sort` int(11) DEFAULT NULL,
  `field_001` text,
  `field_002` text,
  `field_003` text,
  `field_004` text,
  `field_005` text,
  `field_006` text,
  `field_007` text,
  `field_008` text,
  `field_009` text,
  `field_010` text,
  `field_011` text,
  `field_012` text,
  `field_013` text,
  `field_014` text,
  `field_015` text,
  `field_016` text,
  `field_017` text,
  `field_018` text,
  `field_019` text,
  `field_020` text,
  `field_021` text,
  `field_022` text,
  `field_023` text,
  `field_024` text,
  `field_025` text,
  `field_026` text,
  `field_027` text,
  `field_028` text,
  `field_029` text,
  `field_030` text,
  `field_031` text,
  `field_032` text,
  `field_033` text,
  `field_034` text,
  `field_035` text,
  `field_036` text,
  `field_037` text,
  `field_038` text,
  `field_039` text,
  `field_040` text,
  `field_041` text,
  `field_042` text,
  `field_043` text,
  `field_044` text,
  `field_045` text,
  `field_046` text,
  `field_047` text,
  `field_048` text,
  `field_049` text,
  `field_050` text,
  `field_051` text,
  `field_052` text,
  `field_053` text,
  `field_054` text,
  `field_055` text,
  `field_056` text,
  `field_057` text,
  `field_058` text,
  `field_059` text,
  `field_060` text,
  `field_061` text,
  `field_062` text,
  `field_063` text,
  `field_064` text,
  `createdate` text,
  `createrdivision_id` varchar(20) DEFAULT NULL,
  `createrdivision` text,
  `creater_id` varchar(20) DEFAULT NULL,
  `creater` text,
  `editdate` text,
  `editordivision_id` varchar(20) DEFAULT NULL,
  `editordivision` text,
  `editor_id` varchar(20) DEFAULT NULL,
  `editor` text,
  `able_date` datetime DEFAULT NULL,
  `expiry_date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_code` (`user_code`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `enquete_base_users`
--

DROP TABLE IF EXISTS `enquete_base_users`;
CREATE TABLE IF NOT EXISTS `enquete_base_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `base_user_code` varchar(255) DEFAULT NULL,
  `base_user_name` text,
  PRIMARY KEY (`id`),
  KEY `base_user_code` (`base_user_code`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- ビュー用の代替構造 `enquete_view_questions`
--
DROP VIEW IF EXISTS `enquete_view_questions`;
CREATE TABLE IF NOT EXISTS `enquete_view_questions` (
`base_user_code` varchar(255)
,`id` int(11)
,`unid` int(11)
,`include_index` tinyint(1)
,`content_id` int(11)
,`state` text
,`created_at` datetime
,`updated_at` datetime
,`section_code` varchar(255)
,`section_name` varchar(255)
,`section_sort` int(11)
,`enquete_division` tinyint(1)
,`manage_title` varchar(255)
,`title` varchar(255)
,`form_body` text
,`able_date` datetime
,`expiry_date` datetime
,`spec_config` int(11)
,`send_change` varchar(255)
,`createdate` text
,`createrdivision_id` varchar(20)
,`createrdivision` text
,`creater_id` varchar(20)
,`creater` text
,`editdate` text
,`editordivision_id` varchar(20)
,`editordivision` text
,`editor_id` varchar(20)
,`editor` text
,`custom_groups` text
,`custom_groups_json` text
,`reader_groups` text
,`reader_groups_json` text
,`custom_readers` text
,`custom_readers_json` text
,`readers` text
,`readers_json` text
,`default_limit` int(11)
);
-- --------------------------------------------------------

--
-- テーブルの構造 `gwbbs_adms`
--

DROP TABLE IF EXISTS `gwbbs_adms`;
CREATE TABLE IF NOT EXISTS `gwbbs_adms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `title_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `user_code` varchar(255) DEFAULT NULL,
  `user_name` text,
  `group_id` int(11) DEFAULT NULL,
  `group_code` varchar(255) DEFAULT NULL,
  `group_name` text,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwbbs_controls`
--

DROP TABLE IF EXISTS `gwbbs_controls`;
CREATE TABLE IF NOT EXISTS `gwbbs_controls` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `recognized_at` datetime DEFAULT NULL,
  `published_at` datetime DEFAULT NULL,
  `default_published` int(11) DEFAULT NULL,
  `doc_body_size_capacity` int(11) DEFAULT NULL,
  `doc_body_size_currently` int(11) DEFAULT NULL,
  `upload_graphic_file_size_capacity` int(11) DEFAULT NULL,
  `upload_graphic_file_size_capacity_unit` varchar(255) DEFAULT NULL,
  `upload_document_file_size_capacity` int(11) DEFAULT NULL,
  `upload_document_file_size_capacity_unit` varchar(255) DEFAULT NULL,
  `upload_graphic_file_size_max` int(11) DEFAULT NULL,
  `upload_document_file_size_max` int(11) DEFAULT NULL,
  `upload_graphic_file_size_currently` decimal(17,0) DEFAULT NULL,
  `upload_document_file_size_currently` decimal(17,0) DEFAULT NULL,
  `create_section` varchar(255) DEFAULT NULL,
  `create_section_flag` varchar(255) DEFAULT NULL,
  `addnew_forbidden` tinyint(1) DEFAULT NULL,
  `edit_forbidden` tinyint(1) DEFAULT NULL,
  `draft_forbidden` tinyint(1) DEFAULT NULL,
  `delete_forbidden` tinyint(1) DEFAULT NULL,
  `attachfile_index_use` tinyint(1) DEFAULT NULL,
  `importance` int(11) DEFAULT NULL,
  `form_name` varchar(255) DEFAULT NULL,
  `banner` text,
  `banner_position` varchar(255) DEFAULT NULL,
  `left_banner` text,
  `left_menu` text,
  `left_index_use` varchar(1) DEFAULT NULL,
  `left_index_pattern` int(11) DEFAULT NULL,
  `left_index_bg_color` varchar(255) DEFAULT NULL,
  `default_mode` varchar(255) DEFAULT NULL,
  `other_system_link` text,
  `preview_mode` tinyint(1) DEFAULT NULL,
  `wallpaper_id` int(11) DEFAULT NULL,
  `wallpaper` text,
  `css` text,
  `font_color` text,
  `icon_id` int(11) DEFAULT NULL,
  `icon` text,
  `sort_no` int(11) DEFAULT NULL,
  `caption` text,
  `view_hide` tinyint(1) DEFAULT NULL,
  `categoey_view` tinyint(1) DEFAULT NULL,
  `categoey_view_line` int(11) DEFAULT NULL,
  `monthly_view` tinyint(1) DEFAULT NULL,
  `monthly_view_line` int(11) DEFAULT NULL,
  `group_view` tinyint(1) DEFAULT NULL,
  `one_line_use` int(11) DEFAULT NULL,
  `notification` int(11) DEFAULT NULL,
  `restrict_access` tinyint(1) DEFAULT NULL,
  `upload_system` int(11) DEFAULT NULL,
  `limit_date` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `category` int(11) DEFAULT NULL,
  `category1_name` varchar(255) DEFAULT NULL,
  `category2_name` varchar(255) DEFAULT NULL,
  `category3_name` varchar(255) DEFAULT NULL,
  `recognize` int(11) DEFAULT NULL,
  `createdate` text,
  `createrdivision_id` varchar(20) DEFAULT NULL,
  `createrdivision` text,
  `creater_id` varchar(20) DEFAULT NULL,
  `creater` text,
  `editdate` text,
  `editordivision_id` varchar(20) DEFAULT NULL,
  `editordivision` text,
  `editor_id` varchar(20) DEFAULT NULL,
  `editor` text,
  `default_limit` int(11) DEFAULT NULL,
  `dbname` varchar(255) DEFAULT NULL,
  `admingrps` text,
  `admingrps_json` text,
  `adms` text,
  `adms_json` text,
  `dsp_admin_name` text,
  `editors` text,
  `editors_json` text,
  `readers` text,
  `readers_json` text,
  `sueditors` text,
  `sueditors_json` text,
  `sureaders` text,
  `sureaders_json` text,
  `help_display` text,
  `help_url` text,
  `help_admin_url` text,
  `notes_field01` text,
  `notes_field02` text,
  `notes_field03` text,
  `notes_field04` text,
  `notes_field05` text,
  `notes_field06` text,
  `notes_field07` text,
  `notes_field08` text,
  `notes_field09` text,
  `notes_field10` text,
  `docslast_updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwbbs_itemdeletes`
--

DROP TABLE IF EXISTS `gwbbs_itemdeletes`;
CREATE TABLE IF NOT EXISTS `gwbbs_itemdeletes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `admin_code` varchar(255) DEFAULT NULL,
  `title_id` int(11) DEFAULT NULL,
  `board_title` text,
  `board_state` varchar(255) DEFAULT NULL,
  `board_view_hide` varchar(255) DEFAULT NULL,
  `board_sort_no` int(11) DEFAULT NULL,
  `public_doc_count` int(11) DEFAULT NULL,
  `void_doc_count` int(11) DEFAULT NULL,
  `dbname` varchar(255) DEFAULT NULL,
  `limit_date` varchar(255) DEFAULT NULL,
  `board_limit_date` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwbbs_roles`
--

DROP TABLE IF EXISTS `gwbbs_roles`;
CREATE TABLE IF NOT EXISTS `gwbbs_roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `title_id` int(11) DEFAULT NULL,
  `role_code` varchar(255) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `user_code` varchar(255) DEFAULT NULL,
  `user_name` text,
  `group_id` int(11) DEFAULT NULL,
  `group_code` varchar(255) DEFAULT NULL,
  `group_name` text,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwbbs_themes`
--

DROP TABLE IF EXISTS `gwbbs_themes`;
CREATE TABLE IF NOT EXISTS `gwbbs_themes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `recognized_at` datetime DEFAULT NULL,
  `published_at` datetime DEFAULT NULL,
  `latest_updated_at` datetime DEFAULT NULL,
  `board_id` int(11) DEFAULT NULL,
  `theme_id` int(11) DEFAULT NULL,
  `section_code` text,
  `section_name` text,
  `createdate` text,
  `creater_admin` tinyint(1) DEFAULT NULL,
  `createrdivision_id` varchar(20) DEFAULT NULL,
  `createrdivision` text,
  `creater_id` varchar(20) DEFAULT NULL,
  `creater` text,
  `editdate` text,
  `editor_admin` tinyint(1) DEFAULT NULL,
  `editordivision_id` varchar(20) DEFAULT NULL,
  `editordivision` text,
  `editor_id` varchar(20) DEFAULT NULL,
  `editor` text,
  PRIMARY KEY (`id`)
)  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwboard_bgcolors`
--

DROP TABLE IF EXISTS `gwboard_bgcolors`;
CREATE TABLE IF NOT EXISTS `gwboard_bgcolors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `color_code_hex` varchar(255) DEFAULT NULL,
  `color_code_class` varchar(255) DEFAULT NULL,
  `pair_font_color` varchar(255) DEFAULT NULL,
  `memo` text,
  PRIMARY KEY (`id`)
)  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwboard_images`
--

DROP TABLE IF EXISTS `gwboard_images`;
CREATE TABLE IF NOT EXISTS `gwboard_images` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `recognized_at` datetime DEFAULT NULL,
  `published_at` datetime DEFAULT NULL,
  `latest_updated_at` datetime DEFAULT NULL,
  `share` int(11) DEFAULT NULL,
  `range_of_use` int(11) DEFAULT NULL,
  `filename` text,
  `content_type` varchar(255) DEFAULT NULL,
  `memo` text,
  `size` int(11) DEFAULT NULL,
  `width` int(11) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `section_code` text,
  `section_name` text,
  `createdate` text,
  `creater_admin` tinyint(1) DEFAULT NULL,
  `createrdivision_id` varchar(20) DEFAULT NULL,
  `createrdivision` text,
  `creater_id` varchar(20) DEFAULT NULL,
  `creater` text,
  `editdate` text,
  `editor_admin` tinyint(1) DEFAULT NULL,
  `editordivision_id` varchar(20) DEFAULT NULL,
  `editordivision` text,
  `editor_id` varchar(20) DEFAULT NULL,
  `editor` text,
  PRIMARY KEY (`id`)
)  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwboard_maps`
--

DROP TABLE IF EXISTS `gwboard_maps`;
CREATE TABLE IF NOT EXISTS `gwboard_maps` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `system_name` varchar(255) DEFAULT NULL,
  `title_id` int(11) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `field_name` varchar(255) DEFAULT NULL,
  `use_param` int(11) DEFAULT NULL,
  `address` text,
  `latlong` varchar(255) DEFAULT NULL,
  `latitude` varchar(255) DEFAULT NULL,
  `longitude` varchar(255) DEFAULT NULL,
  `memo` text,
  `url` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
)  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwboard_renewal_groups`
--

DROP TABLE IF EXISTS `gwboard_renewal_groups`;
CREATE TABLE IF NOT EXISTS `gwboard_renewal_groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `present_group_id` int(11) DEFAULT NULL,
  `present_group_code` varchar(255) DEFAULT NULL,
  `present_group_name` text,
  `incoming_group_id` int(11) DEFAULT NULL,
  `incoming_group_code` varchar(255) DEFAULT NULL,
  `incoming_group_name` text,
  `start_date` datetime,
  PRIMARY KEY (`id`)
)  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwboard_syntheses`
--

DROP TABLE IF EXISTS `gwboard_syntheses`;
CREATE TABLE IF NOT EXISTS `gwboard_syntheses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `latest_updated_at` datetime DEFAULT NULL,
  `system_name` varchar(255) DEFAULT NULL,
  `state` text,
  `title_id` int(11) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `board_name` varchar(255) DEFAULT NULL,
  `title` text,
  `url` text,
  `editordivision` text,
  `editor` text,
  `able_date` datetime DEFAULT NULL,
  `expiry_date` datetime DEFAULT NULL,
  `acl_flag` int(11) DEFAULT NULL,
  `acl_section_code` varchar(255) DEFAULT NULL,
  `acl_user_code` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwboard_synthesetups`
--

DROP TABLE IF EXISTS `gwboard_synthesetups`;
CREATE TABLE IF NOT EXISTS `gwboard_synthesetups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `gwbbs_check` tinyint(1) DEFAULT NULL,
  `gwfaq_check` tinyint(1) DEFAULT NULL,
  `gwqa_check` tinyint(1) DEFAULT NULL,
  `doclib_check` tinyint(1) DEFAULT NULL,
  `digitallib_check` tinyint(1) DEFAULT NULL,
  `limit_date` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwboard_themes`
--

DROP TABLE IF EXISTS `gwboard_themes`;
CREATE TABLE IF NOT EXISTS `gwboard_themes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `recognized_at` datetime DEFAULT NULL,
  `published_at` datetime DEFAULT NULL,
  `latest_updated_at` datetime DEFAULT NULL,
  `record_use` varchar(255) DEFAULT NULL,
  `sort_no` int(11) DEFAULT NULL,
  `if_name` text,
  `if_icon_id` int(11) DEFAULT NULL,
  `if_icon` text,
  `if_bg_setup` int(11) DEFAULT NULL,
  `if_font_color` text,
  `if_wallpaper_id` int(11) DEFAULT NULL,
  `if_wallpaper` text,
  `if_css` text,
  `name` text,
  `preview_mode` tinyint(1) DEFAULT NULL,
  `bg_setup` int(11) DEFAULT NULL,
  `icon_id` int(11) DEFAULT NULL,
  `icon` text,
  `css` text,
  `font_color` text,
  `wallpaper_id` int(11) DEFAULT NULL,
  `wallpaper` text,
  `section_code` text,
  `section_name` text,
  `createdate` text,
  `creater_admin` tinyint(1) DEFAULT NULL,
  `createrdivision_id` varchar(20) DEFAULT NULL,
  `createrdivision` text,
  `creater_id` varchar(20) DEFAULT NULL,
  `creater` text,
  `editdate` text,
  `editor_admin` tinyint(1) DEFAULT NULL,
  `editordivision_id` varchar(20) DEFAULT NULL,
  `editordivision` text,
  `editor_id` varchar(20) DEFAULT NULL,
  `editor` text,
  PRIMARY KEY (`id`)
)  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwcircular_adms`
--

DROP TABLE IF EXISTS `gwcircular_adms`;
CREATE TABLE IF NOT EXISTS `gwcircular_adms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `title_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `user_code` varchar(255) DEFAULT NULL,
  `user_name` text,
  `group_id` int(11) DEFAULT NULL,
  `group_code` varchar(255) DEFAULT NULL,
  `group_name` text,
  PRIMARY KEY (`id`)
)  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwcircular_controls`
--

DROP TABLE IF EXISTS `gwcircular_controls`;
CREATE TABLE IF NOT EXISTS `gwcircular_controls` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `recognized_at` datetime DEFAULT NULL,
  `published_at` datetime DEFAULT NULL,
  `default_published` int(11) DEFAULT NULL,
  `doc_body_size_capacity` int(11) DEFAULT NULL,
  `doc_body_size_currently` int(11) DEFAULT NULL,
  `upload_graphic_file_size_capacity` int(11) DEFAULT NULL,
  `upload_graphic_file_size_capacity_unit` varchar(255) DEFAULT NULL,
  `upload_document_file_size_capacity` int(11) DEFAULT NULL,
  `upload_document_file_size_capacity_unit` varchar(255) DEFAULT NULL,
  `upload_graphic_file_size_max` int(11) DEFAULT NULL,
  `upload_document_file_size_max` int(11) DEFAULT NULL,
  `upload_graphic_file_size_currently` decimal(17,0) DEFAULT NULL,
  `upload_document_file_size_currently` decimal(17,0) DEFAULT NULL,
  `commission_limit` int(11) DEFAULT NULL,
  `create_section` varchar(255) DEFAULT NULL,
  `create_section_flag` varchar(255) DEFAULT NULL,
  `addnew_forbidden` tinyint(1) DEFAULT NULL,
  `edit_forbidden` tinyint(1) DEFAULT NULL,
  `draft_forbidden` tinyint(1) DEFAULT NULL,
  `delete_forbidden` tinyint(1) DEFAULT NULL,
  `attachfile_index_use` tinyint(1) DEFAULT NULL,
  `importance` int(11) DEFAULT NULL,
  `form_name` varchar(255) DEFAULT NULL,
  `banner` text,
  `banner_position` varchar(255) DEFAULT NULL,
  `left_banner` text,
  `left_menu` text,
  `left_index_use` varchar(1) DEFAULT NULL,
  `left_index_pattern` int(11) DEFAULT NULL,
  `left_index_bg_color` varchar(255) DEFAULT NULL,
  `default_mode` varchar(255) DEFAULT NULL,
  `other_system_link` text,
  `preview_mode` tinyint(1) DEFAULT NULL,
  `wallpaper_id` int(11) DEFAULT NULL,
  `wallpaper` text,
  `css` text,
  `font_color` text,
  `icon_id` int(11) DEFAULT NULL,
  `icon` text,
  `sort_no` int(11) DEFAULT NULL,
  `caption` text,
  `view_hide` tinyint(1) DEFAULT NULL,
  `categoey_view` tinyint(1) DEFAULT NULL,
  `categoey_view_line` int(11) DEFAULT NULL,
  `monthly_view` tinyint(1) DEFAULT NULL,
  `monthly_view_line` int(11) DEFAULT NULL,
  `group_view` tinyint(1) DEFAULT NULL,
  `one_line_use` int(11) DEFAULT NULL,
  `notification` int(11) DEFAULT NULL,
  `restrict_access` tinyint(1) DEFAULT NULL,
  `upload_system` int(11) DEFAULT NULL,
  `limit_date` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `category` int(11) DEFAULT NULL,
  `category1_name` varchar(255) DEFAULT NULL,
  `category2_name` varchar(255) DEFAULT NULL,
  `category3_name` varchar(255) DEFAULT NULL,
  `recognize` int(11) DEFAULT NULL,
  `createdate` text,
  `createrdivision_id` varchar(20) DEFAULT NULL,
  `createrdivision` text,
  `creater_id` varchar(20) DEFAULT NULL,
  `creater` text,
  `editdate` text,
  `editordivision_id` varchar(20) DEFAULT NULL,
  `editordivision` text,
  `editor_id` varchar(20) DEFAULT NULL,
  `editor` text,
  `default_limit` int(11) DEFAULT NULL,
  `dbname` varchar(255) DEFAULT NULL,
  `admingrps` text,
  `admingrps_json` text,
  `adms` text,
  `adms_json` text,
  `dsp_admin_name` text,
  `editors` text,
  `editors_json` text,
  `readers` text,
  `readers_json` text,
  `sueditors` text,
  `sueditors_json` text,
  `sureaders` text,
  `sureaders_json` text,
  `help_display` text,
  `help_url` text,
  `help_admin_url` text,
  `notes_field01` text,
  `notes_field02` text,
  `notes_field03` text,
  `notes_field04` text,
  `notes_field05` text,
  `notes_field06` text,
  `notes_field07` text,
  `notes_field08` text,
  `notes_field09` text,
  `notes_field10` text,
  `docslast_updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwcircular_custom_groups`
--

DROP TABLE IF EXISTS `gwcircular_custom_groups`;
CREATE TABLE IF NOT EXISTS `gwcircular_custom_groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `class_id` int(11) DEFAULT NULL,
  `owner_uid` int(11) DEFAULT NULL,
  `owner_gid` int(11) DEFAULT NULL,
  `updater_uid` int(11) DEFAULT NULL,
  `updater_gid` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `level_no` int(11) DEFAULT NULL,
  `name` text,
  `name_en` text,
  `sort_no` int(11) DEFAULT NULL,
  `sort_prefix` text,
  `is_default` int(11) DEFAULT NULL,
  `reader_groups_json` mediumtext,
  `reader_groups` mediumtext,
  `readers_json` mediumtext,
  `readers` mediumtext,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwcircular_docs`
--

DROP TABLE IF EXISTS `gwcircular_docs`;
CREATE TABLE IF NOT EXISTS `gwcircular_docs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `recognized_at` datetime DEFAULT NULL,
  `published_at` datetime DEFAULT NULL,
  `latest_updated_at` datetime DEFAULT NULL,
  `doc_type` int(11) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `target_user_id` int(11) DEFAULT NULL,
  `target_user_code` varchar(20) DEFAULT NULL,
  `target_user_name` text,
  `confirmation` int(11) DEFAULT NULL,
  `section_code` varchar(255) DEFAULT NULL,
  `section_name` text,
  `importance` int(11) DEFAULT NULL,
  `title_id` int(11) DEFAULT NULL,
  `name` text,
  `title` text,
  `head` mediumtext,
  `body` mediumtext,
  `note` mediumtext,
  `category_use` int(11) DEFAULT NULL,
  `category1_id` int(11) DEFAULT NULL,
  `category2_id` int(11) DEFAULT NULL,
  `category3_id` int(11) DEFAULT NULL,
  `category4_id` int(11) DEFAULT NULL,
  `keywords` text,
  `commission_count` int(11) DEFAULT NULL,
  `unread_count` int(11) DEFAULT NULL,
  `already_count` int(11) DEFAULT NULL,
  `draft_count` int(11) DEFAULT NULL,
  `createdate` text,
  `creater_admin` tinyint(1) DEFAULT NULL,
  `createrdivision_id` varchar(20) DEFAULT NULL,
  `createrdivision` text,
  `creater_id` varchar(20) DEFAULT NULL,
  `creater` text,
  `editdate` text,
  `editor_admin` tinyint(1) DEFAULT NULL,
  `editordivision_id` varchar(20) DEFAULT NULL,
  `editordivision` text,
  `editor_id` varchar(20) DEFAULT NULL,
  `editor` text,
  `able_date` datetime DEFAULT NULL,
  `expiry_date` datetime DEFAULT NULL,
  `attachmentfile` int(11) DEFAULT NULL,
  `reader_groups_json` mediumtext,
  `reader_groups` mediumtext,
  `readers_json` mediumtext,
  `readers` mediumtext,
  PRIMARY KEY (`id`),
  KEY `parent_id` (`parent_id`)
) DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwcircular_files`
--

DROP TABLE IF EXISTS `gwcircular_files`;
CREATE TABLE IF NOT EXISTS `gwcircular_files` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `recognized_at` datetime DEFAULT NULL,
  `published_at` datetime DEFAULT NULL,
  `latest_updated_at` datetime DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `title_id` int(11) DEFAULT NULL,
  `content_type` varchar(255) DEFAULT NULL,
  `filename` text,
  `memo` text,
  `size` int(11) DEFAULT NULL,
  `width` int(11) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `db_file_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwcircular_itemdeletes`
--

DROP TABLE IF EXISTS `gwcircular_itemdeletes`;
CREATE TABLE IF NOT EXISTS `gwcircular_itemdeletes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `admin_code` varchar(255) DEFAULT NULL,
  `title_id` int(11) DEFAULT NULL,
  `board_title` text,
  `board_state` varchar(255) DEFAULT NULL,
  `board_view_hide` varchar(255) DEFAULT NULL,
  `board_sort_no` int(11) DEFAULT NULL,
  `public_doc_count` int(11) DEFAULT NULL,
  `void_doc_count` int(11) DEFAULT NULL,
  `dbname` varchar(255) DEFAULT NULL,
  `limit_date` varchar(255) DEFAULT NULL,
  `board_limit_date` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwcircular_roles`
--

DROP TABLE IF EXISTS `gwcircular_roles`;
CREATE TABLE IF NOT EXISTS `gwcircular_roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `title_id` int(11) DEFAULT NULL,
  `role_code` varchar(255) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `user_code` varchar(255) DEFAULT NULL,
  `user_name` text,
  `group_id` int(11) DEFAULT NULL,
  `group_code` varchar(255) DEFAULT NULL,
  `group_name` text,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwfaq_adms`
--

DROP TABLE IF EXISTS `gwfaq_adms`;
CREATE TABLE IF NOT EXISTS `gwfaq_adms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `title_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `user_code` varchar(255) DEFAULT NULL,
  `user_name` text,
  `group_id` int(11) DEFAULT NULL,
  `group_code` varchar(255) DEFAULT NULL,
  `group_name` text,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwfaq_controls`
--

DROP TABLE IF EXISTS `gwfaq_controls`;
CREATE TABLE IF NOT EXISTS `gwfaq_controls` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `recognized_at` datetime DEFAULT NULL,
  `published_at` datetime DEFAULT NULL,
  `default_published` int(11) DEFAULT NULL,
  `upload_graphic_file_size_capacity` int(11) DEFAULT NULL,
  `upload_graphic_file_size_capacity_unit` varchar(255) DEFAULT NULL,
  `upload_document_file_size_capacity` int(11) DEFAULT NULL,
  `upload_document_file_size_capacity_unit` varchar(255) DEFAULT NULL,
  `upload_graphic_file_size_max` int(11) DEFAULT NULL,
  `upload_document_file_size_max` int(11) DEFAULT NULL,
  `upload_graphic_file_size_currently` decimal(17,0) DEFAULT NULL,
  `upload_document_file_size_currently` decimal(17,0) DEFAULT NULL,
  `create_section` varchar(255) DEFAULT NULL,
  `addnew_forbidden` int(11) DEFAULT NULL,
  `draft_forbidden` int(11) DEFAULT NULL,
  `delete_forbidden` int(11) DEFAULT NULL,
  `importance` int(11) DEFAULT NULL,
  `form_name` varchar(255) DEFAULT NULL,
  `banner` text,
  `banner_position` varchar(255) DEFAULT NULL,
  `left_banner` text,
  `left_menu` text,
  `left_index_use` varchar(1) DEFAULT NULL,
  `left_index_pattern` int(11) DEFAULT NULL,
  `left_index_bg_color` varchar(255) DEFAULT NULL,
  `other_system_link` text,
  `wallpaper` text,
  `css` text,
  `sort_no` int(11) DEFAULT NULL,
  `caption` text,
  `view_hide` tinyint(1) DEFAULT NULL,
  `categoey_view` tinyint(1) DEFAULT NULL,
  `categoey_view_line` int(11) DEFAULT NULL,
  `monthly_view` tinyint(1) DEFAULT NULL,
  `monthly_view_line` int(11) DEFAULT NULL,
  `group_view` tinyint(1) DEFAULT NULL,
  `notification` int(11) DEFAULT NULL,
  `upload_system` int(11) DEFAULT NULL,
  `limit_date` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `category` int(11) DEFAULT NULL,
  `category1_name` varchar(255) DEFAULT NULL,
  `category2_name` varchar(255) DEFAULT NULL,
  `category3_name` varchar(255) DEFAULT NULL,
  `recognize` int(11) DEFAULT NULL,
  `createdate` text,
  `createrdivision_id` varchar(20) DEFAULT NULL,
  `createrdivision` text,
  `creater_id` varchar(20) DEFAULT NULL,
  `creater` text,
  `editdate` text,
  `editordivision_id` varchar(20) DEFAULT NULL,
  `editordivision` text,
  `editor_id` varchar(20) DEFAULT NULL,
  `editor` text,
  `default_limit` int(11) DEFAULT NULL,
  `dbname` varchar(255) DEFAULT NULL,
  `admingrps` text,
  `admingrps_json` text,
  `adms` text,
  `adms_json` text,
  `dsp_admin_name` text,
  `editors` text,
  `editors_json` text,
  `readers` text,
  `readers_json` text,
  `sueditors` text,
  `sueditors_json` text,
  `sureaders` text,
  `sureaders_json` text,
  `help_display` text,
  `help_url` text,
  `help_admin_url` text,
  `docslast_updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwfaq_recognizers`
--

DROP TABLE IF EXISTS `gwfaq_recognizers`;
CREATE TABLE IF NOT EXISTS `gwfaq_recognizers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `title_id` int(11) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `name` text,
  `recognized_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
)  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwfaq_roles`
--

DROP TABLE IF EXISTS `gwfaq_roles`;
CREATE TABLE IF NOT EXISTS `gwfaq_roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `title_id` int(11) DEFAULT NULL,
  `role_code` varchar(255) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `user_code` varchar(255) DEFAULT NULL,
  `user_name` text,
  `group_id` int(11) DEFAULT NULL,
  `group_code` varchar(255) DEFAULT NULL,
  `group_name` text,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwmonitor_base_files`
--

DROP TABLE IF EXISTS `gwmonitor_base_files`;
CREATE TABLE IF NOT EXISTS `gwmonitor_base_files` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `recognized_at` datetime DEFAULT NULL,
  `published_at` datetime DEFAULT NULL,
  `latest_updated_at` datetime DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `title_id` int(11) DEFAULT NULL,
  `content_type` varchar(255) DEFAULT NULL,
  `filename` text,
  `memo` text,
  `size` int(11) DEFAULT NULL,
  `width` int(11) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `db_file_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
)  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwmonitor_controls`
--

DROP TABLE IF EXISTS `gwmonitor_controls`;
CREATE TABLE IF NOT EXISTS `gwmonitor_controls` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `latest_updated_at` datetime DEFAULT NULL,
  `section_code` varchar(255) DEFAULT NULL,
  `section_name` varchar(255) DEFAULT NULL,
  `section_sort` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `form_id` int(11) DEFAULT NULL,
  `form_name` varchar(255) DEFAULT NULL,
  `form_caption` varchar(255) DEFAULT NULL,
  `upload_system` int(11) DEFAULT NULL,
  `admin_setting` int(11) DEFAULT NULL,
  `spec_config` int(11) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `caption` text,
  `able_date` datetime DEFAULT NULL,
  `expiry_date` datetime DEFAULT NULL,
  `reminder_start_section` int(11) DEFAULT NULL,
  `reminder_start_personal` int(11) DEFAULT NULL,
  `public_count` int(11) DEFAULT NULL,
  `draft_count` int(11) DEFAULT NULL,
  `createdate` text,
  `createrdivision_id` varchar(20) DEFAULT NULL,
  `createrdivision` text,
  `creater_id` varchar(20) DEFAULT NULL,
  `creater` text,
  `editdate` text,
  `editordivision_id` varchar(20) DEFAULT NULL,
  `editordivision` text,
  `editor_id` varchar(20) DEFAULT NULL,
  `editor` text,
  `default_limit` int(11) DEFAULT NULL,
  `dsp_admin_name` text,
  `send_change` varchar(255) DEFAULT NULL,
  `custom_groups` text,
  `custom_groups_json` text,
  `reader_groups` text,
  `reader_groups_json` text,
  `custom_readers` text,
  `custom_readers_json` text,
  `readers` text,
  `readers_json` text,
  `upload_graphic_file_size_capacity` int(11) DEFAULT NULL,
  `upload_graphic_file_size_capacity_unit` varchar(255) DEFAULT NULL,
  `upload_document_file_size_capacity` int(11) DEFAULT NULL,
  `upload_document_file_size_capacity_unit` varchar(255) DEFAULT NULL,
  `upload_graphic_file_size_max` int(11) DEFAULT NULL,
  `upload_document_file_size_max` int(11) DEFAULT NULL,
  `upload_graphic_file_size_currently` decimal(17,0) DEFAULT NULL,
  `upload_document_file_size_currently` decimal(17,0) DEFAULT NULL,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwmonitor_custom_groups`
--

DROP TABLE IF EXISTS `gwmonitor_custom_groups`;
CREATE TABLE IF NOT EXISTS `gwmonitor_custom_groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `class_id` int(11) DEFAULT NULL,
  `owner_uid` int(11) DEFAULT NULL,
  `owner_gid` int(11) DEFAULT NULL,
  `updater_uid` int(11) DEFAULT NULL,
  `updater_gid` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `level_no` int(11) DEFAULT NULL,
  `name` text,
  `name_en` text,
  `sort_no` int(11) DEFAULT NULL,
  `sort_prefix` text,
  `is_default` int(11) DEFAULT NULL,
  `reader_groups_json` mediumtext,
  `reader_groups` mediumtext,
  `readers_json` mediumtext,
  `readers` mediumtext,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwmonitor_custom_user_groups`
--

DROP TABLE IF EXISTS `gwmonitor_custom_user_groups`;
CREATE TABLE IF NOT EXISTS `gwmonitor_custom_user_groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `class_id` int(11) DEFAULT NULL,
  `owner_uid` int(11) DEFAULT NULL,
  `owner_gid` int(11) DEFAULT NULL,
  `updater_uid` int(11) DEFAULT NULL,
  `updater_gid` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `level_no` int(11) DEFAULT NULL,
  `name` text,
  `name_en` text,
  `sort_no` int(11) DEFAULT NULL,
  `sort_prefix` text,
  `is_default` int(11) DEFAULT NULL,
  `reader_groups_json` mediumtext,
  `reader_groups` mediumtext,
  `readers_json` mediumtext,
  `readers` mediumtext,
  PRIMARY KEY (`id`)
)  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwmonitor_docs`
--

DROP TABLE IF EXISTS `gwmonitor_docs`;
CREATE TABLE IF NOT EXISTS `gwmonitor_docs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `latest_updated_at` datetime DEFAULT NULL,
  `send_division` int(11) DEFAULT NULL,
  `user_code` varchar(20) DEFAULT NULL,
  `user_name` varchar(255) DEFAULT NULL,
  `l2_section_code` varchar(255) DEFAULT NULL,
  `section_code` varchar(255) DEFAULT NULL,
  `section_name` text,
  `section_sort` int(11) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `email_send` tinyint(1) DEFAULT NULL,
  `title_id` int(11) DEFAULT NULL,
  `name` text,
  `title` text,
  `head` mediumtext,
  `body` mediumtext,
  `note` mediumtext,
  `keywords` text,
  `createdate` text,
  `creater_admin` tinyint(1) DEFAULT NULL,
  `createrdivision_id` varchar(20) DEFAULT NULL,
  `createrdivision` text,
  `creater_id` varchar(20) DEFAULT NULL,
  `creater` text,
  `editdate` text,
  `editor_admin` tinyint(1) DEFAULT NULL,
  `editordivision_id` varchar(20) DEFAULT NULL,
  `editordivision` text,
  `editor_id` varchar(20) DEFAULT NULL,
  `editor` text,
  `able_date` datetime DEFAULT NULL,
  `expiry_date` datetime DEFAULT NULL,
  `remind_start_date` datetime DEFAULT NULL,
  `remind_start_date_personal` datetime DEFAULT NULL,
  `receipt_user_code` varchar(255) DEFAULT NULL,
  `attachmentfile` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwmonitor_files`
--

DROP TABLE IF EXISTS `gwmonitor_files`;
CREATE TABLE IF NOT EXISTS `gwmonitor_files` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `recognized_at` datetime DEFAULT NULL,
  `published_at` datetime DEFAULT NULL,
  `latest_updated_at` datetime DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `title_id` int(11) DEFAULT NULL,
  `content_type` varchar(255) DEFAULT NULL,
  `filename` text,
  `memo` text,
  `size` int(11) DEFAULT NULL,
  `width` int(11) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `db_file_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
)  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwmonitor_forms`
--

DROP TABLE IF EXISTS `gwmonitor_forms`;
CREATE TABLE IF NOT EXISTS `gwmonitor_forms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `sort_no` int(11) DEFAULT NULL,
  `level_no` int(11) DEFAULT NULL,
  `form_name` varchar(255) DEFAULT NULL,
  `form_caption` text,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwmonitor_itemdeletes`
--

DROP TABLE IF EXISTS `gwmonitor_itemdeletes`;
CREATE TABLE IF NOT EXISTS `gwmonitor_itemdeletes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `admin_code` varchar(255) DEFAULT NULL,
  `title_id` int(11) DEFAULT NULL,
  `board_title` text,
  `board_state` varchar(255) DEFAULT NULL,
  `board_view_hide` varchar(255) DEFAULT NULL,
  `board_sort_no` int(11) DEFAULT NULL,
  `public_doc_count` int(11) DEFAULT NULL,
  `void_doc_count` int(11) DEFAULT NULL,
  `dbname` varchar(255) DEFAULT NULL,
  `limit_date` varchar(255) DEFAULT NULL,
  `board_limit_date` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwqa_adms`
--

DROP TABLE IF EXISTS `gwqa_adms`;
CREATE TABLE IF NOT EXISTS `gwqa_adms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `title_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `user_code` varchar(255) DEFAULT NULL,
  `user_name` text,
  `group_id` int(11) DEFAULT NULL,
  `group_code` varchar(255) DEFAULT NULL,
  `group_name` text,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwqa_controls`
--

DROP TABLE IF EXISTS `gwqa_controls`;
CREATE TABLE IF NOT EXISTS `gwqa_controls` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `recognized_at` datetime DEFAULT NULL,
  `published_at` datetime DEFAULT NULL,
  `default_published` int(11) DEFAULT NULL,
  `upload_graphic_file_size_capacity` int(11) DEFAULT NULL,
  `upload_graphic_file_size_capacity_unit` varchar(255) DEFAULT NULL,
  `upload_document_file_size_capacity` int(11) DEFAULT NULL,
  `upload_document_file_size_capacity_unit` varchar(255) DEFAULT NULL,
  `upload_graphic_file_size_max` int(11) DEFAULT NULL,
  `upload_document_file_size_max` int(11) DEFAULT NULL,
  `upload_graphic_file_size_currently` decimal(17,0) DEFAULT NULL,
  `upload_document_file_size_currently` decimal(17,0) DEFAULT NULL,
  `create_section` varchar(255) DEFAULT NULL,
  `addnew_forbidden` int(11) DEFAULT NULL,
  `draft_forbidden` int(11) DEFAULT NULL,
  `delete_forbidden` int(11) DEFAULT NULL,
  `importance` int(11) DEFAULT NULL,
  `form_name` varchar(255) DEFAULT NULL,
  `banner` text,
  `banner_position` varchar(255) DEFAULT NULL,
  `left_banner` text,
  `left_menu` text,
  `left_index_use` varchar(1) DEFAULT NULL,
  `left_index_pattern` int(11) DEFAULT NULL,
  `left_index_bg_color` varchar(255) DEFAULT NULL,
  `other_system_link` text,
  `wallpaper` text,
  `css` text,
  `sort_no` int(11) DEFAULT NULL,
  `caption` text,
  `view_hide` tinyint(1) DEFAULT NULL,
  `categoey_view` tinyint(1) DEFAULT NULL,
  `categoey_view_line` int(11) DEFAULT NULL,
  `monthly_view` tinyint(1) DEFAULT NULL,
  `monthly_view_line` int(11) DEFAULT NULL,
  `group_view` tinyint(1) DEFAULT NULL,
  `notification` int(11) DEFAULT NULL,
  `upload_system` int(11) DEFAULT NULL,
  `limit_date` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `category` int(11) DEFAULT NULL,
  `category1_name` varchar(255) DEFAULT NULL,
  `category2_name` varchar(255) DEFAULT NULL,
  `category3_name` varchar(255) DEFAULT NULL,
  `recognize` int(11) DEFAULT NULL,
  `createdate` text,
  `createrdivision_id` varchar(20) DEFAULT NULL,
  `createrdivision` text,
  `creater_id` varchar(20) DEFAULT NULL,
  `creater` text,
  `editdate` text,
  `editordivision_id` varchar(20) DEFAULT NULL,
  `editordivision` text,
  `editor_id` varchar(20) DEFAULT NULL,
  `editor` text,
  `default_limit` int(11) DEFAULT NULL,
  `dbname` varchar(255) DEFAULT NULL,
  `admingrps` text,
  `admingrps_json` text,
  `adms` text,
  `adms_json` text,
  `dsp_admin_name` text,
  `editors` text,
  `editors_json` text,
  `readers` text,
  `readers_json` text,
  `sueditors` text,
  `sueditors_json` text,
  `sureaders` text,
  `sureaders_json` text,
  `help_display` text,
  `help_url` text,
  `help_admin_url` text,
  `docslast_updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwqa_recognizers`
--

DROP TABLE IF EXISTS `gwqa_recognizers`;
CREATE TABLE IF NOT EXISTS `gwqa_recognizers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `title_id` int(11) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `name` text,
  `recognized_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
)  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwqa_roles`
--

DROP TABLE IF EXISTS `gwqa_roles`;
CREATE TABLE IF NOT EXISTS `gwqa_roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `title_id` int(11) DEFAULT NULL,
  `role_code` varchar(255) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `user_code` varchar(255) DEFAULT NULL,
  `user_name` text,
  `group_id` int(11) DEFAULT NULL,
  `group_code` varchar(255) DEFAULT NULL,
  `group_name` text,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_admin_check_extensions`
--

DROP TABLE IF EXISTS `gw_admin_check_extensions`;
CREATE TABLE IF NOT EXISTS `gw_admin_check_extensions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `state` varchar(255) DEFAULT NULL,
  `sort_no` int(11) DEFAULT NULL,
  `extension` varchar(255) DEFAULT NULL,
  `remark` text,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_uid` int(11) DEFAULT NULL,
  `deleted_gid` int(11) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_uid` int(11) DEFAULT NULL,
  `updated_gid` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `created_uid` int(11) DEFAULT NULL,
  `created_gid` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_admin_messages`
--

DROP TABLE IF EXISTS `gw_admin_messages`;
CREATE TABLE IF NOT EXISTS `gw_admin_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `body` text,
  `sort_no` int(11) DEFAULT NULL,
  `state` int(11) DEFAULT NULL,
  `mode` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_blog_parts`
--

DROP TABLE IF EXISTS `gw_blog_parts`;
CREATE TABLE IF NOT EXISTS `gw_blog_parts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `state` text,
  `sort_no` int(11) DEFAULT NULL,
  `title` text,
  `body` text,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_user` text,
  `deleted_group` text,
  PRIMARY KEY (`id`)
)  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_circulars`
--

DROP TABLE IF EXISTS `gw_circulars`;
CREATE TABLE IF NOT EXISTS `gw_circulars` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `state` int(11) DEFAULT NULL,
  `uid` int(11) DEFAULT NULL,
  `u_code` varchar(255) DEFAULT NULL,
  `gid` int(11) DEFAULT NULL,
  `g_code` varchar(255) DEFAULT NULL,
  `class_id` int(11) DEFAULT NULL,
  `title` text,
  `st_at` datetime DEFAULT NULL,
  `ed_at` datetime DEFAULT NULL,
  `is_finished` int(11) DEFAULT NULL,
  `is_system` int(11) DEFAULT NULL,
  `options` text,
  `body` text,
  `deleted_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `state` (`state`),
  KEY `uid` (`uid`),
  KEY `ed_at` (`ed_at`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_edit_link_pieces`
--

DROP TABLE IF EXISTS `gw_edit_link_pieces`;
CREATE TABLE IF NOT EXISTS `gw_edit_link_pieces` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uid` int(11) DEFAULT NULL,
  `class_created` int(11) DEFAULT '0',
  `published` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `mode` int(11) DEFAULT NULL,
  `level_no` int(11) DEFAULT '0',
  `parent_id` int(11) DEFAULT '0',
  `name` varchar(255) DEFAULT NULL,
  `sort_no` int(11) DEFAULT '0',
  `tab_keys` int(11) DEFAULT '0',
  `display_auth_priv` int(11) DEFAULT NULL,
  `role_name_id` int(11) DEFAULT NULL,
  `display_auth` text,
  `block_icon_id` int(11) DEFAULT NULL,
  `block_css_id` int(11) DEFAULT NULL,
  `link_url` text,
  `remark` text,
  `icon_path` text,
  `link_div_class` varchar(255) DEFAULT NULL,
  `class_external` int(11) DEFAULT '0',
  `ssoid` int(11) DEFAULT NULL,
  `class_sso` int(11) DEFAULT '0',
  `field_account` varchar(255) DEFAULT NULL,
  `field_pass` varchar(255) DEFAULT NULL,
  `css_id` int(11) DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  `deleted_user` varchar(255) DEFAULT NULL,
  `deleted_group` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` varchar(255) DEFAULT NULL,
  `updated_group` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `created_user` varchar(255) DEFAULT NULL,
  `created_group` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_edit_link_piece_csses`
--

DROP TABLE IF EXISTS `gw_edit_link_piece_csses`;
CREATE TABLE IF NOT EXISTS `gw_edit_link_piece_csses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `state` varchar(255) DEFAULT NULL,
  `css_name` varchar(255) DEFAULT NULL,
  `css_sort_no` int(11) DEFAULT '0',
  `css_class` varchar(255) DEFAULT NULL,
  `css_type` int(11) DEFAULT '1',
  `deleted_at` datetime DEFAULT NULL,
  `deleted_user` varchar(255) DEFAULT NULL,
  `deleted_group` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` varchar(255) DEFAULT NULL,
  `updated_group` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `created_user` varchar(255) DEFAULT NULL,
  `created_group` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_edit_tabs`
--

DROP TABLE IF EXISTS `gw_edit_tabs`;
CREATE TABLE IF NOT EXISTS `gw_edit_tabs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `class_created` int(11) DEFAULT '0',
  `published` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `level_no` int(11) DEFAULT '0',
  `parent_id` int(11) DEFAULT '0',
  `name` varchar(255) DEFAULT NULL,
  `sort_no` int(11) DEFAULT '0',
  `tab_keys` int(11) DEFAULT '0',
  `display_auth` text,
  `other_controller_use` int(11) DEFAULT '2',
  `other_controller_url` varchar(255) DEFAULT NULL,
  `link_url` text,
  `icon_path` text,
  `link_div_class` varchar(255) DEFAULT NULL,
  `class_external` int(11) DEFAULT '0',
  `class_sso` int(11) DEFAULT '0',
  `field_account` varchar(255) DEFAULT NULL,
  `field_pass` varchar(255) DEFAULT NULL,
  `css_id` int(11) DEFAULT '0',
  `is_public` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_user` varchar(255) DEFAULT NULL,
  `deleted_group` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` varchar(255) DEFAULT NULL,
  `updated_group` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `created_user` varchar(255) DEFAULT NULL,
  `created_group` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_edit_tab_public_roles`
--

DROP TABLE IF EXISTS `gw_edit_tab_public_roles`;
CREATE TABLE IF NOT EXISTS `gw_edit_tab_public_roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `edit_tab_id` int(11) DEFAULT NULL,
  `class_id` int(11) DEFAULT NULL,
  `uid` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
)  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_holidays`
--

DROP TABLE IF EXISTS `gw_holidays`;
CREATE TABLE IF NOT EXISTS `gw_holidays` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `creator_uid` int(11) DEFAULT NULL,
  `creator_ucode` varchar(255) DEFAULT NULL,
  `creator_uname` text,
  `creator_gid` int(11) DEFAULT NULL,
  `creator_gcode` varchar(255) DEFAULT NULL,
  `creator_gname` text,
  `title_category_id` int(11) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `is_public` int(11) DEFAULT NULL,
  `memo` text,
  `schedule_repeat_id` int(11) DEFAULT NULL,
  `dirty_repeat_id` int(11) DEFAULT NULL,
  `no_time_id` int(11) DEFAULT NULL,
  `st_at` datetime DEFAULT NULL,
  `ed_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `st_at` (`st_at`,`ed_at`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_icons`
--

DROP TABLE IF EXISTS `gw_icons`;
CREATE TABLE IF NOT EXISTS `gw_icons` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `icon_gid` int(11) DEFAULT NULL,
  `idx` int(11) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `path` varchar(255) DEFAULT NULL COMMENT 'relative from RAILS_ROOT/public',
  `content_type` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
)  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_icon_groups`
--

DROP TABLE IF EXISTS `gw_icon_groups`;
CREATE TABLE IF NOT EXISTS `gw_icon_groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
)  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_ind_portal_pieces`
--

DROP TABLE IF EXISTS `gw_ind_portal_pieces`;
CREATE TABLE IF NOT EXISTS `gw_ind_portal_pieces` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uid` int(11) DEFAULT NULL,
  `sort_no` int(11) DEFAULT NULL,
  `name` text NOT NULL,
  `title` text,
  `piece` text,
  `genre` text,
  `tid` int(11) DEFAULT NULL,
  `limit` int(11) DEFAULT NULL,
  `position` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
)  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_infos`
--

DROP TABLE IF EXISTS `gw_infos`;
CREATE TABLE IF NOT EXISTS `gw_infos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cls` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
)  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_memos`
--

DROP TABLE IF EXISTS `gw_memos`;
CREATE TABLE IF NOT EXISTS `gw_memos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `class_id` int(11) DEFAULT NULL,
  `uid` int(11) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `st_at` datetime DEFAULT NULL,
  `ed_at` datetime DEFAULT NULL,
  `is_finished` int(11) DEFAULT NULL,
  `is_system` int(11) DEFAULT NULL,
  `fr_group` varchar(255) DEFAULT NULL,
  `fr_user` varchar(255) DEFAULT NULL,
  `memo_category_id` int(11) DEFAULT NULL,
  `memo_category_text` varchar(255) DEFAULT NULL,
  `body` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_memo_mobiles`
--

DROP TABLE IF EXISTS `gw_memo_mobiles`;
CREATE TABLE IF NOT EXISTS `gw_memo_mobiles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `domain` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_memo_users`
--

DROP TABLE IF EXISTS `gw_memo_users`;
CREATE TABLE IF NOT EXISTS `gw_memo_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `schedule_id` int(11) DEFAULT NULL,
  `class_id` int(11) DEFAULT NULL,
  `uid` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_monitor_reminders`
--

DROP TABLE IF EXISTS `gw_monitor_reminders`;
CREATE TABLE IF NOT EXISTS `gw_monitor_reminders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `state` int(11) DEFAULT NULL,
  `uid` int(11) DEFAULT NULL,
  `u_code` varchar(255) DEFAULT NULL,
  `gid` int(11) DEFAULT NULL,
  `g_code` varchar(255) DEFAULT NULL,
  `class_id` int(11) DEFAULT NULL,
  `title` text,
  `st_at` datetime DEFAULT NULL,
  `ed_at` datetime DEFAULT NULL,
  `is_finished` int(11) DEFAULT NULL,
  `is_system` int(11) DEFAULT NULL,
  `options` text,
  `body` text,
  `deleted_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `state` (`state`),
  KEY `uid` (`uid`),
  KEY `ed_at` (`ed_at`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_notes`
--

DROP TABLE IF EXISTS `gw_notes`;
CREATE TABLE IF NOT EXISTS `gw_notes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uid` int(11) DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `body` text,
  `deadline` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
)  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_portal_adds`
--

DROP TABLE IF EXISTS `gw_portal_adds`;
CREATE TABLE IF NOT EXISTS `gw_portal_adds` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `state` text,
  `published` text,
  `file_path` text,
  `file_directory` text,
  `file_name` text,
  `original_file_name` text,
  `content_type` text,
  `width` int(11) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `place` int(11) DEFAULT NULL,
  `sort_no` int(11) DEFAULT NULL,
  `title` text,
  `body` text,
  `url` text,
  `publish_start_at` datetime DEFAULT NULL,
  `publish_end_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_user` text,
  `deleted_group` text,
  PRIMARY KEY (`id`)
)  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_portal_user_settings`
--

DROP TABLE IF EXISTS `gw_portal_user_settings`;
CREATE TABLE IF NOT EXISTS `gw_portal_user_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uid` int(11) DEFAULT NULL,
  `idx` int(11) DEFAULT NULL,
  `arrange` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `gadget` varchar(255) DEFAULT NULL,
  `options` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
)  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_pref_assembly_members`
--

DROP TABLE IF EXISTS `gw_pref_assembly_members`;
CREATE TABLE IF NOT EXISTS `gw_pref_assembly_members` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `gid` int(11) DEFAULT NULL,
  `g_code` varchar(255) DEFAULT NULL,
  `g_name` varchar(255) DEFAULT NULL,
  `g_order` int(11) DEFAULT NULL,
  `uid` int(11) DEFAULT NULL,
  `u_code` varchar(255) DEFAULT NULL,
  `u_lname` text,
  `u_name` text,
  `u_order` int(11) DEFAULT NULL,
  `title` text,
  `state` varchar(255) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_user` varchar(255) DEFAULT NULL,
  `deleted_group` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` varchar(255) DEFAULT NULL,
  `updated_group` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `created_user` varchar(255) DEFAULT NULL,
  `created_group` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_pref_directors`
--

DROP TABLE IF EXISTS `gw_pref_directors`;
CREATE TABLE IF NOT EXISTS `gw_pref_directors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_gid` int(11) DEFAULT NULL,
  `parent_g_code` varchar(255) DEFAULT NULL,
  `parent_g_name` varchar(255) DEFAULT NULL,
  `parent_g_order` int(11) DEFAULT NULL,
  `gid` int(11) DEFAULT NULL,
  `g_code` varchar(255) DEFAULT NULL,
  `g_name` varchar(255) DEFAULT NULL,
  `g_order` int(11) DEFAULT NULL,
  `uid` int(11) DEFAULT NULL,
  `u_code` varchar(255) DEFAULT NULL,
  `u_lname` text,
  `u_name` text,
  `u_order` int(11) DEFAULT NULL,
  `title` text,
  `state` varchar(255) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_user` varchar(255) DEFAULT NULL,
  `deleted_group` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` varchar(255) DEFAULT NULL,
  `updated_group` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `created_user` varchar(255) DEFAULT NULL,
  `created_group` varchar(255) DEFAULT NULL,
  `is_governor_view` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_pref_executives`
--

DROP TABLE IF EXISTS `gw_pref_executives`;
CREATE TABLE IF NOT EXISTS `gw_pref_executives` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_gid` int(11) DEFAULT NULL,
  `parent_g_code` varchar(255) DEFAULT NULL,
  `parent_g_name` varchar(255) DEFAULT NULL,
  `parent_g_order` int(11) DEFAULT NULL,
  `gid` int(11) DEFAULT NULL,
  `g_code` varchar(255) DEFAULT NULL,
  `g_name` varchar(255) DEFAULT NULL,
  `g_order` int(11) DEFAULT NULL,
  `uid` int(11) DEFAULT NULL,
  `u_code` varchar(255) DEFAULT NULL,
  `u_lname` text,
  `u_name` text,
  `u_order` int(11) DEFAULT NULL,
  `title` text,
  `state` varchar(255) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_user` varchar(255) DEFAULT NULL,
  `deleted_group` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` varchar(255) DEFAULT NULL,
  `updated_group` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `created_user` varchar(255) DEFAULT NULL,
  `created_group` varchar(255) DEFAULT NULL,
  `is_other_view` int(11) DEFAULT NULL,
  `is_governor_view` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_prop_others`
--

DROP TABLE IF EXISTS `gw_prop_others`;
CREATE TABLE IF NOT EXISTS `gw_prop_others` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sort_no` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `type_id` int(11) DEFAULT NULL,
  `state` text,
  `edit_state` int(11) DEFAULT NULL,
  `delete_state` int(11) DEFAULT '0' COMMENT '削除フラグ（1が削除）',
  `reserved_state` int(11) DEFAULT '1' COMMENT '1が予約可能、0が予約不可',
  `comment` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `extra_flag` varchar(255) DEFAULT NULL,
  `extra_data` text,
  `gid` int(11) DEFAULT NULL,
  `gname` varchar(255) DEFAULT NULL,
  `creator_uid` int(11) DEFAULT NULL,
  `updater_uid` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_prop_other_images`
--

DROP TABLE IF EXISTS `gw_prop_other_images`;
CREATE TABLE IF NOT EXISTS `gw_prop_other_images` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `idx` int(11) DEFAULT NULL,
  `note` varchar(255) DEFAULT NULL,
  `path` varchar(255) DEFAULT NULL,
  `orig_filename` varchar(255) DEFAULT NULL,
  `content_type` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_prop_other_limits`
--

DROP TABLE IF EXISTS `gw_prop_other_limits`;
CREATE TABLE IF NOT EXISTS `gw_prop_other_limits` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sort_no` int(11) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `gid` int(11) DEFAULT NULL,
  `limit` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_prop_other_roles`
--

DROP TABLE IF EXISTS `gw_prop_other_roles`;
CREATE TABLE IF NOT EXISTS `gw_prop_other_roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `prop_id` int(11) DEFAULT NULL,
  `gid` int(11) DEFAULT NULL,
  `auth` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `prop_id` (`prop_id`)
)   DEFAULT CHARSET=utf8;


-- --------------------------------------------------------

--
-- テーブルの構造 `gw_prop_types`
--

DROP TABLE IF EXISTS `gw_prop_types`;
CREATE TABLE IF NOT EXISTS `gw_prop_types` (
`id` int(11) NOT NULL AUTO_INCREMENT,
`state` varchar(255) DEFAULT NULL,
`name` varchar(255) DEFAULT NULL,
`sort_no` int(255) DEFAULT NULL,
`created_at` datetime DEFAULT NULL,
`updated_at` datetime DEFAULT NULL,
`deleted_at` datetime DEFAULT NULL,
PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8;


-- --------------------------------------------------------

--
-- テーブルの構造 `gw_rss_caches`
--

DROP TABLE IF EXISTS `gw_rss_caches`;
CREATE TABLE IF NOT EXISTS `gw_rss_caches` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uri` text,
  `fetched` datetime DEFAULT NULL,
  `title` text,
  `published` datetime DEFAULT NULL,
  `link` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
)  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_rss_readers`
--

DROP TABLE IF EXISTS `gw_rss_readers`;
CREATE TABLE IF NOT EXISTS `gw_rss_readers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `state` text,
  `sort_no` int(11) DEFAULT NULL,
  `title` text,
  `uri` text,
  `max` int(11) DEFAULT NULL,
  `interval` int(11) DEFAULT NULL,
  `checked_at` datetime DEFAULT NULL,
  `fetched_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_user` text,
  `deleted_group` text,
  PRIMARY KEY (`id`)
)  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_rss_reader_caches`
--

DROP TABLE IF EXISTS `gw_rss_reader_caches`;
CREATE TABLE IF NOT EXISTS `gw_rss_reader_caches` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `rrid` int(11) DEFAULT NULL,
  `uri` text,
  `title` text,
  `link` text,
  `fetched_at` datetime DEFAULT NULL,
  `published_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
)  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_schedules`
--

DROP TABLE IF EXISTS `gw_schedules`;
CREATE TABLE IF NOT EXISTS `gw_schedules` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `creator_uid` int(11) DEFAULT NULL,
  `creator_ucode` varchar(255) DEFAULT NULL,
  `creator_uname` text,
  `creator_gid` int(11) DEFAULT NULL,
  `creator_gcode` varchar(255) DEFAULT NULL,
  `creator_gname` text,
  `updater_uid` int(11) DEFAULT NULL,
  `updater_ucode` varchar(255) DEFAULT NULL,
  `updater_uname` text,
  `updater_gid` int(11) DEFAULT NULL,
  `updater_gcode` varchar(255) DEFAULT NULL,
  `updater_gname` text,
  `owner_uid` int(11) DEFAULT NULL,
  `owner_ucode` varchar(255) DEFAULT NULL,
  `owner_uname` text,
  `owner_gid` int(11) DEFAULT NULL,
  `owner_gcode` varchar(255) DEFAULT NULL,
  `owner_gname` text,
  `title_category_id` int(11) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `place_category_id` int(11) DEFAULT NULL,
  `place` varchar(255) DEFAULT NULL,
  `to_go` int(11) DEFAULT NULL,
  `is_public` int(11) DEFAULT NULL,
  `is_pr` int(11) DEFAULT NULL,
  `memo` text,
  `admin_memo` text,
  `repeat_id` int(11) DEFAULT NULL,
  `schedule_repeat_id` int(11) DEFAULT NULL,
  `dirty_repeat_id` int(11) DEFAULT NULL,
  `no_time_id` int(11) DEFAULT NULL,
  `schedule_parent_id` int(11) DEFAULT NULL,
  `participant_nums_inner` int(11) DEFAULT NULL,
  `participant_nums_outer` int(11) DEFAULT NULL,
  `check_30_over` int(11) DEFAULT NULL,
  `inquire_to` text,
  `st_at` datetime DEFAULT NULL,
  `ed_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `todo` int(11) DEFAULT NULL,
  `allday` int(11) DEFAULT NULL,
  `guide_state` int(11) DEFAULT NULL,
  `guide_place_id` int(11) DEFAULT NULL,
  `guide_place` text,
  `guide_ed_at` int(11) DEFAULT NULL,
  `event_week` int(11) DEFAULT NULL,
  `event_month` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `st_at` (`st_at`,`ed_at`),
  KEY `schedule_repeat_id` (`schedule_repeat_id`),
  KEY `ed_at` (`ed_at`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_schedule_props`
--

DROP TABLE IF EXISTS `gw_schedule_props`;
CREATE TABLE IF NOT EXISTS `gw_schedule_props` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `schedule_id` int(11) DEFAULT NULL,
  `prop_type` varchar(255) DEFAULT NULL,
  `prop_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `extra_data` text,
  `confirmed_uid` int(11) DEFAULT NULL,
  `confirmed_gid` int(11) DEFAULT NULL,
  `confirmed_at` datetime DEFAULT NULL,
  `rented_uid` int(11) DEFAULT NULL,
  `rented_gid` int(11) DEFAULT NULL,
  `rented_at` datetime DEFAULT NULL,
  `returned_uid` int(11) DEFAULT NULL,
  `returned_gid` int(11) DEFAULT NULL,
  `returned_at` datetime DEFAULT NULL,
  `cancelled_uid` int(11) DEFAULT NULL,
  `cancelled_gid` int(11) DEFAULT NULL,
  `cancelled_at` datetime DEFAULT NULL,
  `st_at` datetime DEFAULT NULL,
  `ed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `schedule_id` (`schedule_id`,`prop_type`,`prop_id`),
  KEY `prop_id` (`prop_id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_schedule_public_roles`
--

DROP TABLE IF EXISTS `gw_schedule_public_roles`;
CREATE TABLE IF NOT EXISTS `gw_schedule_public_roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `schedule_id` int(11) DEFAULT NULL,
  `class_id` int(11) DEFAULT NULL,
  `uid` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
)  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_schedule_repeats`
--

DROP TABLE IF EXISTS `gw_schedule_repeats`;
CREATE TABLE IF NOT EXISTS `gw_schedule_repeats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `st_date_at` datetime DEFAULT NULL,
  `ed_date_at` datetime DEFAULT NULL,
  `st_time_at` datetime DEFAULT NULL,
  `ed_time_at` datetime DEFAULT NULL,
  `class_id` int(11) DEFAULT NULL,
  `weekday_ids` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_schedule_users`
--

DROP TABLE IF EXISTS `gw_schedule_users`;
CREATE TABLE IF NOT EXISTS `gw_schedule_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `schedule_id` int(11) DEFAULT NULL,
  `class_id` int(11) DEFAULT NULL,
  `uid` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `st_at` datetime DEFAULT NULL,
  `ed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `schedule_id` (`schedule_id`,`class_id`,`uid`),
  KEY `uid` (`uid`),
  KEY `schedule_id2` (`schedule_id`)
) DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_section_admin_masters`
--



DROP TABLE IF EXISTS `gw_section_admin_masters`;
CREATE TABLE IF NOT EXISTS `gw_section_admin_masters` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `func_name` text,
  `state` varchar(255) DEFAULT NULL COMMENT '状態',
  `edit_auth` int(11) DEFAULT NULL,
  `management_parent_gid` int(11) DEFAULT NULL COMMENT '主管課',
  `management_gid` int(11) DEFAULT NULL COMMENT '主管課',
  `management_uid` int(11) DEFAULT NULL COMMENT '主管課',
  `range_class_id` int(11) DEFAULT NULL COMMENT '範囲',
  `division_parent_gid` int(11) DEFAULT NULL COMMENT '原課（部局）',
  `division_gid` int(11) DEFAULT NULL COMMENT '原課（諸課）',
  `management_ucode` varchar(255) DEFAULT NULL COMMENT '電子職員録用',
  `fyear_id_sb04` int(11) DEFAULT NULL COMMENT '年度（電子職員録）',
  `management_gcode` varchar(255) DEFAULT NULL COMMENT '電子職員録用',
  `division_gcode` varchar(255) DEFAULT NULL COMMENT '電子職員録用',
  `management_uid_sb04` int(11) DEFAULT NULL COMMENT '電子職員録用',
  `management_gid_sb04` int(11) DEFAULT NULL COMMENT '電子職員録用',
  `division_gid_sb04` int(11) DEFAULT NULL COMMENT '電子職員録用',
  `creator_uid` int(11) DEFAULT NULL,
  `creator_gid` int(11) DEFAULT NULL,
  `updator_uid` int(11) DEFAULT NULL,
  `updator_gid` int(11) DEFAULT NULL,
  `deleted_uid` int(11) DEFAULT NULL,
  `deleted_gid` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_todos`
--

DROP TABLE IF EXISTS `gw_todos`;
CREATE TABLE IF NOT EXISTS `gw_todos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `class_id` int(11) DEFAULT NULL,
  `uid` int(11) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `st_at` datetime DEFAULT NULL,
  `ed_at` datetime DEFAULT NULL,
  `is_finished` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `prior_id` int(11) DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  `body` text,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_user_properties`
--

DROP TABLE IF EXISTS `gw_user_properties`;
CREATE TABLE IF NOT EXISTS `gw_user_properties` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `class_id` int(11) DEFAULT NULL,
  `uid` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `type_name` varchar(255) DEFAULT NULL,
  `options` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_year_fiscal_jps`
--

DROP TABLE IF EXISTS `gw_year_fiscal_jps`;
CREATE TABLE IF NOT EXISTS `gw_year_fiscal_jps` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `start_at` datetime DEFAULT NULL,
  `end_at` datetime DEFAULT NULL,
  `fyear` text,
  `fyear_f` text,
  `markjp` text,
  `markjp_f` text,
  `namejp` text,
  `namejp_f` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_year_mark_jps`
--

DROP TABLE IF EXISTS `gw_year_mark_jps`;
CREATE TABLE IF NOT EXISTS `gw_year_mark_jps` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` text,
  `mark` text,
  `start_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `questionnaire_bases`
--

DROP TABLE IF EXISTS `questionnaire_bases`;
CREATE TABLE IF NOT EXISTS `questionnaire_bases` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `section_code` varchar(255) DEFAULT NULL,
  `section_name` varchar(255) DEFAULT NULL,
  `section_sort` int(11) DEFAULT NULL,
  `enquete_division` tinyint(1) DEFAULT NULL,
  `admin_setting` int(11) DEFAULT NULL,
  `manage_title` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `form_body` text,
  `able_date` datetime DEFAULT NULL,
  `expiry_date` datetime DEFAULT NULL,
  `spec_config` int(11) DEFAULT NULL,
  `send_change` varchar(255) DEFAULT NULL,
  `remarks` text,
  `remarks_setting` text,
  `createdate` text,
  `createrdivision_id` varchar(20) DEFAULT NULL,
  `createrdivision` text,
  `creater_id` varchar(20) DEFAULT NULL,
  `creater` text,
  `editdate` text,
  `editordivision_id` varchar(20) DEFAULT NULL,
  `editordivision` text,
  `editor_id` varchar(20) DEFAULT NULL,
  `editor` text,
  `custom_groups` text,
  `custom_groups_json` text,
  `reader_groups` text,
  `reader_groups_json` text,
  `custom_readers` text,
  `custom_readers_json` text,
  `readers` text,
  `readers_json` text,
  `default_limit` int(11) DEFAULT NULL,
  `answer_count` int(11) DEFAULT NULL,
  `include_index` tinyint(1) DEFAULT NULL,
  `result_open_state` tinyint(1) DEFAULT NULL,
  `keycode` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `questionnaire_field_options`
--

DROP TABLE IF EXISTS `questionnaire_field_options`;
CREATE TABLE IF NOT EXISTS `questionnaire_field_options` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `published_at` datetime DEFAULT NULL,
  `field_id` int(11) DEFAULT NULL,
  `sort_no` int(11) DEFAULT NULL,
  `value` varchar(255) DEFAULT NULL,
  `title` text,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `questionnaire_form_fields`
--

DROP TABLE IF EXISTS `questionnaire_form_fields`;
CREATE TABLE IF NOT EXISTS `questionnaire_form_fields` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `sort_no` int(11) DEFAULT NULL,
  `question_type` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `field_cols` varchar(255) DEFAULT NULL,
  `field_rows` varchar(255) DEFAULT NULL,
  `post_permit_base` int(11) DEFAULT NULL,
  `post_permit` int(11) DEFAULT NULL,
  `post_permit_value` varchar(255) DEFAULT NULL,
  `option_body` text,
  `field_name` varchar(255) DEFAULT NULL,
  `view_type` int(11) DEFAULT NULL,
  `required_entry` int(11) DEFAULT NULL,
  `auto_number_state` tinyint(1) DEFAULT NULL,
  `auto_number` int(11) DEFAULT NULL,
  `group_code` int(11) DEFAULT NULL,
  `group_field` varchar(255) DEFAULT NULL,
  `group_body` text,
  `group_repeat` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `questionnaire_itemdeletes`
--

DROP TABLE IF EXISTS `questionnaire_itemdeletes`;
CREATE TABLE IF NOT EXISTS `questionnaire_itemdeletes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `content_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `admin_code` varchar(255) DEFAULT NULL,
  `limit_date` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `questionnaire_previews`
--

DROP TABLE IF EXISTS `questionnaire_previews`;
CREATE TABLE IF NOT EXISTS `questionnaire_previews` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `field_001` text,
  `field_002` text,
  `field_003` text,
  `field_004` text,
  `field_005` text,
  `field_006` text,
  `field_007` text,
  `field_008` text,
  `field_009` text,
  `field_010` text,
  `field_011` text,
  `field_012` text,
  `field_013` text,
  `field_014` text,
  `field_015` text,
  `field_016` text,
  `field_017` text,
  `field_018` text,
  `field_019` text,
  `field_020` text,
  `field_021` text,
  `field_022` text,
  `field_023` text,
  `field_024` text,
  `field_025` text,
  `field_026` text,
  `field_027` text,
  `field_028` text,
  `field_029` text,
  `field_030` text,
  `field_031` text,
  `field_032` text,
  `field_033` text,
  `field_034` text,
  `field_035` text,
  `field_036` text,
  `field_037` text,
  `field_038` text,
  `field_039` text,
  `field_040` text,
  `field_041` text,
  `field_042` text,
  `field_043` text,
  `field_044` text,
  `field_045` text,
  `field_046` text,
  `field_047` text,
  `field_048` text,
  `field_049` text,
  `field_050` text,
  `field_051` text,
  `field_052` text,
  `field_053` text,
  `field_054` text,
  `field_055` text,
  `field_056` text,
  `field_057` text,
  `field_058` text,
  `field_059` text,
  `field_060` text,
  `field_061` text,
  `field_062` text,
  `field_063` text,
  `field_064` text,
  `createdate` text,
  `createrdivision_id` varchar(20) DEFAULT NULL,
  `createrdivision` text,
  `creater_id` varchar(20) DEFAULT NULL,
  `creater` text,
  `editdate` text,
  `editordivision_id` varchar(20) DEFAULT NULL,
  `editordivision` text,
  `editor_id` varchar(20) DEFAULT NULL,
  `editor` text,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `questionnaire_results`
--

DROP TABLE IF EXISTS `questionnaire_results`;
CREATE TABLE IF NOT EXISTS `questionnaire_results` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `title_id` int(11) DEFAULT NULL,
  `field_id` int(11) DEFAULT NULL,
  `question_type` varchar(255) DEFAULT NULL,
  `question_label` text,
  `option_id` int(11) DEFAULT NULL,
  `option_label` text,
  `sort_no` int(11) DEFAULT NULL,
  `answer_count` int(11) DEFAULT NULL,
  `answer_ratio` decimal(10,5) DEFAULT NULL,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `questionnaire_template_bases`
--

DROP TABLE IF EXISTS `questionnaire_template_bases`;
CREATE TABLE IF NOT EXISTS `questionnaire_template_bases` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `section_code` varchar(255) DEFAULT NULL,
  `section_name` varchar(255) DEFAULT NULL,
  `section_sort` int(11) DEFAULT NULL,
  `enquete_division` tinyint(1) DEFAULT NULL,
  `admin_setting` int(11) DEFAULT NULL,
  `manage_title` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `form_body` text,
  `able_date` datetime DEFAULT NULL,
  `expiry_date` datetime DEFAULT NULL,
  `spec_config` int(11) DEFAULT NULL,
  `send_change` varchar(255) DEFAULT NULL,
  `createdate` text,
  `createrdivision_id` varchar(20) DEFAULT NULL,
  `createrdivision` text,
  `creater_id` varchar(20) DEFAULT NULL,
  `creater` text,
  `editdate` text,
  `editordivision_id` varchar(20) DEFAULT NULL,
  `editordivision` text,
  `editor_id` varchar(20) DEFAULT NULL,
  `editor` text,
  `custom_groups` text,
  `custom_groups_json` text,
  `reader_groups` text,
  `reader_groups_json` text,
  `custom_readers` text,
  `custom_readers_json` text,
  `readers` text,
  `readers_json` text,
  `default_limit` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
)  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `questionnaire_template_field_options`
--

DROP TABLE IF EXISTS `questionnaire_template_field_options`;
CREATE TABLE IF NOT EXISTS `questionnaire_template_field_options` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `published_at` datetime DEFAULT NULL,
  `field_id` int(11) DEFAULT NULL,
  `sort_no` int(11) DEFAULT NULL,
  `value` varchar(255) DEFAULT NULL,
  `title` text,
  PRIMARY KEY (`id`)
)  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `questionnaire_template_form_fields`
--

DROP TABLE IF EXISTS `questionnaire_template_form_fields`;
CREATE TABLE IF NOT EXISTS `questionnaire_template_form_fields` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `sort_no` int(11) DEFAULT NULL,
  `question_type` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `field_cols` varchar(255) DEFAULT NULL,
  `field_rows` varchar(255) DEFAULT NULL,
  `post_permit_base` int(11) DEFAULT NULL,
  `post_permit` int(11) DEFAULT NULL,
  `post_permit_value` varchar(255) DEFAULT NULL,
  `option_body` text,
  `field_name` varchar(255) DEFAULT NULL,
  `view_type` int(11) DEFAULT NULL,
  `required_entry` int(11) DEFAULT NULL,
  `auto_number_state` tinyint(1) DEFAULT NULL,
  `auto_number` int(11) DEFAULT NULL,
  `group_code` int(11) DEFAULT NULL,
  `group_field` varchar(255) DEFAULT NULL,
  `group_body` text,
  `group_repeat` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
)  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `questionnaire_template_previews`
--

DROP TABLE IF EXISTS `questionnaire_template_previews`;
CREATE TABLE IF NOT EXISTS `questionnaire_template_previews` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `field_001` text,
  `field_002` text,
  `field_003` text,
  `field_004` text,
  `field_005` text,
  `field_006` text,
  `field_007` text,
  `field_008` text,
  `field_009` text,
  `field_010` text,
  `field_011` text,
  `field_012` text,
  `field_013` text,
  `field_014` text,
  `field_015` text,
  `field_016` text,
  `field_017` text,
  `field_018` text,
  `field_019` text,
  `field_020` text,
  `field_021` text,
  `field_022` text,
  `field_023` text,
  `field_024` text,
  `field_025` text,
  `field_026` text,
  `field_027` text,
  `field_028` text,
  `field_029` text,
  `field_030` text,
  `field_031` text,
  `field_032` text,
  `field_033` text,
  `field_034` text,
  `field_035` text,
  `field_036` text,
  `field_037` text,
  `field_038` text,
  `field_039` text,
  `field_040` text,
  `field_041` text,
  `field_042` text,
  `field_043` text,
  `field_044` text,
  `field_045` text,
  `field_046` text,
  `field_047` text,
  `field_048` text,
  `field_049` text,
  `field_050` text,
  `field_051` text,
  `field_052` text,
  `field_053` text,
  `field_054` text,
  `field_055` text,
  `field_056` text,
  `field_057` text,
  `field_058` text,
  `field_059` text,
  `field_060` text,
  `field_061` text,
  `field_062` text,
  `field_063` text,
  `field_064` text,
  `createdate` text,
  `createrdivision_id` varchar(20) DEFAULT NULL,
  `createrdivision` text,
  `creater_id` varchar(20) DEFAULT NULL,
  `creater` text,
  `editdate` text,
  `editordivision_id` varchar(20) DEFAULT NULL,
  `editordivision` text,
  `editor_id` varchar(20) DEFAULT NULL,
  `editor` text,
  PRIMARY KEY (`id`)
)  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `questionnaire_temporaries`
--

DROP TABLE IF EXISTS `questionnaire_temporaries`;
CREATE TABLE IF NOT EXISTS `questionnaire_temporaries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `title_id` int(11) DEFAULT NULL,
  `field_id` int(11) DEFAULT NULL,
  `question_type` varchar(255) DEFAULT NULL,
  `answer_text` text,
  `answer_option` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `title_id` (`title_id`)
) DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- ビュー用の構造 `enquete_view_questions`
--
DROP TABLE IF EXISTS `enquete_view_questions`;

CREATE ALGORITHM=UNDEFINED VIEW `enquete_view_questions` AS select `enquete_base_users`.`base_user_code` AS `base_user_code`,`questionnaire_bases`.`id` AS `id`,`questionnaire_bases`.`unid` AS `unid`,`questionnaire_bases`.`include_index` AS `include_index`,`questionnaire_bases`.`content_id` AS `content_id`,`questionnaire_bases`.`state` AS `state`,`questionnaire_bases`.`created_at` AS `created_at`,`questionnaire_bases`.`updated_at` AS `updated_at`,`questionnaire_bases`.`section_code` AS `section_code`,`questionnaire_bases`.`section_name` AS `section_name`,`questionnaire_bases`.`section_sort` AS `section_sort`,`questionnaire_bases`.`enquete_division` AS `enquete_division`,`questionnaire_bases`.`manage_title` AS `manage_title`,`questionnaire_bases`.`title` AS `title`,`questionnaire_bases`.`form_body` AS `form_body`,`questionnaire_bases`.`able_date` AS `able_date`,`questionnaire_bases`.`expiry_date` AS `expiry_date`,`questionnaire_bases`.`spec_config` AS `spec_config`,`questionnaire_bases`.`send_change` AS `send_change`,`questionnaire_bases`.`createdate` AS `createdate`,`questionnaire_bases`.`createrdivision_id` AS `createrdivision_id`,`questionnaire_bases`.`createrdivision` AS `createrdivision`,`questionnaire_bases`.`creater_id` AS `creater_id`,`questionnaire_bases`.`creater` AS `creater`,`questionnaire_bases`.`editdate` AS `editdate`,`questionnaire_bases`.`editordivision_id` AS `editordivision_id`,`questionnaire_bases`.`editordivision` AS `editordivision`,`questionnaire_bases`.`editor_id` AS `editor_id`,`questionnaire_bases`.`editor` AS `editor`,`questionnaire_bases`.`custom_groups` AS `custom_groups`,`questionnaire_bases`.`custom_groups_json` AS `custom_groups_json`,`questionnaire_bases`.`reader_groups` AS `reader_groups`,`questionnaire_bases`.`reader_groups_json` AS `reader_groups_json`,`questionnaire_bases`.`custom_readers` AS `custom_readers`,`questionnaire_bases`.`custom_readers_json` AS `custom_readers_json`,`questionnaire_bases`.`readers` AS `readers`,`questionnaire_bases`.`readers_json` AS `readers_json`,`questionnaire_bases`.`default_limit` AS `default_limit` from (`enquete_base_users` join `questionnaire_bases`) where (`questionnaire_bases`.`state` = _utf8'public');

--
-- テーブルの構造 `gw_plus_updates`
--
DROP TABLE IF EXISTS `gw_plus_updates`;
CREATE TABLE `gw_plus_updates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `doc_id` varchar(255) DEFAULT NULL,
  `post_id` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `project_users` text,
  `project_users_json` text,
  `project_id` varchar(255) DEFAULT NULL,
  `project_code` varchar(255) DEFAULT NULL,
  `class_id` int(11) DEFAULT NULL,
  `title` text,
  `doc_updated_at` datetime DEFAULT NULL,
  `author` text,
  `project_url` text,
  `body` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8;



-- --------------------------------------------------------

--
-- テーブルの構造 `gw_workflow_controls`
--

DROP TABLE IF EXISTS `gw_workflow_controls`;
CREATE TABLE IF NOT EXISTS `gw_workflow_controls` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `recognized_at` datetime DEFAULT NULL,
  `published_at` datetime DEFAULT NULL,
  `default_published` int(11) DEFAULT NULL,
  `doc_body_size_capacity` int(11) DEFAULT NULL,
  `doc_body_size_currently` int(11) DEFAULT NULL,
  `upload_graphic_file_size_capacity` int(11) DEFAULT NULL,
  `upload_graphic_file_size_capacity_unit` varchar(255) DEFAULT NULL,
  `upload_document_file_size_capacity` int(11) DEFAULT NULL,
  `upload_document_file_size_capacity_unit` varchar(255) DEFAULT NULL,
  `upload_graphic_file_size_max` int(11) DEFAULT NULL,
  `upload_document_file_size_max` int(11) DEFAULT NULL,
  `upload_graphic_file_size_currently` decimal(17,0) DEFAULT NULL,
  `upload_document_file_size_currently` decimal(17,0) DEFAULT NULL,
  `commission_limit` int(11) DEFAULT NULL,
  `create_section` varchar(255) DEFAULT NULL,
  `create_section_flag` varchar(255) DEFAULT NULL,
  `addnew_forbidden` tinyint(1) DEFAULT NULL,
  `edit_forbidden` tinyint(1) DEFAULT NULL,
  `draft_forbidden` tinyint(1) DEFAULT NULL,
  `delete_forbidden` tinyint(1) DEFAULT NULL,
  `attachfile_index_use` tinyint(1) DEFAULT NULL,
  `importance` int(11) DEFAULT NULL,
  `form_name` varchar(255) DEFAULT NULL,
  `banner` text,
  `banner_position` varchar(255) DEFAULT NULL,
  `left_banner` text,
  `left_menu` text,
  `left_index_use` varchar(1) DEFAULT NULL,
  `left_index_pattern` int(11) DEFAULT NULL,
  `left_index_bg_color` varchar(255) DEFAULT NULL,
  `default_mode` varchar(255) DEFAULT NULL,
  `other_system_link` text,
  `preview_mode` tinyint(1) DEFAULT NULL,
  `wallpaper_id` int(11) DEFAULT NULL,
  `wallpaper` text,
  `css` text,
  `font_color` text,
  `icon_id` int(11) DEFAULT NULL,
  `icon` text,
  `sort_no` int(11) DEFAULT NULL,
  `caption` text,
  `view_hide` tinyint(1) DEFAULT NULL,
  `categoey_view` tinyint(1) DEFAULT NULL,
  `categoey_view_line` int(11) DEFAULT NULL,
  `monthly_view` tinyint(1) DEFAULT NULL,
  `monthly_view_line` int(11) DEFAULT NULL,
  `group_view` tinyint(1) DEFAULT NULL,
  `one_line_use` int(11) DEFAULT NULL,
  `notification` int(11) DEFAULT NULL,
  `restrict_access` tinyint(1) DEFAULT NULL,
  `upload_system` int(11) DEFAULT NULL,
  `limit_date` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `category` int(11) DEFAULT NULL,
  `category1_name` varchar(255) DEFAULT NULL,
  `category2_name` varchar(255) DEFAULT NULL,
  `category3_name` varchar(255) DEFAULT NULL,
  `recognize` int(11) DEFAULT NULL,
  `createdate` text,
  `createrdivision_id` varchar(20) DEFAULT NULL,
  `createrdivision` text,
  `creater_id` varchar(20) DEFAULT NULL,
  `creater` text,
  `editdate` text,
  `editordivision_id` varchar(20) DEFAULT NULL,
  `editordivision` text,
  `editor_id` varchar(20) DEFAULT NULL,
  `editor` text,
  `default_limit` int(11) DEFAULT NULL,
  `dbname` varchar(255) DEFAULT NULL,
  `admingrps` text,
  `admingrps_json` text,
  `adms` text,
  `adms_json` text,
  `dsp_admin_name` text,
  `editors` text,
  `editors_json` text,
  `readers` text,
  `readers_json` text,
  `sueditors` text,
  `sueditors_json` text,
  `sureaders` text,
  `sureaders_json` text,
  `help_display` text,
  `help_url` text,
  `help_admin_url` text,
  `notes_field01` text,
  `notes_field02` text,
  `notes_field03` text,
  `notes_field04` text,
  `notes_field05` text,
  `notes_field06` text,
  `notes_field07` text,
  `notes_field08` text,
  `notes_field09` text,
  `notes_field10` text,
  `docslast_updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;


-- --------------------------------------------------------

--
-- テーブルの構造 `gw_workflow_docs`
--

DROP TABLE IF EXISTS `gw_workflow_docs`;
CREATE TABLE IF NOT EXISTS `gw_workflow_docs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,

  `state` text,
  `title` text,
  `body` mediumtext,
  `expired_at` datetime DEFAULT NULL,
  `applied_at` datetime DEFAULT NULL,

  `creater_id` varchar(20) DEFAULT NULL,
  `creater_name` varchar(20) DEFAULT NULL,
  `creater_gname` varchar(20) DEFAULT NULL,

  `attachmentfile` int(11) DEFAULT NULL,


  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_workflow_route_steps`
--

DROP TABLE IF EXISTS `gw_workflow_route_steps`;
CREATE TABLE IF NOT EXISTS `gw_workflow_route_steps` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  
  `doc_id` int(11) DEFAULT NULL,
  
  `number` int(11) DEFAULT NULL,
  
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;



-- --------------------------------------------------------

--
-- テーブルの構造 `gw_workflow_route_users`
--

DROP TABLE IF EXISTS `gw_workflow_route_users`;
CREATE TABLE IF NOT EXISTS `gw_workflow_route_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  
  `step_id` int(11) DEFAULT NULL,
  `decided_at` datetime DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `comment` text,
  
  `user_id` int(11) DEFAULT NULL,
  `user_name` text,
  `user_gname` text,
  
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_workflow_custom_routes`
--

DROP TABLE IF EXISTS `gw_workflow_custom_routes`;
CREATE TABLE IF NOT EXISTS `gw_workflow_custom_routes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,

  `owner_uid` int(11) DEFAULT NULL,

  `sort_no` int(11) DEFAULT NULL,
  `state` text,
  `name` text,

  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_workflow_custom_route_steps`
--

DROP TABLE IF EXISTS `gw_workflow_custom_route_steps`;
CREATE TABLE IF NOT EXISTS `gw_workflow_custom_route_steps` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  
  `custom_route_id` int(11) DEFAULT NULL,
  
  `number` int(11) DEFAULT NULL,
  
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;



-- --------------------------------------------------------

--
-- テーブルの構造 `gw_workflow_custom_route_users`
--

DROP TABLE IF EXISTS `gw_workflow_custom_route_users`;
CREATE TABLE IF NOT EXISTS `gw_workflow_custom_route_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  
  `step_id` int(11) DEFAULT NULL,
  
  `user_id` int(11) DEFAULT NULL,
  `user_name` text,
  `user_gname` text,
  
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------




--
-- テーブルの構造 `gwworkflow_files`
--

DROP TABLE IF EXISTS `gwworkflow_files`;
CREATE TABLE IF NOT EXISTS `gwworkflow_files` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `recognized_at` datetime DEFAULT NULL,
  `published_at` datetime DEFAULT NULL,
  `latest_updated_at` datetime DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `title_id` int(11) DEFAULT NULL,
  `content_type` varchar(255) DEFAULT NULL,
  `filename` text,
  `memo` text,
  `size` int(11) DEFAULT NULL,
  `width` int(11) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `db_file_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_workflow_itemdeletes`
--

DROP TABLE IF EXISTS `gw_workflow_itemdeletes`;
CREATE TABLE IF NOT EXISTS `gw_workflow_itemdeletes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `admin_code` varchar(255) DEFAULT NULL,
  `title_id` int(11) DEFAULT NULL,
  `board_title` text,
  `board_state` varchar(255) DEFAULT NULL,
  `board_view_hide` varchar(255) DEFAULT NULL,
  `board_sort_no` int(11) DEFAULT NULL,
  `public_doc_count` int(11) DEFAULT NULL,
  `void_doc_count` int(11) DEFAULT NULL,
  `dbname` varchar(255) DEFAULT NULL,
  `limit_date` varchar(255) DEFAULT NULL,
  `board_limit_date` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gw_workflow_mail_settings`
--

DROP TABLE IF EXISTS `gw_workflow_mail_settings`;
CREATE TABLE IF NOT EXISTS `gw_workflow_mail_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `notifying` BOOLEAN,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;


