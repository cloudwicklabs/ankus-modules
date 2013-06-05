# == Class: hbase
#
# This module installs and manages hbase which is a distributed, scalable, big data store
#
# === Parameters
#
# This module uses hiera for parameter lookups
#
# === Variables
#
# None.
#
# === Requires
#
# Java
# Hadoop
# Zookeeper
#
# === Sample Usage
#
# include hbase::master -> setsup fully functional hbase master node
#
# include hbase::regionserver -> setsup fully functional hbase regionserver
#

class hbase {

  include java

  require utilities

  class client-package  {
    package { "hbase":
      ensure => latest,
      require => File["java-app-dir"],
    } 
  }

  define client {
    include client-package
  }
}