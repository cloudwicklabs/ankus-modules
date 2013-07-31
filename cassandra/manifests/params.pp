class cassandra::params {
    include java::params

    $java_home = $::hostname ? {
        default	=> "${java::params::java_base}/jdk${java::params::java_version}",
    }

    $cassandra_base = $::hostname ? {
    	default	=> "/etc/cassandra",
    }

    $data_path = $::hostname ? {
    	default	=> "/cassandra/data",
    }

    $commitlog_directory = $::hostname ? {
        default => "/cassandra/commitlog",
    }

    $saved_caches = $::hostname ? {
        default => "/cassandra/saved_caches",
    }

    $cluser_name = $::hostname ? {
        default => "Cassandra Cluster",
    }

    $seeds = $::hostname ? {
        default => "cassandra-01, cassandra-02, cassandra-03, cassandra-04",
    }

    $cassandra_log_path = $::hostname ? {
        default => "/var/log/cassandra",
    }

    $jmx_port = $::hostname ? {
        default => "7199",
    }

    $max_heap = $::hostname ? {
        default => "4G",
    }

    $heap_newsize = $::hostname ? {
        default => "800M"
    }
}