# Class: hadoop::hcatalog
#
# Installs and manages hcatalog, which provides table data access for CDH
# components such as Pig, Sqoop, and MapReduce. Table definitions are maintained
# in the Hive metastore, which HCatalog requires. Packages used:
#   hcatalog - HCatalog wrapper for accessing the Hive metastore, libraries for
#              MapReduce and Pig, and a command-line program
#   webhact - A REST API server for HCatalog
#   webhcat-server - Installs webhcat and a server init script
#
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
# Hive Metastore
#
# === Sample Usage
#
# include hadoop-hive
#
# === Copyright
#
# Copyright 2012 Cloudwick Technologies, unless otherwise noted.
#
class hadoop::hcatalog inherits hadoop::params::hcatalog {
  include java
  include $::hadoop::params::default::repo_class

  package { 'hcatalog':
    ensure  => installed,
    require => [
                  File['java-app-dir'],
                  Class[$::hadoop::params::default::repo_class]
                ]
  }

  if ($hadoop::params::default::deployment_mode == 'cdh') {
    package { 'webhcat-server':
      ensure  => installed,
      require => Package['hcatalog']
    }

    service { 'webhcat-server':
      ensure  => running,
      enable  => true,
      require => Package['webhcat-server'],
    }
  } elsif ($hadoo::params::default::deployment_mode == 'hdp') {
    # TODO: update the respective configuration files `webhcat-env.xml`
    package { ['webhcat-tar-hive', 'webhcat-tar-pig']:
      ensure  => installed,
      require => Package['hcatalog']
    }
  }
}