class Hull::FileSystem
  def initialize(context)
    @context = context
  end

  def local(path)
    Hull::LocalFile.new(path)
  end

  def remote(path)
    Hull::RemoteFile.new(@context, path)
  end
end