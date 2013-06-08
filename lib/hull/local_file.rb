require 'digest/sha1'
require 'fileutils'

class Hull::LocalFile
  attr_reader :path

  def initialize(path)
    @path = resolve(path)
  end

  def resolve(path)
    if path =~ /^\//
      path
    else
      File.join(Hull.root, path)
    end
  end

  def hash
    return nil unless exists?
    Digest::SHA1.file(path).hexdigest
  end

  def exists?
    File.exists?(@path)
  end

  # deosnt check permissions or user. should it?
  def matches?(other)
    self.exists? && other.exists? && self.hash == other.hash
  end

  def copy_to(destination)
    if destination.is_local?
      duplicate(destination)
    else
      upload(destination)
    end
    destination
  end

  def copy_from(destination)
    destination.copy_to(self)
  end

  def duplicate(destination)
    FileUtils.cp(path, destination.path)
    destination
  end

  def upload(destination)
    destination.upload(self)
  end

  def delete!
    FileUtils.rm(path) if exists?
    self
  end

  def set_permissions(mask)
    FileUtils.chmod_R(mask, path)
    self
  end

  def permissions
     File.stat(path).mode & 0777
  end

  def set_owner(user, group=nil)
    FileUtils.chown_R(user, group, path)
    self
  end

  def is_local?
    true
  end
end