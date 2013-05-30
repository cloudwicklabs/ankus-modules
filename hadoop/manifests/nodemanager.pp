class hadoop::nodemanager (
	$hadoop_resourcemanager_host = hiera('hadoop_resourcemanager_host'),
	$hadoop_resourcemanager_port = hiera('hadoop_resourcemanager_port', 8032),
	$hadoop_nodemanager_port = hiera('hadoop_nodemanager_port', '8041'),
	$hadoop_resourcetracker_port = hiera('hadoop_resourcetracker_port', 8031),
	$hadoop_resourcescheduler_port = hiera('hadoop_resourcescheduler_port', 8030),
  $hadoop_security_authentication = hiera('hadoop_security_authentication', 'simple'), 
  $data_dirs = hiera('hadoop_data_dirs', ['/tmp/data']),	
	) inherits hadoop::common-yarn {

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
   
    if ($hadoop_security_authentication == "kerberos") {
    	Kerberos::Host_keytab <| tag == "yarn" |> -> Service["hadoop-yarn-nodemanager"]
	}

}