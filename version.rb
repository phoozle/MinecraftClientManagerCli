class MinecraftManager::Version
  class << self
    attr_accessor :mode
  end
  self.mode = :client
  
  URL = "http://assets.minecraft.net/"
  FILTERS = {:server => /.*\/minecraft_server\.jar$/, :client => /.*\/minecraft\.jar$/}
  attr_reader :version, :url, :size, :last_modified, :filename
  
  def self.find(filter)
    all.keep_if {|version| version.version =~ /^#{filter}$/}.first
  end
  
  def self.snapshots
    all.keep_if {|version| version.version =~ /^\d{2}w\d{2}\w{1}$/}
  end
  
  def self.releases
    all.keep_if {|version| version.version =~ /^(\d\_?)+$/}
  end
  
  def initialize(attributes)
    @filename = attributes["Key"].split("/").last
    @version = attributes["Key"].split("/").first
    @url = URL+attributes["Key"]
    @size = attributes["Size"].to_i
    @last_modified = Time.parse attributes["LastModified"]
  end
  
  def self.all
    contents = XmlSimple.xml_in(self.xml, :ForceArray => false)["Contents"]
    contents.keep_if {|asset| asset["Key"] =~ FILTERS[self.mode]} # Filter by mode (client or server)
    versions = contents.map { |version| new version } # Creates class instances
    return versions.sort {|x,y| x.last_modified.to_i <=> y.last_modified.to_i } # Sort by date modified
  end
  
  private
  
  def self.xml
    open(URL).read
  end
  
end