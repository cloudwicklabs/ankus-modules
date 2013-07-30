# == Class:
# hadoop-sqoop::server
# hadoop-sqoop::client
#
# Install and manages sqoop2 tool designed for efficiently transferring bulk data between
# Hadoop and structured datastores such as relational databases
#
# sqoop2-server:  Sqoop 2 server acts as a MapReduce client this node must have Hadoop installed
#                 and configured
# sqoop-client: A Sqoop 2 client will always connect to the Sqoop 2 server to perform any actions,
#               so Hadoop does not need to be installed on the client nodes.
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
# include hadoop-sqoop::server
# include hadoop-sqoop::client
#
# === Copyright
#
# Copyright 2012 Cloudwick Technologies, unless otherwise noted.
#

class hadoop-sqoop {
  include java
  # Class: hadoop-sqoop::server
  #
  #
  class server inherits hadoop-sqoop {
    require utilities
    case $operatingsystem {
      'Ubuntu': {
        package { "sqoop2-server":
          ensure => latest,
          require => [ File["java-app-dir"], Apt::Source['cloudera_precise'] ],
        }
      }
      'CentOS': {
        package { "sqoop2-server":
          ensure => latest,
          require => [ File["java-app-dir"], Yumrepo["cloudera-repo"] ],
        }
      }
    }

    file { "/etc/default/sqoop2-server":
      alias   => 'sqoop-server-defaults',
      content => template('hadoop-sqoop/sqoop2-server.erb'),
      require => Package['sqoop2-server'],
      notify  => Service['sqoop2-server']
    }

    service { "sqoop2-server":
      enable => true,
      ensure => running,
      require => File['sqoop-server-defaults'],
    }

    file { "/var/lib/sqoop2/mysql-connector-java-5.1.22-bin.jar":
      source  => "puppet:///modules/hadoop-sqoop/mysql-connector-java-5.1.22-bin.jar",
      require => Package["sqoop2-server"],
    }
  }

  # Class: hadoop-sqoop::client
  #
  #
  class client inherits hadoop-sqoop {
    require utilities

    case $operatingsystem {
      'Ubuntu': {
        package { "sqoop2-client":
          ensure => latest,
          require => [ File["java-app-dir"], Apt::Source['cloudera_precise'] ],
        }
      }
      'CentOS': {
        package { "sqoop2-client":
          ensure => latest,
          require => [ File["java-app-dir"], Yumrepo["cloudera-repo"] ],
        }
      }
    }
  }

  # class metastore {
  #   package { "sqoop-metastore":
  #     ensure => latest,
  #   }

  #   service { "sqoop-metastore":
  #     ensure => running,
  #     require => Package["sqoop-metastore"],
  #     hasstatus => true,
  #     hasrestart => true,
  #   }
  # }
}