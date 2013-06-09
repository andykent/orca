module Hull
  module DSL
    module_function
    def package(name, &definition)
      Hull.add_package(name) do |pkg|
        pkg.instance_eval(&definition)
      end
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

    def load_extension(name)
      Hull.load_extension(name)
    end

    def node(name, host)
      Hull::Node.new(name, host)
    end
  end
end