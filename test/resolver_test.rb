require_relative 'test_helper'

describe Hull::Resolver do
  before :each do
    @pkg_a = Hull::DSL.package('a') {}
    @pkg_b = Hull::DSL.package('b') {}
    @pkg_c = Hull::DSL.package('c') {}
    @pkg_d = Hull::DSL.package('d') {}
  end

  after :each do
    reset_package_index!
  end

  describe "resolving a tree of package dependancies" do
    it "resolves single packages to a single package" do
      resolver = Hull::Resolver.new(@pkg_a)
      resolver.resolve
      resolver.packages.must_equal [@pkg_a]
    end

    it "resolves a chain of 2 packages to a list of 2 packages" do
      @pkg_a.depends_on(@pkg_b.name)
      resolver = Hull::Resolver.new(@pkg_a)
      resolver.resolve
      resolver.packages.must_equal [@pkg_b, @pkg_a]
    end

    it "resolves a chain of 3 packages to a list of 3 packages" do
      @pkg_a.depends_on(@pkg_b.name)
      @pkg_b.depends_on(@pkg_c.name)
      resolver = Hull::Resolver.new(@pkg_a)
      resolver.resolve
      resolver.packages.must_equal [@pkg_c, @pkg_b, @pkg_a]
    end

    it "resolves a tree of 3 packages to a list of 3 packages" do
      @pkg_a.depends_on(@pkg_b.name)
      @pkg_a.depends_on(@pkg_c.name)
      resolver = Hull::Resolver.new(@pkg_a)
      resolver.resolve
      resolver.packages.must_equal [@pkg_b, @pkg_c, @pkg_a]
    end

    it "resolves a tree of 4 packages to a list of 4 packages" do
      @pkg_a.depends_on(@pkg_b.name)
      @pkg_a.depends_on(@pkg_c.name)
      @pkg_c.depends_on(@pkg_d.name)
      resolver = Hull::Resolver.new(@pkg_a)
      resolver.resolve
      resolver.packages.must_equal [@pkg_b, @pkg_d, @pkg_c, @pkg_a]
    end

    it "errors out on circular dependancies" do
      @pkg_a.depends_on(@pkg_b.name)
      @pkg_b.depends_on(@pkg_a.name)
      resolver = Hull::Resolver.new(@pkg_a)
      assert_raises(Hull::Resolver::CircularDependancyError) { resolver.resolve }
    end
  end
end