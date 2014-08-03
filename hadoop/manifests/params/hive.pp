# Class: hadoop::params::hive
#
#
class hadoop::params::hive inherits hadoop::params::default {
  $hive_packages            = [ 'hive', 'hive-metastore', 'hive-server2' ]
  $postgres_jdbc_connector  = 'postgresql-8.4-703.jdbc3.jar'
  $hadoop_controller        = hiera('controller')
  $hbase_deploy             = hiera('hbase_deploy', 'disabled')
  if ($hbase_deploy != "disabled") {
    $hbase_master           = $hbase_deploy['hbase_master']
    $hbase_zookeeper_quorum = hiera('zookeeper_quorum')
  }
  $hive_psql_dbname         = 'hive'
  $hive_pqsl_username       = 'hive'
  $hive_psql_password       = 'hive'
}
