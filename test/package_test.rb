require_relative 'test_helper'

describe Orca::Package do
  before :each do
    @package = Orca::Package.new('my-package')
  end

  describe "depends_on" do
    it "adds a dependancy" do
      @package.dependancies.must_equal []
      @package.depends_on('other-package')
      @package.dependancies.must_equal ['other-package']
    end

    it "adds multiple dependancies at once" do
      @package.dependancies.must_equal []
      @package.depends_on('other-package', 'third-package')
      @package.dependancies.must_equal ['other-package', 'third-package']
    end
  end

  describe "action" do
    it "allows defining actions with a name and a block" do
      @package.action('my-action') { 'foo' }
      @package.actions['my-action'].call.must_equal 'foo'
    end
  end

  describe "commands" do
    it "can add an 'apply' command" do
      @package.apply { 'my-apply' }
      @package.command(:apply).first.call.must_equal 'my-apply'
    end

    it "can add an 'remove' command" do
      @package.remove { 'my-remove' }
      @package.command(:remove).first.call.must_equal 'my-remove'
    end

    it "can add an 'validate' command" do
      @package.validate { 'my-validate' }
      @package.command(:validate).first.call.must_equal 'my-validate'
    end

    it 'knows if a command is provided' do
      @package.provides_command?(:apply).must_equal false
      @package.apply { 'my-apply' }
      @package.provides_command?(:apply).must_equal true
    end
  end
end