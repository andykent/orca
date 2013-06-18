class Orca::PackageIndex
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
    raise MissingPackageError.new(index_name, pkg_name) if pkg.nil?
    pkg
  end

  def clear!
    @packages = {}
  end

  class MissingPackageError < StandardError
    def initialize(index_name, package_name)
      @index_name = index_name
      @package_name = package_name
    end

    def message
      "package #{@package_name} could not be found in the index #{@index_name}"
    end
  end
end