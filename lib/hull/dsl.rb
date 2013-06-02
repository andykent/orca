module Hull
  module DSL
    module_function
    def package(name, &definition)
      pkg = Hull::Package.new(name)
      pkg.instance_eval(&definition)
      Hull::PackageIndex.default.add(pkg)
    end

    def apply(node_name, pkg_name, command)
      node = Hull::Node.find(node_name)
      pkg = Hull::PackageIndex.default.get(pkg_name)
      Hull::Runner.new(node, pkg).apply(command)
    end

    def demonstrate(node_name, pkg_name, command)
      node = Hull::Node.find(node_name)
      pkg = Hull::PackageIndex.default.get(pkg_name)
      Hull::Runner.new(node, pkg).demonstrate(command)
    end

    def load_package(name)
      require_relative("./packages/#{name}")
    end

    def node(name, host)
      Hull::Node.new(name, host)
    end
  end
end