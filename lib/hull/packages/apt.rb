module Hull::DSL
  package 'apt' do
    action 'install' do |package_name|
      run "DEBIAN_FRONTEND=noninteractive apt-get install -y -q #{package_name}"
    end

    action 'remove' do |package_name|
      run "DEBIAN_FRONTEND=noninteractive apt-get remove -y -q #{package_name}"
    end
  end
end