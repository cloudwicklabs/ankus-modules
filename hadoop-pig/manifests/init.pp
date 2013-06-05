# == Class: hadoop-pig
#
# Apache Pig is a platform for analyzing large data sets that consists of a high-level language for expressing
# data analysis programs, coupled with infrastructure for evaluating these programs
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

class hadoop-pig {
  require utilities
  package { "pig":
    ensure => latest,
  }

  file { "/etc/pig/conf/pig.properties":
    content => template('hadoop-pig/pig.properties.erb'),
    require => Package["pig"],
    owner => "root",
    mode => "755",
  }
}