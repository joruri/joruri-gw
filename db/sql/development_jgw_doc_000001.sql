
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
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8;




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
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8;


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
  PRIMARY KEY (`id`),
  KEY `title_id` (`state`(50),`title_id`,`category1_id`),
  KEY `category1_id` (`category1_id`),
  KEY `title_id2` (`title_id`)
) AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;



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
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8;




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
  PRIMARY KEY (`id`),
  KEY `title_id` (`title_id`),
  KEY `folder_id` (`folder_id`),
  KEY `acl_section_code` (`acl_section_code`),
  KEY `acl_user_code` (`acl_user_code`)
) DEFAULT CHARSET=utf8;




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
  PRIMARY KEY (`id`),
  KEY `title_id` (`title_id`),
  KEY `parent_id` (`parent_id`),
  KEY `sort_no` (`sort_no`)
)  DEFAULT CHARSET=utf8;




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
  PRIMARY KEY (`id`),
  KEY `code` (`code`)
) DEFAULT CHARSET=utf8;




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
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8;



CREATE ALGORITHM=UNDEFINED DEFINER=`joruri`@`localhost` SQL SECURITY DEFINER VIEW
 `doclibrary_view_acl_folders` AS 
 select
 `doclibrary_folders`.`id` AS `id`,
 `doclibrary_folders`.`unid` AS `unid`,
 `doclibrary_folders`.`parent_id` AS `parent_id`,
 `doclibrary_folders`.`state` AS `state`,
 `doclibrary_folders`.`created_at` AS `created_at`,
 `doclibrary_folders`.`updated_at` AS `updated_at`,
 `doclibrary_folders`.`title_id` AS `title_id`,
 `doclibrary_folders`.`sort_no` AS `sort_no`,
 `doclibrary_folders`.`level_no` AS `level_no`,
 `doclibrary_folders`.`children_size` AS `children_size`,
 `doclibrary_folders`.`total_children_size` AS `total_children_size`,
 `doclibrary_folders`.`name` AS `name`,
 `doclibrary_folders`.`memo` AS `memo`,
 `doclibrary_folders`.`readers` AS `readers`,
 `doclibrary_folders`.`readers_json` AS `readers_json`,
 `doclibrary_folders`.`reader_groups` AS `reader_groups`,
 `doclibrary_folders`.`reader_groups_json` AS `reader_groups_json`,
 `doclibrary_folders`.`docs_last_updated_at` AS `docs_last_updated_at`,
 `doclibrary_folder_acls`.`acl_flag` AS `acl_flag`,
 `doclibrary_folder_acls`.`acl_section_id` AS `acl_section_id`,
 `doclibrary_folder_acls`.`acl_section_code` AS `acl_section_code`,
 `doclibrary_folder_acls`.`acl_section_name` AS `acl_section_name`,
 `doclibrary_folder_acls`.`acl_user_id` AS `acl_user_id`,
 `doclibrary_folder_acls`.`acl_user_code` AS `acl_user_code`,
 `doclibrary_folder_acls`.`acl_user_name` AS `acl_user_name` from 
 (`doclibrary_folder_acls` join `doclibrary_folders` on(((`doclibrary_folder_acls`.`folder_id` = `doclibrary_folders`.`id`) and 
 (`doclibrary_folder_acls`.`title_id` = `doclibrary_folders`.`title_id`))));


CREATE ALGORITHM=UNDEFINED DEFINER=`joruri`@`localhost` SQL SECURITY DEFINER VIEW
 `doclibrary_view_acl_doc_counts` AS 
 select
  `doclibrary_docs`.`state` AS `state`,
  `doclibrary_docs`.`title_id` AS `title_id`,
  `doclibrary_folder_acls`.`acl_flag` AS `acl_flag`,
  `doclibrary_folder_acls`.`acl_section_code` AS `acl_section_code`,
  `doclibrary_folder_acls`.`acl_user_code` AS `acl_user_code`,
  `doclibrary_docs`.`section_code` AS `section_code`,count(`doclibrary_docs`.`id`) AS `cnt` 
  from (`doclibrary_docs` join `doclibrary_folder_acls` on(((`doclibrary_docs`.`category1_id` = `doclibrary_folder_acls`.`folder_id`) 
  and (`doclibrary_docs`.`title_id` = `doclibrary_folder_acls`.`title_id`)))) 
  group by `doclibrary_docs`.`state`,
  `doclibrary_docs`.`title_id`,
  `doclibrary_folder_acls`.`acl_flag`,
  `doclibrary_folder_acls`.`acl_section_code`,
  `doclibrary_folder_acls`.`acl_user_code`,
  `doclibrary_docs`.`section_code`;

