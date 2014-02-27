# Class: hadoop::hive
#
# Installs and manages:
#   - hive: a data warehouse system for Hadoop
#   - hive-metastore: stores the metadata for Hive tables and partitions in a 
#       relational database, and provides clients (including Hive) access to 
#       this information via the metastore service API
#   - hive-server2: allows a remote client to submit requests to Hive, using a 
#       variety of programming languages, and retrieve results.
#
# TODO: Add support for hive-server2 deployments which requires zookeeper
#
# === Parameters
#
# None
#
# === Variables
#
# None
#
# === Requires
#
# Java
# Hadoop
#
# === Sample Usage
#
# include hadoop-hive
#
# === Copyright
#
# Copyright 2012 Cloudwick Technologies, unless otherwise noted.
#
class hadoop::hive {
  include hadoop::params::hive
  include java

  package { $hadoop::params::hive::hive_packages:
    ensure  => installed,
    require => [
                  File['java-app-dir'],
                  Class[$::hadoop::params::default::repo_class]
                ]
  }

  file { "/usr/lib/hive/lib/${hadoop::params::hive::postgres_jdbc_connector}":
    owner   => 'root',
    group   => 'root',
    source  => "puppet:///modules/hadoop/${hadoop::params::hive::postgres_jdbc_connector}",
    alias   => 'postgres-jdbc-jar',
    require => Package['hive'],
  }

  file { '/etc/hive/conf/hive-site.xml':
    content => template('hadoop/hive/hive-site.xml.erb'),
    require => Package['hive'],
    alias   => 'hive-conf',
    notify  => Service['hive-metastore'],
  }

  file { '/etc/hive/conf/hive-env.sh':
    content => template('hadoop/hive/hive-env.sh.erb'),
    require => Package['hive'],
    alias   => 'hive-env',
    notify  => Service['hive-metastore'],
  }

  service { 'hive-metastore':
    enable  => true,
    ensure  => running,
    require => [ File['hive-conf'], File['hive-env'] ]
  }
}