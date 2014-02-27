# Class: hadoop::params::hive
#
#
class hadoop::params::hive {
  include hadoop::params::default

  $hive_packages            = [ 'hive', 'hive-metastore', 'hive-server2' ]
  $postgres_jdbc_connector  = 'postgresql-8.4-703.jdbc3.jar'
  $hadoop_controller        = hiera('controller')
  $hbase_deploy             = hiera('hbase_deploy', 'disabled')
  if ($hbase_deploy != "disabled") {
    $hbase_master           = $hbase_deploy['hbase_master']
    $hbase_zookeeper_quorum = hiera('zookeeper_quorum')
  }
  $hive_pqsl_username       = 'hiveuser'
  $hive_psql_password       = 'hiveuser'
}