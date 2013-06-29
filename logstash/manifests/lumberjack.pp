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

class logstash::lumberjack(
  $daemon_name = 'lumberjack_default',
  $logstash_host,
  $logstash_port = 5672,
  $field = 'lumberjack_host1',
  $logfiles = undef
  ) {

  notice('installing role lumberjack (agent)')
  #lumberjack agent requires
  # - a indexer(hostname|ip) to send events to
  # - a list of log files to monitor
  # - field_name used for tag
  # - port on which logstash is listening for lumberjack input
  if $logstash_host == undef {
    fail("\"${role}\" requires hostname|ip of indexer")
  }
  if $logfiles == undef {
    fail("\"${role}\" requires array of log files to send to logstash indexer")
  }
  if $field == undef {
    $lumberjack_tag_fields = 'lumberjack_host'
  } else {
    $lumberjack_tag_fields = $lj_fields
  }

  case $::operatingsystem {
    'RedHat', 'CentOS': {
      $pkg_provider = 'rpm'
      $package_name = 'lumberjack-0.0.30-1.x86_64.rpm'
      $tmpsource = "/tmp/${package_name}"
      $initfile = template("${module_name}/etc/lumberjack/init.d/lumberjack.init.RedHat.erb")
      $defaults_file_path = "/etc/sysconfig/${daemon_name}"
      # if no logfiles are passed, monitor system default log files
      if ! $logfiles {
        $logfiles = [ '/var/log/messages', '/var/log/secure' ]
      }
      $defaults_file = template("${module_name}/etc/lumberjack/defaults/lumberjack.defaults.RedHat.erb")
    }
    'Debian', 'Ubuntu': {
      $pkg_provider = 'dpkg'
      $package_name = 'lumberjack_0.0.30_amd64.deb'
      $tmpsource = "/tmp/${package_name}"
      $initfile = template("${module_name}/etc/lumberjack/init.d/lumberjack.init.Debian.erb")
      $defaults_file_path = "/etc/default/${daemon_name}"
      if ! $logfiles {
        $logfiles = [ '/var/log/syslog', '/var/log/dmesg', '/var/log/auth.log' ]
      }
      $defaults_file = template("${module_name}/etc/lumberjack/defaults/lumberjack.defaults.Debian.erb")
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

  package { $package_name:
    ensure => installed,
    source => $tmpsource,
    provider => $pkg_provider
  }

  file { "/etc/init.d/$daemon_name":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => $initfile,
    before  => Service[$daemon_name]
  }

  file { $defaults_file_path:
    ensure => present,
    owner => 'root',
    group => 'root',
    mode => '0755',
    content => $defaults_file,
    before => Service[$daemon_name]
  }

  file { '/etc/ssl/logstash.pub':
    ensure => file,
    source => "puppet:///modules/${module_name}/lumberjack/logstash.pub",
    before => Service[$daemon_name]
  }

  service { $daemon_name:
    enable => true,
    ensure => running,
    hasrestart => true,
    hasstatus => true,
    require => Package[$package_name]
  }
}