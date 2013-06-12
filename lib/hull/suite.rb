class Hull::Suite

  def load_file(file)
    Hull::DSL.module_eval(File.read(file))
  end

  def execute(node_name, pkg_name, command)
    node = Hull::Node.find(node_name)
    pkg = Hull::PackageIndex.default.get(pkg_name)
    Hull::Runner.new(node, pkg).execute(command)
  end

  def demonstrate(node_name, pkg_name, command)
    node = Hull::Node.find(node_name)
    pkg = Hull::PackageIndex.default.get(pkg_name)
    Hull::Runner.new(node, pkg).demonstrate(command)
  end
end