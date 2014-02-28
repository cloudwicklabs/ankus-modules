# == Class: hadoop::secondarynamenode
#
# Installs and manages hadoop secondarynamenode daemon
#
# === Parameters
#
# None
#
# === Variables
#
# None
#
# === Examples
#
# include hadoop::secondarynamenode
#
# === Authors
#
# Ashrith <ashrith@cloudwick.com>
#
# === Copyright
#
# Copyright 2012 Cloudwick Inc, unless otherwise noted.
#
class hadoop::secondarynamenode inherits hadoop::common_hdfs {
  require hadoop::common_hdfs

  hadoop::create_dir_with_perm { $hadoop::params::default::checkpoint_data_dirs:
    user    => 'hdfs',
    group   => 'hdfs',
    mode    => '0700',
    require => Package['hadoop-hdfs-secondarynamenode']
  }

  package { 'hadoop-hdfs-secondarynamenode':
    ensure  => latest,
    require => Package['hadoop-hdfs'],
  }

  service { 'hadoop-hdfs-secondarynamenode':
    ensure    => running,
    hasstatus => true,
    subscribe => [Package['hadoop-hdfs-secondarynamenode'], File['/etc/hadoop/conf/core-site.xml'], File['/etc/hadoop/conf/hdfs-site.xml'], File['/etc/hadoop/conf/hadoop-env.sh']],
    require   => [Package['hadoop-hdfs-secondarynamenode'], Hadoop::Create_dir_with_perm[$hadoop::params::default::checkpoint_data_dirs]],
  }

  if($hadoop::params::default::hadoop_security_authentication == 'kerberos') {
    file { '/etc/default/hadoop-hdfs-secondarynamenode':
      content => template('hadoop/hadoop-hdfs.erb'),
      require => [Package['hadoop-hdfs-secondarynamenode'], Kerberos::Host_keytab['hdfs']],
    }

    Kerberos::Host_keytab <| tag == 'hdfs' |> -> Service['hadoop-hdfs-secondarynamenode']
  }

  # log_stash for log aggregation
  if ($hadoop::params::default::log_aggregation == 'enabled') {
    logstash::lumberjack_conf { 'secondarynamenode':
      logstash_host => $hadoop::params::default::logstash_server,
      logstash_port => 5672,
      daemon_name   => 'lumberjack_secondarynamenode',
      field         => "secondarynamenode-${::fqdn}",
      logfiles      => ['/var/log/hadoop-hdfs/hadoop-hdfs-secondarynamenode*.log'],
      require       => Service['hadoop-hdfs-secondarynamenode']
    }
  }
}