class Hull::PackageIndex
  attr_reader :index_name

  def initialize(index_name)
    @index_name = index_name
    @packages = {}
  end

  def self.default
    @default ||= new('default')
  end

  def add(pkg)
    @packages[pkg.name] = pkg
  end

  def get(pkg_name)
    pkg = @packages[pkg_name]
    raise "Missing Package #{pkg_name}" if pkg.nil?
    pkg
  end
end