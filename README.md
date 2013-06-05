Hull
====

**Because building servers shouldn't be a PITA.**

Hull is a super simple implementation of infrastructure as code prinicples.

If you've found yourself stuck in the gap between deployment tools like Capistrano and full blown infrastructure tools like Puppet and Chef then Hull is probably for you.


What problem does Hull try to solve?
------------------------------------

All too often you need to get a new server up and running to a known state so that you can get an app deployed. Before Hull there were largely 4 options...

1. Start from scratch and hand install all the packages, files, permissions, etc. Yourself via trial and error over SSH.
2. Use a deployment tool like Capistrano to codeify your shell scripts into semi-reusable steps.
3. Use Puppet or Chef in single machine mode.
4. Use Full blown Puppet or Chef, this requires a server.

Hull fills the rather large gap between (2) and (3). It's a bigger gap then you think as both Puppet and Chef require...

- bootstrapping a machine to a point where you are able to run them
- Creating a seperate repository describing the configuration you require
- learning their complex syntaxes and structures
- hiding the differences of different host OSes

Hull fixes these problems by...

- working directly over SSH, all you need is a box tht you can connect to
- package definitions all go in a single file and most servers can be configured in ~50 lines
- packages are defined in a ruby based DSL that consists of only 5 commands to learn
- Hull makes no assumptions about the underlying OS accept to assume it supports SSH


What problems is Hull avoiding?
-------------------------------

Hull intentionally skirts around some important thengs that may or may not matter to you. If they do then you are probably better using more robust tools such as Puppet or Chef.

Hull doesn't...

- try to scale beyond a smallish number of nodes
- have any algorithyms that attempt to run periodically and converge divergent configurations
- abstract the differences of different host OSes
- provide a server to supervise infrastructure configuration


Installation
------------

To install hull you will need to be running Ruby 1.9 or 2.0 and then install the hull gem from this repository...

    gem 'hull', :git => 'git@github.com:andykent/hull.git'


Command Line Usage
------------------

To get started from within your projct you can run...

    bundle exec hull init .

This will create a config/hull.rb file for you to get started with.

To ship a run a command the syntax is as follows...

    hull [command] [package] [node]

So here are some examples (assuming you have a package called "app" and a node called "server" defined in your hull.rb)...

    hull apply app server
    hull remove app server
    hull demonstrate app server


The Hull DSL
------------

Hull packages are written in a Ruby based DSL. It's really simple to learn in less than 5 mins. Here's an example hull.rb file with all you need to know...

    # define a new pacage called 'gem' that provides some actions for managing rubygems
    package 'gem' do
      depends_on 'ruby-1.9.3'                           # this package depends on another package called ruby-1.9.3
      action 'exists' do |gem_name|                     # define an action that other packages can trigger called 'exists'
        run("gem list -i #{gem_name}") =~ /true/        # execute the command, get the output and check it contains 'true'
      end
      action 'install' do |gem_name|
        run "gem install #{gem_name} --no-ri --no-rdoc"
      end
      action 'uninstall' do |gem_name|
        run "gem uninstall #{gem_name} -x -a"
      end
    end

    # define a package called 'bundler' that can be used to manage the gem by the same name
    package 'bundler' do
      depends_on 'gem'
      apply do                                # apply gets called whenever this package or a package that depends on it is applied
        trigger('gem:install', 'bundler')     # trigger triggers defined actions, in this case the action 'instal' on 'gem'
      end
      remove do                               # remove gets called whenever this package or a package that depends on it is removed
        trigger('gem:remove', 'bundler')
      end
      validate do                             # validate is used internally to check if the package is applied correctly or not
        trigger('gem:exists', 'bundler')
      end
    end
