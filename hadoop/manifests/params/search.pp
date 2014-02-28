# Class: hadoop::params::search
#
#
class hadoop::params::search inherits hadoop::params::default {

  $search_repo_class = $::osfamily ? {
    redhat => 'utils::repos::search::yum',
    debian => 'utils::repos::search::apt'
  }  

  $zookeeper_ensemble = hiera('zookeeper_ensemble'),
  $kerberos_domain = hiera("kerberos_domain", inline_template('<%= domain %>')),
  $kerberos_realm = hiera('kerberos_realm', inline_template('<%= domain.upcase %>')),
  $hadoop_security_authentication = hiera('security')

  # hdfs config
  $hadoop_deploy = hiera('hadoop_deploy')
  $ha = $hadoop_deploy['ha']  
  $hadoop_namenode_host = $hadoop_deploy['namenode']
  $hadoop_namenode_port = hiera('hadoop_namenode_port', '8020')
  if ($ha == "enabled") {
    $hadoop_ha_nameservice_id = hiera('hadoop_ha_nameservice_id', 'ha-nn-uri')
    $hadoop_namenode_uri = "hdfs://${hadoop_ha_nameservice_id}"
  } else {
    $hadoop_namenode_uri = "hdfs://${hadoop_namenode_host}:${hadoop_namenode_port}"
  }
  # mapreduce
  $hadoop_mapreduce = $hadoop_deploy['mapreduce']
  # hbase
  $hbase_deploy = hiera('hbase_deploy')
  # solr nodes
  $hadoop_search_nodes = hiera('worker_nodes')
  $first_solr_instance = inline_template("<%= hadoop_search_nodes.to_a[0] %>")
}