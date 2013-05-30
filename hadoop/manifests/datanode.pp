class hadoop::datanode (
	  $hadoop_namenode_host = hiera('hadoop_namenode'),
  	$hadoop_namenode_port = hiera('hadoop_namenode_port', 8020),
  	$hadoop_datanode_port = hiera('hadoop_datanode_port', 50075),
  	$hadoop_security_authentication = hiera('security', 'simple'),
  	$data_dirs = hiera('hadoop_data_dirs', ['/tmp/data']),
  	$ha = hiera('hadoop_ha', 'disabled'),
    $impala = hiera('impala', 'disabled'),
	) inherits hadoop::common-hdfs {

    package { "hadoop-hdfs-datanode":
    	ensure => latest,
    	require => Package["hadoop-hdfs"],
    }

    service { "hadoop-hdfs-datanode":
      ensure => running,
      hasstatus => true,
      subscribe => [Package["hadoop-hdfs-datanode"], File["/etc/hadoop/conf/core-site.xml"], File["/etc/hadoop/conf/hdfs-site.xml"], File["/etc/hadoop/conf/hadoop-env.sh"]],
      require => [ Package["hadoop-hdfs-datanode"], File[$hdfs_data_dirs] ],
    }

    if ($hadoop_security_authentication == "kerberos") {
      file {
        "/etc/default/hadoop-hdfs-datanode":
          content => template('hadoop/hadoop-hdfs.erb'),
          require => [Package["hadoop-hdfs-datanode"], Kerberos::Host_keytab["hdfs"]],
      }
    }

    file { $hdfs_data_dirs:
      ensure => directory,
      owner => hdfs,
      group => hdfs,
      mode => 700,
      require => [ Package["hadoop-hdfs-datanode"], Exec["create-root-dir"]],
    }

    if ($impala == "enabled") {
      include hadoop::impala
    }

}