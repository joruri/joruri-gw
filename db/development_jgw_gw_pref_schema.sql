
SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

--
-- データベース: `development_jgw_gw_pref`
--

-- --------------------------------------------------------

--
-- テーブルの構造 `gwsub_sb01_trainings`
--

DROP TABLE IF EXISTS `gwsub_sb01_trainings`;
CREATE TABLE IF NOT EXISTS `gwsub_sb01_trainings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `categories` text,
  `fyear_id` int(11) DEFAULT NULL,
  `fyear_markjp` text,
  `title` text,
  `bbs_url` text,
  `body` text,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `state` text,
  `member_id` int(11) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  `member_max` int(11) DEFAULT NULL,
  `group_code` text,
  `group_name` text,
  `member_code` text,
  `member_name` text,
  `member_tel` text,
  `bbs_doc_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwsub_sb01_training_files`
--

DROP TABLE IF EXISTS `gwsub_sb01_training_files`;
CREATE TABLE IF NOT EXISTS `gwsub_sb01_training_files` (
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
) DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwsub_sb01_training_guides`
--

DROP TABLE IF EXISTS `gwsub_sb01_training_guides`;
CREATE TABLE IF NOT EXISTS `gwsub_sb01_training_guides` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `categories` text,
  `fyear_id` int(11) DEFAULT NULL,
  `fyear_markjp` text,
  `title` text,
  `bbs_url` text,
  `remarks` text,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `state` text,
  `member_id` int(11) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwsub_sb01_training_schedules`
--

DROP TABLE IF EXISTS `gwsub_sb01_training_schedules`;
CREATE TABLE IF NOT EXISTS `gwsub_sb01_training_schedules` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `schedule_id` int(11) DEFAULT NULL,
  `training_id` int(11) DEFAULT NULL,
  `condition_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `members_max` int(11) DEFAULT NULL,
  `members_current` int(11) DEFAULT NULL,
  `state` text,
  `from_start` datetime DEFAULT NULL,
  `from_end` datetime DEFAULT NULL,
  `prop_name` text,
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwsub_sb01_training_schedule_conditions`
--

DROP TABLE IF EXISTS `gwsub_sb01_training_schedule_conditions`;
CREATE TABLE IF NOT EXISTS `gwsub_sb01_training_schedule_conditions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `training_id` int(11) DEFAULT NULL,
  `members_max` int(11) DEFAULT NULL,
  `title` text,
  `from_start` text,
  `from_start_min` text,
  `from_end` text,
  `from_end_min` text,
  `member_id` int(11) DEFAULT NULL,
  `prop_id` int(11) DEFAULT NULL,
  `repeat_flg` text,
  `repeat_monthly` text,
  `repeat_weekday` text,
  `from_at` datetime DEFAULT NULL,
  `to_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `state` text,
  `group_id` int(11) DEFAULT NULL,
  `extension` text,
  `prop_kind` int(11) DEFAULT NULL,
  `prop_name` text,
  `repeat_class_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwsub_sb01_training_schedule_members`
--

DROP TABLE IF EXISTS `gwsub_sb01_training_schedule_members`;
CREATE TABLE IF NOT EXISTS `gwsub_sb01_training_schedule_members` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `training_id` int(11) DEFAULT NULL,
  `schedule_id` int(11) DEFAULT NULL,
  `condition_id` int(11) DEFAULT NULL,
  `training_schedule_id` int(11) DEFAULT NULL,
  `training_user_id` int(11) DEFAULT NULL,
  `training_group_id` int(11) DEFAULT NULL,
  `entry_user_id` int(11) DEFAULT NULL,
  `entry_group_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `training_user_tel` text,
  `entry_user_tel` text,
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwsub_sb01_training_schedule_props`
--

DROP TABLE IF EXISTS `gwsub_sb01_training_schedule_props`;
CREATE TABLE IF NOT EXISTS `gwsub_sb01_training_schedule_props` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `training_id` int(11) DEFAULT NULL,
  `schedule_id` int(11) DEFAULT NULL,
  `prop_id` int(11) DEFAULT NULL,
  `members_max` int(11) DEFAULT NULL,
  `members_current` int(11) DEFAULT NULL,
  `member_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `condition_id` int(11) DEFAULT NULL,
  `from_start` text,
  `from_end` text,
  `state` text,
  `group_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwsub_sb04assignedjobs`
