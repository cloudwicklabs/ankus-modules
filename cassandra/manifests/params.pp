#module: cassandra
#file: params.pp
#Description: parameters required for the installation of apache-cassandra
#Author: Ashrith
#Date: 2012-07-15
#version: 0.1
#change the respective parameters to make this moduel working, for more info see the readme file in the module_home

class cassandra::params {

    include java::params
    #to do: add the java-params to the java module and add the following variables
    $java_home = $::hostname ? {
		default			=> "${java::params::java_base}/jdk${java::params::java_version}",
	}

    $version = $::hostname ? {
		default			=> "1.0.8",
	}

	$cassandra_base = $::hostname ? {
		default			=> "/etc/cassandra",
	}

	$data_path = $::hostname ? {
		default			=> "/cassandra/data",
	}

    $commitlog_directory = $::hostname ? {
        default                 => "/cassandra/commitlog",
    }

    $saved_caches = $::hostname ? {
        default                 => "/cassandra/saved_caches",
    }

    $cluser_name = $::hostname ? {
        default                 => "Cassandra Cluster",
    }

    $initial_token = $::hostname ? {
        default                 => "0",
        cassandra-01          => "0",
        cassandra-02          => "42535295865117307932921825928971026432",
        cassandra-03          => "85070591730234615865843651857942052864",
        cassandra-04          => "127605887595351923798765477786913079296",
    }

    $seeds = $::hostname ? {
        default                 => "cassandra-01, cassandra-02, cassandra-03, cassandra-04",
    }

    $cassandra_log_path = $::hostname ? {
        default                 => "/var/log/cassandra",
    }

    $jmx_port = $::hostname ? {
        default                 => "7199",
    }

    $max_heap = $::hostname ? {
        default                 => "4G",
    }

    $heap_newsize = $::hostname ? {
        default                 => "800M"
    }
}


