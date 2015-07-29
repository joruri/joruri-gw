# encoding: utf-8
class System::Script::Task
  def self.publish
    puts "#{self}.publish"
    dump "#{self}.publish"
    success = 0
    error   = 0

    task = System::Task.new
    task.and :process_at, '<=', Core.now
    task.find(:all, :order => :process_at).each do |task|
      next unless unid = task.unid_data

      item_class = eval("#{unid.module.camelize}::#{unid.item_type.singularize.camelize}")
      item = item_class.find(unid.item_id)

      args = []

      case task.name
      when 'publish'
        next unless item.state == 'recognized'
      when 'close'
        next unless item.published_at
      else
        puts "unid=#{unid.id}, do=[unknown]"
        next
      end

      next unless item.content
      next unless item.content.site
      Core.set_attributes_by_site(item.content.site)

      puts "unid=#{unid.id}, do=#{task.name}"

      if item.send(task.name, *args)
        System::Task.delete(task.id)
        puts "  => success.\n"
        success += 1
      else
        puts "  => failed.\n"
        error   += 1
      end
    end

    puts "#{Core.now} - Success:#{success}, Error:#{error}"
    dump "#{Core.now} - Success:#{success}, Error:#{error}"
  end
end
