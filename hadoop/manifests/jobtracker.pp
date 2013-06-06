class hadoop::jobtracker (
  $hadoop_jobtracker_rpc_port = hiera('hadoop_jobtracker_port', 8021),
  $hadoop_security_authentication = hiera('security', 'simple'),
  $data_dirs = hiera('hadoop_data_dirs', ['/tmp/data']),
  $impala = hiera('impala', 'disabled'),
	) inherits hadoop::common-mapreduce {



  	package { "hadoop-0.20-mapreduce-jobtracker":
  		ensure => installed,
  		require => Package["hadoop-0.20-mapreduce"],
  	}

  	service { "hadoop-0.20-mapreduce-jobtracker":
    	ensure => running,
    	hasstatus => true,
    	subscribe => [Package["hadoop-0.20-mapreduce-jobtracker"], File["/etc/hadoop/conf/hadoop-env.sh"],
                  File["/etc/hadoop/conf/mapred-site.xml"], File["/etc/hadoop/conf/core-site.xml"]],
    	require => [ Package["hadoop-0.20-mapreduce-jobtracker"], File[$mapred_data_dirs] ],
  	}

    cron { "orphanjobsfiles":
	    command => "find /var/log/hadoop/ -type f -mtime +3 -name \"job_*_conf.xml\" -delete",
	    user    => "root",
	    hour    => "3",
	    minute  => "0",
  	}

    if ($impala == "enabled") {
      package { "impala-shell":
        ensure => latest,
        require => Yumrepo["impala-repo"],
      }
      include hadoop::impala
    }

  	if ($hadoop_security_authentication == "kerberos") {
  		Kerberos::Host_keytab <| tag == "mapred" |> -> Service["hadoop-0.20-mapreduce-jobtracker"]
  	}
}