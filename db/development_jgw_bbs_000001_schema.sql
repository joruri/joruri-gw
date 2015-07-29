
SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

--
-- データベース: `development_jgw_bbs_000001`
--

-- --------------------------------------------------------

--
-- テーブルの構造 `gwbbs_categories`
--

DROP TABLE IF EXISTS `gwbbs_categories`;
CREATE TABLE IF NOT EXISTS `gwbbs_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `title_id` int(11) DEFAULT NULL,
  `sort_no` int(11) DEFAULT NULL,
  `level_no` int(11) DEFAULT NULL,
  `name` text,
  PRIMARY KEY (`id`)
)  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwbbs_comments`
--

DROP TABLE IF EXISTS `gwbbs_comments`;
CREATE TABLE IF NOT EXISTS `gwbbs_comments` (
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
  `content_state` text,
  `title_id` int(11) DEFAULT NULL,
  `name` text,
  `pname` text,
  `title` text,
  `head` mediumtext,
  `body` mediumtext,
  `note` mediumtext,
  `category1_id` int(11) DEFAULT NULL,
  `category2_id` int(11) DEFAULT NULL,
  `category3_id` int(11) DEFAULT NULL,
  `category4_id` int(11) DEFAULT NULL,
  `keyword1` text,
  `keyword2` text,
  `keyword3` text,
  `keywords` text,
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
  `expiry_date` datetime DEFAULT NULL,
  `inpfld_001` text,
  `inpfld_002` text,
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwbbs_db_files`
--

DROP TABLE IF EXISTS `gwbbs_db_files`;
CREATE TABLE IF NOT EXISTS `gwbbs_db_files` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title_id` int(11) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `data` longblob,
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwbbs_docs`
--

DROP TABLE IF EXISTS `gwbbs_docs`;
CREATE TABLE IF NOT EXISTS `gwbbs_docs` (
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
  `content_state` text,
  `section_code` varchar(255) DEFAULT NULL,
  `section_name` text,
  `importance` int(11) DEFAULT NULL,
  `one_line_note` int(11) DEFAULT NULL,
  `title_id` int(11) DEFAULT NULL,
  `name` text,
  `pname` text,
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
  `form_name` varchar(255) DEFAULT NULL,
  `inpfld_001` text,
  `inpfld_002` text,
  `inpfld_003` text,
  `inpfld_004` text,
  `inpfld_005` text,
  `inpfld_006` text,
  `inpfld_006w` varchar(255) DEFAULT NULL,
  `inpfld_006d` datetime DEFAULT NULL,
  `inpfld_007` text,
  `inpfld_008` text,
  `inpfld_009` text,
  `inpfld_010` text,
  `inpfld_011` text,
  `inpfld_012` text,
  `inpfld_013` text,
  `inpfld_014` text,
  `inpfld_015` text,
  `inpfld_016` text,
  `inpfld_017` text,
  `inpfld_018` text,
  `inpfld_019` text,
  `inpfld_020` text,
  `inpfld_021` text,
  `inpfld_022` text,
  `inpfld_023` text,
  `inpfld_024` text,
  `inpfld_025` text,
  PRIMARY KEY (`id`)
)  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `gwbbs_files`
--

DROP TABLE IF EXISTS `gwbbs_files`;
CREATE TABLE IF NOT EXISTS `gwbbs_files` (
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
-- テーブルの構造 `gwbbs_images`
--

DROP TABLE IF EXISTS `gwbbs_images`;
CREATE TABLE IF NOT EXISTS `gwbbs_images` (
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
  `parent_name` text,
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
-- テーブルの構造 `gwbbs_recognizers`
--

DROP TABLE IF EXISTS `gwbbs_recognizers`;
CREATE TABLE IF NOT EXISTS `gwbbs_recognizers` (
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
) DEFAULT CHARSET=utf8;
