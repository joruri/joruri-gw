
SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

--
-- データベース: `development_jgw_gw_pref`
--

--
-- テーブルのデータをダンプしています `gwsub_sb01_trainings`
--


--
-- テーブルのデータをダンプしています `gwsub_sb01_training_files`
--


--
-- テーブルのデータをダンプしています `gwsub_sb01_training_guides`
--


--
-- テーブルのデータをダンプしています `gwsub_sb01_training_schedules`
--


--
-- テーブルのデータをダンプしています `gwsub_sb01_training_schedule_conditions`
--


--
-- テーブルのデータをダンプしています `gwsub_sb01_training_schedule_members`
--


--
-- テーブルのデータをダンプしています `gwsub_sb01_training_schedule_props`
--


--
-- テーブルのデータをダンプしています `gwsub_sb04assignedjobs`
--


--
-- テーブルのデータをダンプしています `gwsub_sb04helps`
--


--
-- テーブルのデータをダンプしています `gwsub_sb04officialtitles`
--


--
-- テーブルのデータをダンプしています `gwsub_sb04sections`
--


--
-- テーブルのデータをダンプしています `gwsub_sb04stafflists`
--


--
-- テーブルのデータをダンプしています `gwsub_sb04_check_assignedjobs`
--


--
-- テーブルのデータをダンプしています `gwsub_sb04_check_officialtitles`
--


--
-- テーブルのデータをダンプしています `gwsub_sb04_check_sections`
--


--
-- テーブルのデータをダンプしています `gwsub_sb04_check_stafflists`
--


--
-- テーブルのデータをダンプしています `gwsub_sb04_editable_dates`
--

INSERT INTO `gwsub_sb04_editable_dates` (`id`, `fyear_id`, `fyear_markjp`, `published_at`, `start_at`, `end_at`, `headline_at`, `created_at`, `created_user`, `created_group`, `updated_at`, `updated_user`, `updated_group`) VALUES
(1, 141, 'H21', '2009-04-01 00:00:00', '2009-04-02 00:00:00', '2009-04-25 23:59:59', '2009-04-01 00:00:00', '2009-12-09 12:57:56', NULL, NULL, '2010-03-09 18:30:17', NULL, NULL),
(2, 140, 'H20', '2008-04-01 00:00:00', '2008-04-02 00:00:00', '2008-04-30 23:59:59', '2008-04-01 00:00:00', '2009-12-09 12:58:26', NULL, NULL, '2009-12-09 12:58:26', NULL, NULL),
(3, 139, 'H19', '2007-04-01 00:00:00', '2007-04-02 00:00:00', '2007-04-30 23:59:59', '2007-04-01 00:00:00', '2009-12-09 12:58:46', NULL, NULL, '2009-12-09 12:58:46', NULL, NULL),
(4, 142, 'H22', '2010-04-05 00:00:00', '2010-04-06 00:00:00', '2010-04-12 23:59:59', '2010-04-01 00:00:00', '2010-03-11 13:22:51', NULL, NULL, '2010-04-12 11:36:01', NULL, NULL),
(5, 143, 'H23', '2011-05-01 00:00:00', '2011-05-02 00:00:00', '2011-05-08 23:59:59', '2011-05-01 00:00:00', '2011-03-29 19:59:49', NULL, NULL, '2011-05-09 17:09:28', NULL, NULL),
(6, 145, 'H24', '2012-05-01 08:00:00', '2012-05-01 08:00:00', '2012-05-15 18:00:00', '2012-04-01 00:00:00', '2012-08-22 18:53:53', NULL, NULL, '2012-08-22 18:54:17', NULL, NULL);

--
-- テーブルのデータをダンプしています `gwsub_sb04_limit_settings`
--

INSERT INTO `gwsub_sb04_limit_settings` (`id`, `type_name`, `limit`, `created_at`, `updated_at`, `updated_user`, `updated_group`) VALUES
(1, 'stafflistview_limit', 100, '2011-07-07 14:36:44', '2012-05-15 16:02:12', 'システム管理者', '秘書広報課'),
(2, 'divideduties_limit', 50, '2011-07-07 14:36:44', '2011-07-12 18:25:15', 'システム管理者', '秘書広報課');

--
-- テーブルのデータをダンプしています `gwsub_sb04_seating_lists`
--


--
-- テーブルのデータをダンプしています `gwsub_sb04_year_copy_logs`
--

