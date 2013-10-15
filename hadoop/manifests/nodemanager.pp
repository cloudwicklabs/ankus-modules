class hadoop::nodemanager inherits hadoop::common-yarn {

    package { "hadoop-yarn-nodemanager":
      ensure => latest,
      require => File["java-app-dir"],
    }

    service { "hadoop-yarn-nodemanager":
      ensure => running,
      hasstatus => true,
      subscribe => [Package["hadoop-yarn-nodemanager"], File["/etc/hadoop/conf/hadoop-env.sh"],
                    File["/etc/hadoop/conf/yarn-site.xml"], File["/etc/hadoop/conf/core-site.xml"]],
      require => [ Package["hadoop-yarn-nodemanager"], File[$yarn_data_dirs] ],
    }

    file { $yarn_data_dirs:
    	ensure => directory,
    	owner => yarn,
      group => yarn,
      mode => 755,
    	require => [ Package["hadoop-yarn-nodemanager"], Exec["create-root-dir"]],
    }

    file { $yarn_container_log_dirs:
      ensure => directory,
      owner => yarn,
      group => yarn,
      mode => 755,
      require => [ Package["hadoop-yarn-nodemanager"], Exec["create-root-dir"]],
    }

    if ($hadoop_security_authentication == "kerberos") {
    	Kerberos::Host_keytab <| tag == "yarn" |> -> Service["hadoop-yarn-nodemanager"]
	}

}