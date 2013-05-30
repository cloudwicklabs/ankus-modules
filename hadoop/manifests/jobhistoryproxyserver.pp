class hadoop::jobhistoryproxyserver(
	$hadoop_jobhistory_host = hiera('hadoop_jobhistory_host', "$fqdn"),
	$hadoop_jobhistory_port = hiera('hadoop_jobhistory_port', '10020'),
	$hadoop_jobhistory_webapp_port = hiera('hadoop_jobhistory_webapp_port', '19888'),
	$hadoop_proxyserver_port = hiera('hadoop_proxyserver_port', '8089'),
	$hadoop_security_authentication = hiera('security', 'simple'),
	) inherits hadoop::common-yarn {

	package { "hadoop-mapreduce-historyserver":
		ensure => latest,
		require => File["java-app-dir"],
	}

    service { "hadoop-mapreduce-historyserver":
      ensure => running,
      hasstatus => true,
      subscribe => [Package["hadoop-mapreduce-historyserver"], File["/etc/hadoop/conf/hadoop-env.sh"],
                    File["/etc/hadoop/conf/yarn-site.xml"], File["/etc/hadoop/conf/core-site.xml"],
                    File["/etc/hadoop/conf/mapred-site.xml"]],
      require => [Package["hadoop-mapreduce-historyserver"]],
    }

    package { "hadoop-yarn-proxyserver":
      ensure => latest,
      require => File["java-app-dir"],
    }

    service { "hadoop-yarn-proxyserver":
      ensure => running,
      hasstatus => true,
      subscribe => [Package["hadoop-yarn-proxyserver"], File["/etc/hadoop/conf/hadoop-env.sh"],
                    File["/etc/hadoop/conf/yarn-site.xml"], File["/etc/hadoop/conf/core-site.xml"]],
      require => [ Package["hadoop-yarn-proxyserver"] ],
    }

    if($hadoop_security_authentication == "kerberos") {
    	Kerberos::Host_keytab <| tag == "yarn" |> -> Service["hadoop-mapreduce-historyserver", "hadoop-yarn-proxyserver"]
	}

}