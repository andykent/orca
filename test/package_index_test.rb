require_relative 'test_helper'

describe Hull::PackageIndex do
  before :each do
    @package = Hull::Package.new('my-package')
    @default = Hull::PackageIndex.default
  end

  after :each do
    reset_package_index!
  end

  describe "default" do
    it "returns a package index singleton named default" do
      Hull::PackageIndex.default.index_name.must_equal 'default'
    end

    it "allways returns the same package index" do
      Hull::PackageIndex.default.must_equal Hull::PackageIndex.default
    end
  end

  describe "add" do
    it "adds a package to the index" do
      @default.add(@package)
      @default.get(@package.name).must_equal @package
    end
  end

  describe 'get' do
    it "fetches a package by name" do
      @default.add(@package)
      @default.get(@package.name).must_equal @package
    end

    it "throws an execption if the package doesn't exist" do
      assert_raises(Hull::PackageIndex::MissingPackageError) { @default.get(@package.name) }
    end
  end

  describe "clear!" do
    it "wipes the index clean of packages" do
      @default.add(@package)
      @default.clear!
      assert_raises(Hull::PackageIndex::MissingPackageError) { @default.get(@package.name) }
    end
  end
end