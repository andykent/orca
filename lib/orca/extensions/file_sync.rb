Orca.extension do
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
    raise ArgumentError.new('A file :source  or template must be provided') unless @config[:source] or @config[:template]
    raise ArgumentError.new('A file :destination must be provided') unless @config[:destination]
  end

  def local_path(context)
    value_for context, @config[:source]
  end

  def template_path(context)
    value_for context, @config[:template]
  end

  def local_path_for_node(context)
    return local_path(context) if @config[:source]
    Orca::Template.new(context.node, template_path(context)).render_to_tempfile
  end

  def remote_path(context)
    value_for context, @config[:destination]
  end

  def permissions(context)
    value_for context, @config[:permissions]
  end

  def user(context)
    value_for context, @config[:user]
  end

  def group(context)
    value_for context, @config[:group]
  end

  def create_dir(context)
    value_for context, (@config[:create_dir] || @config[:create_dirs])
  end

  def package_name(suffix)
    name = @config[:name]
    if name.nil? && !@config[:destination].is_a?(String)
      raise ArgumentError.new("You must provide a :name option unless :destination is a String")
    end
    name ||= @config[:destination]
    "file-#{suffix}[#{name}]"
  end

  def configure
    fs = self
    add_content_package
    add_permissions_package unless @config[:permissions].nil? and @config[:user].nil? and @config[:group].nil?
  end

  def run_after_apply(context)
    context.instance_eval(&@after_apply) if @after_apply
  end

  def add_content_package
    fs = self
    add_package('content') do |package|
      package.command :apply do
        if fs.create_dir(self)
          mk_dir = fs.create_dir(self) == true ? File.dirname(fs.remote_path(self)) : fs.create_dir(self)
          sudo("mkdir -p #{mk_dir}")
          sudo("chown #{fs.user(self)}:#{fs.group(self) || fs.user(self)} #{mk_dir}") if fs.user(self)
        end
        local_file = local(fs.local_path_for_node(self))
        tmp_path = "orca-upload-#{local_file.hash}"
        local_file.copy_to(remote(tmp_path))
        sudo("mv #{tmp_path} #{fs.remote_path(self)}")
        fs.run_after_apply(self)
      end

      package.command :remove do
        remote(fs.remote_path(self)).delete!
      end

      package.command :validate do
        local(fs.local_path_for_node(self)).matches?(remote(fs.remote_path(self)))
      end
    end
  end

  def add_permissions_package
    fs = self
    add_package('permissions') do |package|
      package.command :apply do
        remote(fs.remote_path(self)).set_owner(fs.user(self), fs.group(self)) unless fs.user(self).nil? and fs.group(self).nil?
        remote(fs.remote_path(self)).set_permissions(fs.permissions(self)) unless fs.permissions(self).nil?
        fs.run_after_apply(self)
      end

      package.command :validate do
        r_file = remote(fs.remote_path(self))
        valid = r_file.permissions == fs.permissions(self)
        valid = valid && r_file.user == fs.user(self) if fs.user(self)
        valid = valid && r_file.group == fs.group(self) if fs.group(self)
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

  def value_for(context, option)
    return nil if option.nil?
    return context.instance_exec(&option) if option.respond_to?(:call)
    option
  end
end