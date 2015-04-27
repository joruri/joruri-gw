

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
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8;
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
  PRIMARY KEY (`id`),
  KEY `state` (`state`(30)),
  KEY `level_no` (`level_no`,`display_order`,`sort_no`,`id`),
  KEY `parent_id` (`parent_id`),
  KEY `display_order` (`display_order`,`sort_no`)
) DEFAULT CHARSET=utf8;
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
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8;
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
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `digitallibrary_recognizers`
--
