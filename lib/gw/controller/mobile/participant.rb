# coding: utf-8
module Gw::Controller::Mobile::Participant

  def mobile_manage
    if params[:createMemo]
      return mobile_create_memo
    elsif params[:editMemo]
      return mobile_edit_memo
    elsif params[:quoteMemo]
      return mobile_quote_memo
    elsif params[:createSchedule]
      return mobile_create_schedule
    elsif params[:editSchedule]
      return mobile_edit_schedule
    elsif params[:quoteSchedule]
      return mobile_quote_schedule
    elsif params[:selectMember]
      mobile_select_member
    else params[:deleteMember]
      mobile_delete_member
    end
    uid = params[:uid]
    uid = Site.user.id if uid.blank?
    if params[:dis].blank?
      location = "/gw/mobile_participants?group_id=#{params[:group_id]}&view=#{params[:view]}&memo_id=#{params[:memo_id]}"
    else
      location = "/gw/mobile_schedules/list?group_id=#{params[:group_id]}&view=#{params[:view]}&memo_id=#{params[:memo_id]}"
      location += "&gid=#{params[:gid]}&cgid=#{params[:cgid]}&uid=#{uid}&dis=#{params[:dis]}"
    end

    redirect_to location
  end

protected

  def mobile_create_memo
    session[:mobile] ||= {}
    session[:mobile][:to] ||= []
    session[:mobile][:to] += to_ids(params[:to])
    session[:mobile][:to].uniq!
    users_str = ""
    session[:mobile][:to].each_with_index do |to,n|
      users_str << to
      users_str << "," unless n == session[:mobile][:to].length - 1
    end
    flash[:mail_to] = users_str

    location = '/gw/memos/new'
    session[:mobile] = nil
    return redirect_to location
  end

  def mobile_edit_memo
    session[:mobile] ||= {}
    session[:mobile][:to] ||= []
    session[:mobile][:to] += to_ids(params[:to])
    session[:mobile][:to].uniq!
    users_str = ""
    session[:mobile][:to].each_with_index do |to,n|
      users_str << to
      users_str << "," unless n == session[:mobile][:to].length - 1
    end
    flash[:mail_to] = users_str

    location = "/gw/memos/#{params[:memo_id]}/edit"
    session[:mobile] = nil
    return redirect_to location
  end

  def mobile_quote_memo
    session[:mobile] ||= {}
    session[:mobile][:to] ||= []
    session[:mobile][:to] += to_ids(params[:to])
    session[:mobile][:to].uniq!
    users_str = ""
    session[:mobile][:to].each_with_index do |to,n|
      users_str << to
      users_str << "," unless n == session[:mobile][:to].length - 1
    end
    flash[:mail_to] = users_str

    location = "/gw/memos/#{params[:memo_id]}/quote"
    session[:mobile] = nil
    return redirect_to location
  end

  def mobile_create_schedule
    session[:mobile] ||= {}
    session[:mobile][:to] ||= []
    session[:mobile][:to] += to_ids(params[:to])
    session[:mobile][:to].uniq!
    users_str = ""
    session[:mobile][:to].each_with_index do |to,n|
      users_str << to
      users_str << "," unless n == session[:mobile][:to].length - 1
    end
    flash[:mail_to] = users_str

    location = "/gw/schedules/new"
    location += "?gid=#{params[:gid]}&cgid=#{params[:cgid]}&dis=#{params[:dis]}"
    session[:mobile] = nil
    return redirect_to location
  end

  def mobile_edit_schedule
    session[:mobile] ||= {}
    session[:mobile][:to] ||= []
    session[:mobile][:to] += to_ids(params[:to])
    session[:mobile][:to].uniq!
    users_str = ""
    session[:mobile][:to].each_with_index do |to,n|
      users_str << to
      users_str << "," unless n == session[:mobile][:to].length - 1
    end
    flash[:mail_to] = users_str

    location = "/gw/schedules/#{params[:memo_id]}/edit"
    location += "?gid=#{params[:gid]}&cgid=#{params[:cgid]}&dis=#{params[:dis]}"
    session[:mobile] = nil
    return redirect_to location
  end

  def mobile_quote_schedule
    session[:mobile] ||= {}
    session[:mobile][:to] ||= []
    session[:mobile][:to] += to_ids(params[:to])
    session[:mobile][:to].uniq!
    users_str = ""
    session[:mobile][:to].each_with_index do |to,n|
      users_str << to
      users_str << "," unless n == session[:mobile][:to].length - 1
    end
    flash[:mail_to] = users_str

    location = "/gw/schedules/#{params[:memo_id]}/quote"
    location += "?gid=#{params[:gid]}&cgid=#{params[:cgid]}&dis=#{params[:dis]}"
    session[:mobile] = nil
    return redirect_to location
  end

  def mobile_delete_member

    delete_address = lambda do
      delete_str = ""
      params[:deleteMember].each {|key, value|
        delete_str = key
      }
      strs = delete_str.split('_')
      return false if strs.length < 2
      session[:mobile][strs[0].intern].delete_at(strs[1].to_i)
      true
    end

    if delete_address.call
      flash[:notice] = "1件の選択済みユーザーを削除しました。"
    else
      flash[:notice] = "選択済みユーザーを削除できませんでした。"
    end
  end

  def mobile_select_member
    session[:mobile] ||= {}
    select_num = 0
    over = false
    if session[:mobile][:to].blank?
      before_num = 0
    else
      before_num = session[:mobile][:to].length
    end
    if params[:to].blank?
      add_member = 0
    else
      add_member = params[:to].length
    end
    select = before_num + add_member
    if select >= 10
      flash[:notice] = "#{select_num}件のユーザーを選択しました。10人を越える送り先を選択することは出来ません。"
      return
    end
    session[:mobile] ||= {}
    session[:mobile][:to] ||= []

    session[:mobile][:to] += to_ids(params[:to])
    session[:mobile][:to].uniq!
    select_num += (session[:mobile][:to].length - before_num)
    flash[:notice] = "#{select_num}件のユーザーを選択しました。"
  end

  def to_ids(hash)
    ids = []
    unless hash.blank?
      hash.each do |h|
        ids << h[0]
      end
    end
    return ids
  end
end