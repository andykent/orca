Orca
====

**Because building servers shouldn't be a PITA.**

Orca is a super simple way to build and configure servers.

If you've found yourself stuck in the gap between deployment tools like Capistrano and full blown infrastructure tools like Puppet and Chef then Orca is probably for you. This is especially the case if you choose to cycle machines and prefer baking from scratch when changes are required rather than attempting to converge system state (although you can build convergent systems using Orca if you wish).


What problem does Orca try to solve?
------------------------------------

All too often you need to get a new server up and running to a known state so that you can get an app deployed. Before Orca there were boardly 4 options...

1. Start from scratch and hand install all the packages, files, permissions, etc. Yourself via trial and error over SSH.
2. Use a deployment tool like Capistrano to codeify your shell scripts into semi-reusable steps.
3. Use Puppet or Chef in single machine mode.
4. Use Full blown Puppet or Chef, this requires a server.

Orca fills the rather large gap between (2) and (3). It's a bigger gap then you think as both Puppet and Chef require...

- bootstrapping a machine to a point where you are able to run them
- Creating a seperate repository describing the configuration you require
- learning their complex syntaxes and structures
- hiding the differences of different host OSes

Orca fixes these problems by...

- working directly over SSH, all you need is a box tht you can connect to
- package definitions can all go in a single file and most servers can be configured in ~50 lines
- packages are defined in a ruby based DSL that consists of only 5 very basic commands to learn
- Orca makes no assumptions about the underlying OS accept to assume it supports SSH
- Orca is extensible and adding platform specific features like package manger support can be achieved in a dozen or so lines.


What problems is Orca avoiding?
-------------------------------

Orca intentionally skirts around some important thengs that may or may not matter to you. If they do then you are probably better using more robust tools such as Puppet or Chef.

Orca doesn't...

- try to scale beyond a smallish number of nodes
- have any algorithms that attempt to run periodically and converge divergent configurations
- abstract the differences of different host OSes
- provide a server to supervise infrastructure configuration


Installation
------------

To install orca you will need to be running Ruby 1.9 or 2.0 and then install the orca gem...

    gem install orca

or ideally add it to your gemfile...

    gem 'orca'


Command Line Usage
------------------

To get started from within your projct you can run...

    orca init .

This will create a config/orca.rb file for you to get started with.

To ship run a command the syntax is as follows...

    orca [command] [package] [node]

So here are some examples (assuming you have a package called "app" and a node called "server" defined in your orca.rb)...

    orca apply app server
    orca remove app server

You can also directly trigger actions from the CLI like so...

    orca trigger nginx:reload web-1

Options, all commands support the following optional parameters...

    --demonstrate       | dont actually run the commands on the server just pretend like you are
    --sequential        | dont attempt to run commands accross multiple nodes in parrallel
    --throw             | throw a stack trace rather than pretty printing errors
    --file              | path to the orca.rb file to load, defaults to ./orca/orca.rb
    --verbose           | print all SSH output, useful for debugging but can be rather long
    --skip-dependancies | Don't validate and run dependancies, only the pkg in question


The Orca DSL
------------

Orca packages are written in a Ruby based DSL. It's really simple to learn in less than 5 mins. Here's an example orca.rb file with all you'll need to know to get started...

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

A more complete WIP example can be found in this gist... https://gist.github.com/andykent/5814997


Extensions
----------

The core of Orca doesn't have any platform specific logic but is designed to be a foundation to build apon. Extensions can be written in their own files, projects or gems, simply `require 'orca'` and then use the `Orca.extension` helper.

Some example extensions are included in this repo and can be required into your orca.rb file if you need them...

`require "orca/extensions/apt"` - Adds support for specifying aptitude dependancies with the `apt_package` helper.

`relative "orca/extensions/file_sync"` - Adds support for syncing and converging local/remove files with the `file` action.


Extras
------

*Vagrant Provisioner Plugin*
https://github.com/andykent/vagrant-orca
Allows you to completely provision a machine with `vagrant up`
