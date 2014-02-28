# == Class: hadoop::sqoop
#
# Install and manages sqoop2 tool designed for efficiently transferring bulk data between
# Hadoop and structured datastores such as relational databases
#
# === Parameters
#
# None.
#
# === Variables
#
# None.
#
# === Requires
#
# Java
# Hadoop
#
# === Sample Usage
#
# include hadoop::sqoop
#
# === Copyright
#
# Copyright 2012 Cloudwick Technologies, unless otherwise noted.
#

class hadoop::sqoop inherits hadoop::params::default {
  include $::hadoop::params::default::repo_class
  include java

  if ($hadoop::params::default::deployment_mode == 'cdh') {
    package { 'sqoop2-server':
      ensure  => installed,
      require => [ File['java-app-dir'], Class[$::hadoop::params::default::repo_class] ]
    }

    package { 'sqoop2-client':
      ensure  => installed,
      require => [ File['java-app-dir'], Class[$::hadoop::params::default::repo_class] ]
    }

    file { '/etc/default/sqoop2-server':
      alias   => 'sqoop-server-defaults',
      content => template('hadoop/sqoop/sqoop2-server.erb'),
      require => Package['sqoop2-server'],
      notify  => Service['sqoop2-server']
    }

    service { 'sqoop2-server':
      ensure  => running,
      enable  => true,
      require => File['sqoop-server-defaults'],
    }

    file { '/var/lib/sqoop2/mysql-connector-java-5.1.22-bin.jar':
      source  => 'puppet:///modules/hadoop/mysql-connector-java-5.1.22-bin.jar',
      require => Package['sqoop2-server'],
    }
  } else {
    package { 'sqoop':
      ensure  => installed,
      require => [ File['java-app-dir'], Class[$::hadoop::params::default::repo_class] ]
    }
  }
}