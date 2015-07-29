
SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

--
-- データベース: `development_jgw_core`
--

-- --------------------------------------------------------

--
-- テーブルの構造 `intra_maintenances`
--

DROP TABLE IF EXISTS `intra_maintenances`;
CREATE TABLE IF NOT EXISTS `intra_maintenances` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `published_at` datetime DEFAULT NULL,
  `title` text,
  `body` text,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `intra_messages`
--

DROP TABLE IF EXISTS `intra_messages`;
CREATE TABLE IF NOT EXISTS `intra_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `published_at` datetime DEFAULT NULL,
  `title` text,
  `body` text,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `sessions`
--

DROP TABLE IF EXISTS `sessions`;
CREATE TABLE IF NOT EXISTS `sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `session_id` varchar(255) NOT NULL,
  `data` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sessions_on_session_id` (`session_id`),
  KEY `index_sessions_on_updated_at` (`updated_at`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `system_admin_logs`
--

DROP TABLE IF EXISTS `system_admin_logs`;
CREATE TABLE IF NOT EXISTS `system_admin_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `item_unid` int(11) DEFAULT NULL,
  `controller` text,
  `action` text,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `system_authorizations`
--
DROP VIEW IF EXISTS `system_authorizations`;
CREATE TABLE IF NOT EXISTS `system_authorizations` (
`user_id` int(11)
,`user_code` varchar(255)
,`user_name` text
,`user_name_en` text
,`user_password` text
,`user_email` text
,`remember_token` text
,`remember_token_expires_at` datetime
,`group_id` int(11)
,`group_code` varchar(255)
,`group_name` text
,`group_name_en` text
,`group_email` text
);
-- --------------------------------------------------------

--
-- テーブルの構造 `system_commitments`
--

DROP TABLE IF EXISTS `system_commitments`;
CREATE TABLE IF NOT EXISTS `system_commitments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `version` text,
  `name` text,
  `value` longtext,
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `system_creators`
--

DROP TABLE IF EXISTS `system_creators`;
CREATE TABLE IF NOT EXISTS `system_creators` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `unid` int(11) DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `system_custom_groups`
--

DROP TABLE IF EXISTS `system_custom_groups`;
CREATE TABLE IF NOT EXISTS `system_custom_groups` (
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
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `system_custom_group_roles`
--

DROP TABLE IF EXISTS `system_custom_group_roles`;
CREATE TABLE IF NOT EXISTS `system_custom_group_roles` (
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
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `system_groups`
--

DROP TABLE IF EXISTS `system_groups`;
CREATE TABLE IF NOT EXISTS `system_groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `level_no` int(11) DEFAULT NULL,
  `version_id` int(11) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL COMMENT 'group_code',
  `name` text,
  `name_en` text,
  `email` text,
  `start_at` datetime DEFAULT NULL,
  `end_at` datetime DEFAULT NULL,
  `sort_no` int(11) DEFAULT NULL,
  `ldap_version` varchar(255) DEFAULT NULL,
  `ldap` int(11) DEFAULT NULL COMMENT 'ldap_flg',
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `system_group_changes`
--

DROP TABLE IF EXISTS `system_group_changes`;
CREATE TABLE IF NOT EXISTS `system_group_changes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `state` text,
  `target_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- テーブルの構造 `system_group_change_pickups`
--

DROP TABLE IF EXISTS `system_group_change_pickups`;
CREATE TABLE IF NOT EXISTS `system_group_change_pickups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `target_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- テーブルの構造 `system_group_histories`
--

DROP TABLE IF EXISTS `system_group_histories`;
CREATE TABLE IF NOT EXISTS `system_group_histories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `level_no` int(11) DEFAULT NULL,
  `version_id` int(11) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL COMMENT 'group_code',
  `name` text,
  `name_en` text,
  `email` text,
  `start_at` datetime DEFAULT NULL,
  `end_at` datetime DEFAULT NULL,
  `sort_no` int(11) DEFAULT NULL,
  `ldap_version` varchar(255) DEFAULT NULL,
  `ldap` int(11) DEFAULT NULL COMMENT 'ldap_flg',
   PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `system_group_history_temporaries`
--

DROP TABLE IF EXISTS `system_group_history_temporaries`;
CREATE TABLE IF NOT EXISTS `system_group_history_temporaries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `level_no` int(11) DEFAULT NULL,
  `version_id` int(11) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL COMMENT 'group_code',
  `name` text,
  `name_en` text,
  `email` text,
  `start_at` datetime DEFAULT NULL,
  `end_at` datetime DEFAULT NULL,
  `sort_no` int(11) DEFAULT NULL,
  `ldap_version` varchar(255) DEFAULT NULL,
  `ldap` int(11) DEFAULT NULL COMMENT 'ldap_flg',
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `system_group_nexts`
--

