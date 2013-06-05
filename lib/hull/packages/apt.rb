module Hull::DSL
  def apt_package(pkg_name, apt_name=pkg_name, &blk)
    package pkg_name do
      depends_on 'apt'
      validate { trigger 'apt:exists', apt_name  }
      apply    { trigger 'apt:install', apt_name }
      remove   { trigger 'apt:remove', apt_name  }
      instance_eval(&blk) if blk
    end
  end

  package 'apt' do
    action 'install' do |package_name|
      run "DEBIAN_FRONTEND=noninteractive apt-get install -y -q #{package_name}"
    end

    action 'remove' do |package_name|
      run "DEBIAN_FRONTEND=noninteractive apt-get remove -y -q #{package_name}"
    end

    action 'ppa' do |repo|
      run "DEBIAN_FRONTEND=noninteractive add-apt-repository #{repo} -y"
    end

    action 'update' do
      run "DEBIAN_FRONTEND=noninteractive apt-get update -y -qq"
    end

    action 'exists' do |package_name|
      run("dpkg -s #{package_name} 2>&1 | grep Status") =~ /Status: install ok installed/
    end

    validate do
      trigger('apt:exists', 'python-software-properties') &&
      trigger('apt:exists', 'software-properties-common')
    end

    apply do
      trigger 'apt:install', 'python-software-properties'
      trigger 'apt:install', 'software-properties-common'
      trigger 'apt:update'
    end

    remove do
      trigger 'apt:remove', 'python-software-properties'
      trigger 'apt:remove', 'software-properties-common'
    end
  end
end