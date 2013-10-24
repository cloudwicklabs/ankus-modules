# Class: hadoop-search::server
#
# Installs and manages solr daemon
#
class hadoop-search::server(
  $zookeeper_ensemble = hiera('zookeeper_ensemble'),
  $kerberos_domain = hiera("hadoop_kerberos_domain", inline_template('<%= domain %>')),
  $kerberos_realm = hiera('hadoop_kerberos_realm', inline_template('<%= domain.upcase %>')),
  $hadoop_security_authentication = hiera('security')
  ) inherits hadoop-search {

  # hdfs config
  $hadoop_deploy = hiera('hadoop_deploy')
  $ha = $hadoop_deploy['hadoop_ha']  
  $hadoop_namenode_host = $hadoop_deploy['hadoop_namenode']
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
  $hadoop_search_nodes = hiera('slave_nodes')
  $first_solr_instance = inline_template("<%= hadoop_search_nodes.to_a[0] %>")

  package { "solr-server":
    ensure => latest,
    require => Package["solr"],
  }

  if ($hadoop_mapreduce != 'disabled') {
    package { "solr-mapreduce":
      ensure => latest,
      require => Package["solr"],
    }
  }

  if ($hbase_deploy != 'disabled') {
    package { ["hbase-solr-indexer", "hbase-solr-doc"]:
      ensure => latest,
      require => Package["solr"],
    }
  }

  file { "/etc/default/solr":
    content => template("hadoop-search/solr.erb"),
    require => Package["solr-server"]
  }

  service { "solr-server":
    enable => true,
    ensure => running,
    require => [Package["solr-server"], File["/etc/default/solr"]],
  }

  # instantiate zookeeper namespace from first solr instance
  if ($::fqdn == $first_solr_instance) {  
    exec { "instantiate zookeeper namespace":
      command => "/bin/bash -c 'solrctl init >> /var/lib/solr/zk.namespace.log 2>&1'",
      creates => "/var/lib/solr/zk.namespace.log",
      logoutput => true,
      tag => "zk-namespace",
      require => Package["solr-server"],
      before => Service["solr-server"],
    }
  }

  if($hadoop_security_authentication == "kerberos") {
    require kerberos::client

    kerberos::host_keytab { "solr":
      spnego => true,
    }

    file { "/etc/solr/conf/jaas.conf":
      content => template("hadoop-search/jaas.conf.erb"),
      require => Package["solr-server"],
    }

    Kerberos::Host_keytab <| title == "solr" |> -> Service["solr-server"]
  }

}