# == Class: hadoop::datanode
#
# Manages hadoop datanode on a specified node
#
# === Parameters
#
# Nonde
#
# === Variables
#
# None
#
# === Examples
#
# include hadoop::datanode
#
# === Authors
#
# Ashrith <ashrith@cloudwick.com>
#
# === Copyright
#
# Copyright 2012 Cloudwick Inc, unless otherwise noted.
#
class hadoop::datanode inherits hadoop::common_hdfs {
  require hadoop::common_hdfs
  
  package { 'hadoop-hdfs-datanode':
    ensure   => latest,
    require  => Package['hadoop-hdfs'],
  }

  hadoop::create_dir_with_perm { $hadoop::params::default::hdfs_data_dirs:
    user    => 'hdfs',
    group   => 'hdfs',
    mode    => 700,
    require => Package['hadoop-hdfs-datanode']
  }

  service { 'hadoop-hdfs-datanode':
    ensure    => running,
    hasstatus => true,
    subscribe => [
                    Package['hadoop-hdfs-datanode'],
                    File['/etc/hadoop/conf/core-site.xml'],
                    File['/etc/hadoop/conf/hdfs-site.xml'],
                    File['/etc/hadoop/conf/hadoop-env.sh']
                  ],
    require   => [
                    Package['hadoop-hdfs-datanode'],
                    Hadoop::Create_dir_with_perm[$hadoop::params::default::hdfs_data_dirs],
                    Utils::Limits::Conf['hdfs-nofile-soft', 'hdfs-nofile-hard']
                  ],
  }

  utils::limits::conf {
    'hdfs-nofile-soft':
      domain  => 'hdfs',
      type    => soft,
      item    => nofile,
      value   => $hadoop::params::default::ulimit_nofiles;
    'hdfs-nofile-hard':
      domain  => 'hdfs',
      type    => hard,
      item    => nofile,
      value   => $hadoop::params::default::ulimit_nofiles;    
  }  

  if ($hadoop::params::default::hadoop_security_authentication == 'kerberos') {
    file { '/etc/default/hadoop-hdfs-datanode':
        content => template('hadoop/hadoop-hdfs.erb'),
        require => [
                      Package['hadoop-hdfs-datanode'],
                      Kerberos::Host_keytab['hdfs']
                    ],
    }
  }

  if ($hadoop::params::default::impala == 'enabled') {
    include hadoop::impala
  }

  # log_stash for log aggregation
  if ($hadoop::params::default::log_aggregation == 'enabled') {
    logstash::lumberjack_conf { 'datanode':
      logstash_host => $hadoop::params::default::logstash_server,
      logstash_port => 5672,
      daemon_name   => 'lumberjack_datanode',
      field         => "datanode-${::fqdn}",
      logfiles      => ['/var/log/hadoop-hdfs/hadoop-hdfs-datanode*.log'],
      require       => Service['hadoop-hdfs-datanode']
    }
  }
}