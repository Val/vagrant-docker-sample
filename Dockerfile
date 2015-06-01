# -*- mode:dockerfile;tab-width:2;indent-tabs-mode:nil;coding:utf-8 -*-
# vim: ft=sh syn=sh fileencoding=utf-8 sw=2 ts=2 ai eol et si
#
# Dockerfile: Vagrant + Docker + SSH sample Docker file
# (c) 2014-2015 Laurent Vallar <val@zbla.net>, WTFPL license v2 see below.
#
# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What The Fuck You Want
# To Public License, Version 2, as published by Sam Hocevar. See
# http://www.wtfpl.net/ for more details.

FROM debian:jessie
MAINTAINER Laurent Vallar "val@zbla.net"
LABEL Description="Vagrant + Docker + SSH sample image" \
  Vendor="ACME Products" Version="1.0"

# Tell debconf to run in non-interactive mode
ENV DEBIAN_FRONTEND noninteractive

# Fix TERM
ENV TERM linux

# Set some build environment variables
ENV DEB_MIRROR http://httpredir.debian.org/debian/
ENV DEB_SECURITY_MIRROR http://security.debian.org/
ENV DEB_COMPONENTS main contrib non-free
ENV VAGRANT_UNSECURE_SSH_KEY \
  https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub

# Create sources.list & update Apt database
RUN echo "deb $DEB_MIRROR jessie $DEB_COMPONENTS" > /etc/apt/sources.list && \
  echo "deb $DEB_SECURITY_MIRROR jessie/updates $DEB_COMPONENTS" \
    >> /etc/apt/sources.list && \
  echo "deb $DEB_MIRROR jessie-proposed-updates $DEB_COMPONENTS" \
    >> /etc/apt/sources.list && \
  echo "deb $DEB_MIRROR jessie-backports $DEB_COMPONENTS" \
    >> /etc/apt/sources.list && \
  apt-get update

# Disable Apt recommends and suggests
RUN echo 'APT::Install-Recommends "0";' \
    > /etc/apt/apt.conf.d/30disable-recommends && \
  echo 'APT::Install-Suggests "0";' \
    > /etc/apt/apt.conf.d/40disable-suggests

# We need ssh to access the instance
RUN /bin/echo -e "locales\tlocales/default_environment_locale\tselect\tNone" \
    | debconf-set-selections && \
  /bin/echo -e \
    "locales\tlocales/locales_to_be_generated\tmultiselect\ten_US.UTF-8 UTF-8" \
  | debconf-set-selections

# Install packages & cleanup
RUN apt-get install -y openssh-server vim-tiny locales localepurge sudo curl \
  psmisc bind9-host iputils-ping telnet netcat net-tools ca-certificates && \
  apt-get autoremove -y && apt-get clean

# Create and configure vagrant user
RUN useradd -m vagrant -s /bin/bash && \
  ( echo "vagrant:vagrant" | chpasswd ) && \
  adduser vagrant sudo && \
  install -o vagrant -g vagrant /dev/null /home/vagrant/.Xauthority && \
  install -o vagrant -g vagrant -m 700 -d /home/vagrant/.ssh

# Add unsecure Vagrant key
RUN sudo -u vagrant curl -vL $VAGRANT_UNSECURE_SSH_KEY \
  > /home/vagrant/.ssh/authorized_keys

# Set locale (fix locale warnings)
RUN localedef -v -c -i en_US -f UTF-8 en_US.UTF-8 || :

# Set Timezone
RUN echo "Etc/UTC" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata

# Create sshd run directory
RUN mkdir -p /run/sshd && chmod 0755 /run/sshd

# Cleanups
RUN rm -rf /tmp/* /var/tmp/*

# Allow SSH serveur connections
EXPOSE 22

# Start ssh services.
CMD ["/usr/sbin/sshd", "-4", "-D", "-o", "UseDNS=no", "-o", "UsePAM=no" ]