--

DROP TABLE IF EXISTS `gwsub_sb04assignedjobs`;
CREATE TABLE IF NOT EXISTS `gwsub_sb04assignedjobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fyear_id` int(11) DEFAULT NULL,
  `fyear_markjp` text,
  `section_id` int(11) DEFAULT NULL,
  `section_code` text,
  `section_name` text,
  `code_int` int(11) DEFAULT NULL,
  `code` text,
  `name` text,
  `tel` text,
  `address` text,
  `remarks` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwsub_sb04helps`
--

DROP TABLE IF EXISTS `gwsub_sb04helps`;
CREATE TABLE IF NOT EXISTS `gwsub_sb04helps` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `categories` int(11) DEFAULT NULL,
  `title` text,
  `bbs_url` text,
  `remarks` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwsub_sb04officialtitles`
--

DROP TABLE IF EXISTS `gwsub_sb04officialtitles`;
CREATE TABLE IF NOT EXISTS `gwsub_sb04officialtitles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fyear_id` int(11) DEFAULT NULL,
  `fyear_markjp` text,
  `code_int` int(11) DEFAULT NULL,
  `code` text,
  `name` text,
  `remarks` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwsub_sb04sections`
--

DROP TABLE IF EXISTS `gwsub_sb04sections`;
CREATE TABLE IF NOT EXISTS `gwsub_sb04sections` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fyear_id` int(11) DEFAULT NULL,
  `fyear_markjp` text,
  `code` text,
  `name` text,
  `remarks` text,
  `bbs_url` text,
  `ldap_code` text,
  `ldap_name` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  PRIMARY KEY (`id`),
  KEY `fyear_id` (`fyear_id`),
  KEY `code` (`code`(10))
) DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwsub_sb04stafflists`
--

DROP TABLE IF EXISTS `gwsub_sb04stafflists`;
CREATE TABLE IF NOT EXISTS `gwsub_sb04stafflists` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fyear_id` int(11) DEFAULT NULL,
  `fyear_markjp` text,
  `staff_no` text,
  `multi_section_flg` text,
  `name` text,
  `name_print` text,
  `kana` text,
  `section_id` int(11) DEFAULT NULL,
  `section_code` text,
  `section_name` text,
  `assignedjobs_id` int(11) DEFAULT NULL,
  `assignedjobs_code_int` int(11) DEFAULT NULL,
  `assignedjobs_code` text,
  `assignedjobs_name` text,
  `assignedjobs_tel` text,
  `assignedjobs_address` text,
  `official_title_id` int(11) DEFAULT NULL,
  `official_title_code` text,
  `official_title_code_int` int(11) DEFAULT NULL,
  `official_title_name` text,
  `categories_id` int(11) DEFAULT NULL,
  `categories_code` text,
  `categories_name` text,
  `extension` text,
  `divide_duties` text,
  `divide_duties_order` text,
  `divide_duties_order_int` int(11) DEFAULT NULL,
  `remarks` text,
  `personal_state` text,
  `display_state` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  PRIMARY KEY (`id`),
  KEY `fyear_markjp` (`fyear_markjp`(10)),
  KEY `fyear_id` (`fyear_id`)
) DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwsub_sb04_check_assignedjobs`
--

DROP TABLE IF EXISTS `gwsub_sb04_check_assignedjobs`;
CREATE TABLE IF NOT EXISTS `gwsub_sb04_check_assignedjobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fyear_id` int(11) DEFAULT NULL,
  `fyear_markjp` text,
  `section_id` int(11) DEFAULT NULL,
  `section_code` text,
  `section_name` text,
  `code_int` int(11) DEFAULT NULL,
  `code` text,
  `name` text,
  `tel` text,
  `address` text,
  `remarks` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwsub_sb04_check_officialtitles`
