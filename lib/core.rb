class Core
  ## Core attributes.
  cattr_reader   :now
  cattr_reader   :config
  cattr_accessor :title
  cattr_reader   :map_key
  cattr_reader   :env
  cattr_reader   :params
###  cattr_reader   :mode
###  cattr_reader   :site
  cattr_reader   :script_uri
  cattr_reader   :request_uri
  cattr_reader   :internal_uri
###  cattr_reader   :current_node
  cattr_accessor :ldap
  cattr_accessor :imap
  cattr_accessor :user
  cattr_accessor :user_group
  cattr_accessor :dispatched
###  cattr_accessor :concept
  cattr_accessor :messages

  ## Initializes.
  def self.initialize(env = nil)
    @@now          = Time.now.to_s(:db)
    @@config       = Util::Config.load(:core)
    @@title        = @@config['title'] || 'Joruri'
    @@map_key      = @@config['map_key']
    @@env          = env
    @@params       = parse_query_string(env)
###    @@mode         = nil
###    @@site         = nil
    @@script_uri   = env['SCRIPT_URI'] || "http://#{env['HTTP_HOST']}#{env['PATH_INFO']}"
    @@request_uri  = nil
    @@internal_uri = nil
###    @@current_node = nil
    @@ldap         = nil
    @@imap         = nil
    @@user         = nil
    @@user_group   = nil
    @@dispatched   = nil
###    @@concept      = nil
    @@messages     = []

    #require 'page'
    Page.initialize
  end

  ## Now.
  def self.now
    return @@now if @@now
    return @@now = Time.now.to_s(:db)
  end

  ## Absolute path.
  def self.uri
    @@config['uri'].sub(/^[a-z]+:\/\/[^\/]+\//, '/')
  end

  ## Full URI.
  def self.full_uri
    @@config['uri']
  end

  ## Proxy.
  def self.proxy
    @@config['proxy']
  end

  ## Parses query string.
  def self.parse_query_string(env)
    env['QUERY_STRING'] ? CGI.parse(env['QUERY_STRING']) : nil
  end

###  ## Sets the mode.
###  def self.set_mode(mode)
###    old = @@mode
###    @@mode = mode
###    return old
###  end

  ## LDAP.
  def self.ldap
    return @@ldap if @@ldap
    @@ldap = Sys::Lib::Ldap.new
  end

  ## IMAP.
  def self.imap
    return @@imap if @@imap
    @@imap = Sys::Lib::Net::Imap.connect
  end

  ## Controller was dispatched?
  def self.dispatched?
    @@dispatched
  end

  ## Controller was dispatched.
  def self.dispatched
    @@dispatched = true
  end

  ## Recognizes the path for dispatch.
  def self.recognize_path(path)
###    Page.error    = false
    Page.uri      = path
###    @@request_uri = path
    @@request_uri = @@internal_uri = path

###    self.recognize_mode
###    self.recognize_site if @mode != 'script'
###
###    @@internal_uri = '/404.html' unless @@internal_uri
  end

###  def self.search_node(path)
###    return nil unless Page.site
###
###    if path =~ /\.html\.r$/
###      Page.ruby = true
###      path = path.gsub(/\.r$/, '')
###    end
####    if path =~ /\/index\.html$/
####      path = path.gsub(/index\.html$/, '')
####    end
###    if path =~ /\/$/
###      path += 'index.html'
###    end
###
###    node     = nil
###    rest     = ''
###    paths    = path.gsub(/\/+/, '/').split('/')
###    paths[0] = '/'
###
###    paths.size.times do |i|
###      if i == 0
###        current = Cms::Node.find(Page.site.node_id)
###      else
###        n = Cms::Node.new
###        n.and :site_id  , Page.site.id
###        n.and :parent_id, node.id
###        n.and :name     , paths[i]
###        n.public if @@mode != 'preview'
###        current = n.find(:first)
###      end
###      break unless current
###
###      node = current
###      rest = paths.slice(i + 1, paths.size).join('/')
###    end
###    return nil unless node
###
###    @@current_node = node
###    return "/_public/#{node.model.underscore.pluralize.gsub(/^(.*?\/)/, "\\1node_")}/#{rest}"
###  end

###  def self.concept(key = nil)
###    return nil unless @@concept
###    key.nil? ? @@concept : @@concept.send(key)
###  end

###  def self.set_concept(session, concept_id = nil)
###    if concept_id
###      @@concept = Cms::Concept.find_by_id(concept_id)
###      @@concept = Cms::Concept.new.readable_children[0] unless @@concept
###      session[:cms_concept] = (@@concept ? @@concept.id : nil)
###    else
###      concept_id = session[:cms_concept]
###      @@concept = Cms::Concept.find_by_id(concept_id)
###      @@concept = Cms::Concept.new.readable_children[0] unless @@concept
###    end
###  end

  def self.terminate
    if @@ldap
      @@ldap.connection.unbind rescue nil
      @@ldap = nil
    end
    if @@imap
      @@imap.logout rescue nil
      @@imap.disconnect rescue nil
      @@imap = nil
    end
  end

private
###  def self.recognize_mode
###    if (@@request_uri =~ /^\/_[a-z]+(\/|$)/)
###      @@mode = @@request_uri.gsub(/^\/_([a-z]+).*/, '\1')
###    else
###      @@mode = 'public'
###    end
###  end

###  def self.recognize_site
###    case @@mode
###    when 'admin'
###      @@site         = self.get_site_by_cookie
###      Page.site      = @@site
###      @@internal_uri = @@request_uri
###      @@current_node = nil
###    when 'preview'
###      site_id        = @@request_uri.gsub(/^\/_[a-z]+\/([0-9]+)(.*)/, '\1').to_i
###      @@site         = Cms::Core.find(site_id)
###      Page.site      = @@site
###      @@internal_uri = search_node @@request_uri.gsub(/^\/_[a-z]+\/[0-9]*(.*)/, '\1')
###    when 'public'
###      @@site         = Cms::Core.find_by_script_uri(@@script_uri)
###      Page.site      = @@site
###      #if @@site.nil? && env['SCRIPT_URI'].index(Core.full_uri) == 0
###      #  @@site       = Cms::Core.find(:first, :order => :id)
###      #end
###      @@internal_uri = search_node @@request_uri
###    when 'files'
###      @@site         = Cms::Core.find_by_script_uri(@@script_uri)
###      Page.site      = @@site
###      @@internal_uri = @@request_uri
###    when 'script'
###      @@site         = nil
###      Page.site      = @@site
###      @@internal_uri = @@request_uri
###      @@current_node = nil
###    end
###  end

###  def self.get_site_by_cookie
###    site_id = self.get_cookie('cms_site')
###    return Cms::Core.find_by_id(site_id) if site_id
###    return Cms::Core.find(:first, :order => :id)
###  end

###  def self.get_cookie(name)
###    cookies = CGI::Cookie.parse(Core.env['HTTP_COOKIE'])
###    return cookies[name].value.first if cookies.has_key?(name)
###    return nil
###  end
end
