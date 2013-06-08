class Hull::Resolver
  attr_reader :packages, :tree
  def initialize(package)
    @package = package
    @last_seen = package
    @tree = [@package]
    @packages = []
  end

  def resolve
    dependancies = @package.dependancies.map { |d| Hull::PackageIndex.default.get(d) }
    begin
      @tree += dependancies.map {|d| Hull::Resolver.new(d).resolve.tree }
    rescue SystemStackError
      raise CircularDependancyError.new
    end
    @packages = @tree.flatten
    @packages.reverse!
    @packages.uniq!
    add_children
    self
  end

  def add_children
    @packages = @packages.reduce([]) do |arr, package|
      arr << package
      package.children.each do |child_name|
        child = Hull::PackageIndex.default.get(child_name)
        arr << child unless arr.include?(child)
      end
      arr
    end
  end

  class CircularDependancyError < StandardError
  end
end