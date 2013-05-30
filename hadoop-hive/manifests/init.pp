# == Class: hadoop-hive
#
# This module installs and manages hive, which is a data warehouse system for Hadoop
#
# === Parameters
#
# None
#
# === Variables
#
# [*hbase_hive_integration*]
#   specifies whether to integrate hive and hbase
#   possible values -> enabled | disabled
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

class hadoop-hive {

	$hbase_install = hiera('hbase_install')
  $hadoop_controller = hiera('controller')
  $impala = hiera('impala', 'disabled')

	if ($hbase_install == "enabled"){
		$hbase_master = hiera('hbase_master')
		$hbase_zookeeper_quorum = hiera('zookeeper_quorum')
	}

  $hive_packages = [ "hive", "hive-metastore" ]

  package { $hive_packages:
    ensure => latest,
  }

  file { "/usr/lib/hive/lib/postgresql-8.4-703.jdbc3.jar":
    owner => "root",
    group => "root",
    source => "puppet:///modules/hadoop-hive/postgresql-8.4-703.jdbc3.jar",
    alias => "postgres-jdbc-jar",
    require => Package["hive"],
  }

  file { "/etc/hive/conf/hive-site.xml":
    content => template('hadoop-hive/hive-site.xml.erb'),
    require => Package["hive"],
  }

  # if( $impala == "enabled" ) {
  #   #export hive-site.xml
  #   @@file { "/etc/impala/conf/hive-site.xml":
  #     ensure => present,
  #     content => template('hadoop-hive/hive-site.xml.erb'),
  #     tag => "hive-site-conf",
  #   }
  # }
}