Orca.extension :file_sync do
  class Orca::Package
    def file(config, &blk)
      Orca::FileSync.new(self, config, &blk).configure
    end
  end
end

class Orca::FileSync
  def initialize(parent, config, &blk)
    @parent = parent
    @config = config
    @after_apply = blk
    raise ArgumentError.new('A file :source must be provided') unless local_path
    raise ArgumentError.new('A file :destination must be provided') unless remote_path
  end

  def local_path
    @config[:source]
  end

  def remote_path
    @config[:destination]
  end

  def permissions
    @config[:permissions]
  end

  def user
    @config[:user]
  end

  def group
    @config[:group]
  end

  def create_dir
    @config[:create_dir] || @config[:create_dirs]
  end

  def package_name(suffix)
    "file-#{suffix}[#{remote_path}]"
  end

  def configure
    fs = self
    add_content_package
    add_permissions_package unless permissions.nil? and user.nil? and group.nil?
  end

  def run_after_apply(context)
    context.instance_eval(&@after_apply) if @after_apply
  end

  def add_content_package
    fs = self
    add_package('content') do |package|
      package.command :apply do
        if fs.create_dir
          mk_dir = fs.create_dir == true ? File.dirname(fs.remote_path) : fs.create_dir
          sudo("mkdir -p #{mk_dir}")
          sudo("chown #{fs.user}:#{fs.group || fs.user} #{mk_dir}") if fs.user
        end
        local_file = local(fs.local_path)
        tmp_path = "orca-upload-#{local_file.hash}"
        local_file.copy_to(remote(tmp_path))
        sudo("mv #{tmp_path} #{fs.remote_path}")
        fs.run_after_apply(self)
      end

      package.command :remove do
        remote(fs.remote_path).delete!
      end

      package.command :validate do
        local(fs.local_path).matches?(remote(fs.remote_path))
      end
    end
  end

  def add_permissions_package
    fs = self
    add_package('permissions') do |package|
      package.command :apply do
        remote(fs.remote_path).set_owner(fs.user, fs.group) unless fs.user.nil? and fs.group.nil?
        remote(fs.remote_path).set_permissions(fs.permissions) unless fs.permissions.nil?
        fs.run_after_apply(self)
      end

      package.command :validate do
        r_file = remote(fs.remote_path)
        valid = r_file.permissions == fs.permissions
        valid = valid && r_file.user == fs.user if fs.user
        valid = valid && r_file.group == fs.group if fs.group
        valid
      end
    end
  end

  def add_package(suffix)
    package = Orca.add_package(package_name(suffix))
    yield(package)
    @parent.triggers(package.name)
    package
  end
end