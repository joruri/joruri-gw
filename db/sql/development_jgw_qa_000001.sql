
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
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


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
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


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
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;


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
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
