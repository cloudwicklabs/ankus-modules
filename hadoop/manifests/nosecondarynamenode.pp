# == Class: hadoop::nosecondarynamenode
#
# Disables secondary namenode deployment
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
# include hadoop::nosecondarynamenode
#
# === Authors
#
# Ashrith <ashrith@cloudwick.com>
#
# === Copyright
#
# Copyright 2012 Cloudwick Inc, unless otherwise noted.
#
class hadoop::nosecondarynamenode inherits hadoop::common_hdfs {
  service { 'hadoop-hdfs-secondarynamenode':
    ensure => "stopped",
  }
  
  package { 'hadoop-hdfs-secondarynamenode':
    ensure => 'absent',
    require => Service['hadoop-hdfs-secondarynamenode'],
  }
}