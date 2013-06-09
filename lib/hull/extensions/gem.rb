Hull.extension :gem do
  def gem_package(pkg_name, gem_name=pkg_name)
    package pkg_name do
      depends_on 'gem' # should depend on Ruby but which???
      validate { trigger 'gem:exists', gem_name  }
      apply    { trigger 'gem:install', gem_name }
      remove   { trigger 'gem:remove', gem_name  }
    end
  end

  package 'gem' do
    action 'exists' do |gem_name|
      run("gem list -i #{gem_name}") =~ /true/
    end

    action 'install' do |gem_name|
      run "gem install #{gem_name} --no-ri --no-rdoc"
    end

    action 'remove' do |gem_name|
      run "gem uninstall #{gem_name} -x -a"
    end
  end
end