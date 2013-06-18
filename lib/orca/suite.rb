class Orca::Suite

  def load_file(file)
    Orca::DSL.module_eval(File.read(file))
  end

  def execute(node_name, pkg_name, command)
    node = Orca::Node.find(node_name)
    pkg = Orca::PackageIndex.default.get(pkg_name)
    Orca::Runner.new(node, pkg).execute(command)
  end

  def demonstrate(node_name, pkg_name, command)
    node = Orca::Node.find(node_name)
    pkg = Orca::PackageIndex.default.get(pkg_name)
    Orca::Runner.new(node, pkg).demonstrate(command)
  end
end