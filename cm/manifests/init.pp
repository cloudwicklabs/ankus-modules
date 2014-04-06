# == Class: cm
#
# installs and manages cloudera manager
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
# Java.
#
# === Sample Usage
#
# include cm::server
# include cm::agent
#
# === Authors
#
# Ashrith <ashrith@cloudwick.com>
#
# === Copyright
#
# Copyright 2012 Cloudwick Technologies, unless otherwise noted.
#
class cm($role, $pass = 1, $hdfs_enabled = true) {
  if ($role == 'server' and $pass == 1) {
    class { 'cm::server': } ->
    class { 'cm::agent': }
  } elsif ($role == 'server' and $pass == 2) {
    class { 'cm::server': } ->
    class { 'cm::agent': } ->
    class { 'cm::cluster_init': }
    if ($hdfs_enabled == true) {
      class { 'cm::hdfs_init':
        require => Class['cm::cluster_init']
      }
    }
  } elsif ($role == 'agent') {
    class { 'cm::agent': }
  }
}
