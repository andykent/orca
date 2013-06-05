# This is an example Hull configuration file
# You will need to edit or define for youself at
# least one node and one package for hull to work.


# Define at least one or more nodes where you want
# package to be applied, nodes are usually
# physical or virtual machines.

node 'server', 'my.server.address'


# packages get applied to servers from the command line
# Most simple projects will have an 'app' package which
# defines all the projects dependancies.

package 'app' do
  depends_on 'my-package'
end


# Define the other packages that you will need...

package 'my-package' do
  apply do
    # your logic here
  end
end
