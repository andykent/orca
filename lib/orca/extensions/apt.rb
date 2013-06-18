Orca.extension :apt do
  module_function
  def apt_package(pkg_name, apt_name=pkg_name, &blk)
    package pkg_name do
      depends_on 'apt'
      validate { trigger 'apt:exists', apt_name  }
      apply    do
        trigger 'apt:update'
        trigger 'apt:install', apt_name
      end
      remove   { trigger 'apt:remove', apt_name  }
      instance_eval(&blk) if blk
    end
  end

  package 'apt' do
    action 'install' do |package_name|
      sudo "DEBIAN_FRONTEND=noninteractive apt-get install -y -qq #{package_name}"
    end

    action 'remove' do |package_name|
      sudo "DEBIAN_FRONTEND=noninteractive apt-get remove -y -qq #{package_name}"
    end

    action 'ppa' do |repo|
      sudo "DEBIAN_FRONTEND=noninteractive add-apt-repository #{repo} -y"
    end

    action 'update' do
      sudo "DEBIAN_FRONTEND=noninteractive apt-get update -y -qq"
    end

    action 'exists' do |package_name|
      run("dpkg -s #{package_name} 2>&1 | grep Status") =~ /Status: install ok installed/
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