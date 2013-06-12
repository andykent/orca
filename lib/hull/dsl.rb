module Hull
  module DSL
    module_function
    def package(name, &definition)
      Hull.add_package(name) do |pkg|
        pkg.instance_eval(&definition)
      end
    end

    def load_extension(name)
      Hull.load_extension(name)
    end

    def node(name, host, options={})
      Hull::Node.new(name, host, options)
    end
  end
end