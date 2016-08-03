namespace :joruri do
  namespace :gw do
    desc '不要となったデータを削除します'
    task :delete_expired => :environment do
      Rake::Task['joruri:core:initialize'].invoke
      # delete expired data
      Rake::Task['joruri:gw:schedule:delete_expired'].invoke
      Rake::Task['joruri:gw:schedule_prop_temporaries:delete_expired'].invoke
      Rake::Task['joruri:gw:schedule_todo:delete_expired'].invoke
      Rake::Task['joruri:gw:memo:delete_expired'].invoke
      Rake::Task['joruri:gw:memo:delete_tempfiles'].invoke
      Rake::Task['joruri:gw:reminder_external:delete_expired'].invoke
      Rake::Task['joruri:gw:dcn:delete_expired'].invoke
      Rake::Task['joruri:gw:plus:delete_expired'].invoke
      Rake::Task['joruri:gw:meeting_monitor:delete_expired'].invoke
      Rake::Task['joruri:gwbbs:delete_expired'].invoke
      Rake::Task['joruri:gwcircular:delete_expired'].invoke
      Rake::Task['joruri:gwmonitor:delete_expired'].invoke
      Rake::Task['joruri:gwworkflow:delete_expired'].invoke
      Rake::Task['joruri:questionnaire:delete_expired'].invoke
      Rake::Task['joruri:system:session:delete_expired'].invoke
      # delete preparation data
      Rake::Task['joruri:gwbbs:delete_preparation'].invoke
      Rake::Task['joruri:gwfaq:delete_preparation'].invoke
      Rake::Task['joruri:gwqa:delete_preparation'].invoke
      Rake::Task['joruri:doclibrary:delete_preparation'].invoke
      Rake::Task['joruri:digitallibrary:delete_preparation'].invoke
      Rake::Task['joruri:gwcircular:delete_preparation'].invoke
      Rake::Task['joruri:gwsub:sb01:delete_abandoned_files'].invoke
    end

    namespace :schedule do
      desc '削除期間が過ぎたスケジュールを削除します'
      task :delete_expired => :environment do
        Rake::Task['joruri:core:initialize'].invoke
        Gw::Script::Schedule.delete
      end
    end
    namespace :schedule_prop_temporaries do
      desc '不要になった施設予約仮データを削除します'
      task :delete_expired => :environment do
        Rake::Task['joruri:core:initialize'].invoke
        Gw::Script::Schedule.schedule_prop_temporary_delete
      end
    end
    namespace :schedule_todo do
      desc '完了済みで削除期間が過ぎたToDoを削除します'
      task :delete_expired => :environment do
        Rake::Task['joruri:core:initialize'].invoke
        Gw::Script::Schedule.todo_delete
      end
    end

    namespace :schedule_prop do
      desc '時間切れになった管財の予約を自動キャンセルします'
      task :cancel_timeup => :environment do
        Rake::Task['joruri:core:initialize'].invoke
        Gw::Script::ScheduleProp.cancel_timeup
      end
    end

    namespace :memo do
      desc '既読で削除期間が過ぎた連絡メモを削除します'
      task :delete_expired => :environment do
        Rake::Task['joruri:core:initialize'].invoke
        Gw::Script::Memo.delete
      end
      desc '不要となった連絡メモ添付ファイルのデータを削除します'
      task :delete_tempfiles=> :environment do
        Rake::Task['joruri:core:initialize'].invoke
        Gw::Script::Memo.delete_tempfiles
      end
    end

    namespace :pref_exective do
      desc '幹部・部課長の在席表示を全てoffにします'
      task :state_all_off => :environment do
        Rake::Task['joruri:core:initialize'].invoke
        Gw::Script::PrefExective.state_all_off
      end
    end

    namespace :reminder_external do
      desc '不要となった外部リマインダーデータを削除します'
      task :delete_expired => :environment do
        Rake::Task['joruri:core:initialize'].invoke
        Gw::Script::ReminderExternal.delete
      end
    end

    namespace :dcn do
      desc '不要となった電子決済データを削除します'
      task :delete_expired => :environment do
        Rake::Task['joruri:core:initialize'].invoke
        Gw::Script::Dcn.delete
      end
    end

    namespace :meeting_monitor do
      desc '会議等案内システムを死活監視します'
      task :notice => :environment do
        Rake::Task['joruri:core:initialize'].invoke
        Gw::Script::MeetingMonitor.monitor_notice
      end
      desc '会議等案内システムのアクセスログを削除します'
      task :delete_expired => :environment do
        Rake::Task['joruri:core:initialize'].invoke
        Gw::Script::MeetingMonitor.delete_expired
      end
    end

    namespace :plus do
      desc 'Joruri Plus+の期限切れリマインダーを削除します'
      task :delete_expired => :environment do
        Rake::Task['joruri:core:initialize'].invoke
        Gw::Script::PlusUpdate.destroy_reminders
      end
    end

  end
end
