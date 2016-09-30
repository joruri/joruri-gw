# encoding: utf-8
## gwsub
puts "Import sb01 demo"

user1 = System::User.where(code: 'user1').first
group1 = System::Group.where(code: '001002').first

fyed_id_today = Gw::YearFiscalJp.get_record(Date.today)

from_date = Time.now
to_date   = from_date + 3.weeks

training = Gwsub::Sb01Training.create({
  fyear_id: fyed_id_today.id,
  fyear_markjp: fyed_id_today.markjp,
  categories: 1,
  state: 1,
  bbs_doc_id:  nil,
  bbs_url: nil,
  title: '人権意識向上研修',
  body: read_data('gwsub/sb01'),
  group_id: group1.id,
  member_id: user1.id,
  member_tel: '000-0000-0000'
})

condition = Gwsub::Sb01TrainingScheduleCondition.create({
  training_id: training.id ,
  title: training.title ,
  state: 2 ,
  member_id: user1.id,
  group_id: group1.id,
  repeat_flg: 2 ,
  from_at: from_date ,
  to_at: to_date ,
  from_start: '14' ,
  from_start_min: '00' ,
  from_end: '16' ,
  from_end_min: '00' ,
  repeat_class_id: 3 ,
  repeat_weekday: '2',
  prop_name: '第三会議室' ,
  prop_kind: '9',
  members_max: 30
})

repeats = Gwsub::Sb01TrainingScheduleCondition.repeat_dates(condition)

if condition.repeat_flg == '2'
  skd_repeat = Gw::ScheduleRepeat.new({
    :st_date_at  => condition.from_at,
    :ed_date_at  => condition.to_at,
    :st_time_at  => '2010-04-01 '+ condition.from_start+ ':' + condition.from_start_min,
    :ed_time_at  => '2010-04-01 '+ condition.from_end+ ':' + condition.from_end_min,
    :class_id    => condition.repeat_class_id,
    :weekday_ids => condition.repeat_weekday
  })
  if skd_repeat.save
    repeat_id = skd_repeat.id
  else
    repeat_id = nil
  end
else
  repeat_id = nil
end

repeats.each do |s|
  skd = Gw::Schedule.new({
      :title_category_id  => 300 ,
      :title              => s[0] ,
      :place_category_id  => nil ,
      :is_public          => 1 ,
      :is_pr              => nil ,
      :memo               => nil ,
      :inquire_to         => condition.training_rel.member_tel ,
      :place              => condition.prop_name,
      :repeat_id          => repeat_id,
      :st_at              => s[1] ,
      :ed_at              => s[2] ,
      :creator_uid        => condition.training_rel.member_id ,
      :creator_ucode      => condition.training_rel.member_code ,
      :creator_uname      => condition.training_rel.member_name ,
      :creator_gid        => condition.training_rel.group_id ,
      :creator_gcode      => condition.training_rel.group_code ,
      :creator_gname      => condition.training_rel.group_name ,
      :updater_uid        => condition.training_rel.member_id ,
      :updater_ucode      => condition.training_rel.member_code ,
      :updater_uname      => condition.training_rel.member_name ,
      :updater_gid        => condition.training_rel.group_id ,
      :updater_gcode      => condition.training_rel.group_code ,
      :updater_gname      => condition.training_rel.group_name ,
      :owner_uid          => condition.training_rel.member_id ,
      :owner_ucode        => condition.training_rel.member_code ,
      :owner_uname        => condition.training_rel.member_name ,
      :owner_gid          => condition.training_rel.group_id ,
      :owner_gcode        => condition.training_rel.group_code ,
      :owner_gname        => condition.training_rel.group_name
    })
  skd.save!
  # メンバー
  skd_user = Gw::ScheduleUser.new({
    :schedule_id      =>  skd.id ,
    :class_id         =>  1 ,
    :uid              =>  s[4],
    :st_at              => s[1],
    :ed_at              => s[2]
    })
  skd_user.save!
  # 研修スケジュール
  skd_training = Gwsub::Sb01TrainingSchedule.new({
    :training_id      =>  condition.training_id.to_i ,
    :condition_id     =>  condition.id.to_i ,
    :schedule_id      =>  skd.id.to_i ,
    :members_max      =>  s[5].to_i ,
    :members_current  =>  0,
    :state            =>  condition.training_rel.state,
    :from_start       =>  s[1] ,
    :from_end         =>  s[2],
    :prop_name        =>  condition.prop_name
  })
  skd_training.save!
end


training.update_columns(state: 2)

Gwsub::Sb01TrainingSchedule.where("training_id=#{training.id}").update_all("state='2'")
