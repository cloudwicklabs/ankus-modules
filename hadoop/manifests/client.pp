# == Class: example_class
#
# manages list packages required to run a hadoop client
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
# include hadoop::client
#
# === Authors
#
# cloudwick <ashrith@cloudwick.com>
#
# === Copyright
#
# Copyright 2012 Cloudwick Inc, unless otherwise noted.
#
class hadoop::client inherits hadoop::common_hdfs {
  package { 'hadoop-client':
    ensure  => installed,
    require => Package['hadoop-hdfs'],
  }

  package { ['hadoop-doc', 'hadoop-debuginfo', 'hadoop-libhdfs']:
    ensure   => latest,
    require  => [File['java-app-dir'], Package['hadoop'], Package['hadoop-hdfs']],
  }
}