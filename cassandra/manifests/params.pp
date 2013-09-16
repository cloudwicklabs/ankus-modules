class cassandra::params {
    include java::params
    include utilities

    $java_home = $::hostname ? {
        default	=> "${java::params::java_base}/jdk${java::params::java_version}",
    }

    $cassandra_base = $::hostname ? {
    	default	=> "/etc/cassandra",
    }

    $num_tokens = hiera('cassandra_num_tokens', '256')
    $data_dirs = hiera('storage_dirs', "/cassandra")
    $data_path = append_each("/data", $data_dirs)
    $commitlog_directory = append_each("/commitlog", $data_dirs)
    $saved_caches = append_each("/saved_caches", $data_dirs)
    $cluster_name = hiera(cassandra_cluster_name, "Ankus Cassandra Cluster")
    $jmx_port = hiera(cassandra_jmx_port, '7199')
    $max_heap = hiera(cassandra_max_heap, '4G')
    $heap_newsize = hiera(cassandra_heap_newsize, '800M')
    $authenticator = hiera(cassandra_authenticator, 'AllowAllAuthenticator')
    $authorizer = hiera(cassandra_authorizer, 'AllowAllAuthorizer')
    $partitioner = hiera(cassandra_partitioner, 'org.apache.cassandra.dht.Murmur3Partitioner')
    $disk_failure_policy = hiera(cassandra_disk_failure_policy, 'stop')
}