require_relative 'test_helper'

describe Hull::LocalFile do
  before :each do
    @local_file_path = File.join(File.dirname(__FILE__), 'fixtures', 'example.txt')
    @local_file = Hull::LocalFile.new(@local_file_path)
  end

  describe 'path' do
    it "returns the absolute path of a local file" do
      @local_file.path.must_equal @local_file_path
    end
  end

  describe 'hash' do
    it "returns the sha1 of a local file" do
      @local_file.hash.must_equal 'c3499c2729730a7f807efb8676a92dcb6f8a3f8f'
    end
  end

  describe 'matches' do
    it "returns true if the passed file has a matching hash" do
      @local_file.matches?(@local_file).must_equal true
    end
  end

  describe 'exists?' do
    it "checks if a file exists" do
      @local_file.exists?.must_equal true
    end
  end

  describe 'copy_to' do
    before(:each) { @destination = Hull::LocalFile.new("/tmp/example-#{Time.now.to_i}.txt") }
    after(:each)  { @destination.delete! }

    it "copies a file to another local location" do
      @destination.exists?.must_equal false
      @local_file.copy_to(@destination).must_equal @destination
      @destination.exists?.must_equal true
    end

    it "copies a file to a remote location by uploading it" do
      @remote_destination_context = mock()
      @remote_destination = Hull::RemoteFile.new(@remote_destination_context, "/tmp/example-dest.txt")
      @remote_destination_context.expects(:upload).with(@local_file.path, @remote_destination.path)
      @local_file.copy_to(@remote_destination).must_equal @remote_destination
    end
  end

  describe 'set_permissions' do
    it "sets permissions on the file based on a mask" do
      @local_file.set_permissions(0664).must_equal @local_file
      @local_file.permissions.must_equal 0664
      @local_file.set_permissions(0644).must_equal @local_file
      @local_file.permissions.must_equal 0644
    end
  end
end