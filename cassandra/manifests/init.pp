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
# Java7.
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

class cassandra inherits cassandra::params {

  include java7
  require cassandra::params
  require utilities::repos

  $cassandra_deploy = hiera('cassandra_deploy')
  $seeds = $cassandra_deploy['cassandra_seeds']
  $data_dir1 = inline_template("<%= data_dirs.to_a[0] %>")

  case $operatingsystem {
    'Ubuntu': {
      package { "dsc20":
        ensure => latest,
        require => [ File["java7-app-dir"], Apt::Source['datastax-repo'] ],
      }
    }
    'CentOS': {
      package { $cassandra_pkg:
        ensure => latest,
        require => [ File["java7-app-dir"], Yumrepo["datastax-repo"] ],
      }
    }
  }

  # Define: createDirWithPerm creates directories with parent directories
  # Parameters: user and group permission for the directories being created
  #
  define createDirWithPerm($user="cassandra", $group="cassandra") {
    mkdir_p { $name:
      ensure => present
    }

    file { $name:
      ensure => directory,
      owner => $user,
      group => $group,
      mode => 700,
      require => Mkdir_p[$name]
    }
  }

  createDirWithPerm { $data_dirs:
    user => "cassandra",
    group => "cassandra",
    require => Package[$cassandra_pkg]
  }

  createDirWithPerm { $commitlog_directory:
    user => "cassandra",
    group => "cassandra",
    require => Package[$cassandra_pkg]
  }

  createDirWithPerm { $saved_caches:
    user => "cassandra",
    group => "cassandra",
    require => Package[$cassandra_pkg]
  }

  file { "${cassandra::params::cassandra_base}/cassandra.yaml":
    ensure  => present,
    alias   => 'conf',
    require => Package[$cassandra_pkg],
    content => template("cassandra/conf/cassandra.yaml.erb"),
    notify  => Service['cassandra'];
  }

  file { "${cassandra::params::cassandra_base}/cassandra-env.sh":
    ensure  => present,
    alias   => 'conf-env',
    require => Package[$cassandra_pkg],
    content => template("cassandra/conf/cassandra-env.sh.erb"),
    notify  => Service['cassandra'];
  }

  service { "cassandra":
    enable => true,
    ensure => running,
    hasrestart => true,
    hasstatus => true,
    require => [Package[$cassandra_pkg],
                File['conf', 'conf-env'],
                     # $data_path,
                     # $commitlog_directory,
                     # $saved_caches]],
                CreateDirWithPerm[$data_dirs, $commitlog_directory, $saved_caches]]
  }
}
