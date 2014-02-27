# == Class: hadoop::pig
#
# Apache Pig is a platform for analyzing large data sets that consists of a
# high-level language for expressing data analysis programs, coupled with 
# infrastructure for evaluating these programs
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
# include hadoop-pig
#
# === Copyright
#
# Copyright 2012 Cloudwick Technologies, unless otherwise noted.
#

class hadoop::pig {
  include hadoop::params::default

  # REGISTER /usr/lib/pig/datafu-0.0.4-cdh4.3.0.jar
  $package_datafu = $::osfamily ? {
    redhat => 'pig-udf',
    debian => 'pig-udf-datafu'
  }

  package { 'pig':
    ensure  => installed,
    require => [ File['java-app-dir'], Class[$::hadoop::params::default::repo_class] ]
  }

  if ($hadoop::params::default::deployment_mode == 'cdh') {
    package { $package_datafu:
      ensure  => installed,
      require => Package['pig']
    }
  }

  file { '/etc/pig/conf/pig.properties':
    content => template('hadoop/pig/pig.properties.erb'),
    require => Package['pig'],
    owner   => 'root',
    mode    => '755'
  }
}