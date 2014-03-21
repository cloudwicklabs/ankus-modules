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
  if ($pass == 1) {
    if ($role == 'server') {
      class { 'cm::server': } ->
      class { 'cm::agent': }
    } else {
      class { 'cm::agent': }
    }
  } elsif ($pass == 2) {
    if ($role == 'server') {
      class { 'cm::server': } ->
      class { 'cm::agent': } ->
      cm::api::cluster { $cm::params::cm_cluster_name:
        cluster_version => $cm::params::cm_cluster_ver
      } ->
      class { 'cm::api::parcels::configure': }
      if ($hdfs_enabled == true) {
        class { 'cm::hdfs_init':
          require => Class['cm::api::parcels::configure']
        }
      }
    } else {
      class { 'cm::agent': }
    }
  }
}
