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

  $cm_username = hiera('cloudera_manager_username', 'admin')
  $cm_password = hiera('cloudera_manager_username', 'admin')
  $cm_version  = hiera('cloudera_manager_version', 5)
  $cm_api_port = hiera('cloduera_manager_api_port', '7180')

  $repo_class = $::osfamily ? {
    /(?i-mx:redhat)/ => 'utils::repos::cm::yum',
    /(?i-mx:debian)/ => 'utils::repos::cm::apt',
  }

  $cm_embedded_database_pkg = $cm_version ? {
    /5/ => 'cloudera-manager-server-db-2',
    /4/ => 'cloudera-manager-server-db',
  }

  $cm_server_host = hiera('cloudera_cm_server_host', 'localhost')

  $cm_server_port = hiera('cloudera_cm_server_port', '7182')

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
