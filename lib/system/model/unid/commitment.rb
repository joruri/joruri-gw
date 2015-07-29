# encoding: utf-8
module System::Model::Unid::Commitment
  def self.included(mod)
    mod.has_many :commitments, :primary_key => 'unid', :foreign_key => 'unid', :class_name => 'System::Commitment',
      :order => :id, :dependent => :destroy
  end

  def commit(params = {})
    com         = System::Commitment.new
    com.unid    = unid
    com.version = params[:version] || Core.now.gsub(/[^0-9]/, '')
    com.name    = params[:name]
    com.value   = params[:value]
    com.save
  end

  def collect_recent_commitments
    coms = []
    System::Commitment.find(:all, :conditions => {:unid => unid}, :group => :version, :order => 'version DESC').each do |com|
      conditions = {:unid => unid, :version => com.version}
      coms << System::Commitment.find(:all, :conditions => conditions, :order => :name)
    end
    coms
  end
end