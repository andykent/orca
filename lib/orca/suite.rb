class Orca::Suite

  def load_file(file)
    Orca::DSL.module_eval(File.read(file))
  end

  def execute(group_name, pkg_name, command)
    group = Orca::Group.find(group_name)
    group.nodes.each do |node|
      pkg = Orca::PackageIndex.default.get(pkg_name)
      Orca::Runner.new(node, pkg).execute(command)
    end
  end

  def demonstrate(group_name, pkg_name, command)
    group = Orca::Group.find(group_name)
    group.nodes.each do |node|
      pkg = Orca::PackageIndex.default.get(pkg_name)
      Orca::Runner.new(node, pkg).demonstrate(command)
    end
  end
end