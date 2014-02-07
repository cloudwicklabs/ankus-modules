class hadoop::resourcemanager (
  $hadoop_resourcemanager_host = hiera('hadoop_resourcemanager_host', "$fqdn"),
  $hadoop_resourcemanager_port = hiera('hadoop_resourcemanager_port', 8032),
  $hadoop_resourcetracker_port = hiera('hadoop_resourcetracker_port', 8031),
  $hadoop_resourcescheduler_port = hiera('hadoop_resourcescheduler_port', 8030),
  $hadoop_security_authentication = hiera('hadoop_security_authentication', 'simple'),
  $data_dirs = hiera('storage_dirs', ['/tmp/data']),
	) inherits hadoop::common-yarn {


  package { "hadoop-yarn-resourcemanager":
    ensure => latest,
    require => File["java-app-dir"],
  }

  service { "hadoop-yarn-resourcemanager":
    ensure => running,
    hasstatus => true,
    subscribe => [Package["hadoop-yarn-resourcemanager"], File["/etc/hadoop/conf/hadoop-env.sh"],
                  File["/etc/hadoop/conf/yarn-site.xml"], File["/etc/hadoop/conf/core-site.xml"],
                  File["/etc/hadoop/conf/mapred-site.xml"]],
    require => [ Package["hadoop-yarn-resourcemanager"], Hadoop::Create_dir_with_perm[$yarn_master_dirs] ],
  }

  hadoop::create_dir_with_perm { $yarn_master_dirs:
    user => "yarn",
    group => "yarn",
    mode => 755,
    require => Package['hadoop-yarn-resourcemanager']
  }

  file { $yarn_data_dirs:
    ensure => directory,
    owner => yarn,
    group => yarn,
    mode => 755,
    require => [ Package["hadoop-yarn-resourcemanager"], Exec["create-root-dir"]],
  }

	cron { "orphanjobsfiles":
    command => "find /var/log/hadoop/ -type f -mtime +3 -name \"job_*_conf.xml\" -delete",
    user    => "root",
    hour    => "3",
    minute  => "0",
	}

  if ($hadoop_security_authentication == "kerberos") {
  	Kerberos::Host_keytab <| tag == "yarn" |> -> Service["hadoop-yarn-resourcemanager"]
  }
}