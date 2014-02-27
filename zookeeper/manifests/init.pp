# == Class: zookeeper
#			zookeeper::client
#			zookeeper::server
#
# This module installs and manages zookeeper, which is a centralized service
# for maintaining configuration information, naming, providing distributed
# synchronization, and providing group services for hadoop/hbase
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
#
# === Examples
#
#	include zookeeper::client
#
#	class { "zookeeper::server":
#		myid 	 => "0",
#		ensemble => ["zk1.cw.com:2888:3888", "zk2.cw.com:2888:3888", "zk3.cw.com:2888:3888"],
#		kerberos_realm => "CW.COM",
#	}
#
# === Authors
#
# Ashrith <ashrith@cloudwick.com>
#
# === Copyright
#
# Copyright 2012 Cloudwick Inc, unless otherwise noted.
#

class zookeeper {

  $cloudera_repo_class = $::osfamily ? {
    redhat => 'utils::repos::cloudera::yum',
    debian => 'utils::repos::cloudera::apt'
  }

  $hdp_repo_class = $::osfamily ? {
    redhat => 'utils::repos::hdp::yum',
    debian => 'utils::repos::hdp::apt'
  }

  $deployment_mode = $hadoop_deploy['packages_source']

  $repo_class = $::deployment_mode ? {
    cdh  => $cloudera_repo_class,
    hdp  => $hdp_repo_class
  }
}