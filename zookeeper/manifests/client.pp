# == Class: zookeeper::client
#
# manages list packages required to run a zookeeper client
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
# include zookeeper::client
#
# === Authors
#
# cloudwick <ashrith@cloudwick.com>
#
# === Copyright
#
# Copyright 2012 Cloudwick Inc, unless otherwise noted.
#
class zookeeper::client inherits zookeeper {
  include java
  include $::zookeeper::repo_class

  package { 'zookeeper':
    ensure  => installed,
    require => [ File['java-app-dir'], Class[$::zookeeper::repo_class] ]
  }
}
