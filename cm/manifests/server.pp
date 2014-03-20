# == Class: cm::server
#
# installs and manages cloudera cm server
#
# === Parameters
#
# cm::server
#
# === Variables
#
# scm::params
#
# === Requires
#
# Java.
#
# === Sample Usage
#
# include cm::server
#
# === Authors
#
# Ashrith <ashrith@cloudwick.com>
#
# === Copyright
#
# Copyright 2012 Cloudwick Technologies, unless otherwise noted.
#
class cm::server(
  $ensure         = $cm::params::ensure,
  $autoupgrade    = $cm::params::safe_autoupgrade,
  $service_ensure = $cm::params::service_ensure,
  $db_type        = $cm::params::db_type,
  $db_host        = $cm::params::db_host,
  $db_port        = $cm::params::db_port,
  $database_name  = $cm::params::scm_database_name,
  $username       = $cm::params::scm_username,
  $password       = $cm::params::scm_password
  ) inherits cm::params {
  validate_bool($autoupgrade)

  require java
  require cm::database # creates database req for scm server
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

  package { 'cloudera-manager-server':
    ensure  => $package_ensure,
    require => Class[$::cm::params::repo_class]
  }

  file { "/etc/default/cloudera-scm-server":
    ensure => $file_ensure,
    content => template("${module_name}/cloudera-scm-server.erb"),
    require => Package['cloudera-manager-server'],
    notify => Service['cloudera-scm-server']
  }

  file { "/etc/cloudera-scm-server/db.properties":
    ensure => $file_ensure,
    content => template("${module_name}/db.properties.erb"),
    require => Package['cloudera-manager-server'],
    notify => Service['cloudera-scm-server']
  }

  # exec { 'scm_prepare_database':
  #   command => "/usr/share/cmf/schema/scm_prepare_database.sh ${db_type} --host=${db_host} --port=${db_port} --scm-host=${::fqdn} --user=${db_user} --password=${db_pass} ${database_name} ${username} ${password} && touch /etc/cloudera-scm-server/.scm_prepare_database",
  #   creates => '/etc/cloudera-scm-server/.scm_prepare_database',
  #   require => $scm_prepare_database_require,
  #   before  => Service['cloudera-scm-server'],
  # }

  service { 'cloudera-scm-server':
    ensure     => $service_ensure_real,
    enable     => $service_enable,
    hasrestart => true,
    hasstatus  => true,
    require    => Package['cloudera-manager-server'],
  }

  # package { $::cm::params::cm_embedded_database_pkg:
  #   ensure  => $package_ensure,
  #   require => Class[$::cm::params::repo_class]
  # }
  #
  # exec { 'cloudera-manager-server-db':
  #   command => "service cloudera-scm-server-db initdb",
  #   path => '/sbin:/usr/sbin:/usr/bin:/bin',
  #   creates => '/etc/cloudera-scm-server/db.mgmt.properties',
  #   require => Package[$::cm::params::cm_embedded_database_pkg],
  # }
  #
  # service { 'cloudera-scm-server-db':
  #   ensure     => $service_ensure_real,
  #   enable     => $service_enable,
  #   hasrestart => true,
  #   hasstatus  => true,
  #   require    => Exec['cloudera-manager-server-db'],
  #   before     => Service['cloudera-scm-server'],
  # }
}
