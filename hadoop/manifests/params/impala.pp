# Class: hadoop::params::impala
#
#
class hadoop::params::impala {
  include hadoop::params::default

  $impala_repo_class = $::osfamily ? {
    redhat => 'utils::repos::impala::yum',
    debian => 'utils::repos::impala::apt'
  }

  # this could be specified as % like 60% or absolute notation like 500m or 1G
  $memory_limit = hiera('impala_memory_limit', '1G')

  # hive-site
  $hadoop_controller  = hiera('controller')
  $impala             = hiera('impala', 'disabled')
  $jobtracker         = $hadoop::params::default::hadoop_mapreduce['master']

  if ($hadoop::params::default::hbase_deploy != 'disabled'){
    $hbase_master           = $hadoop::params::default::hbase_deploy['master']
    $hbase_zookeeper_quorum = hiera('zookeeper_quorum')
  }

  #impala specific variable
  $namenode         = $hadoop::params::default::hadoop_deploy['hadoop_namenode']
  $first_namenode   = $namenode[0]
  $namenode_port    = $hadoop::params::default::hadoop_namenode_port
  if ($hadoop::params::default::ha != 'disabled') {
    $hadoop_ha_nameservice_id = hiera('hadoop_ha_nameservice_id', 'ha-nn-uri')
    $default_fs = "hdfs://${hadoop_ha_nameservice_id}"
  } else {
    $default_fs = "hdfs://${first_namenode}:${namenode_port}"
  }
}