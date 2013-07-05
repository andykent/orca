Orca.extension do

  # supports three formats
  # apt_package 'git-core' - create a package 'git-core' that installs 'git-core'
  # apt_package 'git', 'git-core' - creates a package 'git' that installs 'git-core'
  # apt_package 'git', package:'git-core', version:'1.7.2' - creates a package 'git' that installs 'git-core=1.7.2'
  module_function
  def apt_package(pkg_name, opts=pkg_name, &blk)
    apt_name = opts
    version = nil
    if opts.is_a? Hash
      version = opts[:version]
      apt_name = opts[:package] || pkg_name
    end
    package pkg_name do
      depends_on('apt')
      validate { trigger('apt:exists', apt_name, version) }
      apply do
        trigger('apt:update')
        trigger('apt:install', apt_name, version)
      end
      remove { trigger('apt:remove', apt_name, version) }
      instance_eval(&blk) if blk
    end
  end

  package 'apt' do
    action 'install' do |package_name, version=nil|
      package_description = [package_name, version].compact.join('=')
      sudo "DEBIAN_FRONTEND=noninteractive apt-get install -y -qq #{package_description}"
    end

    action 'remove' do |package_name, version=nil|
      package_description = [package_name, version].compact.join('=')
      sudo "DEBIAN_FRONTEND=noninteractive apt-get remove -y -qq #{package_description}"
    end

    action 'ppa' do |repo|
      sudo "DEBIAN_FRONTEND=noninteractive add-apt-repository #{repo} -y"
      trigger 'apt:update', true
    end

    action 'update' do |force=false|
      sudo "DEBIAN_FRONTEND=noninteractive apt-get update -y -qq", {:once => !force}
    end

    action 'exists' do |package_name, required_version=nil|
      pkg_info = run("dpkg -s #{package_name} 2>&1")
      installed = pkg_info =~ /Status: install ok installed/
      next false unless installed
      next true if required_version.nil?
      version = pkg_info.match(/^Version: (.+?)$/)[1]
      version_matches = (version == required_version)
      log("#{package_name}: expected '#{required_version}' but found '#{version}'") unless version_matches
      version_matches
    end

    validate do
      trigger('apt:exists', 'python-software-properties') &&
      trigger('apt:exists', 'software-properties-common')
    end

    apply do
      trigger 'apt:update'
      trigger 'apt:install', 'python-software-properties'
      trigger 'apt:install', 'software-properties-common'
    end

    remove do
      trigger 'apt:remove', 'python-software-properties'
      trigger 'apt:remove', 'software-properties-common'
    end
  end

end