--

DROP TABLE IF EXISTS `gwsub_sb04_check_officialtitles`;
CREATE TABLE IF NOT EXISTS `gwsub_sb04_check_officialtitles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fyear_id` int(11) DEFAULT NULL,
  `fyear_markjp` text,
  `code_int` int(11) DEFAULT NULL,
  `code` text,
  `name` text,
  `remarks` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwsub_sb04_check_sections`
--

DROP TABLE IF EXISTS `gwsub_sb04_check_sections`;
CREATE TABLE IF NOT EXISTS `gwsub_sb04_check_sections` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fyear_id` int(11) DEFAULT NULL,
  `fyear_markjp` text,
  `code` text,
  `name` text,
  `remarks` text,
  `bbs_url` text,
  `ldap_code` text,
  `ldap_name` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwsub_sb04_check_stafflists`
--

DROP TABLE IF EXISTS `gwsub_sb04_check_stafflists`;
CREATE TABLE IF NOT EXISTS `gwsub_sb04_check_stafflists` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fyear_id` int(11) DEFAULT NULL,
  `fyear_markjp` text,
  `staff_no` text,
  `multi_section_flg` text,
  `name` text,
  `name_print` text,
  `kana` text,
  `section_id` int(11) DEFAULT NULL,
  `section_code` text,
  `section_name` text,
  `assignedjobs_id` int(11) DEFAULT NULL,
  `assignedjobs_code_int` int(11) DEFAULT NULL,
  `assignedjobs_code` text,
  `assignedjobs_name` text,
  `assignedjobs_tel` text,
  `assignedjobs_address` text,
  `official_title_id` int(11) DEFAULT NULL,
  `official_title_code` text,
  `official_title_code_int` int(11) DEFAULT NULL,
  `official_title_name` text,
  `categories_id` int(11) DEFAULT NULL,
  `categories_code` text,
  `categories_name` text,
  `extension` text,
  `divide_duties` text,
  `divide_duties_order` text,
  `divide_duties_order_int` int(11) DEFAULT NULL,
  `remarks` text,
  `personal_state` text,
  `display_state` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwsub_sb04_editable_dates`
--

DROP TABLE IF EXISTS `gwsub_sb04_editable_dates`;
CREATE TABLE IF NOT EXISTS `gwsub_sb04_editable_dates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fyear_id` int(11) DEFAULT NULL,
  `fyear_markjp` text,
  `published_at` datetime DEFAULT NULL,
  `start_at` datetime DEFAULT NULL,
  `end_at` datetime DEFAULT NULL,
  `headline_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwsub_sb04_limit_settings`
--

DROP TABLE IF EXISTS `gwsub_sb04_limit_settings`;
CREATE TABLE IF NOT EXISTS `gwsub_sb04_limit_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type_name` varchar(255) DEFAULT NULL,
  `limit` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwsub_sb04_seating_lists`
--

DROP TABLE IF EXISTS `gwsub_sb04_seating_lists`;
CREATE TABLE IF NOT EXISTS `gwsub_sb04_seating_lists` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fyear_id` int(11) DEFAULT NULL,
  `fyear_markjp` text,
  `title` text,
  `bbs_url` text,
  `remarks` text,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwsub_sb04_year_copy_logs`
--

DROP TABLE IF EXISTS `gwsub_sb04_year_copy_logs`;
CREATE TABLE IF NOT EXISTS `gwsub_sb04_year_copy_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(255) DEFAULT NULL,
  `origin_fyear_id` int(11) DEFAULT NULL,
  `origin_section_id` int(11) DEFAULT NULL,
  `origin_section_code` varchar(255) DEFAULT NULL,
  `origin_section_name` text,
  `destination_fyear_id` int(11) DEFAULT NULL,
  `destination_section_id` int(11) DEFAULT NULL,
  `destination_section_code` varchar(255) DEFAULT NULL,
  `destination_section_name` text,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8;
