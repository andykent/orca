module Orca
  module DSL
    module_function
    def package(name, &definition)
      Orca.add_package(name) do |pkg|
        pkg.instance_eval(&definition)
      end
    end

    def load_extension(name)
      Orca.load_extension(name)
    end

    def node(name, host, options={})
      Orca::Node.new(name, host, options)
    end
  end
end