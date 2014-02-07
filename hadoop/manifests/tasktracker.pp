class hadoop::tasktracker inherits hadoop::common-mapreduce {
	package { "hadoop-0.20-mapreduce-tasktracker":
		ensure => latest,
		require => Package["hadoop-0.20-mapreduce"],
	}

  hadoop::create_dir_with_perm { $mapred_data_dirs:
    user => "mapred",
    group => "hadoop",
    mode => 755,
    require => Package['hadoop-0.20-mapreduce-tasktracker']
  }

	service { "hadoop-0.20-mapreduce-tasktracker":
  	ensure => running,
  	hasstatus => true,
  	subscribe => [Package["hadoop-0.20-mapreduce-tasktracker"], File["/etc/hadoop/conf/hadoop-env.sh"],
                File["/etc/hadoop/conf/mapred-site.xml"], File["/etc/hadoop/conf/core-site.xml"]],
  	require => [ Package["hadoop-0.20-mapreduce-tasktracker"], Hadoop::Create_dir_with_perm[$mapred_data_dirs] ],
	}

	if ($hadoop_security_authentication == "kerberos") {
		Kerberos::Host_keytab <| tag == "mapred" |> -> Service["hadoop-0.20-mapreduce-tasktracker"]
	}

  if ($log_aggregation == 'enabled') {
    logstash::lumberjack_conf { 'tasktracker':
      logstash_host => $logstash_server,
      logstash_port => 5672,
      daemon_name => 'lumberjack_tasktracker',
      field => "tasktracker-${::fqdn}",
      logfiles => ['/var/log/hadoop-0.20-mapreduce/hadoop*tasktracker*.log'],
      require => Service['hadoop-0.20-mapreduce-tasktracker']
    }
  }
}