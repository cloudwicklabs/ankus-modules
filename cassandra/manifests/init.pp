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
  include $::cassandra::params::repo_class

  package { $::cassandra::params::cassandra_pkg:
    ensure   => installed,
    require  => [
                  File['java7-app-dir'],
                  Class[$::cassandra::params::repo_class]
    ]
  }

  # Define: createDirWithPerm creates directories with parent directories
  # Parameters: user and group permission for the directories being created
  #
  define createDirWithPerm($user="cassandra", $group="cassandra") {
    mkdir_p { $name:
      ensure => present
    }

    file { $name:
      ensure   => directory,
      owner    => $user,
      group    => $group,
      mode     => 0700,
      require  => Mkdir_p[$name]
    }
  }

  createDirWithPerm {
    $data_dirs:
      user    => 'cassandra',
      group   => 'cassandra',
      require => Package[$::cassandra::params::cassandra_pkg];
    $commitlog_directory:
      user    => 'cassandra',
      group   => 'cassandra',
      require => Package[$::cassandra::params::cassandra_pkg];
    $saved_caches:
      user    => 'cassandra',
      group   => 'cassandra',
      require => Package[$::cassandra::params::cassandra_pkg];
  }

  file {
    "${cassandra::params::cassandra_base}/cassandra.yaml":
      ensure  => present,
      alias   => 'conf',
      require => Package[$cassandra_pkg],
      content => template('cassandra/conf/cassandra.yaml.erb'),
      notify  => Service['cassandra'];
    "${cassandra::params::cassandra_base}/cassandra-env.sh":
      ensure  => present,
      alias   => 'conf-env',
      require => Package[$cassandra_pkg],
      content => template('cassandra/conf/cassandra-env.sh.erb'),
      notify  => Service['cassandra'];
    '/etc/default/cassandra':
      ensure  => present,
      alias   => 'conf-default',
      require => Package[$cassandra_pkg],
      content => template('cassandra/conf/cassandra.default.erb'),
      notify  => Service['cassandra'];
  }

  service { 'cassandra':
    enable     => true,
    ensure     => running,
    hasrestart => true,
    hasstatus  => true,
    require    => [
                    Package[$cassandra_pkg],
                    File['conf', 'conf-env', 'conf-default'],
                    CreateDirWithPerm[
                      $data_dirs,
                      $commitlog_directory,
                      $saved_caches
                    ]
                  ]
  }

  # log_stash
  if ($cassandra::params::log_aggregation == 'enabled') {
    logstash::lumberjack_conf { 'cassandra_system_log':
      logstash_host => $cassandra::params::logstash_server,
      logstash_port => 5672,
      daemon_name   => 'lumberjack_cassandra_system',
      field         => "cassandra-system-${::fqdn}",
      logfiles      => ['/var/log/cassandra/system.log'],
      require       => Service['cassandra']
    }
    logstash::lumberjack_conf { 'cassandra':
      logstash_host => $cassandra::params::logstash_server,
      logstash_port => 5672,
      daemon_name   => 'lumberjack_cassandra',
      field         => "cassandra-${::fqdn}",
      logfiles      => ['/var/log/cassandra/cassandra.log'],
      require       => Service['cassandra']
    }
  }
}
