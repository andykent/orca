load_package 'apt'


package 'ubuntu-dev' do
  depends_on 'build-essential'
  depends_on 'git'
end

package 'build-essential' do
  depends_on 'apt'

  install do
    trigger 'apt:install', 'build-essential'
  end

  remove do
    trigger 'apt:remove', 'build-essential'
  end
end


package 'git' do
  install do
    trigger 'apt:install', 'git-core'
  end

  remove do
    trigger 'apt:remove', 'git-core'
  end
end


node 'kent-web-1', '198.211.122.159'



# apply 'kent-web-1', 'ubuntu-dev', :install
# demonstrate '198.211.122.159', 'ubuntu-dev', :install