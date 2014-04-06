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
  $cm_username     = hiera('cloudera_manager_username', 'admin')
  $cm_password     = hiera('cloudera_manager_username', 'admin')
  $cm_version      = hiera('cloudera_manager_version', 5)
  $cm_api_port     = hiera('cloduera_manager_api_port', '7180')
  $cm_cluster_name = hiera('cm_cluster_name', 'ankus_cluster')
  $cm_cluster_ver  = hiera('cm_cluster_ver', 'CDH4')
  $cm_nodes        = hiera('cm_cluster_nodes') # ['localhost']

  $repo_class = $::osfamily ? {
    /(?i-mx:redhat)/ => 'utils::repos::cm::yum',
    /(?i-mx:debian)/ => 'utils::repos::cm::apt',
  }

  $cm_embedded_database_pkg = $cm_version ? {
    /5/ => 'cloudera-manager-server-db-2',
    /4/ => 'cloudera-manager-server-db',
  }

  $cm_server_host = hiera('cloudera_cm_server_host', $::fqdn)

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

  #scm database
  $db_type = "postgresql"
  $db_host = $::fqdn
  $db_port = '5432'
  $scm_database_name = hiera('cm_database_name', 'scm')
  $scm_username = hiera('cm_database_user', 'scm')
  $scm_password = hiera('cm_database_password', 'scm')

  #management services user configuration
  $cm_amon_database_name     = hiera('cm_amon_database_name', 'amon')
  $cm_amon_database_user     = hiera('cm_amon_database_user', 'amon')
  $cm_amon_listen_port       = hiera('cm_amon_listen_port', '9999')
  $cm_amon_database_type     = hiera('cm_amon_database_type', 'postgresql')
  $cm_amon_database_password = hiera('cm_amon_database_password', 'amon')
  $cm_smon_database_name     = hiera('cm_smon_database_name', 'smon')
  $cm_smon_database_user     = hiera('cm_smon_database_user', 'smon')
  $cm_smon_listen_port       = hiera('cm_smon_listen_port', '9997')
  $cm_smon_debug_port        = hiera('cm_smon_debug_port', '8081')
  $cm_smon_database_type     = hiera('cm_smon_database_type', 'postgresql')
  $cm_smon_database_password = hiera('cm_smon_database_password', 'smon')
  $cm_hmon_database_name     = hiera('cm_hmon_database_name', 'hmon')
  $cm_hmon_database_user     = hiera('cm_hmon_database_user', 'hmon')
  $cm_hmon_listen_port       = hiera('cm_hmon_listen_port', '9995')
  $cm_hmon_database_type     = hiera('cm_hmon_database_type', 'postgresql')
  $cm_hmon_database_password = hiera('cm_hmon_database_password', 'hmon')

  # Host specific
  $namenode_host = hiera('hadoop_namenode', $::fqdn)
}
