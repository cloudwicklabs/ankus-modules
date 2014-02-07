class hadoop::journalnode(
	$hadoop_journalnode_host = hiera('hadoop_journalnode_host', "$fqdn"),
	$hadoop_journalnode_port = hiera('hadoop_journalnode_port', 8485),
	) inherits hadoop::common-hdfs {

  package { "hadoop-hdfs-journalnode":
    ensure => latest,
    require => [ File["java-app-dir"],Package["hadoop-hdfs"] ],
  }

  hadoop::create_dir_with_perm { $jn_data_dir:
    user => "hdfs",
    group => "hdfs",
    mode => 700,
    require => Package['hadoop-hdfs-journalnode']
  }

	service { "hadoop-hdfs-journalnode":
	  enable => true,
		ensure => running,
		hasrestart => true,
		hasstatus => true,
		require => [ Package["hadoop-hdfs-journalnode"], Hadoop::Create_dir_with_perm[$jn_data_dir]],
	}

	if ($hadoop_security_authentication == "kerberos") {
		Kerberos::Host_keytab <| tag == "hdfs" |> -> Service["hadoop-hdfs-journalnode"]
	}
}