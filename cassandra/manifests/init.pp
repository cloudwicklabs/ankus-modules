# == Class: cassandra
#
# installs and manages datastax cassandra
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

  case $operatingsystem {
    'Ubuntu': {
      include apt
      apt::source { "datastax-repo":
        #deb http://debian.datastax.com/community stable main
        location        => "http://debian.datastax.com/community",
        release         => "stable",
        repos           => "main",
        include_src     => true
      }
    }
    'CentOS': {
      yumrepo { "datastax-repo":
        descr => "DataStax Repo for Cassandra",
        baseurl => 'http://rpm.datastax.com/community',
        enabled => 1,
        gpgcheck => 0,
        notify => Exec["refresh-yum"],
      }
      exec { "refresh-yum":
        command => "/usr/bin/yum clean all",
        require => Yumrepo['datastax-repo']
        refreshonly => true
      }
    }
    default:  {fail('Supported OS are CentOS, Ubuntu')}
  }

  case $operatingsystem {
    'Ubuntu': {
      package { "dsc12":
        ensure => latest,
        require => [ File["java-app-dir"], Apt::Source['datastax-repo'] ],
      }
    }
    'CentOS': {
      package { "dsc12":
        ensure => latest,
        require => [ File["java-app-dir"], Yumrepo["datastax-repo"] ],
      }
    }
  }

  mkdir_p { $data_dirs:
    ensure => present,
  }

  file { $data_path:
    ensure => directory,
    owner => cassandra,
    group => cassandra,
    mode => 700,
    require => [Package["dcs12"], Mkdir_p[$data_dirs]],
  }

  file { $commitlog_directory:
    ensure => directory,
    owner => cassandra,
    group => cassandra,
    mode => 700,
    require => [Package["dcs12"], Mkdir_p[$data_dirs]],
  }

  file { $saved_caches:
    ensure => directory,
    owner => cassandra,
    group => cassandra,
    mode => 700,
    require => [Package["dcs12"], Mkdir_p[$data_dirs]],
  }

  file { "${cassandra::params::cassandra_base}/conf/cassandra.yaml":
    ensure  => present,
    alias   => 'conf',
    require => Package['dsc12'],
    content => template("cassandra/conf/cassandra.yaml.erb"),
    notify  => Service['cassandra'];
  }

  file {'${cassandra::params::cassandra_base}/conf/cassandra-env.sh':
    ensure  => present,
    alias   => 'conf-env',
    require => Package['dsc12'],
    content => template("cassandra/conf/cassandra-env.sh.erb"),
    notify  => Service['cassandra'];
  }

  service { "cassandra":
    enable => true,
    ensure => running,
    hasrestart => true,
    hasstatus => true,
    require => [Package['dsc12'], File['conf', 'conf-env', $data_path, $commitlog_directory, $saved_caches]],
  }
}
