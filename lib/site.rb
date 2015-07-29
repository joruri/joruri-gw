class Site
  def self.user
    Core.user
  end

  def self.user_group
    Core.user_group
  end

  def self.mode
    #ひとまず admin を返す
    'admin'
  end

  def self.request_path

  end

  def self.title
    site = YAML.load_file('config/site.yml')
    site['gw_information']['title']
  end

  def self.parent_user_groups
    self.user_group.parent_tree
  end

end

#class Site < Core
#
#end

=begin
class Site < Core

#  def self.context
#    return ::JoruriContext[self.to_s] if ::JoruriContext[self.to_s]
#    ctx = {}
#    ctx.instance_eval{
#      def logger
#        @logger ||= RAILS_DEFAULT_LOGGER
#      end
#      def []=(k,v)
#        logger.debug { "set context value. thread=#{Thread.current.inspect}, #{k}=#{v.inspect}" }
#        super(k,v)
#      end
#    }
#    ::JoruriContext[self.to_s] = ctx
#  end
#
#  def self.request_path
#    context[:request_path]
#  end
#  def self.internal_path
#    context[:internal_path]
#  end
#  def self.upload_path
#    context[:upload_path]
#  end
#  def self.uri
#    context[:uri]
#  end
#  def self.request_uri
#    context[:request_uri]
#  end
#  def self.mode
#    context[:mode]
#  end
#  def self.root_node
#    context[:root_node]
#  end
#  def self.current_node
#    context[:current_node]
#  end
#  def self.current_node=(v)
#    context[:current_node] = v
#  end
#
#  def self.env
#    context[:env]
#  end
#  def self.env=(v)
#    context[:env] = v
#  end
#  def self.current_item
#    context[:current_item]
#  end
#  def self.current_item=(v)
#    context[:current_item] = v
#  end
#  def self.current_piece
#    context[:current_piece]
#  end
#  def self.current_piece=(v)
#    context[:current_piece] = v
#  end
#  def self.user
#    context[:user]
#  end
#  def self.user=(v)
#    context[:user] = v
#  end
#  def self.user_group
#    context[:user_group]
#  end
#  def self.user_group=(v)
#    context[:user_group] = v
#  end
#  def self.mobile
#    context[:mobile]
#  end
#  def self.mobile=(v)
#    context[:mobile] = v
#  end
#  def self.format
#    context[:format]
#  end
#  def self.format=(v)
#    context[:format] = v
#  end
#
#  def self.id
#    context[:id]
#  end
#  def self.id=(v)
#    context[:id] = v
#  end
#  def self.domain
#    context[:domain]
#  end
#  def self.domain=(v)
#    context[:domain] = v
#  end
#  def self.name
#    context[:name]
#  end
#  def self.name=(v)
#    context[:name] = v
#  end
#  def self.node_id
#    context[:node_id]
#  end
#  def self.node_id=(v)
#    context[:node_id] = v
#  end
#  def self.mobile_is
#    context[:mobile_is]
#  end
#  def self.mobile_is=(v)
#    context[:mobile_is] = v
#  end
#
#  def self.config
#    context[:config]
#  end
#  def self.proxy
#    context[:proxy]
#  end
#  def self.ruby
#    context[:ruby]
#  end
#  def self.ruby=(v)
#    context[:ruby] = v
#  end
#
#  def self.ldap_use
#    [0,1].index(GW_USE_LDAP).nil? ? nil : (GW_USE_LDAP == 1)
#  end
#  def self.max_level
#    GW_GROUP_MAX_LEVEL
#  end
#  def self.code_length(level)
#    return nil if (1..GW_GROUP_CODE_LENGTH.length).to_a.index(level).nil?
#    GW_GROUP_CODE_LENGTH[level - 1] rescue nil
#  end
#
#  def self.initialize(path)
#    Core.now       = Time.now.to_s(:db)
#    Page.error     = false
#    context[:root_node]    = Cms::Node.find_by_name('/')
#    context[:current_node] = nil
#    context[:request_uri]  = path
#    context[:request_path] = path.gsub(/#.*/, '')
#    context[:upload_path]  = File.join(Rails.root, 'upload')
#    initialize_uri(path)
#    initialize_mode
#    initialize_path
#    pp_public_dispatch_log [
#      "root_node", "current_node", "request_uri", "request_path", "upload_path",
#      "uri", "mode", "internal_path"
#    ].collect{|x| {x => eval("context[:#{x}]")} }.unshift({"position" => "Site#initialize"}) if context[:mode] == "public"
#  end
#
#
#  def self.public_path
#    Rails.public_path
#  end
#
#  def self.uri(options = {})
#    if options[:protocol]
#      'http://' + Util::Config.load('site', 'domain') + '/'
#    elsif options[:http]
#      'http://' + Util::Config.load('site', 'domain') + '/'
#    elsif options[:https]
#      'https://' + Util::Config.load('site', 'domain') + '/'
#    else
#      context[:uri]
#    end
#  end
#
#  def self.find_mobile_node
#    node     = nil
#    rest     = ''
#    paths    = context[:request_uri].split('/')
#    paths[0] = '/'
#
#    paths.size.times do |i|
#      next if paths[i] == ''
#
#      _node = Cms::Node.new
#      _node.public if context[:mode] != 'preview'
#      _node.parent_id = node ? node.id : 0
#      _node.name      = paths[i]
#
#      _node.and :id, 2 if paths[i] == '/'
#      break unless tmp = _node.find(:first)
#
#      node = tmp
#      rest = paths.slice(i + 1, paths.size).join('/')
#    end
#    return node
#  end
#
#  private
#  def self.initialize_uri(path)
#    context[:uri] = '/'
#  end
#
#  def self.initialize_mode
#    if context[:request_path] =~ /^\/_admin/
#      context[:mode] = 'admin'
#    elsif context[:request_path] =~ /^\/_[a-z]+\//
#      context[:mode] = context[:request_path].gsub(/^\/_([a-z]+).*/, '\1')
#    else
#      context[:mode] = 'public'
#    end
#  end
#
#  def self.initialize_path
#    context[:internal_path] = '404.html'
#
#    case context[:mode]
#      when 'admin'
#      context[:internal_path] = context[:request_path]
#      when 'tool'
#      context[:internal_path] = context[:request_path]
#      when 'preview'
#
#      context[:request_path] = context[:request_path].gsub(/^\/_[a-z]+(.*)/, '\1')
#      context[:internal_path] = initialize_node context[:request_path]
#      when 'publish'
#      context[:request_path] = context[:request_path].gsub(/^\/_[a-z]+(.*)/, '\1')
#      context[:internal_path] = initialize_node context[:request_path]
#      when 'public'
#      context[:internal_path] = initialize_node context[:request_path]
#    end
#  end
#
#  def self.initialize_node(path)
#    node     = nil
#    rest     = ''
#    paths    = path.split('/')
#    paths[0] = '/'
#
#    paths.size.times do |i|
#      next if paths[i] == ''
#
#      _node = Cms::Node.new
#      _node.public if context[:mode] != 'preview'
#      _node.parent_id = node ? node.id : 0
#      _node.name      = paths[i]
#      break unless tmp = _node.find(:first)
#
#      node = tmp
#      rest = paths.slice(i + 1, paths.size).join('/')
#    end
#    return '404.html' unless node
#
#    context[:current_node] = node
#    pp_public_dispatch_log [
#      "node.module", "node.controller", "rest"
#    ].collect{|x| {x => eval(x)} }.unshift({"position" => "Site#initialize_node"}) if context[:mode] == "public"
#    return File.join('/_public', node.module, node.controller, rest)
#  end
end

=end