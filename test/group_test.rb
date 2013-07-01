require_relative 'test_helper'

describe Orca::Group do
  describe "#from_node" do
    it "creates a new group based on a node name" do
      node = mock(:name => 'test-node')
      Orca::Group.from_node(node)
      group = Orca::Group.find('test-node')
      group.must_be_instance_of(Orca::Group)
      group.name.must_equal('test-node')
      group.nodes.must_equal [node]
    end
  end

  describe ".node(name, host, options)" do
    it "adds a new node from parameters" do
      group = Orca::Group.new('test')
      group.node('mynode', 'myhost')
      group.nodes.size.must_equal 1
      group.nodes.first.name.must_equal 'mynode'
      group.nodes.first.host.must_equal 'myhost'
    end

    it "inherits config from the group" do
      group = Orca::Group.new('test', :user => 'testuser')
      group.node('mynode', 'myhost')
      group.nodes.size.must_equal 1
      group.nodes.first.name.must_equal 'mynode'
      group.nodes.first.host.must_equal 'myhost'
      group.nodes.first.user.must_equal 'testuser'
    end
  end

  describe ".add_node(node)" do
    it "adds a new node by object" do
      group = Orca::Group.new('test')
      node = mock
      group.add_node(node)
      group.nodes.must_equal [node]
    end
  end

  describe ".includes(other_group)" do
    it "copied the nodes from another group" do
      node = mock
      group = Orca::Group.new('test-a', {}, [node])
      group2 = Orca::Group.new('test-b')
      group2.nodes.must_equal []
      group2.includes(group)
      group2.nodes.must_equal [node]
    end

    it "copied the nodes from another group by name" do
      node = mock
      group = Orca::Group.new('test-a', {}, [node])
      group2 = Orca::Group.new('test-b')
      group2.nodes.must_equal []
      group2.includes('test-a')
      group2.nodes.must_equal [node]
    end
  end

  describe ".set(property, value)" do
    it "sets a config option for the group" do
      group = Orca::Group.new('test')
      group.set :user, 'testuser'
      group.config[:user].must_equal 'testuser'
    end
  end
end