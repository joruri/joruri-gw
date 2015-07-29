# encoding: utf-8
module System::Model::Unid::Publication
  def self.included(mod)
    mod.belongs_to :publisher, :foreign_key => 'unid', :class_name => 'System::Publisher',
      :dependent => :destroy

  end

  def public_status
    return published_at ? '公開中' : '非公開'
  end

  def public_path
    Core.public_path + public_uri
  end

  def public_uri
    '/hoge'
  end

  def preview_uri
    '/_preview' + public_uri
  end

  def publish_uri
    Core.uri(:protocol => true) + '_publish' + public_uri
  end

  def publishable
    editable
    self.and "state", 'recognized'
    return self
  end

  def closable
    editable
    public
    return self
  end

  def publishable?
    editable?
    return state == 'recognized' ? true : false
  end

  def rebuildable?
    editable?
    return published_at != nil ? true : false
  end

  def closable?
    editable?
    return published_at.nil? ? false : true
  end

  def request_publish_data
    status       = nil
    data         = ''
    page_data    = nil
    content_data = nil

    req = Util::Http::Request.new
    res = req.send(publish_uri)

    return nil if res[:status] != 200

    pub = {}
    xml = REXML::Document.new(res[:body])
    xml[1].each_child do |c|

    end

    return pub
  end

  def publish(options = {})
    @save_mode = :publish

    bak = {:state => state_was, :published_at => published_at}
    self.state        = 'public'
    self.published_at = Core.now if published_at == nil || options[:skip_update] == nil
    return false unless save

    unless res = request_publish_data
      dump "#{Core.now.to_s} request faild!"
      @save_mode = nil
      update_attributes(bak)
      return false
    end
    return false unless Util::File.put(public_path, :data => res[:page_data], :mkdir => true)

    pub                = publisher || System::Publisher.new
    pub.published_at   = Core.now
    pub.published_path = public_path
    pub.name           = File.basename(public_path)
    pub.content_type   = res[:page_type]
    pub.content_length = res[:page_size]
    if pub.id
      return false unless pub.save
    else
      pub.id         = unid
      pub.created_at = Core.now
      pub.updated_at = Core.now
      return false unless pub.save_with_direct_sql
    end
    publisher(true)

    if self.class.include?(System::Model::Unid::Commitment)
      commit(:name => 'attributes', :value => to_xml(:root => 'item', :indent => 0))
      commit(:name => 'page',       :value => res[:page_data])    if res[:page_data]
      commit(:name => 'content',    :value => res[:content_data]) if res[:content_data]
    end
    return true
  end

  def rebuild

  end

  def close
    @save_mode = :close

    publisher.destroy if publisher
    publisher(true)

    self.state        = 'closed' if self.state == 'public'
    self.published_at = nil
    save
  end
end