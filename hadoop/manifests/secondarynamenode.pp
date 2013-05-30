class hadoop::secondarynamenode (
	$hadoop_secondarynamenode_host = hiera('hadoop_secondarynamenode_host', "$fqdn"),
	$hadoop_secondarynamenode_port = hiera('hadoop_secondarynamenode_port', 50090),
	$hadoop_security_authentication = hiera('security', 'simple'),
	$data_dirs = hiera('hadoop_data_dirs', ['/tmp/data']),
	) inherits hadoop::common-hdfs {

    file { $checkpoint_data_dirs:
        ensure => directory,
        owner => hdfs,
        group => hdfs,
        mode => 700,
        require => [Package["hadoop-hdfs-secondarynamenode"], Exec["create-root-dir"]],
    }

	package { "hadoop-hdfs-secondarynamenode":
		ensure => latest,
		require => Package["hadoop-hdfs"],
	}

    service { "hadoop-hdfs-secondarynamenode":
      ensure => running,
      hasstatus => true,
      subscribe => [Package["hadoop-hdfs-secondarynamenode"], File[$checkpoint_data_dirs],File["/etc/hadoop/conf/core-site.xml"], File["/etc/hadoop/conf/hdfs-site.xml"], File["/etc/hadoop/conf/hadoop-env.sh"]],
      require => [Package["hadoop-hdfs-secondarynamenode"]],
    }

    if($hadoop_security_authentication == "kerberos") {
        file { "/etc/default/hadoop-hdfs-secondarynamenode":
            content => template('hadoop/hadoop-hdfs.erb'),
            require => [Package["hadoop-hdfs-secondarynamenode"], Kerberos::Host_keytab["hdfs"]],
        }

        Kerberos::Host_keytab <| tag == "hdfs" |> -> Service["hadoop-hdfs-secondarynamenode"]
    }
}