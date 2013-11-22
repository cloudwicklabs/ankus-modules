# == Class: cassandra
#
# installs and manages datastax cassandra dsc 2.0
#
# === Parameters
#
# cassandra::params
#
# === Variables
#
# None
#
# === Requires
#
# Java.
#
# === Sample Usage
#
# include cassandra
#
# === Authors
#
# Ashrith <ashrith@cloudwick.com>
#
# === Copyright
#
# Copyright 2012 Cloudwick Technologies, unless otherwise noted.
#

class cassandra {

  include java
  require cassandra::params
  require utilities::repos

  $cassandra_deploy = hiera('cassandra_deploy')
  $seeds = $cassandra_deploy['cassandra_seeds']

  case $operatingsystem {
    'Ubuntu': {
      package { "dsc20":
        ensure => latest,
        require => [ File["java-app-dir"], Apt::Source['datastax-repo'] ],
      }
    }
    'CentOS': {
      package { "dsc20":
        ensure => latest,
        require => [ File["java-app-dir"], Yumrepo["datastax-repo"] ],
      }
    }
  }

  mkdir_p { "${cassandra::params::data_dirs}":
    ensure => present,
  }

  file { "${cassandra::params::data_path}":
    ensure => directory,
    owner => cassandra,
    group => cassandra,
    mode => 700,
    require => [Package["dsc20"], Mkdir_p["${cassandra::params::data_dirs}"]],
  }

  file { "${cassandra::params::commitlog_directory}":
    ensure => directory,
    owner => cassandra,
    group => cassandra,
    mode => 700,
    require => [Package["dsc20"], Mkdir_p["${cassandra::params::data_dirs}"]],
  }

  file { "${cassandra::params::saved_caches}":
    ensure => directory,
    owner => cassandra,
    group => cassandra,
    mode => 700,
    require => [Package["dsc20"], Mkdir_p["${cassandra::params::data_dirs}"]],
  }

  file { "${cassandra::params::cassandra_base}/conf/cassandra.yaml":
    ensure  => present,
    alias   => 'conf',
    require => Package['dsc20'],
    content => template("cassandra/conf/cassandra.yaml.erb"),
    notify  => Service['cassandra'];
  }

  file { "${cassandra::params::cassandra_base}/conf/cassandra-env.sh":
    ensure  => present,
    alias   => 'conf-env',
    require => Package['dsc20'],
    content => template("cassandra/conf/cassandra-env.sh.erb"),
    notify  => Service['cassandra'];
  }

  service { "cassandra":
    enable => true,
    ensure => running,
    hasrestart => true,
    hasstatus => true,
    require => [Package['dsc20'],
                File['conf',
                      'conf-env',
                      "${cassandra::params::data_path}",
                      "${cassandra::params::commitlog_directory}",
                      "${cassandra::params::saved_caches}"]],
  }
}
