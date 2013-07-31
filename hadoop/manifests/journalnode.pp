class hadoop::journalnode(
	$hadoop_journalnode_host = hiera('hadoop_journalnode_host', "$fqdn"),
	$hadoop_journalnode_port = hiera('hadoop_journalnode_port', 8485),
	) inherits hadoop::common-hdfs {

  package { "hadoop-hdfs-journalnode":
    ensure => latest,
    require => [ File["java-app-dir"],Package["hadoop-hdfs"] ],
  }

	file { $jn_data_dir:
		ensure => directory,
		owner => hdfs,
  	group => hdfs,
  	mode => 700,
  	require => [Package["hadoop-hdfs-journalnode"], Exec["create-root-dir"]],
	}

	service { "hadoop-hdfs-journalnode":
	  enable => true,
		ensure => running,
		hasrestart => true,
		hasstatus => true,
		require => [ Package["hadoop-hdfs-journalnode"], File[$jn_data_dir] ],
	}

	if ($hadoop_security_authentication == "kerberos") {
		Kerberos::Host_keytab <| tag == "hdfs" |> -> Service["hadoop-hdfs-journalnode"]
	}
}