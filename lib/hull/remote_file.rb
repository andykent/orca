require 'digest/sha1'
require 'fileutils'

class Hull::RemoteFile
  attr_reader :path

  def initialize(context, path)
    @context = context
    @path = path
    @exists = nil
  end

  def hash
    return nil unless exists?
    @hash ||= @context.run("sha1sum #{path}")[0...40]
  end

  def exists?
    return @exists unless @exists.nil?
    result = @context.run(%[if [ -f #{path} ]; then echo "true"; else echo "false"; fi])
    @exists = result.strip == 'true'
  end

  # deosnt check permissions or user. should it?
  def matches?(other)
    self.exists? && other.exists? && self.hash == other.hash
  end

  def copy_to(destination)
    if destination.is_local?
      download(destination)
    else
      duplicate(destination)
    end
    destination
  end

  def copy_from(destination)
    destination.copy_to(self)
  end

  def duplicate(destination)
    @context.run("cp #{path} #{destination.path}")
    destination
  end

  def download(destination)
    @context.download(path, destination.path)
  end

  def upload(source)
    @context.upload(source.path, path)
  end

  def delete!
    # FileUtils.rm(path)
    self
  end

  def set_permissions(mask)
    # FileUtils.chmod_R(mask, path)
    self
  end

  def permissions
    # File.stat(path).mode & 0777
  end

  def set_owner(user, group=nil)
    # FileUtils.chown_R(user, group, path)
    self
  end

  def is_local?
    false
  end
end