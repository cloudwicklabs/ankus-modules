# Class: hadoop::hbase_master
#
# Installs and manages hbase master node, hbase is a distributed, scalable, 
# big data store
#
# === Parameters
#
# None
#
# === Variables
#
# @see hadoop::params::hbase
#
# === Requires
#
# Java
# Hadoop
#
# === Sample Usage
#
# include hadoop::hbase_master
#
# === Copyright
#
# Copyright 2012 Cloudwick Technologies, unless otherwise noted.
#
class hadoop::hbase_master {
  include java
  include hadoop::params::hbase

  package { 'hbase-master':
    ensure  => latest,
    require => [
                  File['java-app-dir'],
                  Class[$::hadoop::params::default::repo_class]
                ]
  }

  file { '/etc/hbase/conf/hbase-site.xml':
    content => template('hadoop/hbase/hbase-site.xml.erb'),
    require => Package['hbase-master']
  }

  file { '/etc/hbase/conf/hbase-env.sh':
    content => template('hadoop/hbase/hbase-env.sh.erb'),
    require => Package["hbase"],
  }

  if ($hadoop::params::default::monitoring == 'enabled') {
    file { '/etc/hbase/conf/hadoop-metrics.properties':
      content => template("hadoop/hbase/hadoop-metrics.properties.erb"),
      require => Package['hbase-master'],
    }
  }

  service { 'hbase-master':
    ensure      => running,
    require     => Package['hbase-master'],
    subscribe   => File['/etc/hbase/conf/hbase-site.xml', '/etc/hbase/conf/hbase-env.sh'],
    hasrestart  => true,
    hasstatus   => true,
  }

  if($hadoop::params::default::hadoop_security_authentication != 'simple') {
    require kerberos::client

    kerberos::host_keytab { 'hbase':
      spnego => true,
    }

    file { '/etc/hbase/conf/jaas.conf':
      content => template('hadoop/hbase/jaas.conf.erb'),
      require => Package['hbase-master'],
    }

    Package['hbase-master'] -> Kerberos::Host_keytab <| title == 'hbase' |> -> Service['hbase-master']
  }

  # log_stash
  if ($hadoop::params::default::log_aggregation == 'enabled') {
    #require logstash::lumberjack_def
    logstash::lumberjack_conf { 'hbasemaster':
      logstash_host => $hadoop::params::default::logstash_server,
      logstash_port => 5672,
      daemon_name   => 'lumberjack_hbasemaster',
      field         => "hbasemaster-${::fqdn}",
      logfiles      => ['/var/log/hbase/hbase-hbase-master*.log'],
      require       => Service['hbase-master']
    }
  }
}