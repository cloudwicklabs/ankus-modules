class hadoop::client(
	$hadoop_namenode_host = hiera('hadoop_namenode'),
	$hadoop_namenode_port = hiera('hadoop_namenode_port', 8020),
	$hadoop_security_authentication = hiera('security', 'simple'),
	$ha = hiera('hadoop_ha', 'disabled'),
	) inherits hadoop::common-hdfs {

    package { "hadoop-client":
      ensure => installed,
       require => Package["hadoop-hdfs"],
    }

    package { ["hadoop-doc", "hadoop-debuginfo", "hadoop-libhdfs"]:
       ensure => latest,
       require => [File["java-app-dir"], Package["hadoop"], Package["hadoop-hdfs"]],
    }
}