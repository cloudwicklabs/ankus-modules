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
class cm($role, $pass = 1) {
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
      class { 'cm::api::parcels::configure': }
    } else {
      class { 'cm::agent': }
    }
  }
}
