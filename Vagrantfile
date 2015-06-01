#!/usr/bin/env ruby
# -*- mode:ruby;tab-width:2;indent-tabs-mode:nil;coding:utf-8 -*-
# vim: ft=ruby syn=ruby fileencoding=utf-8 sw=2 ts=2 ai eol et si
#
# Vagranfile: Vagrant + Docker + SSH sample Vagrant file
# (c) 2014-2015 Laurent Vallar <val@zbla.net>, WTFPL license v2 see below.
#
# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What The Fuck You Want
# To Public License, Version 2, as published by Sam Hocevar. See
# http://www.wtfpl.net/ for more details.

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'docker'
VAGRANTFILE_API_VERSION         = '2'
ENV['LC_ALL']                   = 'en_US.UTF-8'

Vagrant.configure( VAGRANTFILE_API_VERSION ) do |config|

  config.vm.provider( :docker ) do |docker|
    docker.build_dir            = '.'
    docker.has_ssh              = true
    docker.remains_running      = true
    docker.name                 = 'jessie-docker'
    docker.build_args           = [ '-t', 'jessie-docker' ]
  end

	config.vm.network :forwarded_port, guest: 3000, host: 3000, auto_correct: true

  config.vm.synced_folder('/dev/shm', '/dev/shm') if File.directory? '/dev/shm'

  config.vm.hostname            = "jessie-docker"

  config.ssh.username           = "vagrant"
  config.ssh.forward_x11        = false
  config.ssh.forward_agent      = false
  config.ssh.pty                = true
  config.ssh.insert_key         = true

end
