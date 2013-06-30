# == Class: logstash::lumberjack
#
# This class will install and manage lumberjack agent to send log events to logstash
#
# === Parameters
#
# [*daemon_name*]
#   name of the daemon, used to manage multiple lumberjack daemons for various logs
#
# [*logstash_host*]
#   hostname of the logstash indexer to send events to
#
# [*logstash_port*]
#   port on which logstash is listening for lumberjack events
#
# [*logfiles*]
#   a list of log files path for the lumberjack to monitor
#   ex: ['/var/log/syslog', '/var/log/hadoop-hdfs/hadoop-namenode*'] (or) [ '/var/log/*.log' ]
#
# [*field*]
#   a custom field name, if provided will be used as a tag from that host
#
#
# BUG: Currently lumberjack only works with existing log files
# https://github.com/jordansissel/lumberjack/issues/49
# https://github.com/jordansissel/lumberjack/issues/41

class logstash::lumberjack {

  notice('installing role lumberjack (agent)')

  case $::operatingsystem {
    'RedHat', 'CentOS': {
      $pkg_provider = 'rpm'
      $package_name = 'lumberjack-0.0.30-1.x86_64.rpm'
      $tmpsource = "/tmp/${package_name}"
    }
    'Debian', 'Ubuntu': {
      $pkg_provider = 'dpkg'
      $package_name = 'lumberjack_0.0.30_amd64.deb'
      $tmpsource = "/tmp/${package_name}"
    }
    default: {
      fail("${module_name} provides no package for ${::operatingsystem}")
    }
  }

  file { $tmpsource:
    ensure => present,
    source => "puppet:///modules/${module_name}/lumberjack/${package_name}",
    backup => false,
    owner => 'root',
    group => 'root',
    before => Package[$package_name]
  }

  file { '/etc/ssl/logstash.pub':
    ensure => file,
    source => "puppet:///modules/${module_name}/lumberjack/logstash.pub",
    before => Package[$package_name]
  }

  package { $package_name:
    ensure => installed,
    source => $tmpsource,
    provider => $pkg_provider
  }
}