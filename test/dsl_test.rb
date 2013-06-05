require_relative 'test_helper'

describe Hull::DSL do
  describe "'package' command" do
    after :each do
      reset_package_index!
    end

    it "adds a package to the index" do
      Hull::DSL.package('my-package') { nil }
      Hull::PackageIndex.default.get('my-package').must_be_instance_of Hull::Package
    end

    it "creates a new package based on the supplied name" do
      Hull::DSL.package('my-package') { nil }
      package = Hull::PackageIndex.default.get('my-package')
      package.name.must_equal 'my-package'
    end

    it "executes the given definition block in the package context" do
      Hull::DSL.package('my-package') { depends_on 'other-package' }
      package = Hull::PackageIndex.default.get('my-package')
      package.dependancies.must_equal ['other-package']
    end
  end

  describe "'node' command" do
    it "creates a node and adds it to the index" do
      Hull::DSL.node('node-name', 'node-host')
      node = Hull::Node.find('node-name')
      node.name.must_equal 'node-name'
      node.host.must_equal 'node-host'
    end
  end
end