class hadoop::tasktracker (
	$hadoop_jobtracker_rpc_port = hiera('hadoop_jobtracker_port', 8021),
	$hadoop_tasktracker_port = hiera('hadoop_tasktracker_port', 50060),
  $hadoop_security_authentication = hiera('security', 'simple'),
  $data_dirs = hiera('hadoop_data_dirs', ['/tmp/data']),
	) inherits hadoop::common-mapreduce {

	package { "hadoop-0.20-mapreduce-tasktracker":
		ensure => latest,
		require => Package["hadoop-0.20-mapreduce"],
	}

  	service { "hadoop-0.20-mapreduce-tasktracker":
    	ensure => running,
    	hasstatus => true,
    	subscribe => [Package["hadoop-0.20-mapreduce-tasktracker"], File["/etc/hadoop/conf/hadoop-env.sh"],
                  File["/etc/hadoop/conf/mapred-site.xml"], File["/etc/hadoop/conf/core-site.xml"]],
    	require => [ Package["hadoop-0.20-mapreduce-tasktracker"], File[$mapred_data_dirs] ],
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