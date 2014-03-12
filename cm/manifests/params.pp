# == Class: cm::params
#
# === Parameters
#
# None
#
# === Variables
#
# [*cm_version*]
#  version of cm to install
#
# === Requires
#
# Java.
#
# === Sample Usage
#
# include cm::params
#
# === Authors
#
# Ashrith <ashrith@cloudwick.com>
#
# === Copyright
#
# Copyright 2012 Cloudwick Technologies, unless otherwise noted.
#
class cm::params {

  $repo_class = $::osfamily ? {
    /(?i-mx:redhat)/ => 'utils::repos::cm::yum',
    /(?i-mx:debian)/ => 'utils::repos::cm::apt',
  }

  $cm_server_host = $::cloudera_cm_server_host ? {
    undef   => 'localhost',
    default => $::cloudera_cm_server_host,
  }

  $cm_server_port = $::cloudera_cm_server_port ? {
    undef   => '7182',
    default => $::cloudera_cm_server_port,
  }

  $ensure = $::cloudera_ensure ? {
    undef => 'present',
    default => $::cloudera_ensure,
  }

  $service_ensure = $::cloudera_service_ensure ? {
    undef => 'running',
    default => $::cloudera_service_ensure,
  }

  $autoupgrade = $::cloudera_autoupgrade ? {
    undef => false,
    default => $::cloudera_autoupgrade,
  }
  if is_string($autoupgrade) {
    $safe_autoupgrade = str2bool($autoupgrade)
  } else {
    $safe_autoupgrade = $autoupgrade
  }

  $use_parcels = $::cloudera_use_parcels ? {
    undef => false,
    default => $::cloudera_use_parcels,
  }
  if is_string($use_parcels) {
    $safe_use_parcels = str2bool($use_parcels)
  } else {
    $safe_use_parcels = $use_parcels
  }
}