DROP TABLE IF EXISTS `system_group_nexts`;
CREATE TABLE IF NOT EXISTS `system_group_nexts` (
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
)  DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- テーブルの構造 `system_group_temporaries`
--

DROP TABLE IF EXISTS `system_group_temporaries`;
CREATE TABLE IF NOT EXISTS `system_group_temporaries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `level_no` int(11) DEFAULT NULL,
  `version_id` int(11) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL COMMENT 'group_code',
  `name` text,
  `name_en` text,
  `email` text,
  `start_at` datetime DEFAULT NULL,
  `end_at` datetime DEFAULT NULL,
  `sort_no` int(11) DEFAULT NULL,
  `ldap_version` varchar(255) DEFAULT NULL,
  `ldap` int(11) DEFAULT NULL COMMENT 'ldap_flg',
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `system_group_updates`
--

DROP TABLE IF EXISTS `system_group_updates`;
CREATE TABLE IF NOT EXISTS `system_group_updates` (
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
)  DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- テーブルの構造 `system_group_versions`
--

DROP TABLE IF EXISTS `system_group_versions`;
CREATE TABLE IF NOT EXISTS `system_group_versions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `version` int(11) DEFAULT NULL,
  `start_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `system_idconversions`
--

DROP TABLE IF EXISTS `system_idconversions`;
CREATE TABLE IF NOT EXISTS `system_idconversions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `tablename` text,
  `modelname` varchar(255) DEFAULT NULL,
  `converted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `system_inquiries`
--

DROP TABLE IF EXISTS `system_inquiries`;
CREATE TABLE IF NOT EXISTS `system_inquiries` (
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
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `system_languages`
--

DROP TABLE IF EXISTS `system_languages`;
CREATE TABLE IF NOT EXISTS `system_languages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `state` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `sort_no` int(11) DEFAULT NULL,
  `name` text,
  `title` text,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `system_ldap_temporaries`
--

DROP TABLE IF EXISTS `system_ldap_temporaries`;
CREATE TABLE IF NOT EXISTS `system_ldap_temporaries` (
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
  `kana` text,
  `email` text,
  `match` text,
  `official_position` varchar(255) DEFAULT NULL,
  `assigned_job` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `version` (`version`(20),`parent_id`,`data_type`(20),`sort_no`)
) DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `system_login_logs`
--

DROP TABLE IF EXISTS `system_login_logs`;
CREATE TABLE IF NOT EXISTS `system_login_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `system_maps`
--

DROP TABLE IF EXISTS `system_maps`;
CREATE TABLE IF NOT EXISTS `system_maps` (
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
) DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `system_priv_names`
--

DROP TABLE IF EXISTS `system_priv_names`;
CREATE TABLE IF NOT EXISTS `system_priv_names` (
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
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `system_public_logs`
--

DROP TABLE IF EXISTS `system_public_logs`;
CREATE TABLE IF NOT EXISTS `system_public_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `item_unid` int(11) DEFAULT NULL,
  `controller` text,
  `action` text,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `system_publishers`
--

DROP TABLE IF EXISTS `system_publishers`;
CREATE TABLE IF NOT EXISTS `system_publishers` (
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
) DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `system_recognitions`
--

DROP TABLE IF EXISTS `system_recognitions`;
CREATE TABLE IF NOT EXISTS `system_recognitions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `after_process` text,
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `system_recognizers`
--

DROP TABLE IF EXISTS `system_recognizers`;
CREATE TABLE IF NOT EXISTS `system_recognizers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `name` text NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `recognized_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `system_roles`
--

DROP TABLE IF EXISTS `system_roles`;
CREATE TABLE IF NOT EXISTS `system_roles` (
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
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `system_role_developers`
--

DROP TABLE IF EXISTS `system_role_developers`;
CREATE TABLE IF NOT EXISTS `system_role_developers` (
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
) DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `system_role_names`
--

DROP TABLE IF EXISTS `system_role_names`;
CREATE TABLE IF NOT EXISTS `system_role_names` (
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
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `system_role_name_privs`
--

DROP TABLE IF EXISTS `system_role_name_privs`;
CREATE TABLE IF NOT EXISTS `system_role_name_privs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `role_id` int(11) DEFAULT NULL,
  `priv_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `system_sequences`
--

DROP TABLE IF EXISTS `system_sequences`;
CREATE TABLE IF NOT EXISTS `system_sequences` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `name` text,
  `version` int(11) DEFAULT NULL,
  `value` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `system_tags`
--

DROP TABLE IF EXISTS `system_tags`;
CREATE TABLE IF NOT EXISTS `system_tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `name` text,
  `word` text,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `system_tasks`
