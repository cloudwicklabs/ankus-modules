# Class: hadoop::params::hdfs
#
#
class hadoop::params::hdfs inherits hadoop::params::default {

  if ($hadoop::params::default::ha != 'disabled' ) {
    # core-site
    $hadoop_ha_nameservice_id = hiera('hadoop_ha_nameservice_id', 'ha-nn-uri')

    # hdfs-site
    $zk                       = hiera('zookeeper_ensemble')
    $jn                       = hiera('journal_quorum')
    $shared_edits_dir         = hiera('hadoop_ha_shared_edits_dir', 'hdfs_shared')
    $journal_shared_edits_dir = $hadoop::params::default::hadoop_ha ? {
      'disabled' => '',
      default => "qjournal://${jn}/${shared_edits_dir}"
    }
  }
  $sshfence_user            = hiera('hadoop_ha_sshfence_user', 'hdfs')
  $sshfence_user_home       = hiera('hadoop_ha_sshfence_user_home', '/var/lib/hadoop-hdfs')
  $sshfence_keydir          = "${sshfence_user_home}/.ssh"
  $sshfence_keypath         = "${sshfence_keydir}/id_sshfence"

  # hdfs-site
  $hdfs_support_append                                  = hiera('hadoop_support_append', true)
  $hadoop_config_dfs_block_size                         = hiera('hadoop_config_dfs_block_size', '134217728')
  $hadoop_config_dfs_replication                        = hiera('hadoop_config_dfs_replication', '3')
  $hadoop_config_dfs_permissions_supergroup             = hiera('hadoop_config_dfs_permissions_supergroup', 'hadoop')
  $hadoop_config_dfs_datanode_max_transfer_threads      = hiera('hadoop_config_dfs_datanode_max_transfer_threads', '4096')
  $hadoop_config_dfs_datanode_du_reserved               = hiera('hadoop_config_dfs_datanode_du_reserved', '0')
  $hadoop_config_dfs_datanode_balance_bandwidthpersec   = hiera('hadoop_config_dfs_datanode_balance_bandwidthpersec', '1048576')
  $hadoop_config_dfs_permissions_enabled                = hiera('hadoop_config_dfs_permissions_enabled', true)
  $hadoop_config_dfs_namenode_safemode_threshold_pct    = hiera('hadoop_config_dfs_namenode_safemode_threshold_pct', '099f')
  $hadoop_config_dfs_namenode_replication_min           = hiera('hadoop_config_dfs_namenode_replication_min', '1')
  $hadoop_config_dfs_namenode_safemode_extension        = hiera('hadoop_config_dfs_namenode_safemode_extension', '30000')
  $hadoop_config_dfs_df_interval                        = hiera('hadoop_config_dfs_df_interval', '60000')
  $hadoop_config_dfs_client_block_write_retries         = hiera('hadoop_config_dfs_client_block_write_retries', '3')
  $num_of_nodes                                         = hiera('number_of_nodes')
  if ($hadoop::params::default::ha == 'disabled') {
    $hadoop_secondarynamenode_host                      = $hadoop::params::default::hadoop_deploy['secondarynamenode']
    $hadoop_secondarynamenode_port                      = hiera('hadoop_secondarynamenode_port', 50090)
  }
  # for security
  # if ($auth == "kerberos" and $ha != "disabled") {
  #   fail("High-availability secure clusters are not currently supported")
  # }
}