CREATE ALGORITHM=UNDEFINED DEFINER=`joruri`@`localhost` SQL SECURITY DEFINER VIEW
 `doclibrary_view_acl_docs` AS
  select 
  `doclibrary_docs`.`id` AS `id`,
  `doclibrary_folders`.`sort_no` AS `sort_no`,
  `doclibrary_folder_acls`.`acl_flag` AS `acl_flag`,
  `doclibrary_folder_acls`.`acl_section_id` AS `acl_section_id`,
  `doclibrary_folder_acls`.`acl_section_code` AS `acl_section_code`,
  `doclibrary_folder_acls`.`acl_section_name` AS `acl_section_name`,
  `doclibrary_folder_acls`.`acl_user_id` AS `acl_user_id`,
  `doclibrary_folder_acls`.`acl_user_code` AS `acl_user_code`,
  `doclibrary_folder_acls`.`acl_user_name` AS `acl_user_name`,
  `doclibrary_folders`.`name` AS `folder_name` 
  from ((`doclibrary_docs` join `doclibrary_folder_acls`
   on(((`doclibrary_docs`.`title_id` = `doclibrary_folder_acls`.`title_id`)
   and (`doclibrary_docs`.`category1_id` = `doclibrary_folder_acls`.`folder_id`))))
   join `doclibrary_folders`
    on((`doclibrary_docs`.`category1_id` = `doclibrary_folders`.`id`)));

CREATE ALGORITHM=UNDEFINED DEFINER=`joruri`@`localhost` SQL SECURITY DEFINER VIEW
 `doclibrary_view_acl_files` AS
  select 
  `doclibrary_docs`.`state` AS `docs_state`,
  `doclibrary_files`.`id` AS `id`,
  `doclibrary_files`.`unid` AS `unid`,
  `doclibrary_files`.`content_id` AS `content_id`,
  `doclibrary_files`.`state` AS `state`,
  `doclibrary_files`.`created_at` AS `created_at`,
  `doclibrary_files`.`updated_at` AS `updated_at`,
  `doclibrary_files`.`recognized_at` AS `recognized_at`,
  `doclibrary_files`.`published_at` AS `published_at`,
  `doclibrary_files`.`latest_updated_at` AS `latest_updated_at`,
  `doclibrary_files`.`parent_id` AS `parent_id`,
  `doclibrary_files`.`title_id` AS `title_id`,
  `doclibrary_files`.`content_type` AS `content_type`,
  `doclibrary_files`.`filename` AS `filename`,
  `doclibrary_files`.`memo` AS `memo`,
  `doclibrary_files`.`size` AS `size`,
  `doclibrary_files`.`width` AS `width`,
  `doclibrary_files`.`height` AS `height`,
  `doclibrary_files`.`db_file_id` AS `db_file_id`,
  `doclibrary_docs`.`category1_id` AS `category1_id`,
  `doclibrary_docs`.`section_code` AS `section_code`,
  `doclibrary_folder_acls`.`acl_flag` AS `acl_flag`,
  `doclibrary_folder_acls`.`acl_section_id` AS `acl_section_id`,
  `doclibrary_folder_acls`.`acl_section_code` AS `acl_section_code`,
  `doclibrary_folder_acls`.`acl_section_name` AS `acl_section_name`,
  `doclibrary_folder_acls`.`acl_user_id` AS `acl_user_id`,
  `doclibrary_folder_acls`.`acl_user_code` AS `acl_user_code`,
  `doclibrary_folder_acls`.`acl_user_name` AS `acl_user_name` 
  from ((`doclibrary_files` join `doclibrary_docs` 
   on(((`doclibrary_files`.`parent_id` = `doclibrary_docs`.`id`) 
   and (`doclibrary_files`.`title_id` = `doclibrary_docs`.`title_id`)))) 
  join `doclibrary_folder_acls`
   on(((`doclibrary_docs`.`category1_id` = `doclibrary_folder_acls`.`folder_id`)
    and (`doclibrary_docs`.`title_id` = `doclibrary_folder_acls`.`title_id`))));

