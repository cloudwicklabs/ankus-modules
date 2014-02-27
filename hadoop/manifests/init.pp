# == Class: hadoop
#
# This module installs and manages hadoop, framework that allows for
# the distributed processing of large data sets across clusters of computers
# using simple programming models
#
# === Parameters
#
# None
#
# === Variables
#
# None
#
# === Requires
#
# Java
# Kerberos (if security is enabled)
# puppetlabs-stdlib
# puppetlabs-apt
#
# === Sample Usage
#
# include hadoop::namenode
# include hadoop::secondarynamenode
# include hadoop::jobtracker
# include hadoop::datanode
# include hadoop::tasktracker
# include hadoop::resourcemanger
# include hadoop::jobhistoryproxyserver
# include hadoop::nodemanager
#
# === Authors
#
# Ashrith <ashrith@cloudwick.com>
#
# === Copyright
#
# Copyright 2012 Cloudwick Inc, unless otherwise noted.
#

class hadoop {
}