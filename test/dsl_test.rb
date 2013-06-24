require_relative 'test_helper'

describe Orca::DSL do
  describe "'package' command" do
    after :each do
      reset_package_index!
    end

    it "adds a package to the index" do
      Orca::DSL.package('my-package') { nil }
      Orca::PackageIndex.default.get('my-package').must_be_instance_of Orca::Package
    end

    it "creates a new package based on the supplied name" do
      Orca::DSL.package('my-package') { nil }
      package = Orca::PackageIndex.default.get('my-package')
      package.name.must_equal 'my-package'
    end

    it "executes the given definition block in the package context" do
      Orca::DSL.package('my-package') { depends_on 'other-package' }
      package = Orca::PackageIndex.default.get('my-package')
      package.dependancies.must_equal ['other-package']
    end
  end

  describe "'node' command" do
    it "creates a node and adds it to the index" do
      Orca::DSL.node('node-name', 'node-host')
      node = Orca::Node.find('node-name')
      node.name.must_equal 'node-name'
      node.host.must_equal 'node-host'
    end
  end

  describe "'group' command" do
    it "creates a group" do
      Orca::DSL.group('group-name')
      group = Orca::Group.find('group-name')
      group.must_be_instance_of Orca::Group
      group.name.must_equal 'group-name'
    end

    it "evals in the group context" do
      node = mock
      Orca::DSL.group('group-name') { add_node(node) }
      group = Orca::Group.find('group-name')
      group.nodes.must_equal [node]
    end
  end
end