class hadoop::datanode inherits hadoop::common-hdfs {
  package { "hadoop-hdfs-datanode":
  	ensure => latest,
  	require => Package["hadoop-hdfs"],
  }

  hadoop::create_dir_with_perm { $hdfs_data_dirs:
    user => "hdfs",
    group => "hdfs",
    mode => 700,
    require => Package['hadoop-hdfs-datanode']
  }  

  service { "hadoop-hdfs-datanode":
    ensure => running,
    hasstatus => true,
    subscribe => [Package["hadoop-hdfs-datanode"], File["/etc/hadoop/conf/core-site.xml"], File["/etc/hadoop/conf/hdfs-site.xml"], File["/etc/hadoop/conf/hadoop-env.sh"]],
    require => [ Package["hadoop-hdfs-datanode"], Hadoop::Create_dir_with_perm[$hdfs_data_dirs] ],
  }

  if ($hadoop_security_authentication == "kerberos") {
    file {
      "/etc/default/hadoop-hdfs-datanode":
        content => template('hadoop/hadoop-hdfs.erb'),
        require => [Package["hadoop-hdfs-datanode"], Kerberos::Host_keytab["hdfs"]],
    }
  }

  if ($impala == "enabled") {
    include hadoop::impala
  }

  #log_stash
  if ($log_aggregation == 'enabled') {
    #require logstash::lumberjack_def
    logstash::lumberjack_conf { 'datanode':
      logstash_host => $logstash_server,
      logstash_port => 5672,
      daemon_name => 'lumberjack_datanode',
      field => "datanode-${::fqdn}",
      logfiles => ['/var/log/hadoop-hdfs/hadoop-hdfs-datanode*.log'],
      require => Service['hadoop-hdfs-datanode']
    }
  }
}