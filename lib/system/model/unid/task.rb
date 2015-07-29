# encoding: utf-8
module System::Model::Unid::Task
  def self.included(mod)
    mod.has_many :tasks, :primary_key => 'unid', :foreign_key => 'unid', :class_name => 'System::Task',
      :dependent => :destroy

    mod.after_save :save_tasks
  end

  attr_accessor :_tasks

  def find_task_by_name(name)
    return nil if tasks.size == 0
    tasks.each do |task|
      return task.process_at if task.name == name
    end
    return nil
  end

  def save_tasks
    return true  unless _tasks
    return false unless unid
    return false if @save_tasks_callback_flag

    @save_tasks_callback_flag = true

    _tasks.each do |k, date|
      name  = k.to_s

      if date == ''
        tasks.each do |task|
          task.destroy if task.name == name
        end
      else
        items = []
        tasks.each do |task|
          if task.name == name
            items << task
          end
        end

        if items.size > 1
          items.each {|task| task.destroy}
          items = []
        end

        if items.size == 0
          task = System::Task.new({:unid => unid, :name => name, :process_at => date})
          task.save
        else
          items[0].process_at = date
          items[0].save
        end
      end
    end

    tasks(true)
    return true
  end
end