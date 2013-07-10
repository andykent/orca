require 'erb'
require 'tilt'

class Orca::Template
  def initialize(node, path)
    @node = node
    @path = resolve(path)
    @template = Tilt.new(@path)
  end

  def render(locals={})
    @template.render(@node, locals)
  end

  def render_to_tempfile(locals={})
    basename = File.basename(@path).gsub('.', '-')
    file = Tempfile.new(basename)
    file.write render(locals)
    file.close
    file.path
  end

  private

  def resolve(path)
    if path =~ /^\//
      path
    else
      File.join(Orca.root, path)
    end
  end
end