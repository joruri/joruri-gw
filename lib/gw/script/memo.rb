# encoding: utf-8
class Gw::Script::Memo
  def self.delete
    puts "#{self}.delete"
    dump "#{self}.delete"
    success = 0
    error   = 0

    key = 'memos'
    options = {}
    options[:class_id] = 3
    settings = Gw::Model::Schedule.get_settings key, options
    return if settings['read_memos_admin_delete'].blank?
    return if settings['unread_memos_admin_delete'].blank?

    case settings['read_memos_admin_delete'].to_i
      when 1
        x = 5
      when 2
        x = 10
      when 3
        x = 20
      when 4
        x = 30
      else
        x = 30
    end
    return if x <= 0

    d1 = Date.today
    d1 = d1 - x
    memos = Gw::Memo.find_by_sql(["select * from gw_memos where is_finished = 1 and created_at < :d", {:d => "#{d1.strftime('%Y-%m-%d 0:0:0')}"} ])
    memos.each do |memo|
      if memo.delete
        puts "  => success.\n"
        success += 1

        memo.memo_users.each do |memo_user|
          memo_user.delete
        end

      else
        puts "  => failed.\n"
        error   += 1
      end
    end


    case settings['unread_memos_admin_delete'].to_i
      when 1
        x = 5
      when 2
        x = 10
      when 3
        x = 20
      when 4
        x = 30
      else
        x = 30
    end
    return if x <= 0

    d1 = Date.today
    d1 = d1 - x
    memos = Gw::Memo.find_by_sql(["select * from gw_memos where ( is_finished is null or is_finished = 0 ) and  created_at < :d", {:d => "#{d1.strftime('%Y-%m-%d 0:0:0')}"} ])
    #dump "#{d1.strftime('%Y-%m-%d 0:0:0')}"
    memos.each do |memo|
      if memo.delete
        puts "  => success.\n"
        success += 1

        memo.memo_users.each do |memo_user|
          memo_user.delete
        end

      else
        puts "  => failed.\n"
        error   += 1
      end
    end


    if success > 0
      ActiveRecord::Base::connection::execute 'optimize table gw_memos;'
      ActiveRecord::Base::connection::execute 'optimize table gw_memo_users;'
      ActiveRecord::Base::connection::execute 'analyze table gw_memos;'
      ActiveRecord::Base::connection::execute 'analyze table gw_memo_users;'
    end

    puts "#{Core.now} - Success:#{success}, Error:#{error}"
    dump "#{Core.now} - Success:#{success}, Error:#{error}"
  end

end
