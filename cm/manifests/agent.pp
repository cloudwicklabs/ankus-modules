# == Class: cm::agent
#
# installs and manages cloudera cm agent
#
# === Parameters
#
# cm::params
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
# include cm::agent
#
# === Authors
#
# Ashrith <ashrith@cloudwick.com>
#
# === Copyright
#
# Copyright 2012 Cloudwick Technologies, unless otherwise noted.
#
class cm::agent(
  $ensure           = $cm::params::ensure,
  $autoupgrade      = $cm::params::safe_autoupgrade,
  $service_ensure   = $cm::params::service_ensure,
  $server_host      = $cm::params::cm_server_host,
  $server_port      = $cm::params::cm_server_port,
  ) inherits cm::params {
  validate_bool($autoupgrade)

  require java
  include $::cm::params::repo_class

  case $ensure {
    /(present)/: {
      if $autoupgrade == true {
        $package_ensure = 'latest'
      } else {
        $package_ensure = 'present'
      }

      if $service_ensure in [ running, stopped ] {
        $service_ensure_real = $service_ensure
        $service_enable = true
      } else {
        fail('service_ensure parameter must be running or stopped')
      }
      $file_ensure = 'present'
    }
    /(absent)/: {
      $package_ensure = 'absent'
      $service_ensure_real = 'stopped'
      $service_enable = false
      $file_ensure = 'absent'
    }
    default: {
      fail('ensure parameter must be present or absent')
    }
  }

  package { 'cloudera-manager-agent':
    ensure  => $package_ensure,
    require => Class[$::cm::params::repo_class]
  }

  package { 'cloudera-manager-daemons':
    ensure  => $package_ensure,
    require => Class[$::cm::params::repo_class]
  }

  file { "/etc/default/cloudera-scm-agent":
    ensure => $file_ensure,
    content => template('cm/cloudera-scm-agent.erb'),
    require => Package['cloudera-manager-agent'],
    notify => Service['cloudera-scm-agent']
  }

  file { 'scm-config.ini':
    ensure  => $file_ensure,
    path    => '/etc/cloudera-scm-agent/config.ini',
    content => template('cm/scm-config.ini.erb'),
    require => Package['cloudera-manager-agent'],
    notify  => Service['cloudera-scm-agent'],
  }

  service { 'cloudera-scm-agent':
    ensure     => $service_ensure_real,
    enable     => $service_enable,
    hasrestart => true,
    hasstatus  => true,
    require    => Package['cloudera-manager-agent'],
  }
}
