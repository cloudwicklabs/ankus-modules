# == Class: hadoop-flume
#
# This module installs and manages Flume, which is a distributed, reliable, and 
# available service for efficiently collecting, aggregating, and moving large 
# amounts of log data. 
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
# Hadoop
#
# === Sample Usage
#
# include hadoop-flume::client
# include hadoop-flume::agent
# include hadoop-flume::master
#
# === Authors
#
# Ashrith <ashrith@cloudwick.com>
#
# === Copyright
#
# Copyright 2012 Cloudwick Technologies, unless otherwise noted.
#


class hadoop-flume {
  class client {
    package { "flume":
      ensure => latest,
    } 
  }

  #flume node
  class agent {
    package { "flume-node":
      ensure => latest,
    } 

    service { "flume-node":
      ensure => running,
      require => Package["flume-node"],
      # FIXME: this need to be fixed in upstream flume
      hasstatus => false,
      hasrestart => true,
    }
  }

  class master {
    package { "flume-master":
      ensure => latest,
    } 

    service { "flume-master":
      ensure => running,
      require => Package["flume-node"],
      # FIXME: this need to be fixed in upstream flume
      hasstatus => true,
      hasrestart => true,
    }
  }
}