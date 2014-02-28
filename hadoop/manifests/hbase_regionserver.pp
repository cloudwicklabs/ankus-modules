# Class: hadoop::hbase_regionserver
#
# Installs and manages hbase reagion server node, which is the work horse of
# hbase big data store
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
# include hadoop::hbase_regionserver
#
# === Copyright
#
# Copyright 2012 Cloudwick Technologies, unless otherwise noted.
#
class hadoop::hbase_regionserver inherits hadoop::params::hbase {
  include java
  include $::hadoop::params::default::repo_class

  package { 'hbase-regionserver':
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

  service { 'hbase-regionserver':
    ensure      => running,
    require     => [ Package['hbase-regionserver'], Utils::Limits::Conf['hbase-nofile-soft', 'hbase-nofile-hard']],
    subscribe   => File['/etc/hbase/conf/hbase-site.xml', '/etc/hbase/conf/hbase-env.sh'],
    hasrestart  => true,
    hasstatus   => true,
  }

  # increase the file handles limit for hbase daemons
  utils::limits::conf {
    'hbase-nofile-soft':
      domain  => 'hbase',
      type    => soft,
      item    => nofile,
      value   => $hadoop::params::default::ulimit_nofiles;
    'hbase-nofile-hard':
      domain  => 'hbase',
      type    => hard,
      item    => nofile,
      value   => $hadoop::params::default::ulimit_nofiles;
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

    Package['hbase-regionserver'] -> Kerberos::Host_keytab <| title == 'hbase' |> -> Service['hbase-regionserver']
  }

  # log_stash
  if ($hadoop::params::default::log_aggregation == 'enabled') {
    #require logstash::lumberjack_def
    logstash::lumberjack_conf { 'hbase-regionserver':
      logstash_host => $hadoop::params::default::logstash_server,
      logstash_port => 5672,
      daemon_name   => 'lumberjack_hbaseregionserver',
      field         => "hbaseregionserver-${::fqdn}",
      logfiles      => ['/var/log/hbase/hbase-hbase-regionserver*.log'],
      require       => Service['hbase-regionserver']
    }
  }
}