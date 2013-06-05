# == Class: hadoop-sqoop
#
# Install and manages sqoop tool designed for efficiently transferring bulk data between
# Hadoop and structured datastores such as relational databases
#
# === Parameters
#
# None.
#
# === Variables
#
# None.
#
# === Requires
#
# Java
# Hadoop
#
# === Sample Usage
#
# include hadoop-sqoop
#
# === Copyright
#
# Copyright 2012 Cloudwick Technologies, unless otherwise noted.
#

class hadoop-sqoop {
    require utilities
    package { "sqoop":
      ensure => latest,
    }

    file { "/usr/lib/sqoop/lib/mysql-connector-java-5.1.22-bin.jar":
      source  => "puppet:///modules/hadoop-sqoop/mysql-connector-java-5.1.22-bin.jar",
      require => Package["sqoop"],
    }

  class metastore {
    package { "sqoop-metastore":
      ensure => latest,
    }

    service { "sqoop-metastore":
      ensure => running,
      require => Package["sqoop-metastore"],
      hasstatus => true,
      hasrestart => true,
    }
  }
}