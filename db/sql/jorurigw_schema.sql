
--
-- Table structure for table `delayed_jobs`
--

DROP TABLE IF EXISTS `delayed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `delayed_jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `priority` int(11) NOT NULL DEFAULT '0',
  `attempts` int(11) NOT NULL DEFAULT '0',
  `handler` text NOT NULL,
  `last_error` text,
  `run_at` datetime DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `failed_at` datetime DEFAULT NULL,
  `locked_by` varchar(255) DEFAULT NULL,
  `queue` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `delayed_jobs_priority` (`priority`,`run_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `digitallibrary_adms`
--

DROP TABLE IF EXISTS `digitallibrary_adms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `digitallibrary_adms` (
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
  PRIMARY KEY (`id`),
  KEY `index_digitallibrary_adms_on_title_id` (`title_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `digitallibrary_controls`
--

DROP TABLE IF EXISTS `digitallibrary_controls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `digitallibrary_controls` (
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
  PRIMARY KEY (`id`),
  KEY `index_digitallibrary_controls_on_notification` (`notification`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `digitallibrary_db_files`
--

DROP TABLE IF EXISTS `digitallibrary_db_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `digitallibrary_db_files` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title_id` int(11) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `data` longblob,
  `serial_no` int(11) DEFAULT NULL,
  `migrated` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_digitallibrary_db_files_on_title_id` (`title_id`),
  KEY `index_digitallibrary_db_files_on_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `digitallibrary_docs`
--

DROP TABLE IF EXISTS `digitallibrary_docs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `digitallibrary_docs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `recognized_at` datetime DEFAULT NULL,
  `published_at` datetime DEFAULT NULL,
  `latest_updated_at` datetime DEFAULT NULL,
  `doc_type` int(11) DEFAULT NULL,
  `display_order` int(11) DEFAULT NULL,
  `doc_alias` int(11) DEFAULT NULL,
  `title_id` int(11) DEFAULT NULL,
  `chg_parent_id` int(11) DEFAULT NULL,
  `sort_no` int(11) DEFAULT NULL,
  `seq_no` float DEFAULT NULL,
  `order_no` int(11) DEFAULT NULL,
  `seq_name` varchar(255) DEFAULT NULL,
  `level_no` int(11) DEFAULT NULL,
  `section_code` varchar(255) DEFAULT NULL,
  `section_name` text,
  `name` text,
  `title` text,
  `body` mediumtext,
  `note` mediumtext,
  `category1_id` int(11) DEFAULT NULL,
  `category2_id` int(11) DEFAULT NULL,
  `category3_id` int(11) DEFAULT NULL,
  `category4_id` int(11) DEFAULT NULL,
  `keywords` mediumtext,
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
  `readers` text,
  `readers_json` text,
  `notes_001` text,
  `attachmentfile` int(11) DEFAULT NULL,
  `serial_no` int(11) DEFAULT NULL,
  `migrated` int(11) DEFAULT NULL,
  `wiki` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_digitallibrary_docs_on_title_id` (`title_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `digitallibrary_files`
--

DROP TABLE IF EXISTS `digitallibrary_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `digitallibrary_files` (
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
  `serial_no` int(11) DEFAULT NULL,
  `migrated` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_digitallibrary_files_on_title_id` (`title_id`),
  KEY `index_digitallibrary_files_on_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `digitallibrary_images`
--

DROP TABLE IF EXISTS `digitallibrary_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `digitallibrary_images` (
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
  `serial_no` int(11) DEFAULT NULL,
  `migrated` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_digitallibrary_images_on_title_id` (`title_id`),
  KEY `index_digitallibrary_images_on_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `digitallibrary_recognizers`
--

DROP TABLE IF EXISTS `digitallibrary_recognizers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `digitallibrary_recognizers` (
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
  `serial_no` int(11) DEFAULT NULL,
  `migrated` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_digitallibrary_recognizers_on_title_id` (`title_id`),
  KEY `index_digitallibrary_recognizers_on_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `digitallibrary_roles`
--

DROP TABLE IF EXISTS `digitallibrary_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `digitallibrary_roles` (
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
  PRIMARY KEY (`id`),
  KEY `index_digitallibrary_roles_on_title_id` (`title_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `doclibrary_adms`
--

DROP TABLE IF EXISTS `doclibrary_adms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `doclibrary_adms` (
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
  PRIMARY KEY (`id`),
  KEY `index_doclibrary_adms_on_title_id` (`title_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `doclibrary_categories`
--

DROP TABLE IF EXISTS `doclibrary_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `doclibrary_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `title_id` int(11) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `sort_no` int(11) DEFAULT NULL,
  `level_no` int(11) DEFAULT NULL,
  `wareki` text,
  `nen` int(11) DEFAULT NULL,
  `gatsu` int(11) DEFAULT NULL,
  `sono` int(11) DEFAULT NULL,
  `sono2` int(11) DEFAULT NULL,
  `filename` varchar(255) DEFAULT NULL,
  `note_id` varchar(255) DEFAULT NULL,
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
  `serial_no` int(11) DEFAULT NULL,
  `migrated` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_doclibrary_categories_on_title_id` (`title_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `doclibrary_controls`
--

DROP TABLE IF EXISTS `doclibrary_controls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `doclibrary_controls` (
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
  PRIMARY KEY (`id`),
  KEY `index_doclibrary_controls_on_notification` (`notification`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `doclibrary_db_files`
--

DROP TABLE IF EXISTS `doclibrary_db_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `doclibrary_db_files` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title_id` int(11) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `data` longblob,
  `serial_no` int(11) DEFAULT NULL,
  `migrated` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_doclibrary_db_files_on_title_id` (`title_id`),
  KEY `index_doclibrary_db_files_on_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `doclibrary_docs`
--

DROP TABLE IF EXISTS `doclibrary_docs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `doclibrary_docs` (
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
  `expiry_date` datetime DEFAULT NULL,
  `attachmentfile` int(11) DEFAULT NULL,
  `form_name` varchar(255) DEFAULT NULL,
  `inpfld_001` text,
  `inpfld_002` int(11) DEFAULT NULL,
  `inpfld_003` int(11) DEFAULT NULL,
  `inpfld_004` int(11) DEFAULT NULL,
  `inpfld_005` int(11) DEFAULT NULL,
  `inpfld_006` int(11) DEFAULT NULL,
  `inpfld_007` text,
  `inpfld_008` text,
  `inpfld_009` text,
  `inpfld_010` text,
  `inpfld_011` text,
  `inpfld_012` text,
  `notes_001` text,
  `notes_002` text,
  `notes_003` text,
  `serial_no` int(11) DEFAULT NULL,
  `migrated` int(11) DEFAULT NULL,
  `wiki` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `doclibrary_files`
--

DROP TABLE IF EXISTS `doclibrary_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `doclibrary_files` (
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
  `serial_no` int(11) DEFAULT NULL,
  `migrated` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_doclibrary_files_on_title_id` (`title_id`),
  KEY `index_doclibrary_files_on_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `doclibrary_folder_acls`
--

DROP TABLE IF EXISTS `doclibrary_folder_acls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `doclibrary_folder_acls` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `content_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `folder_id` int(11) DEFAULT NULL,
  `title_id` int(11) DEFAULT NULL,
  `acl_flag` int(11) DEFAULT NULL,
  `acl_section_id` int(11) DEFAULT NULL,
  `acl_section_code` varchar(255) DEFAULT NULL,
  `acl_section_name` text,
  `acl_user_id` int(11) DEFAULT NULL,
  `acl_user_code` varchar(255) DEFAULT NULL,
  `acl_user_name` text,
  `serial_no` int(11) DEFAULT NULL,
  `migrated` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `doclibrary_folders`
--

DROP TABLE IF EXISTS `doclibrary_folders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `doclibrary_folders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `title_id` int(11) DEFAULT NULL,
  `sort_no` int(11) DEFAULT NULL,
  `level_no` int(11) DEFAULT NULL,
  `children_size` int(11) DEFAULT NULL,
  `total_children_size` int(11) DEFAULT NULL,
  `name` text,
  `memo` text,
  `readers` text,
  `readers_json` text,
  `reader_groups` text,
  `reader_groups_json` text,
  `docs_last_updated_at` datetime DEFAULT NULL,
  `serial_no` int(11) DEFAULT NULL,
  `migrated` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `doclibrary_group_folders`
--

DROP TABLE IF EXISTS `doclibrary_group_folders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `doclibrary_group_folders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `state` text,
  `use_state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `title_id` int(11) DEFAULT NULL,
  `sort_no` int(11) DEFAULT NULL,
  `level_no` int(11) DEFAULT NULL,
  `children_size` int(11) DEFAULT NULL,
  `total_children_size` int(11) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `name` text,
  `sysgroup_id` int(11) DEFAULT NULL,
  `sysparent_id` int(11) DEFAULT NULL,
  `readers` text,
  `readers_json` text,
  `reader_groups` text,
  `reader_groups_json` text,
  `docs_last_updated_at` datetime DEFAULT NULL,
  `serial_no` int(11) DEFAULT NULL,
  `migrated` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `doclibrary_images`
--

DROP TABLE IF EXISTS `doclibrary_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `doclibrary_images` (
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
  `serial_no` int(11) DEFAULT NULL,
  `migrated` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_doclibrary_images_on_title_id` (`title_id`),
  KEY `index_doclibrary_images_on_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `doclibrary_recognizers`
--

DROP TABLE IF EXISTS `doclibrary_recognizers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `doclibrary_recognizers` (
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
  `serial_no` int(11) DEFAULT NULL,
  `migrated` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_doclibrary_recognizers_on_title_id` (`title_id`),
  KEY `index_doclibrary_recognizers_on_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `doclibrary_roles`
--

DROP TABLE IF EXISTS `doclibrary_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `doclibrary_roles` (
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
  PRIMARY KEY (`id`),
  KEY `index_doclibrary_roles_on_title_id` (`title_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `enquete_answers`
--

DROP TABLE IF EXISTS `enquete_answers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `enquete_answers` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `enquete_base_users`
--

DROP TABLE IF EXISTS `enquete_base_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `enquete_base_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `base_user_code` varchar(255) DEFAULT NULL,
  `base_user_name` text,
  PRIMARY KEY (`id`),
  KEY `base_user_code` (`base_user_code`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary view structure for view `enquete_view_questions`
--

DROP TABLE IF EXISTS `enquete_view_questions`;
/*!50001 DROP VIEW IF EXISTS `enquete_view_questions`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `enquete_view_questions` AS SELECT 
 1 AS `base_user_code`,
 1 AS `id`,
 1 AS `unid`,
 1 AS `include_index`,
 1 AS `content_id`,
 1 AS `state`,
 1 AS `created_at`,
 1 AS `updated_at`,
 1 AS `section_code`,
 1 AS `section_name`,
 1 AS `section_sort`,
 1 AS `enquete_division`,
 1 AS `manage_title`,
 1 AS `title`,
 1 AS `form_body`,
 1 AS `able_date`,
 1 AS `expiry_date`,
 1 AS `spec_config`,
 1 AS `send_change`,
 1 AS `createdate`,
 1 AS `createrdivision_id`,
 1 AS `createrdivision`,
 1 AS `creater_id`,
 1 AS `creater`,
 1 AS `editdate`,
 1 AS `editordivision_id`,
 1 AS `editordivision`,
 1 AS `editor_id`,
 1 AS `editor`,
 1 AS `custom_groups`,
 1 AS `custom_groups_json`,
 1 AS `reader_groups`,
 1 AS `reader_groups_json`,
 1 AS `custom_readers`,
 1 AS `custom_readers_json`,
 1 AS `readers`,
 1 AS `readers_json`,
 1 AS `default_limit`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `gw_access_controls`
--

DROP TABLE IF EXISTS `gw_access_controls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_access_controls` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `state` varchar(255) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `path` text,
  `priority` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_gw_access_controls_on_state_and_user_id` (`state`,`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_admin_check_extensions`
--

DROP TABLE IF EXISTS `gw_admin_check_extensions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_admin_check_extensions` (
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
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_admin_messages`
--

DROP TABLE IF EXISTS `gw_admin_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_admin_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `body` text,
  `sort_no` int(11) DEFAULT NULL,
  `state` int(11) DEFAULT NULL,
  `mode` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_blog_parts`
--

DROP TABLE IF EXISTS `gw_blog_parts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_blog_parts` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_circulars`
--

DROP TABLE IF EXISTS `gw_circulars`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_circulars` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_dcn_approvals`
--

DROP TABLE IF EXISTS `gw_dcn_approvals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_dcn_approvals` (
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
  `author` text,
  `options` text,
  `body` text,
  `deleted_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_edit_link_piece_csses`
--

DROP TABLE IF EXISTS `gw_edit_link_piece_csses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_edit_link_piece_csses` (
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
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_edit_link_pieces`
--

DROP TABLE IF EXISTS `gw_edit_link_pieces`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_edit_link_pieces` (
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
  `class_sso` varchar(255) DEFAULT '0',
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
  PRIMARY KEY (`id`),
  KEY `idx_gw_edit_link_pieces` (`published`,`state`,`sort_no`)
) ENGINE=InnoDB AUTO_INCREMENT=1508 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_edit_tab_public_roles`
--

DROP TABLE IF EXISTS `gw_edit_tab_public_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_edit_tab_public_roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `edit_tab_id` int(11) DEFAULT NULL,
  `class_id` int(11) DEFAULT NULL,
  `uid` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_edit_tabs`
--

DROP TABLE IF EXISTS `gw_edit_tabs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_edit_tabs` (
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
  `other_controller_use` varchar(255) DEFAULT '2',
  `other_controller_url` varchar(255) DEFAULT NULL,
  `link_url` text,
  `icon_path` text,
  `link_div_class` varchar(255) DEFAULT NULL,
  `class_external` int(11) DEFAULT '0',
  `class_sso` varchar(255) DEFAULT '0',
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
) ENGINE=InnoDB AUTO_INCREMENT=185 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_holidays`
--

DROP TABLE IF EXISTS `gw_holidays`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_holidays` (
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
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_icon_groups`
--

DROP TABLE IF EXISTS `gw_icon_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_icon_groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_icons`
--

DROP TABLE IF EXISTS `gw_icons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_icons` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `icon_gid` int(11) DEFAULT NULL,
  `idx` int(11) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `path` varchar(255) DEFAULT NULL COMMENT 'relative from RAILS_ROOT/public',
  `content_type` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_ind_portal_pieces`
--

DROP TABLE IF EXISTS `gw_ind_portal_pieces`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_ind_portal_pieces` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_infos`
--

DROP TABLE IF EXISTS `gw_infos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_infos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cls` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_meeting_access_logs`
--

DROP TABLE IF EXISTS `gw_meeting_access_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_meeting_access_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ip_address` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_meeting_guide_backgrounds`
--

DROP TABLE IF EXISTS `gw_meeting_guide_backgrounds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_meeting_guide_backgrounds` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `published` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `area` int(11) DEFAULT NULL,
  `sort_no` int(11) DEFAULT NULL,
  `file_path` text,
  `file_directory` text,
  `file_name` text,
  `original_file_name` text,
  `content_type` varchar(255) DEFAULT NULL,
  `width` int(11) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `background_color` varchar(255) DEFAULT NULL,
  `caption` text,
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_meeting_guide_notices`
--

DROP TABLE IF EXISTS `gw_meeting_guide_notices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_meeting_guide_notices` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `published` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `sort_no` int(11) DEFAULT NULL,
  `title` text,
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_meeting_guide_places`
--

DROP TABLE IF EXISTS `gw_meeting_guide_places`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_meeting_guide_places` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `state` text,
  `sort_no` int(11) DEFAULT NULL,
  `place` text,
  `place_master` text,
  `place_type` int(11) DEFAULT NULL,
  `prop_id` int(11) DEFAULT NULL,
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_meeting_monitor_managers`
--

DROP TABLE IF EXISTS `gw_meeting_monitor_managers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_meeting_monitor_managers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `manager_group_id` int(11) DEFAULT NULL,
  `manager_user_id` int(11) DEFAULT NULL,
  `manager_user_addr` text,
  `state` text,
  `created_user` text,
  `updated_user` text,
  `deleted_user` text,
  `created_group` text,
  `updated_group` text,
  `deleted_group` text,
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_meeting_monitor_settings`
--

DROP TABLE IF EXISTS `gw_meeting_monitor_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_meeting_monitor_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `state` text,
  `mail_from` text,
  `mail_title` text,
  `mail_body` text,
  `notice_body` text,
  `conditions` text,
  `weekday_notice` text,
  `holiday_notice` text,
  `monitor_type` int(11) DEFAULT NULL,
  `name` text,
  `ip_address` text,
  `created_user` text,
  `updated_user` text,
  `deleted_user` text,
  `created_group` text,
  `updated_group` text,
  `deleted_group` text,
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_memo_mobiles`
--

DROP TABLE IF EXISTS `gw_memo_mobiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_memo_mobiles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `domain` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_memo_users`
--

DROP TABLE IF EXISTS `gw_memo_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_memo_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `schedule_id` int(11) DEFAULT NULL,
  `class_id` int(11) DEFAULT NULL,
  `uid` int(11) DEFAULT NULL,
  `ucode` varchar(255) DEFAULT NULL,
  `uname` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_gw_memo_users_on_schedule_id` (`schedule_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_memos`
--

DROP TABLE IF EXISTS `gw_memos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_memos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `class_id` int(11) DEFAULT NULL,
  `uid` int(11) DEFAULT NULL,
  `ucode` varchar(255) DEFAULT NULL,
  `uname` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `st_at` datetime DEFAULT NULL,
  `ed_at` datetime DEFAULT NULL,
  `is_finished` int(11) DEFAULT '0',
  `is_system` int(11) DEFAULT NULL,
  `fr_group` varchar(255) DEFAULT NULL,
  `fr_user` varchar(255) DEFAULT NULL,
  `memo_category_id` int(11) DEFAULT NULL,
  `memo_category_text` varchar(255) DEFAULT NULL,
  `body` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_monitor_reminders`
--

DROP TABLE IF EXISTS `gw_monitor_reminders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_monitor_reminders` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_notes`
--

DROP TABLE IF EXISTS `gw_notes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_notes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uid` int(11) DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `body` text,
  `deadline` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_plus_updates`
--

DROP TABLE IF EXISTS `gw_plus_updates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_portal_ad_daily_accesses`
--

DROP TABLE IF EXISTS `gw_portal_ad_daily_accesses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_portal_ad_daily_accesses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `state` text,
  `ad_id` int(11) DEFAULT NULL,
  `content` text,
  `click_count` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `accessed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_portal_add_access_logs`
--

DROP TABLE IF EXISTS `gw_portal_add_access_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_portal_add_access_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `add_id` int(11) DEFAULT NULL,
  `accessed_at` datetime DEFAULT NULL,
  `ipaddr` varchar(255) DEFAULT NULL,
  `user_agent` text,
  `referer` text,
  `path` text,
  `content` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_gw_portal_add_access_logs_on_add_id_and_accessed_at` (`add_id`,`accessed_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_portal_add_patterns`
--

DROP TABLE IF EXISTS `gw_portal_add_patterns`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_portal_add_patterns` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pattern` int(11) DEFAULT NULL,
  `place` int(11) DEFAULT NULL,
  `state` text,
  `add_id` int(11) DEFAULT NULL,
  `sort_no` int(11) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  `title` text,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_portal_adds`
--

DROP TABLE IF EXISTS `gw_portal_adds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_portal_adds` (
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
  `class_external` int(11) DEFAULT NULL,
  `class_sso` varchar(255) DEFAULT NULL,
  `field_account` varchar(255) DEFAULT NULL,
  `field_pass` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_user` text,
  `deleted_group` text,
  `click_count` int(11) NOT NULL DEFAULT '0',
  `is_large` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_portal_user_settings`
--

DROP TABLE IF EXISTS `gw_portal_user_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_portal_user_settings` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_pref_assembly_members`
--

DROP TABLE IF EXISTS `gw_pref_assembly_members`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_pref_assembly_members` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_pref_configs`
--

DROP TABLE IF EXISTS `gw_pref_configs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_pref_configs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `state` text,
  `option_type` text,
  `name` text,
  `options` text,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_pref_director_temps`
--

DROP TABLE IF EXISTS `gw_pref_director_temps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_pref_director_temps` (
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
  `display_parent_gid` int(11) DEFAULT NULL,
  `version` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_pref_directors`
--

DROP TABLE IF EXISTS `gw_pref_directors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_pref_directors` (
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
  `display_parent_gid` int(11) DEFAULT NULL,
  `version` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_pref_executives`
--

DROP TABLE IF EXISTS `gw_pref_executives`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_pref_executives` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_pref_soumu_messages`
--

DROP TABLE IF EXISTS `gw_pref_soumu_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_pref_soumu_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `body` text,
  `sort_no` int(11) DEFAULT NULL,
  `state` int(11) DEFAULT NULL,
  `tab_keys` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_prop_extra_pm_meetingroom_actuals`
--

DROP TABLE IF EXISTS `gw_prop_extra_pm_meetingroom_actuals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_prop_extra_pm_meetingroom_actuals` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `schedule_id` int(11) DEFAULT NULL,
  `schedule_prop_id` int(11) DEFAULT NULL,
  `car_id` int(11) DEFAULT NULL,
  `driver_user_id` int(11) DEFAULT NULL,
  `driver_user_code` varchar(255) DEFAULT NULL,
  `driver_user_name` varchar(255) DEFAULT NULL,
  `driver_group_id` int(11) DEFAULT NULL,
  `driver_group_code` varchar(255) DEFAULT NULL,
  `driver_group_name` varchar(255) DEFAULT NULL,
  `start_at` datetime DEFAULT NULL,
  `end_at` datetime DEFAULT NULL,
  `start_meter` int(11) DEFAULT NULL,
  `end_meter` int(11) DEFAULT NULL,
  `run_meter` int(11) DEFAULT NULL,
  `summaries_state` text,
  `bill_state` text,
  `toll_fee` int(11) DEFAULT NULL,
  `refuel_amount` int(11) DEFAULT NULL,
  `to_go` text,
  `title` text,
  `updated_user` text,
  `updated_group` text,
  `created_user` text,
  `created_group` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_gw_prop_extra_pm_meetingroom_actuals_on_schedule_id` (`schedule_id`),
  KEY `index_gw_prop_extra_pm_meetingroom_actuals_on_schedule_prop_id` (`schedule_prop_id`),
  KEY `index_gw_prop_extra_pm_meetingroom_actuals_on_car_id` (`car_id`),
  KEY `index_gw_prop_extra_pm_meetingroom_actuals_on_driver_user_id` (`driver_user_id`),
  KEY `index_gw_prop_extra_pm_meetingroom_actuals_on_driver_group_id` (`driver_group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_prop_extra_pm_meetingroom_csvput_histories`
--

DROP TABLE IF EXISTS `gw_prop_extra_pm_meetingroom_csvput_histories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_prop_extra_pm_meetingroom_csvput_histories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `start_at` datetime DEFAULT NULL,
  `end_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `created_user` text,
  `created_group` text,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_prop_extra_pm_meetingroom_summaries`
--

DROP TABLE IF EXISTS `gw_prop_extra_pm_meetingroom_summaries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_prop_extra_pm_meetingroom_summaries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `summaries_at` datetime DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  `run_meter` int(11) DEFAULT NULL,
  `bill_amount` int(11) DEFAULT NULL,
  `bill_state` text,
  `updated_user` text,
  `updated_group` text,
  `created_user` text,
  `created_group` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_prop_extra_pm_meetingroom_summarize_histories`
--

DROP TABLE IF EXISTS `gw_prop_extra_pm_meetingroom_summarize_histories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_prop_extra_pm_meetingroom_summarize_histories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `start_at` datetime DEFAULT NULL,
  `end_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `created_user` text,
  `created_group` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_prop_extra_pm_messages`
--

DROP TABLE IF EXISTS `gw_prop_extra_pm_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_prop_extra_pm_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `body` text,
  `sort_no` int(11) DEFAULT NULL,
  `state` int(11) DEFAULT NULL,
  `prop_class_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_prop_extra_pm_remarks`
--

DROP TABLE IF EXISTS `gw_prop_extra_pm_remarks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_prop_extra_pm_remarks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `prop_class_id` int(11) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `sort_no` int(11) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_prop_extra_pm_renewal_groups`
--

DROP TABLE IF EXISTS `gw_prop_extra_pm_renewal_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_prop_extra_pm_renewal_groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `present_group_id` int(11) DEFAULT NULL,
  `present_group_code` varchar(255) DEFAULT NULL,
  `incoming_group_id` int(11) DEFAULT NULL,
  `incoming_group_name` text,
  `modified_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `present_group_name` text,
  `incoming_group_code` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_prop_extra_pm_rentcar_actuals`
--

DROP TABLE IF EXISTS `gw_prop_extra_pm_rentcar_actuals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_prop_extra_pm_rentcar_actuals` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `schedule_id` int(11) DEFAULT NULL,
  `schedule_prop_id` int(11) DEFAULT NULL,
  `car_id` int(11) DEFAULT NULL,
  `driver_user_id` int(11) DEFAULT NULL,
  `driver_user_code` varchar(255) DEFAULT NULL,
  `driver_user_name` varchar(255) DEFAULT NULL,
  `driver_group_id` int(11) DEFAULT NULL,
  `driver_group_code` varchar(255) DEFAULT NULL,
  `driver_group_name` varchar(255) DEFAULT NULL,
  `user_uname` text,
  `user_gname` text,
  `start_at` datetime DEFAULT NULL,
  `end_at` datetime DEFAULT NULL,
  `start_meter` int(11) DEFAULT NULL,
  `end_meter` int(11) DEFAULT NULL,
  `run_meter` int(11) DEFAULT NULL,
  `summaries_state` text,
  `bill_state` text,
  `toll_fee` int(11) DEFAULT NULL,
  `refuel_amount` int(11) DEFAULT NULL,
  `to_go` text,
  `title` text,
  `updated_user` text,
  `updated_group` text,
  `created_user` text,
  `created_group` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_gw_prop_extra_pm_rentcar_actuals_on_schedule_id` (`schedule_id`),
  KEY `index_gw_prop_extra_pm_rentcar_actuals_on_schedule_prop_id` (`schedule_prop_id`),
  KEY `index_gw_prop_extra_pm_rentcar_actuals_on_car_id` (`car_id`),
  KEY `index_gw_prop_extra_pm_rentcar_actuals_on_driver_user_id` (`driver_user_id`),
  KEY `index_gw_prop_extra_pm_rentcar_actuals_on_driver_group_id` (`driver_group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_prop_extra_pm_rentcar_csvput_histories`
--

DROP TABLE IF EXISTS `gw_prop_extra_pm_rentcar_csvput_histories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_prop_extra_pm_rentcar_csvput_histories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `start_at` datetime DEFAULT NULL,
  `end_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `created_user` text,
  `created_group` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_prop_extra_pm_rentcar_summaries`
--

DROP TABLE IF EXISTS `gw_prop_extra_pm_rentcar_summaries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_prop_extra_pm_rentcar_summaries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `summaries_at` datetime DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  `run_meter` int(11) DEFAULT NULL,
  `bill_amount` int(11) DEFAULT NULL,
  `bill_state` text,
  `updated_user` text,
  `updated_group` text,
  `created_user` text,
  `created_group` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_prop_extra_pm_rentcar_summarize_histories`
--

DROP TABLE IF EXISTS `gw_prop_extra_pm_rentcar_summarize_histories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_prop_extra_pm_rentcar_summarize_histories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `start_at` datetime DEFAULT NULL,
  `end_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `created_user` text,
  `created_group` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_prop_extra_pm_rentcar_unit_prices`
--

DROP TABLE IF EXISTS `gw_prop_extra_pm_rentcar_unit_prices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_prop_extra_pm_rentcar_unit_prices` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unit_price` int(11) DEFAULT NULL,
  `start_at` datetime DEFAULT NULL,
  `end_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `created_user` text,
  `created_group` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_prop_meetingroom_images`
--

DROP TABLE IF EXISTS `gw_prop_meetingroom_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_prop_meetingroom_images` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `idx` int(11) DEFAULT NULL,
  `note` varchar(255) DEFAULT NULL,
  `path` varchar(255) DEFAULT NULL,
  `orig_filename` varchar(255) DEFAULT NULL,
  `content_type` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_prop_meetingrooms`
--

DROP TABLE IF EXISTS `gw_prop_meetingrooms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_prop_meetingrooms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sort_no` int(11) DEFAULT NULL,
  `type_id` int(11) DEFAULT NULL,
  `delete_state` int(11) DEFAULT NULL,
  `reserved_state` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `position` varchar(255) DEFAULT NULL,
  `tel` varchar(255) DEFAULT NULL,
  `max_person` int(11) DEFAULT NULL,
  `max_tables` int(11) DEFAULT NULL,
  `max_chairs` int(11) DEFAULT NULL,
  `note` varchar(255) DEFAULT NULL,
  `extra_flag` varchar(255) DEFAULT NULL,
  `extra_data` text,
  `gid` varchar(255) DEFAULT NULL,
  `gname` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_prop_other_images`
--

DROP TABLE IF EXISTS `gw_prop_other_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_prop_other_images` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_prop_other_limits`
--

DROP TABLE IF EXISTS `gw_prop_other_limits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_prop_other_limits` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sort_no` int(11) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `gid` int(11) DEFAULT NULL,
  `limit` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_prop_other_roles`
--

DROP TABLE IF EXISTS `gw_prop_other_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_prop_other_roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `prop_id` int(11) DEFAULT NULL,
  `gid` int(11) DEFAULT NULL,
  `auth` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `prop_id` (`prop_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_prop_others`
--

DROP TABLE IF EXISTS `gw_prop_others`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_prop_others` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sort_no` int(11) DEFAULT NULL,
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_prop_rentcar_images`
--

DROP TABLE IF EXISTS `gw_prop_rentcar_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_prop_rentcar_images` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `idx` int(11) DEFAULT NULL,
  `note` varchar(255) DEFAULT NULL,
  `path` varchar(255) DEFAULT NULL,
  `orig_filename` varchar(255) DEFAULT NULL,
  `content_type` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_prop_rentcar_meters`
--

DROP TABLE IF EXISTS `gw_prop_rentcar_meters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_prop_rentcar_meters` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `travelled_km` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_prop_rentcars`
--

DROP TABLE IF EXISTS `gw_prop_rentcars`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_prop_rentcars` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sort_no` int(11) DEFAULT NULL,
  `car_model` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `type_id` int(11) DEFAULT NULL,
  `delete_state` int(11) DEFAULT NULL,
  `reserved_state` int(11) DEFAULT NULL,
  `register_no` varchar(255) DEFAULT NULL,
  `exhaust` varchar(255) DEFAULT NULL,
  `year_type` int(11) DEFAULT NULL,
  `comment` text,
  `extra_flag` varchar(255) DEFAULT NULL,
  `extra_data` text,
  `gid` varchar(255) DEFAULT NULL,
  `gname` varchar(255) DEFAULT NULL,
  `travelled_km` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_prop_types`
--

DROP TABLE IF EXISTS `gw_prop_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_prop_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `state` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `sort_no` int(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `restricted` int(11) DEFAULT NULL,
  `user_str` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=301 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_prop_types_messages`
--

DROP TABLE IF EXISTS `gw_prop_types_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_prop_types_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `state` int(11) DEFAULT NULL,
  `sort_no` int(11) DEFAULT NULL,
  `body` text,
  `type_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_prop_types_users`
--

DROP TABLE IF EXISTS `gw_prop_types_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_prop_types_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `user_name` text,
  `type_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_reminder_external_systems`
--

DROP TABLE IF EXISTS `gw_reminder_external_systems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_reminder_external_systems` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `user_id` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `sso_user_field` varchar(255) DEFAULT NULL,
  `sso_pass_field` varchar(255) DEFAULT NULL,
  `css_name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_reminder_externals`
--

DROP TABLE IF EXISTS `gw_reminder_externals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_reminder_externals` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `system` text,
  `data_id` text,
  `title` text,
  `updated` datetime DEFAULT NULL,
  `link` text,
  `author` text,
  `contributor` text,
  `member` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_reminders`
--

DROP TABLE IF EXISTS `gw_reminders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_reminders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `state` varchar(255) DEFAULT NULL,
  `sort_no` int(11) DEFAULT NULL,
  `title` text,
  `name` text,
  `css_name` varchar(255) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_user` text,
  `deleted_group` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  PRIMARY KEY (`id`),
  KEY `index_gw_reminders_on_state` (`state`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_rss_caches`
--

DROP TABLE IF EXISTS `gw_rss_caches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_rss_caches` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uri` text,
  `fetched` datetime DEFAULT NULL,
  `title` text,
  `published` datetime DEFAULT NULL,
  `link` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_rss_reader_caches`
--

DROP TABLE IF EXISTS `gw_rss_reader_caches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_rss_reader_caches` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_rss_readers`
--

DROP TABLE IF EXISTS `gw_rss_readers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_rss_readers` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_schedule_event_masters`
--

DROP TABLE IF EXISTS `gw_schedule_event_masters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_schedule_event_masters` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `edit_auth` int(11) DEFAULT NULL,
  `management_parent_gid` int(11) DEFAULT NULL,
  `management_gid` int(11) DEFAULT NULL,
  `management_uid` int(11) DEFAULT NULL,
  `range_class_id` int(11) DEFAULT NULL,
  `division_parent_gid` int(11) DEFAULT NULL,
  `division_gid` int(11) DEFAULT NULL,
  `creator_uid` int(11) DEFAULT NULL,
  `creator_gid` int(11) DEFAULT NULL,
  `updator_uid` int(11) DEFAULT NULL,
  `updator_gid` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_schedule_events`
--

DROP TABLE IF EXISTS `gw_schedule_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_schedule_events` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `schedule_id` int(11) DEFAULT NULL,
  `gid` int(11) DEFAULT NULL,
  `gcode` varchar(255) DEFAULT NULL,
  `gname` varchar(255) DEFAULT NULL,
  `parent_gid` int(11) DEFAULT NULL,
  `parent_gcode` varchar(255) DEFAULT NULL,
  `parent_gname` varchar(255) DEFAULT NULL,
  `uid` int(11) DEFAULT NULL,
  `ucode` varchar(255) DEFAULT NULL,
  `uname` varchar(255) DEFAULT NULL,
  `sort_id` int(11) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `event_word` text,
  `place` varchar(255) DEFAULT NULL,
  `st_at` datetime DEFAULT NULL,
  `ed_at` datetime DEFAULT NULL,
  `event_week` int(11) DEFAULT NULL,
  `week_approval` int(11) DEFAULT NULL,
  `week_approved_at` datetime DEFAULT NULL,
  `week_approval_uid` int(11) DEFAULT NULL,
  `week_approval_ucode` varchar(255) DEFAULT NULL,
  `week_approval_uname` varchar(255) DEFAULT NULL,
  `week_approval_gid` int(11) DEFAULT NULL,
  `week_approval_gcode` varchar(255) DEFAULT NULL,
  `week_approval_gname` varchar(255) DEFAULT NULL,
  `week_open` int(11) DEFAULT NULL,
  `week_opened_at` datetime DEFAULT NULL,
  `week_open_uid` int(11) DEFAULT NULL,
  `week_open_ucode` varchar(255) DEFAULT NULL,
  `week_open_uname` varchar(255) DEFAULT NULL,
  `week_open_gid` int(11) DEFAULT NULL,
  `week_open_gcode` varchar(255) DEFAULT NULL,
  `week_open_gname` varchar(255) DEFAULT NULL,
  `event_month` int(11) DEFAULT NULL,
  `month_approval` int(11) DEFAULT NULL,
  `month_approved_at` datetime DEFAULT NULL,
  `month_approval_uid` int(11) DEFAULT NULL,
  `month_approval_ucode` varchar(255) DEFAULT NULL,
  `month_approval_uname` varchar(255) DEFAULT NULL,
  `month_approval_gid` int(11) DEFAULT NULL,
  `month_approval_gcode` varchar(255) DEFAULT NULL,
  `month_approval_gname` varchar(255) DEFAULT NULL,
  `month_open` int(11) DEFAULT NULL,
  `month_opened_at` datetime DEFAULT NULL,
  `month_open_uid` int(11) DEFAULT NULL,
  `month_open_ucode` varchar(255) DEFAULT NULL,
  `month_open_uname` varchar(255) DEFAULT NULL,
  `month_open_gid` int(11) DEFAULT NULL,
  `month_open_gcode` varchar(255) DEFAULT NULL,
  `month_open_gname` varchar(255) DEFAULT NULL,
  `allday` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_gw_schedule_events_on_schedule_id` (`schedule_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_schedule_options`
--

DROP TABLE IF EXISTS `gw_schedule_options`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_schedule_options` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `schedule_id` int(11) DEFAULT NULL,
  `kind` varchar(50) DEFAULT NULL,
  `body` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_schedule_props`
--

DROP TABLE IF EXISTS `gw_schedule_props`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_schedule_props` (
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
  KEY `prop_id` (`prop_id`),
  KEY `index_gw_schedule_props_on_schedule_id` (`schedule_id`),
  KEY `index_gw_schedule_props_on_prop_type` (`prop_type`),
  KEY `index_gw_schedule_props_on_prop_id_and_prop_type` (`prop_id`,`prop_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- --------------------------------------------------------

DROP TABLE IF EXISTS `gw_schedule_prop_temporaries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;

CREATE TABLE `gw_schedule_prop_temporaries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tmp_id` varchar(255) DEFAULT NULL,
  `prop_type` varchar(255) DEFAULT NULL,
  `prop_id` int(11) DEFAULT NULL,
  `st_at` datetime DEFAULT NULL,
  `ed_at` datetime DEFAULT NULL,
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
-- --------------------------------------------------------



/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_schedule_public_roles`
--

DROP TABLE IF EXISTS `gw_schedule_public_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_schedule_public_roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `schedule_id` int(11) DEFAULT NULL,
  `class_id` int(11) DEFAULT NULL,
  `uid` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_gw_schedule_public_roles_on_schedule_id` (`schedule_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_schedule_repeats`
--

DROP TABLE IF EXISTS `gw_schedule_repeats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_schedule_repeats` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_schedule_todos`
--

DROP TABLE IF EXISTS `gw_schedule_todos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_schedule_todos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `schedule_id` int(11) DEFAULT NULL,
  `st_at` datetime DEFAULT NULL,
  `ed_at` datetime DEFAULT NULL,
  `todo_ed_at_indefinite` int(11) NOT NULL DEFAULT '0',
  `is_finished` int(11) DEFAULT '0',
  `todo_st_at_id` int(11) DEFAULT '0',
  `todo_ed_at_id` int(11) DEFAULT '0',
  `todo_repeat_time_id` int(11) DEFAULT '0',
  `finished_at` datetime DEFAULT NULL,
  `finished_uid` int(11) DEFAULT NULL,
  `finished_gid` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `todo_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_gw_schedule_todos_on_schedule_id` (`schedule_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_schedule_users`
--

DROP TABLE IF EXISTS `gw_schedule_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_schedule_users` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_schedules`
--

DROP TABLE IF EXISTS `gw_schedules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_schedules` (
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
  `todo` int(11) DEFAULT '0',
  `allday` int(11) DEFAULT NULL,
  `guide_state` int(11) DEFAULT NULL,
  `guide_place_id` int(11) DEFAULT NULL,
  `guide_place` text,
  `guide_ed_at` int(11) DEFAULT NULL,
  `event_week` int(11) DEFAULT NULL,
  `event_month` int(11) DEFAULT NULL,
  `tmp_id` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `st_at` (`st_at`,`ed_at`),
  KEY `schedule_repeat_id` (`schedule_repeat_id`),
  KEY `ed_at` (`ed_at`),
  KEY `index_gw_schedules_on_schedule_parent_id` (`schedule_parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_section_admin_master_func_names`
--

DROP TABLE IF EXISTS `gw_section_admin_master_func_names`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_section_admin_master_func_names` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `func_name` text,
  `name` text,
  `state` text,
  `sort_no` int(11) DEFAULT NULL,
  `creator_uid` int(11) DEFAULT NULL,
  `creator_gid` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updator_uid` int(11) DEFAULT NULL,
  `updator_gid` int(11) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_uid` int(11) DEFAULT NULL,
  `deleted_gid` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_section_admin_masters`
--

DROP TABLE IF EXISTS `gw_section_admin_masters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_section_admin_masters` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_todos`
--

DROP TABLE IF EXISTS `gw_todos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_todos` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_user_properties`
--

DROP TABLE IF EXISTS `gw_user_properties`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_user_properties` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `class_id` int(11) DEFAULT NULL,
  `uid` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `type_name` varchar(255) DEFAULT NULL,
  `options` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_gw_user_properties_searches` (`class_id`,`uid`,`name`,`type_name`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_workflow_controls`
--

DROP TABLE IF EXISTS `gw_workflow_controls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_workflow_controls` (
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_workflow_custom_route_steps`
--

DROP TABLE IF EXISTS `gw_workflow_custom_route_steps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_workflow_custom_route_steps` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `custom_route_id` int(11) DEFAULT NULL,
  `number` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_workflow_custom_route_users`
--

DROP TABLE IF EXISTS `gw_workflow_custom_route_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_workflow_custom_route_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `step_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `user_name` text,
  `user_gname` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_workflow_custom_routes`
--

DROP TABLE IF EXISTS `gw_workflow_custom_routes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_workflow_custom_routes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `owner_uid` int(11) DEFAULT NULL,
  `sort_no` int(11) DEFAULT NULL,
  `state` text,
  `name` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_workflow_docs`
--

DROP TABLE IF EXISTS `gw_workflow_docs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_workflow_docs` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_workflow_itemdeletes`
--

DROP TABLE IF EXISTS `gw_workflow_itemdeletes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_workflow_itemdeletes` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_workflow_mail_settings`
--

DROP TABLE IF EXISTS `gw_workflow_mail_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_workflow_mail_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `notifying` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_workflow_route_steps`
--

DROP TABLE IF EXISTS `gw_workflow_route_steps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_workflow_route_steps` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `doc_id` int(11) DEFAULT NULL,
  `number` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_workflow_route_users`
--

DROP TABLE IF EXISTS `gw_workflow_route_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_workflow_route_users` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_year_fiscal_jps`
--

DROP TABLE IF EXISTS `gw_year_fiscal_jps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_year_fiscal_jps` (
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
) ENGINE=InnoDB AUTO_INCREMENT=146 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gw_year_mark_jps`
--

DROP TABLE IF EXISTS `gw_year_mark_jps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gw_year_mark_jps` (
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
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwbbs_adms`
--

DROP TABLE IF EXISTS `gwbbs_adms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwbbs_adms` (
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
  PRIMARY KEY (`id`),
  KEY `index_gwbbs_adms_on_title_id` (`title_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwbbs_categories`
--

DROP TABLE IF EXISTS `gwbbs_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwbbs_categories` (
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
  `serial_no` int(11) DEFAULT NULL,
  `migrated` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_gwbbs_categories_on_title_id` (`title_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwbbs_comments`
--

DROP TABLE IF EXISTS `gwbbs_comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwbbs_comments` (
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
  `serial_no` int(11) DEFAULT NULL,
  `migrated` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_gwbbs_comments_on_title_id` (`title_id`),
  KEY `index_gwbbs_comments_on_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwbbs_controls`
--

DROP TABLE IF EXISTS `gwbbs_controls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwbbs_controls` (
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
  `icon_filename` text,
  `icon_position` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_gwbbs_controls_on_notification` (`notification`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwbbs_db_files`
--

DROP TABLE IF EXISTS `gwbbs_db_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwbbs_db_files` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title_id` int(11) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `data` longblob,
  `serial_no` int(11) DEFAULT NULL,
  `migrated` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_gwbbs_db_files_on_title_id` (`title_id`),
  KEY `index_gwbbs_db_files_on_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwbbs_docs`
--

DROP TABLE IF EXISTS `gwbbs_docs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwbbs_docs` (
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
  `serial_no` int(11) DEFAULT NULL,
  `migrated` int(11) DEFAULT NULL,
  `wiki` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_gwbbs_docs_on_title_id` (`title_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwbbs_files`
--

DROP TABLE IF EXISTS `gwbbs_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwbbs_files` (
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
  `serial_no` int(11) DEFAULT NULL,
  `migrated` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_gwbbs_files_on_title_id` (`title_id`),
  KEY `index_gwbbs_files_on_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwbbs_images`
--

DROP TABLE IF EXISTS `gwbbs_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwbbs_images` (
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
  `serial_no` int(11) DEFAULT NULL,
  `migrated` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_gwbbs_images_on_title_id` (`title_id`),
  KEY `index_gwbbs_images_on_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwbbs_itemdeletes`
--

DROP TABLE IF EXISTS `gwbbs_itemdeletes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwbbs_itemdeletes` (
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwbbs_itemimages`
--

DROP TABLE IF EXISTS `gwbbs_itemimages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwbbs_itemimages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type_name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `title_id` int(11) DEFAULT NULL,
  `filename` text,
  `width` int(11) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwbbs_recognizers`
--

DROP TABLE IF EXISTS `gwbbs_recognizers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwbbs_recognizers` (
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
  `serial_no` int(11) DEFAULT NULL,
  `migrated` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_gwbbs_recognizers_on_title_id` (`title_id`),
  KEY `index_gwbbs_recognizers_on_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwbbs_roles`
--

DROP TABLE IF EXISTS `gwbbs_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwbbs_roles` (
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
  PRIMARY KEY (`id`),
  KEY `index_gwbbs_roles_on_title_id` (`title_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwbbs_themes`
--

DROP TABLE IF EXISTS `gwbbs_themes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwbbs_themes` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwboard_bgcolors`
--

DROP TABLE IF EXISTS `gwboard_bgcolors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwboard_bgcolors` (
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
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwboard_images`
--

DROP TABLE IF EXISTS `gwboard_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwboard_images` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwboard_maps`
--

DROP TABLE IF EXISTS `gwboard_maps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwboard_maps` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwboard_renewal_groups`
--

DROP TABLE IF EXISTS `gwboard_renewal_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwboard_renewal_groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `present_group_id` int(11) DEFAULT NULL,
  `present_group_code` varchar(255) DEFAULT NULL,
  `present_group_name` text,
  `incoming_group_id` int(11) DEFAULT NULL,
  `incoming_group_code` varchar(255) DEFAULT NULL,
  `incoming_group_name` text,
  `start_date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwboard_syntheses`
--

DROP TABLE IF EXISTS `gwboard_syntheses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwboard_syntheses` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwboard_synthesetups`
--

DROP TABLE IF EXISTS `gwboard_synthesetups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwboard_synthesetups` (
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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwboard_themes`
--

DROP TABLE IF EXISTS `gwboard_themes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwboard_themes` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwcircular_adms`
--

DROP TABLE IF EXISTS `gwcircular_adms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwcircular_adms` (
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
  PRIMARY KEY (`id`),
  KEY `index_gwcircular_adms_on_title_id` (`title_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwcircular_controls`
--

DROP TABLE IF EXISTS `gwcircular_controls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwcircular_controls` (
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwcircular_custom_groups`
--

DROP TABLE IF EXISTS `gwcircular_custom_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwcircular_custom_groups` (
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
  PRIMARY KEY (`id`),
  KEY `index_gwcircular_custom_groups_on_owner_uid` (`owner_uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwcircular_docs`
--

DROP TABLE IF EXISTS `gwcircular_docs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwcircular_docs` (
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
  `wiki` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `parent_id` (`parent_id`),
  KEY `index_gwcircular_docs_on_title_id` (`title_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwcircular_files`
--

DROP TABLE IF EXISTS `gwcircular_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwcircular_files` (
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
  PRIMARY KEY (`id`),
  KEY `index_gwcircular_files_on_title_id` (`title_id`),
  KEY `index_gwcircular_files_on_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwcircular_itemdeletes`
--

DROP TABLE IF EXISTS `gwcircular_itemdeletes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwcircular_itemdeletes` (
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwcircular_roles`
--

DROP TABLE IF EXISTS `gwcircular_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwcircular_roles` (
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
  PRIMARY KEY (`id`),
  KEY `index_gwcircular_roles_on_title_id` (`title_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwfaq_adms`
--

DROP TABLE IF EXISTS `gwfaq_adms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwfaq_adms` (
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
  PRIMARY KEY (`id`),
  KEY `index_gwfaq_adms_on_title_id` (`title_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwfaq_categories`
--

DROP TABLE IF EXISTS `gwfaq_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwfaq_categories` (
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
  `serial_no` int(11) DEFAULT NULL,
  `migrated` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_gwfaq_categories_on_title_id` (`title_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwfaq_controls`
--

DROP TABLE IF EXISTS `gwfaq_controls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwfaq_controls` (
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
  PRIMARY KEY (`id`),
  KEY `index_gwfaq_controls_on_notification` (`notification`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwfaq_db_files`
--

DROP TABLE IF EXISTS `gwfaq_db_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwfaq_db_files` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title_id` int(11) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `data` longblob,
  `serial_no` int(11) DEFAULT NULL,
  `migrated` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_gwfaq_db_files_on_title_id` (`title_id`),
  KEY `index_gwfaq_db_files_on_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwfaq_docs`
--

DROP TABLE IF EXISTS `gwfaq_docs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwfaq_docs` (
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
  `attachmentfile` int(11) DEFAULT NULL,
  `serial_no` int(11) DEFAULT NULL,
  `migrated` int(11) DEFAULT NULL,
  `wiki` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwfaq_files`
--

DROP TABLE IF EXISTS `gwfaq_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwfaq_files` (
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
  `serial_no` int(11) DEFAULT NULL,
  `migrated` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_gwfaq_files_on_title_id` (`title_id`),
  KEY `index_gwfaq_files_on_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwfaq_images`
--

DROP TABLE IF EXISTS `gwfaq_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwfaq_images` (
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
  `serial_no` int(11) DEFAULT NULL,
  `migrated` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_gwfaq_images_on_title_id` (`title_id`),
  KEY `index_gwfaq_images_on_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwfaq_recognizers`
--

DROP TABLE IF EXISTS `gwfaq_recognizers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwfaq_recognizers` (
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
  `serial_no` int(11) DEFAULT NULL,
  `migrated` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_gwfaq_recognizers_on_title_id` (`title_id`),
  KEY `index_gwfaq_recognizers_on_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwfaq_roles`
--

DROP TABLE IF EXISTS `gwfaq_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwfaq_roles` (
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
  PRIMARY KEY (`id`),
  KEY `index_gwfaq_roles_on_title_id` (`title_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwmonitor_base_files`
--

DROP TABLE IF EXISTS `gwmonitor_base_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwmonitor_base_files` (
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
  PRIMARY KEY (`id`),
  KEY `index_gwmonitor_base_files_on_title_id` (`title_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwmonitor_controls`
--

DROP TABLE IF EXISTS `gwmonitor_controls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwmonitor_controls` (
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
  `wiki` int(11) DEFAULT NULL,
  `form_configs` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwmonitor_custom_groups`
--

DROP TABLE IF EXISTS `gwmonitor_custom_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwmonitor_custom_groups` (
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
  PRIMARY KEY (`id`),
  KEY `index_gwmonitor_custom_groups_on_owner_uid` (`owner_uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwmonitor_custom_user_groups`
--

DROP TABLE IF EXISTS `gwmonitor_custom_user_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwmonitor_custom_user_groups` (
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
  PRIMARY KEY (`id`),
  KEY `index_gwmonitor_custom_user_groups_on_owner_uid` (`owner_uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwmonitor_docs`
--

DROP TABLE IF EXISTS `gwmonitor_docs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwmonitor_docs` (
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
  PRIMARY KEY (`id`),
  KEY `index_gwmonitor_docs_on_title_id` (`title_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwmonitor_files`
--

DROP TABLE IF EXISTS `gwmonitor_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwmonitor_files` (
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
  PRIMARY KEY (`id`),
  KEY `index_gwmonitor_files_on_title_id` (`title_id`),
  KEY `index_gwmonitor_files_on_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwmonitor_forms`
--

DROP TABLE IF EXISTS `gwmonitor_forms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwmonitor_forms` (
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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwmonitor_itemdeletes`
--

DROP TABLE IF EXISTS `gwmonitor_itemdeletes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwmonitor_itemdeletes` (
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwqa_adms`
--

DROP TABLE IF EXISTS `gwqa_adms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwqa_adms` (
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
  PRIMARY KEY (`id`),
  KEY `index_gwqa_adms_on_title_id` (`title_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwqa_categories`
--

DROP TABLE IF EXISTS `gwqa_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwqa_categories` (
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
  `serial_no` int(11) DEFAULT NULL,
  `migrated` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_gwqa_categories_on_title_id` (`title_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwqa_controls`
--

DROP TABLE IF EXISTS `gwqa_controls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwqa_controls` (
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
  PRIMARY KEY (`id`),
  KEY `index_gwqa_controls_on_notification` (`notification`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwqa_db_files`
--

DROP TABLE IF EXISTS `gwqa_db_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwqa_db_files` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title_id` int(11) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `data` longblob,
  `serial_no` int(11) DEFAULT NULL,
  `migrated` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_gwqa_db_files_on_title_id` (`title_id`),
  KEY `index_gwqa_db_files_on_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwqa_docs`
--

DROP TABLE IF EXISTS `gwqa_docs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwqa_docs` (
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
  `expiry_date` datetime DEFAULT NULL,
  `attachmentfile` int(11) DEFAULT NULL,
  `answer_count` int(11) DEFAULT NULL,
  `inpfld_001` text,
  `inpfld_002` text,
  `latest_answer` datetime DEFAULT NULL,
  `serial_no` int(11) DEFAULT NULL,
  `migrated` int(11) DEFAULT NULL,
  `wiki` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_gwqa_docs_on_title_id` (`title_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwqa_files`
--

DROP TABLE IF EXISTS `gwqa_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwqa_files` (
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
  `serial_no` int(11) DEFAULT NULL,
  `migrated` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_gwqa_files_on_title_id` (`title_id`),
  KEY `index_gwqa_files_on_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwqa_images`
--

DROP TABLE IF EXISTS `gwqa_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwqa_images` (
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
  `serial_no` int(11) DEFAULT NULL,
  `migrated` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_gwqa_images_on_title_id` (`title_id`),
  KEY `index_gwqa_images_on_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwqa_recognizers`
--

DROP TABLE IF EXISTS `gwqa_recognizers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwqa_recognizers` (
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
  `serial_no` int(11) DEFAULT NULL,
  `migrated` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_gwqa_recognizers_on_title_id` (`title_id`),
  KEY `index_gwqa_recognizers_on_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwqa_roles`
--

DROP TABLE IF EXISTS `gwqa_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwqa_roles` (
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
  PRIMARY KEY (`id`),
  KEY `index_gwqa_roles_on_title_id` (`title_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_capacityunitsets`
--

DROP TABLE IF EXISTS `gwsub_capacityunitsets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_capacityunitsets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code_int` int(11) DEFAULT NULL,
  `code` text,
  `name` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  PRIMARY KEY (`id`),
  KEY `index_gwsub_capacityunitsets_on_code_int` (`code_int`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_externalmediakinds`
--

DROP TABLE IF EXISTS `gwsub_externalmediakinds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_externalmediakinds` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sort_order_int` int(11) DEFAULT NULL,
  `sort_order` text,
  `kind` text,
  `name` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  PRIMARY KEY (`id`),
  KEY `index_gwsub_externalmediakinds_on_sort_order_int` (`sort_order_int`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_externalmedias`
--

DROP TABLE IF EXISTS `gwsub_externalmedias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_externalmedias` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `new_registedno` int(11) DEFAULT NULL,
  `section_id` int(11) DEFAULT NULL,
  `section_code` varchar(255) DEFAULT NULL,
  `section_name` text,
  `registedno` text,
  `externalmediakind_id` int(11) DEFAULT NULL,
  `externalmediakind_name` varchar(255) DEFAULT NULL,
  `registed_seq` text,
  `registed_at` datetime DEFAULT NULL,
  `equipmentname` text,
  `user_section_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `user` varchar(255) DEFAULT NULL,
  `categories` int(11) DEFAULT NULL,
  `ending_at` datetime DEFAULT NULL,
  `remarks` text,
  `last_updated_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  PRIMARY KEY (`id`),
  KEY `index_gwsub_externalmedias_on_section_id` (`section_id`),
  KEY `index_gwsub_externalmedias_on_externalmediakind_id` (`externalmediakind_id`),
  KEY `index_gwsub_externalmedias_on_user_section_id` (`user_section_id`),
  KEY `index_gwsub_externalmedias_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_externalusbs`
--

DROP TABLE IF EXISTS `gwsub_externalusbs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_externalusbs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `new_registedno` int(11) DEFAULT NULL,
  `section_id` int(11) DEFAULT NULL,
  `section_code` varchar(255) DEFAULT NULL,
  `section_name` text,
  `registedno` text,
  `externalmediakind_id` int(11) DEFAULT NULL,
  `registed_at` datetime DEFAULT NULL,
  `equipmentname` text,
  `capacity` text,
  `capacityunit_id` int(11) DEFAULT NULL,
  `sendstate` text,
  `user_section_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `user` varchar(255) DEFAULT NULL,
  `categories` int(11) DEFAULT NULL,
  `ending_at` datetime DEFAULT NULL,
  `remarks` text,
  `last_updated_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  PRIMARY KEY (`id`),
  KEY `index_gwsub_externalusbs_on_section_id` (`section_id`),
  KEY `index_gwsub_externalusbs_on_externalmediakind_id` (`externalmediakind_id`),
  KEY `index_gwsub_externalusbs_on_capacityunit_id` (`capacityunit_id`),
  KEY `index_gwsub_externalusbs_on_user_section_id` (`user_section_id`),
  KEY `index_gwsub_externalusbs_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb00_conference_managers`
--

DROP TABLE IF EXISTS `gwsub_sb00_conference_managers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb00_conference_managers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `controler` text,
  `controler_title` text,
  `memo_str` text,
  `fyear_id` int(11) DEFAULT NULL,
  `fyear_markjp` text,
  `group_id` int(11) DEFAULT NULL,
  `group_code` text,
  `group_name` text,
  `user_id` int(11) DEFAULT NULL,
  `user_code` text,
  `user_name` text,
  `official_title_id` int(11) DEFAULT NULL,
  `official_title_name` text,
  `send_state` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb00_conference_references`
--

DROP TABLE IF EXISTS `gwsub_sb00_conference_references`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb00_conference_references` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fyear_id` int(11) DEFAULT NULL,
  `fyear_markjp` text,
  `kind_code` text,
  `title` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  `kind_name` text,
  `group_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb00_conference_section_manager_names`
--

DROP TABLE IF EXISTS `gwsub_sb00_conference_section_manager_names`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb00_conference_section_manager_names` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fyear_id` int(11) DEFAULT NULL,
  `markjp` text,
  `state` varchar(255) DEFAULT NULL,
  `parent_gid` int(11) DEFAULT NULL,
  `gid` int(11) DEFAULT NULL,
  `g_sort_no` int(11) DEFAULT NULL,
  `g_code` varchar(255) DEFAULT NULL,
  `g_name` text,
  `manager_name` text,
  `deleted_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb01_training_files`
--

DROP TABLE IF EXISTS `gwsub_sb01_training_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb01_training_files` (
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
  PRIMARY KEY (`id`),
  KEY `index_gwsub_sb01_training_files_on_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb01_training_guides`
--

DROP TABLE IF EXISTS `gwsub_sb01_training_guides`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb01_training_guides` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb01_training_schedule_conditions`
--

DROP TABLE IF EXISTS `gwsub_sb01_training_schedule_conditions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb01_training_schedule_conditions` (
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
  PRIMARY KEY (`id`),
  KEY `index_gwsub_sb01_training_schedule_conditions_on_training_id` (`training_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb01_training_schedule_members`
--

DROP TABLE IF EXISTS `gwsub_sb01_training_schedule_members`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb01_training_schedule_members` (
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
  PRIMARY KEY (`id`),
  KEY `index_gwsub_sb01_training_schedule_members_on_training_id` (`training_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb01_training_schedule_props`
--

DROP TABLE IF EXISTS `gwsub_sb01_training_schedule_props`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb01_training_schedule_props` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb01_training_schedules`
--

DROP TABLE IF EXISTS `gwsub_sb01_training_schedules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb01_training_schedules` (
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
  PRIMARY KEY (`id`),
  KEY `index_gwsub_sb01_training_schedules_on_training_id` (`training_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb01_trainings`
--

DROP TABLE IF EXISTS `gwsub_sb01_trainings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb01_trainings` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb04_check_assignedjobs`
--

DROP TABLE IF EXISTS `gwsub_sb04_check_assignedjobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb04_check_assignedjobs` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb04_check_officialtitles`
--

DROP TABLE IF EXISTS `gwsub_sb04_check_officialtitles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb04_check_officialtitles` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb04_check_sections`
--

DROP TABLE IF EXISTS `gwsub_sb04_check_sections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb04_check_sections` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb04_check_stafflists`
--

DROP TABLE IF EXISTS `gwsub_sb04_check_stafflists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb04_check_stafflists` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb04_editable_dates`
--

DROP TABLE IF EXISTS `gwsub_sb04_editable_dates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb04_editable_dates` (
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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb04_limit_settings`
--

DROP TABLE IF EXISTS `gwsub_sb04_limit_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb04_limit_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type_name` varchar(255) DEFAULT NULL,
  `limit` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb04_seating_lists`
--

DROP TABLE IF EXISTS `gwsub_sb04_seating_lists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb04_seating_lists` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb04_settings`
--

DROP TABLE IF EXISTS `gwsub_sb04_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb04_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `type_name` varchar(255) DEFAULT NULL,
  `data` text,
  `updated_user` text,
  `updated_group` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb04_year_copy_logs`
--

DROP TABLE IF EXISTS `gwsub_sb04_year_copy_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb04_year_copy_logs` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb04assignedjobs`
--

DROP TABLE IF EXISTS `gwsub_sb04assignedjobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb04assignedjobs` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb04helps`
--

DROP TABLE IF EXISTS `gwsub_sb04helps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb04helps` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb04officialtitles`
--

DROP TABLE IF EXISTS `gwsub_sb04officialtitles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb04officialtitles` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb04sections`
--

DROP TABLE IF EXISTS `gwsub_sb04sections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb04sections` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb04stafflists`
--

DROP TABLE IF EXISTS `gwsub_sb04stafflists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb04stafflists` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb05_db_files`
--

DROP TABLE IF EXISTS `gwsub_sb05_db_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb05_db_files` (
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
  `file_state` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb05_desired_date_conditions`
--

DROP TABLE IF EXISTS `gwsub_sb05_desired_date_conditions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb05_desired_date_conditions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `media_id` int(11) DEFAULT NULL,
  `w1` tinyint(1) DEFAULT '0',
  `w2` tinyint(1) DEFAULT '0',
  `w3` tinyint(1) DEFAULT '0',
  `w4` tinyint(1) DEFAULT '0',
  `w5` tinyint(1) DEFAULT '0',
  `d0` tinyint(1) DEFAULT '0',
  `d1` tinyint(1) DEFAULT '0',
  `d2` tinyint(1) DEFAULT '0',
  `d3` tinyint(1) DEFAULT '0',
  `d4` tinyint(1) DEFAULT '0',
  `d5` tinyint(1) DEFAULT '0',
  `d6` tinyint(1) DEFAULT '0',
  `st_at` datetime DEFAULT NULL,
  `ed_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb05_desired_dates`
--

DROP TABLE IF EXISTS `gwsub_sb05_desired_dates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb05_desired_dates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `media_id` int(11) DEFAULT NULL,
  `desired_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  `media_code` text,
  `weekday` text,
  `monthly` text,
  `edit_limit_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb05_files`
--

DROP TABLE IF EXISTS `gwsub_sb05_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb05_files` (
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
  `file_state` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb05_media_types`
--

DROP TABLE IF EXISTS `gwsub_sb05_media_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb05_media_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `media_code` int(11) DEFAULT NULL,
  `media_name` text,
  `categories_code` int(11) DEFAULT NULL,
  `categories_name` text,
  `max_size` int(11) DEFAULT NULL,
  `state` int(11) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb05_notices`
--

DROP TABLE IF EXISTS `gwsub_sb05_notices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb05_notices` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `media_id` int(11) DEFAULT NULL,
  `media_code` int(11) DEFAULT NULL,
  `media_name` text,
  `categories_code` int(11) DEFAULT NULL,
  `categories_name` text,
  `sample` text,
  `remarks` text,
  `form_templates` text,
  `admin_remarks` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb05_recognizers`
--

DROP TABLE IF EXISTS `gwsub_sb05_recognizers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb05_recognizers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `recognized_at` text,
  `mode` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb05_requests`
--

DROP TABLE IF EXISTS `gwsub_sb05_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb05_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sb05_users_id` int(11) DEFAULT NULL,
  `user_code` text,
  `user_name` text,
  `user_display` text,
  `org_code` text,
  `org_name` text,
  `org_display` text,
  `telephone` text,
  `media_id` int(11) DEFAULT NULL,
  `media_code` int(11) DEFAULT NULL,
  `media_name` text,
  `categories_code` int(11) DEFAULT NULL,
  `categories_name` text,
  `start_at` datetime DEFAULT NULL,
  `end_at` datetime DEFAULT NULL,
  `title` text,
  `body1` text,
  `magazine_url` text,
  `magazine_url_mobile` text,
  `mm_attachiment` int(11) DEFAULT NULL,
  `img` text,
  `contract_at` datetime DEFAULT NULL,
  `base_at` datetime DEFAULT NULL,
  `magazine_state` text,
  `r_state` text,
  `m_state` text,
  `admin_remarks` text,
  `notes_imported` text,
  `notes_updated_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  `mm_image_state` text,
  `attaches_file` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb05_users`
--

DROP TABLE IF EXISTS `gwsub_sb05_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb05_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `org_id` int(11) DEFAULT NULL,
  `user_code` text,
  `user_name` text,
  `user_display` text,
  `org_code` text,
  `org_name` text,
  `org_display` text,
  `telephone` text,
  `notes_imported` text,
  `notes_updated_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb06_assigned_conf_categories`
--

DROP TABLE IF EXISTS `gwsub_sb06_assigned_conf_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb06_assigned_conf_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cat_sort_no` int(11) DEFAULT NULL,
  `cat_code` text,
  `cat_name` text,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `select_list` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb06_assigned_conf_groups`
--

DROP TABLE IF EXISTS `gwsub_sb06_assigned_conf_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb06_assigned_conf_groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fyear_id` int(11) DEFAULT NULL,
  `fyear_markjp` text,
  `group_id` int(11) DEFAULT NULL,
  `group_code` text,
  `group_name` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  `categories_id` int(11) DEFAULT NULL,
  `cat_sort_no` int(11) DEFAULT NULL,
  `cat_code` text,
  `cat_name` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb06_assigned_conf_items`
--

DROP TABLE IF EXISTS `gwsub_sb06_assigned_conf_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb06_assigned_conf_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fyear_id` int(11) DEFAULT NULL,
  `fyear_markjp` text,
  `conf_kind_id` int(11) DEFAULT NULL,
  `item_sort_no` int(11) DEFAULT NULL,
  `item_title` text,
  `item_max_count` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `select_list` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb06_assigned_conf_kinds`
--

DROP TABLE IF EXISTS `gwsub_sb06_assigned_conf_kinds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb06_assigned_conf_kinds` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fyear_id` int(11) DEFAULT NULL,
  `fyear_markjp` text,
  `conf_cat_id` int(11) DEFAULT NULL,
  `conf_kind_code` text,
  `conf_kind_name` text,
  `conf_kind_sort_no` int(11) DEFAULT NULL,
  `conf_menu_name` text,
  `conf_to_name` text,
  `conf_title` text,
  `conf_form_no` text,
  `conf_max_count` int(11) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  `select_list` int(11) DEFAULT NULL,
  `conf_body` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb06_assigned_conference_members`
--

DROP TABLE IF EXISTS `gwsub_sb06_assigned_conference_members`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb06_assigned_conference_members` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_user_id` int(11) DEFAULT NULL,
  `created_group` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_user_id` int(11) DEFAULT NULL,
  `updated_group` text,
  `conference_id` int(11) DEFAULT NULL,
  `state` text,
  `categories_id` int(11) DEFAULT NULL,
  `cat_sort_no` int(11) DEFAULT NULL,
  `cat_code` text,
  `cat_name` text,
  `conf_kind_id` int(11) DEFAULT NULL,
  `conf_kind_sort_no` int(11) DEFAULT NULL,
  `conf_kind_name` text,
  `fyear_id` int(11) DEFAULT NULL,
  `fyear_markjp` text,
  `fyear_namejp` text,
  `conf_mark` text,
  `conf_no` text,
  `conf_group_id` int(11) DEFAULT NULL,
  `conf_group_code` text,
  `conf_group_name` text,
  `conf_at` datetime DEFAULT NULL,
  `section_manager_id` int(11) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  `group_code` text,
  `group_name` text,
  `group_name_display` text,
  `conf_kind_place` text,
  `conf_item_id` int(11) DEFAULT NULL,
  `conf_item_sort_no` int(11) DEFAULT NULL,
  `conf_item_title` text,
  `work_name` text,
  `work_kind` text,
  `official_title_id` int(11) DEFAULT NULL,
  `official_title_name` text,
  `sort_no` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `user_name` text,
  `extension` text,
  `user_mail` text,
  `user_job_name` text,
  `start_at` datetime DEFAULT NULL,
  `remarks` text,
  `user_section_id` int(11) DEFAULT NULL,
  `user_section_name` text,
  `user_section_sort_no` int(11) DEFAULT NULL,
  `main_group_id` int(11) DEFAULT NULL,
  `main_group_name` text,
  `main_group_sort_no` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb06_assigned_conferences`
--

DROP TABLE IF EXISTS `gwsub_sb06_assigned_conferences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb06_assigned_conferences` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_user_id` int(11) DEFAULT NULL,
  `created_group` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_user_id` int(11) DEFAULT NULL,
  `updated_group` text,
  `state` text,
  `categories_id` int(11) DEFAULT NULL,
  `cat_sort_no` int(11) DEFAULT NULL,
  `cat_code` text,
  `cat_name` text,
  `conf_kind_id` int(11) DEFAULT NULL,
  `conf_kind_sort_no` int(11) DEFAULT NULL,
  `conf_kind_name` text,
  `fyear_id` int(11) DEFAULT NULL,
  `fyear_markjp` text,
  `fyear_namejp` text,
  `conf_mark` text,
  `conf_no` text,
  `conf_group_id` int(11) DEFAULT NULL,
  `conf_group_code` text,
  `conf_group_name` text,
  `conf_at` datetime DEFAULT NULL,
  `section_manager_id` int(11) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  `group_code` text,
  `group_name` text,
  `group_name_display` text,
  `conf_kind_place` text,
  `conf_item_id` int(11) DEFAULT NULL,
  `conf_item_sort_no` int(11) DEFAULT NULL,
  `conf_item_title` text,
  `work_name` text,
  `work_kind` text,
  `official_title_id` int(11) DEFAULT NULL,
  `official_title_name` text,
  `sort_no` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `user_name` text,
  `extension` text,
  `user_mail` text,
  `user_job_name` text,
  `start_at` datetime DEFAULT NULL,
  `remarks` text,
  `user_section_id` int(11) DEFAULT NULL,
  `user_section_name` text,
  `user_section_sort_no` int(11) DEFAULT NULL,
  `main_group_id` int(11) DEFAULT NULL,
  `main_group_name` text,
  `main_group_sort_no` int(11) DEFAULT NULL,
  `admin_group_id` int(11) DEFAULT NULL,
  `admin_group_code` text,
  `admin_group_name` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb06_assigned_helps`
--

DROP TABLE IF EXISTS `gwsub_sb06_assigned_helps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb06_assigned_helps` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `help_kind` int(11) DEFAULT NULL,
  `conf_cat_id` int(11) DEFAULT NULL,
  `conf_kind_sort_no` int(11) DEFAULT NULL,
  `conf_kind_id` int(11) DEFAULT NULL,
  `fyear_id` int(11) DEFAULT NULL,
  `fyear_markjp` text,
  `conf_group_id` int(11) DEFAULT NULL,
  `title` text,
  `bbs_url` text,
  `remarks` text,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `state` varchar(255) DEFAULT NULL,
  `sort_no` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb06_assigned_official_titles`
--

DROP TABLE IF EXISTS `gwsub_sb06_assigned_official_titles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb06_assigned_official_titles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `official_title_code` text,
  `official_title_name` text,
  `official_title_sort_no` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb06_budget_assign_admins`
--

DROP TABLE IF EXISTS `gwsub_sb06_budget_assign_admins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb06_budget_assign_admins` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `group_parent_id` int(11) DEFAULT NULL,
  `group_parent_ou` text,
  `group_parent_code` text,
  `group_parent_name` text,
  `group_id` int(11) DEFAULT NULL,
  `group_ou` text,
  `group_code` text,
  `group_name` text,
  `multi_group_parent_id` int(11) DEFAULT NULL,
  `multi_group_parent_ou` text,
  `multi_group_parent_code` text,
  `multi_group_parent_name` text,
  `multi_group_id` int(11) DEFAULT NULL,
  `multi_group_ou` text,
  `multi_group_code` text,
  `multi_group_name` text,
  `multi_sequence` text,
  `multi_user_code` text,
  `user_id` int(11) DEFAULT NULL,
  `user_code` text,
  `user_name` text,
  `budget_role_id` int(11) DEFAULT NULL,
  `budget_role_code` text,
  `budget_role_name` text,
  `admin_state` text,
  `main_state` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb06_budget_assign_mains`
--

DROP TABLE IF EXISTS `gwsub_sb06_budget_assign_mains`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb06_budget_assign_mains` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `group_parent_id` int(11) DEFAULT NULL,
  `group_parent_ou` text,
  `group_parent_code` text,
  `group_parent_name` text,
  `group_id` int(11) DEFAULT NULL,
  `group_ou` text,
  `group_code` text,
  `group_name` text,
  `multi_group_parent_id` int(11) DEFAULT NULL,
  `multi_group_parent_ou` text,
  `multi_group_parent_code` text,
  `multi_group_parent_name` text,
  `multi_group_id` int(11) DEFAULT NULL,
  `multi_group_ou` text,
  `multi_group_code` text,
  `multi_group_name` text,
  `multi_sequence` text,
  `multi_user_code` text,
  `user_id` int(11) DEFAULT NULL,
  `user_code` text,
  `user_name` text,
  `budget_role_id` int(11) DEFAULT NULL,
  `budget_role_code` text,
  `budget_role_name` text,
  `admin_state` text,
  `main_state` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb06_budget_assigns`
--

DROP TABLE IF EXISTS `gwsub_sb06_budget_assigns`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb06_budget_assigns` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `group_parent_id` int(11) DEFAULT NULL,
  `group_parent_ou` text,
  `group_parent_code` text,
  `group_parent_name` text,
  `group_id` int(11) DEFAULT NULL,
  `group_ou` text,
  `group_code` text,
  `group_name` text,
  `multi_group_parent_id` int(11) DEFAULT NULL,
  `multi_group_parent_ou` text,
  `multi_group_parent_code` text,
  `multi_group_parent_name` text,
  `multi_group_id` int(11) DEFAULT NULL,
  `multi_group_ou` text,
  `multi_group_code` text,
  `multi_group_name` text,
  `multi_sequence` text,
  `multi_user_code` text,
  `user_id` int(11) DEFAULT NULL,
  `user_code` text,
  `user_name` text,
  `budget_role_id` int(11) DEFAULT NULL,
  `budget_role_code` text,
  `budget_role_name` text,
  `admin_state` text,
  `main_state` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb06_budget_editable_dates`
--

DROP TABLE IF EXISTS `gwsub_sb06_budget_editable_dates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb06_budget_editable_dates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `start_at` datetime DEFAULT NULL,
  `end_at` datetime DEFAULT NULL,
  `recognize_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb06_budget_notices`
--

DROP TABLE IF EXISTS `gwsub_sb06_budget_notices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb06_budget_notices` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `kind` text,
  `title` text,
  `bbs_url` text,
  `remarks` text,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb06_budget_roles`
--

DROP TABLE IF EXISTS `gwsub_sb06_budget_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb06_budget_roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` text,
  `name` text,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb06_recognizers`
--

DROP TABLE IF EXISTS `gwsub_sb06_recognizers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb06_recognizers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `recognized_at` text,
  `mode` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb12_groups`
--

DROP TABLE IF EXISTS `gwsub_sb12_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb12_groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `state` text,
  `code` varchar(255) DEFAULT NULL,
  `name` text,
  `sort_no` int(11) DEFAULT NULL,
  `ldap` int(11) DEFAULT NULL,
  `latest_updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwsub_sb13_groups`
--

DROP TABLE IF EXISTS `gwsub_sb13_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwsub_sb13_groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `state` text,
  `code` varchar(255) DEFAULT NULL,
  `name` text,
  `sort_no` int(11) DEFAULT NULL,
  `ldap` int(11) DEFAULT NULL,
  `latest_updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gwworkflow_files`
--

DROP TABLE IF EXISTS `gwworkflow_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gwworkflow_files` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `intra_maintenances`
--

DROP TABLE IF EXISTS `intra_maintenances`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `intra_maintenances` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `published_at` datetime DEFAULT NULL,
  `title` text,
  `body` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `intra_messages`
--

DROP TABLE IF EXISTS `intra_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `intra_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `published_at` datetime DEFAULT NULL,
  `title` text,
  `body` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `questionnaire_bases`
--

DROP TABLE IF EXISTS `questionnaire_bases`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `questionnaire_bases` (
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
  `send_to` int(11) DEFAULT NULL,
  `send_to_kind` int(11) DEFAULT NULL,
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `questionnaire_field_options`
--

DROP TABLE IF EXISTS `questionnaire_field_options`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `questionnaire_field_options` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `questionnaire_form_fields`
--

DROP TABLE IF EXISTS `questionnaire_form_fields`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `questionnaire_form_fields` (
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
  `group_name` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `questionnaire_itemdeletes`
--

DROP TABLE IF EXISTS `questionnaire_itemdeletes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `questionnaire_itemdeletes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `content_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `admin_code` varchar(255) DEFAULT NULL,
  `limit_date` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `questionnaire_previews`
--

DROP TABLE IF EXISTS `questionnaire_previews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `questionnaire_previews` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `questionnaire_results`
--

DROP TABLE IF EXISTS `questionnaire_results`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `questionnaire_results` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `questionnaire_template_bases`
--

DROP TABLE IF EXISTS `questionnaire_template_bases`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `questionnaire_template_bases` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `questionnaire_template_field_options`
--

DROP TABLE IF EXISTS `questionnaire_template_field_options`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `questionnaire_template_field_options` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `questionnaire_template_form_fields`
--

DROP TABLE IF EXISTS `questionnaire_template_form_fields`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `questionnaire_template_form_fields` (
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
  `group_name` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `questionnaire_template_previews`
--

DROP TABLE IF EXISTS `questionnaire_template_previews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `questionnaire_template_previews` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `questionnaire_temporaries`
--

DROP TABLE IF EXISTS `questionnaire_temporaries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `questionnaire_temporaries` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `session_id` varchar(255) NOT NULL,
  `data` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sessions_on_session_id` (`session_id`),
  KEY `index_sessions_on_updated_at` (`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_admin_logs`
--

DROP TABLE IF EXISTS `system_admin_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_admin_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `item_unid` int(11) DEFAULT NULL,
  `controller` text,
  `action` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary view structure for view `system_authorizations`
--

DROP TABLE IF EXISTS `system_authorizations`;
/*!50001 DROP VIEW IF EXISTS `system_authorizations`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `system_authorizations` AS SELECT 
 1 AS `user_id`,
 1 AS `user_code`,
 1 AS `user_name`,
 1 AS `user_name_en`,
 1 AS `user_password`,
 1 AS `user_email`,
 1 AS `remember_token`,
 1 AS `remember_token_expires_at`,
 1 AS `group_id`,
 1 AS `group_code`,
 1 AS `group_name`,
 1 AS `group_name_en`,
 1 AS `group_email`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `system_commitments`
--

DROP TABLE IF EXISTS `system_commitments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_commitments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `version` text,
  `name` text,
  `value` longtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_creators`
--

DROP TABLE IF EXISTS `system_creators`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_creators` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `unid` int(11) DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3561 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_custom_group_roles`
--

DROP TABLE IF EXISTS `system_custom_group_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_custom_group_roles` (
  `rid` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  `custom_group_id` int(11) DEFAULT NULL,
  `priv_name` text,
  `user_id` int(11) DEFAULT NULL,
  `class_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`rid`),
  KEY `custom_group_id` (`custom_group_id`),
  KEY `group_id` (`group_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=28241 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_custom_groups`
--

DROP TABLE IF EXISTS `system_custom_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_custom_groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `class_id` int(11) DEFAULT NULL,
  `owner_uid` int(11) DEFAULT NULL,
  `owner_gid` int(11) DEFAULT NULL,
  `updater_uid` int(11) NOT NULL,
  `updater_gid` int(11) NOT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `level_no` int(11) DEFAULT NULL,
  `name` text,
  `name_en` text,
  `sort_no` int(11) DEFAULT NULL,
  `sort_prefix` text,
  `is_default` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_group_change_dates`
--

DROP TABLE IF EXISTS `system_group_change_dates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_group_change_dates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `created_user` text,
  `created_group` text,
  `updated_at` datetime DEFAULT NULL,
  `updated_user` text,
  `updated_group` text,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_user` text,
  `deleted_group` text,
  `start_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_group_change_pickups`
--

DROP TABLE IF EXISTS `system_group_change_pickups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_group_change_pickups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `target_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_group_changes`
--

DROP TABLE IF EXISTS `system_group_changes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_group_changes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `state` text,
  `target_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_group_histories`
--

DROP TABLE IF EXISTS `system_group_histories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_group_histories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `level_no` int(11) DEFAULT NULL,
  `version_id` int(11) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL COMMENT 'group_code',
  `name` text,
  `name_en` text,
  `group_s_name` text,
  `email` text,
  `start_at` datetime DEFAULT NULL,
  `end_at` datetime DEFAULT NULL,
  `sort_no` int(11) DEFAULT NULL,
  `ldap_version` varchar(255) DEFAULT NULL,
  `ldap` int(11) DEFAULT NULL COMMENT 'ldap_flg',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=727 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_group_history_temporaries`
--

DROP TABLE IF EXISTS `system_group_history_temporaries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_group_history_temporaries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `level_no` int(11) DEFAULT NULL,
  `version_id` int(11) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL COMMENT 'group_code',
  `name` text,
  `name_en` text,
  `group_s_name` text,
  `email` text,
  `start_at` datetime DEFAULT NULL,
  `end_at` datetime DEFAULT NULL,
  `sort_no` int(11) DEFAULT NULL,
  `ldap_version` varchar(255) DEFAULT NULL,
  `ldap` int(11) DEFAULT NULL COMMENT 'ldap_flg',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_group_nexts`
--

DROP TABLE IF EXISTS `system_group_nexts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_group_nexts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `group_update_id` int(11) DEFAULT NULL,
  `operation` text,
  `old_group_id` int(11) DEFAULT NULL,
  `old_code` text,
  `old_name` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `old_parent_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_group_temporaries`
--

DROP TABLE IF EXISTS `system_group_temporaries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_group_temporaries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `level_no` int(11) DEFAULT NULL,
  `version_id` int(11) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL COMMENT 'group_code',
  `name` text,
  `name_en` text,
  `group_s_name` text,
  `email` text,
  `start_at` datetime DEFAULT NULL,
  `end_at` datetime DEFAULT NULL,
  `sort_no` int(11) DEFAULT NULL,
  `ldap_version` varchar(255) DEFAULT NULL,
  `ldap` int(11) DEFAULT NULL COMMENT 'ldap_flg',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_group_updates`
--

DROP TABLE IF EXISTS `system_group_updates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_group_updates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_code` text,
  `parent_name` text,
  `level_no` int(11) DEFAULT NULL,
  `code` text,
  `name` text,
  `state` text,
  `start_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_group_versions`
--

DROP TABLE IF EXISTS `system_group_versions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_group_versions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `version` int(11) DEFAULT NULL,
  `start_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_groups`
--

DROP TABLE IF EXISTS `system_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `level_no` int(11) DEFAULT NULL,
  `version_id` int(11) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL COMMENT 'group_code',
  `name` text,
  `name_en` text,
  `group_s_name` text,
  `email` text,
  `start_at` datetime DEFAULT NULL,
  `end_at` datetime DEFAULT NULL,
  `sort_no` int(11) DEFAULT NULL,
  `ldap_version` varchar(255) DEFAULT NULL,
  `ldap` int(11) DEFAULT NULL COMMENT 'ldap_flg',
  PRIMARY KEY (`id`),
  KEY `index_system_groups_on_code` (`code`),
  KEY `index_system_groups_on_ldap` (`ldap`),
  KEY `index_system_groups_on_state` (`state`)
) ENGINE=InnoDB AUTO_INCREMENT=727 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_idconversions`
--

DROP TABLE IF EXISTS `system_idconversions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_idconversions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `tablename` text,
  `modelname` varchar(255) DEFAULT NULL,
  `converted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_inquiries`
--

DROP TABLE IF EXISTS `system_inquiries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_inquiries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `state` text NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  `charge` text,
  `tel` text,
  `fax` text,
  `email` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=268 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_languages`
--

DROP TABLE IF EXISTS `system_languages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_languages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `sort_no` int(11) DEFAULT NULL,
  `name` text,
  `title` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_ldap_temporaries`
--

DROP TABLE IF EXISTS `system_ldap_temporaries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_ldap_temporaries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `version` varchar(255) DEFAULT NULL,
  `data_type` varchar(255) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `sort_no` varchar(255) DEFAULT NULL,
  `name` text,
  `name_en` text,
  `group_s_name` text,
  `kana` text,
  `email` text,
  `match` text,
  `official_position` varchar(255) DEFAULT NULL,
  `assigned_job` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `version` (`version`(20),`parent_id`,`data_type`(20),`sort_no`),
  KEY `index_system_ldap_temporaries_on_version` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_login_logs`
--

DROP TABLE IF EXISTS `system_login_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_login_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_maps`
--

DROP TABLE IF EXISTS `system_maps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_maps` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `name` text,
  `title` text,
  `map_lat` text,
  `map_lng` text,
  `map_zoom` text,
  `point1_name` text,
  `point1_lat` text,
  `point1_lng` text,
  `point2_name` text,
  `point2_lat` text,
  `point2_lng` text,
  `point3_name` text,
  `point3_lat` text,
  `point3_lng` text,
  `point4_name` text,
  `point4_lat` text,
  `point4_lng` text,
  `point5_name` text,
  `point5_lat` text,
  `point5_lng` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_priv_names`
--

DROP TABLE IF EXISTS `system_priv_names`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_priv_names` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `state` text,
  `content_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `display_name` text,
  `priv_name` text,
  `sort_no` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_product_synchro_plans`
--

DROP TABLE IF EXISTS `system_product_synchro_plans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_product_synchro_plans` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `state` varchar(255) DEFAULT NULL,
  `start_at` datetime DEFAULT NULL,
  `product_ids` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_system_product_synchro_plans_on_state_and_start_at` (`state`,`start_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_product_synchros`
--

DROP TABLE IF EXISTS `system_product_synchros`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_product_synchros` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) DEFAULT NULL,
  `plan_id` int(11) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `version` varchar(255) DEFAULT NULL,
  `remark_temp` text,
  `remark_back` text,
  `remark_sync` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_system_product_synchros_on_product_id` (`product_id`),
  KEY `index_system_product_synchros_on_plan_id` (`plan_id`),
  KEY `index_system_product_synchros_on_state` (`state`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_products`
--

DROP TABLE IF EXISTS `system_products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_products` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_type` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `sort_no` int(11) DEFAULT '0',
  `product_synchro` tinyint(4) DEFAULT '0',
  `sso` tinyint(4) DEFAULT '0',
  `sso_url` text,
  `sso_url_mobile` text,
  PRIMARY KEY (`id`),
  KEY `index_system_products_on_product_type` (`product_type`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_public_logs`
--

DROP TABLE IF EXISTS `system_public_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_public_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `item_unid` int(11) DEFAULT NULL,
  `controller` text,
  `action` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_publishers`
--

DROP TABLE IF EXISTS `system_publishers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_publishers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `published_at` datetime DEFAULT NULL,
  `name` text,
  `published_path` text,
  `content_type` text,
  `content_length` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_recognitions`
--

DROP TABLE IF EXISTS `system_recognitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_recognitions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `after_process` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_recognizers`
--

DROP TABLE IF EXISTS `system_recognizers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_recognizers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `name` text NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `recognized_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_role_developers`
--

DROP TABLE IF EXISTS `system_role_developers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_role_developers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `idx` int(11) DEFAULT NULL,
  `class_id` int(11) DEFAULT NULL,
  `uid` varchar(255) DEFAULT NULL,
  `priv` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `role_name_id` int(11) DEFAULT NULL,
  `table_name` text,
  `priv_name` text,
  `priv_user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_role_name_privs`
--

DROP TABLE IF EXISTS `system_role_name_privs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_role_name_privs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `role_id` int(11) DEFAULT NULL,
  `priv_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_system_role_name_privs_on_role_id` (`role_id`),
  KEY `index_system_role_name_privs_on_priv_id` (`priv_id`)
) ENGINE=InnoDB AUTO_INCREMENT=220 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_role_names`
--

DROP TABLE IF EXISTS `system_role_names`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_role_names` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `state` text,
  `content_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `display_name` text,
  `table_name` text,
  `sort_no` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=65 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_roles`
--

DROP TABLE IF EXISTS `system_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `table_name` varchar(255) DEFAULT NULL,
  `priv_name` varchar(255) DEFAULT NULL,
  `idx` int(11) DEFAULT NULL,
  `class_id` int(11) DEFAULT NULL,
  `uid` varchar(255) DEFAULT NULL,
  `priv` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `role_name_id` int(11) DEFAULT NULL,
  `priv_user_id` int(11) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_system_roles_on_table_name_and_priv_name_and_class_id_and` (`table_name`,`priv_name`,`class_id`,`uid`,`idx`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_sequences`
--

DROP TABLE IF EXISTS `system_sequences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_sequences` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `name` text,
  `version` int(11) DEFAULT NULL,
  `value` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_tags`
--

DROP TABLE IF EXISTS `system_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `name` text,
  `word` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_tasks`
--

DROP TABLE IF EXISTS `system_tasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_tasks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `process_at` datetime DEFAULT NULL,
  `name` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_unids`
--

DROP TABLE IF EXISTS `system_unids`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_unids` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `module` text,
  `item_type` text,
  `item_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3485 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_user_temporaries`
--

DROP TABLE IF EXISTS `system_user_temporaries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_user_temporaries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `air_login_id` varchar(255) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `code` varchar(255) NOT NULL,
  `ldap` int(11) NOT NULL,
  `ldap_version` int(11) DEFAULT NULL,
  `auth_no` text,
  `sort_no` varchar(255) DEFAULT NULL,
  `name` text,
  `name_en` text,
  `kana` text,
  `password` text,
  `mobile_access` int(11) DEFAULT NULL,
  `mobile_password` varchar(255) DEFAULT NULL,
  `email` text,
  `official_position` varchar(255) DEFAULT NULL,
  `assigned_job` varchar(255) DEFAULT NULL,
  `remember_token` text,
  `remember_token_expires_at` datetime DEFAULT NULL,
  `air_token` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_users`
--

DROP TABLE IF EXISTS `system_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `air_login_id` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `code` varchar(255) NOT NULL,
  `ldap` int(11) NOT NULL,
  `ldap_version` int(11) DEFAULT NULL,
  `auth_no` text,
  `sort_no` varchar(255) DEFAULT NULL,
  `name` text,
  `name_en` text,
  `group_s_name` text,
  `kana` text,
  `password` text,
  `mobile_access` int(11) DEFAULT NULL,
  `mobile_password` varchar(255) DEFAULT NULL,
  `email` text,
  `official_position` varchar(255) DEFAULT NULL,
  `assigned_job` varchar(255) DEFAULT NULL,
  `remember_token` text,
  `remember_token_expires_at` datetime DEFAULT NULL,
  `air_token` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_code` (`code`),
  KEY `index_system_users_on_ldap` (`ldap`),
  KEY `index_system_users_on_state` (`state`)
) ENGINE=InnoDB AUTO_INCREMENT=5478 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_users_custom_groups`
--

DROP TABLE IF EXISTS `system_users_custom_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_users_custom_groups` (
  `rid` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `custom_group_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `title` text,
  `title_en` text,
  `sort_no` int(11) DEFAULT NULL,
  `icon` text,
  PRIMARY KEY (`rid`),
  KEY `custom_group_id` (`custom_group_id`)
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_users_group_histories`
--

DROP TABLE IF EXISTS `system_users_group_histories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_users_group_histories` (
  `rid` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  `job_order` int(11) DEFAULT NULL COMMENT '本務0・兼務1',
  `start_at` datetime DEFAULT NULL COMMENT '適用開始日',
  `end_at` datetime DEFAULT NULL,
  `user_code` varchar(255) DEFAULT NULL,
  `group_code` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`rid`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_users_group_history_temporaries`
--

DROP TABLE IF EXISTS `system_users_group_history_temporaries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_users_group_history_temporaries` (
  `rid` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  `job_order` int(11) DEFAULT NULL COMMENT '本務0・兼務1',
  `start_at` datetime DEFAULT NULL COMMENT '適用開始日',
  `end_at` datetime DEFAULT NULL,
  `user_code` varchar(255) DEFAULT NULL,
  `group_code` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`rid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_users_group_temporaries`
--

DROP TABLE IF EXISTS `system_users_group_temporaries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_users_group_temporaries` (
  `rid` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  `job_order` int(11) DEFAULT NULL COMMENT '本務0・兼務1',
  `start_at` datetime DEFAULT NULL COMMENT '適用開始日',
  `end_at` datetime DEFAULT NULL,
  `user_code` varchar(255) DEFAULT NULL,
  `group_code` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`rid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_users_groups`
--

DROP TABLE IF EXISTS `system_users_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_users_groups` (
  `rid` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  `job_order` int(11) DEFAULT NULL COMMENT '本務0・兼務1',
  `start_at` datetime DEFAULT NULL COMMENT '適用開始日',
  `end_at` datetime DEFAULT NULL,
  `user_code` varchar(255) DEFAULT NULL,
  `group_code` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`rid`),
  KEY `index_system_users_groups_on_user_id` (`user_id`),
  KEY `index_system_users_groups_on_group_id` (`group_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11865 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_users_groups_csvdata`
--

DROP TABLE IF EXISTS `system_users_groups_csvdata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_users_groups_csvdata` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `state` varchar(255) NOT NULL,
  `data_type` varchar(255) NOT NULL,
  `level_no` int(11) DEFAULT NULL,
  `parent_id` int(11) NOT NULL,
  `parent_code` varchar(255) NOT NULL,
  `code` varchar(255) NOT NULL,
  `sort_no` int(11) DEFAULT NULL,
  `ldap` int(11) NOT NULL,
  `job_order` int(11) DEFAULT NULL,
  `name` text NOT NULL,
  `name_en` text,
  `kana` text,
  `password` varchar(255) DEFAULT NULL,
  `mobile_access` int(11) DEFAULT NULL,
  `mobile_password` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `official_position` varchar(255) DEFAULT NULL,
  `assigned_job` varchar(255) DEFAULT NULL,
  `start_at` datetime NOT NULL,
  `end_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
