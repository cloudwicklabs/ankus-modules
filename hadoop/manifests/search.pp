# Class: hadoop::search
#
# Installs and manages solr daemon
#
class hadoop::search inherits hadoop::params::search {
  include java
  include $::hadoop::params::default::repo_class

  package { 'solr':
    ensure  => latest,
    require => [ File['java-app-dir'], Class[$::hadoop::params::impala::imapal_repo_class] ],
  }

  package { 'solr-server':
    ensure  => latest,
    require => Package['solr'],
  }

  if ($hadoop::params::default::hadoop_mapreduce != 'disabled') {
    package { 'solr-mapreduce':
      ensure  => latest,
      require => Package['solr'],
    }
  }

  if ($hadoop::params::default::hbase_deploy != 'disabled') {
    package { ['hbase-solr-indexer', 'hbase-solr-doc']:
      ensure  => latest,
      require => Package['solr'],
    }
  }

  file { '/etc/default/solr':
    content => template('hadoop/search/solr.erb'),
    require => Package['solr-server']
  }

  service { 'solr-server':
    ensure  => running,
    enable  => true,
    require => [Package['solr-server'], File['/etc/default/solr']],
  }

  # instantiate zookeeper namespace from first solr instance
  if ($::fqdn == $hadoop::params::search::first_solr_instance) {
    exec { 'instantiate zookeeper namespace':
      command   => '/bin/bash -c \'solrctl init >> /var/lib/solr/zk.namespace.log 2>&1\'',
      creates   => '/var/lib/solr/zk.namespace.log',
      logoutput => true,
      tag       => 'zk-namespace',
      require   => Package['solr-server'],
      before    => Service['solr-server'],
    }
  }

  if($hadoop::params::default::hadoop_security_authentication == 'kerberos') {
    require kerberos::client

    kerberos::host_keytab { 'solr':
      spnego => true,
    }

    file { '/etc/solr/conf/jaas.conf':
      content => template('hadoop/search/jaas.conf.erb'),
      require => Package['solr-server'],
    }

    Kerberos::Host_keytab <| title == 'solr' |> -> Service['solr-server']
  }
}