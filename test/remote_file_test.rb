require_relative 'test_helper'

describe Orca::RemoteFile do
  before :each do
    @local_file_path = File.join(File.dirname(__FILE__), 'fixtures', 'example.txt')
    @local_file = Orca::LocalFile.new(@local_file_path)
    @remote_file_path = '/tmp/example.txt'
    @context = mock()
    @remote_file = Orca::RemoteFile.new(@context, @remote_file_path)
  end

  describe 'path' do
    it "returns the absolute path of a local file" do
      @remote_file.path.must_equal @remote_file_path
    end
  end

  describe 'hash' do
    it "returns the sha1 of a remote file" do
      @context.expects(:run)
              .with(%[if [ -f #{@remote_file_path} ]; then echo "true"; else echo "false"; fi])
              .returns("true\n")
      @context.expects(:run)
              .with("sha1sum #{@remote_file_path}")
              .returns("c3499c2729730a7f807efb8676a92dcb6f8a3f8f #{@remote_file_path}")
      @remote_file.hash.must_equal 'c3499c2729730a7f807efb8676a92dcb6f8a3f8f'
    end
  end

  describe 'matches' do
    it "returns true if the passed file has a matching hash" do
      @context.expects(:run)
              .with(%[if [ -f #{@remote_file_path} ]; then echo "true"; else echo "false"; fi])
              .returns("true\n")
      @context.expects(:run)
              .with("sha1sum #{@remote_file_path}")
              .returns("c3499c2729730a7f807efb8676a92dcb6f8a3f8f #{@remote_file_path}")
      @remote_file.matches?(@remote_file).must_equal true
    end
  end

  describe 'exists?' do
    it "checks if a file exists" do
      @context.expects(:run)
              .with(%[if [ -f #{@remote_file_path} ]; then echo "true"; else echo "false"; fi])
              .returns("true\n")
      @remote_file.exists?.must_equal true
    end

    it "checks if a missing file exists" do
      @context.expects(:run)
              .with(%[if [ -f #{@remote_file_path} ]; then echo "true"; else echo "false"; fi])
              .returns("false\n")
      @remote_file.exists?.must_equal false
    end
  end

  describe 'copy_to' do
    it "copies a file to another remote location" do
      @remote_destination_context = mock()
      @remote_destination = Orca::RemoteFile.new(@remote_destination_context, "/tmp/example-dest.txt")
      @context.expects(:sudo)
              .with(%[cp #{@remote_file.path} #{@remote_destination.path}])
              .returns("true\n")
      @remote_file.copy_to(@remote_destination).must_equal @remote_destination
    end

    it "copies a file to local location by downlaoding it" do
      @local_destination = Orca::LocalFile.new("/tmp/example-#{Time.now.to_i}.txt")
      @context.expects(:download)
              .with(@remote_file_path, @local_destination.path)
      @remote_file.copy_to(@local_destination).must_equal @local_destination
    end
  end

  describe 'delete!' do
    it "removes the file from the remote server" do
      @context.expects(:run)
              .with(%[if [ -f #{@remote_file_path} ]; then echo "true"; else echo "false"; fi])
              .returns("true\n")
      @context.expects(:remove).with(@remote_file.path)
      @remote_file.delete!
    end

    it "doesn't delete missing files" do
      @context.expects(:run)
              .with(%[if [ -f #{@remote_file_path} ]; then echo "true"; else echo "false"; fi])
              .returns("false\n")
      @context.expects(:remove).with(@remote_file.path).never
      @remote_file.delete!
    end
  end

  describe 'set_permissions' do
    it "sets permissions on the file based on a mask" do
      @context.expects(:sudo).with('chmod -R 644 /tmp/example.txt')
      @context.expects(:run).with("stat --format=%a /tmp/example.txt").returns("644\n")
      @remote_file.set_permissions(0644).must_equal @remote_file
      @remote_file.permissions.must_equal 0644
    end
  end
end