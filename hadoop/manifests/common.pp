# == Class: hadoop::common
#
# Abstracts away common configuration for all hadoop nodes
#
# === Parameters
#
# None
#
# === Variables
#
# None
#
# === Examples
#
# include hadoop
#
# === Authors
#
# Ashrith <ashrith@cloudwick.com>
#
# === Copyright
#
# Copyright 2012 Cloudwick Inc, unless otherwise noted.
#
class hadoop::common inherits hadoop::params::default {
  include $::hadoop::params::default::repo_class
  include java

  notice("ulimits : $ulimits_nofiles")

  package { 'hadoop':
    ensure  => latest,
    require => [
                  File['java-app-dir'],
                  Class[$::hadoop::params::default::repo_class]
                ]
  }

  file { '/etc/hadoop/conf/hadoop-env.sh':
    content => template('hadoop/hadoop-env.sh.erb'),
    require => Package['hadoop']
  }

  file { '/etc/hadoop/conf/core-site.xml':
    content => template('hadoop/core-site.xml.erb'),
    require => Package['hadoop']
  }

  if ($hadoop::params::default::monitoring == 'enabled') {
    file { '/etc/hadoop/conf/hadoop-metrics2.properties':
      content => template('hadoop/hadoop-metrics2.properties.erb'),
      require => Package['hadoop']
    }
  }

  file { '/etc/hadoop/conf/topology.rb':
    source  => 'puppet:///modules/hadoop/topology.rb',
    require => Package['hadoop']
  }
}