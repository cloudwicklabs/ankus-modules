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

  # Installs Pig's UDFs(User defined functions) developed by linkedin, to use these udf's register the jar
  # REGISTER /usr/lib/pig/datafu-0.0.4-cdh4.3.0.jar
  case $operatingsystem {
    'Ubuntu': {
      package { "pig-udf-datafu":
        ensure => installed,
      }
    }
    'CentOS': {
      package { "pig-udf-datafu":
        ensure => installed,
      }
    }
  }

  file { "/etc/pig/conf/pig.properties":
    content => template('hadoop-pig/pig.properties.erb'),
    require => Package["pig"],
    owner => "root",
    mode => "755",
  }
}