--

DROP TABLE IF EXISTS `system_tasks`;
CREATE TABLE IF NOT EXISTS `system_tasks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unid` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `process_at` datetime DEFAULT NULL,
  `name` text,
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `system_unids`
--

DROP TABLE IF EXISTS `system_unids`;
CREATE TABLE IF NOT EXISTS `system_unids` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `module` text,
  `item_type` text,
  `item_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `system_users`
--

DROP TABLE IF EXISTS `system_users`;
CREATE TABLE IF NOT EXISTS `system_users` (
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
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `system_users_custom_groups`
--

DROP TABLE IF EXISTS `system_users_custom_groups`;
CREATE TABLE IF NOT EXISTS `system_users_custom_groups` (
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
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `system_users_groups_csvdata`
--

DROP TABLE IF EXISTS `system_users_groups_csvdata`;
CREATE TABLE IF NOT EXISTS `system_users_groups_csvdata` (
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
) DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `system_users_groups`
--

DROP TABLE IF EXISTS `system_users_groups`;
CREATE TABLE IF NOT EXISTS `system_users_groups` (
  `rid` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  `job_order` int(11) DEFAULT NULL COMMENT  '本務0・兼務1',
  `start_at` datetime DEFAULT NULL COMMENT '適用開始日',
  `end_at` datetime DEFAULT NULL,
  `user_code` varchar(255) DEFAULT NULL,
  `group_code` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`rid`)
)   DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `system_users_group_histories`
--

DROP TABLE IF EXISTS `system_users_group_histories`;
CREATE TABLE IF NOT EXISTS `system_users_group_histories` (
  `rid` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  `job_order` int(11) DEFAULT NULL COMMENT  '本務0・兼務1',
  `start_at` datetime DEFAULT NULL COMMENT '適用開始日',
  `end_at` datetime DEFAULT NULL,
  `user_code` varchar(255) DEFAULT NULL,
  `group_code` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`rid`)
) DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `system_users_group_history_temporaries`
--

DROP TABLE IF EXISTS `system_users_group_history_temporaries`;
CREATE TABLE IF NOT EXISTS `system_users_group_history_temporaries` (
  `rid` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  `job_order` int(11) DEFAULT NULL COMMENT  '本務0・兼務1',
  `start_at` datetime DEFAULT NULL COMMENT '適用開始日',
  `end_at` datetime DEFAULT NULL,
  `user_code` varchar(255) DEFAULT NULL,
  `group_code` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`rid`)
) DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `system_users_group_temporaries`
--

DROP TABLE IF EXISTS `system_users_group_temporaries`;
CREATE TABLE IF NOT EXISTS `system_users_group_temporaries` (
  `rid` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  `job_order` int(11) DEFAULT NULL COMMENT  '本務0・兼務1',
  `start_at` datetime DEFAULT NULL COMMENT '適用開始日',
  `end_at` datetime DEFAULT NULL,
  `user_code` varchar(255) DEFAULT NULL,
  `group_code` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`rid`)
) DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `system_user_temporaries`
--

DROP TABLE IF EXISTS `system_user_temporaries`;
CREATE TABLE IF NOT EXISTS `system_user_temporaries` (
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
) DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- テーブルの構造 `system_group_change_dates`
--

CREATE TABLE IF NOT EXISTS `system_group_change_dates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime,
  `created_user` text,
  `created_group` text,
  `updated_at` datetime,
  `updated_user` text,
  `updated_group` text,
  `deleted_at` datetime,
  `deleted_user` text,
  `deleted_group` text,
  `start_at` datetime,
  PRIMARY KEY (`id`)
) DEFAULT CHARSET=utf8;

-- --------------------------------------------------------
--
-- テーブルの構造 `system_authorizations`
--
DROP TABLE IF EXISTS `system_authorizations`;

CREATE ALGORITHM=UNDEFINED VIEW `system_authorizations` AS (select `users`.`id` AS `user_id`,`users`.`code` AS `user_code`,`users`.`name` AS `user_name`,`users`.`name_en` AS `user_name_en`,`users`.`password` AS `user_password`,`users`.`email` AS `user_email`,`users`.`remember_token` AS `remember_token`,`users`.`remember_token_expires_at` AS `remember_token_expires_at`,`groups`.`id` AS `group_id`,`groups`.`code` AS `group_code`,`groups`.`name` AS `group_name`,`groups`.`name_en` AS `group_name_en`,`groups`.`email` AS `group_email` from ((`system_users` `users` join `system_users_groups` `sug` on((`sug`.`user_id` = `users`.`id`))) join `system_groups` `groups` on((`groups`.`id` = `sug`.`group_id`))) where (`users`.`ldap` = 0));
