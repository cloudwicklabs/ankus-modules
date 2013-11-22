class cassandra::params {
    include java7::params
    include utilities

    $java_home = $::hostname ? {
        default	=> "${java7::params::java_base}/jdk${java7::params::java_version}",
    }

    $cassandra_base = $::hostname ? {
    	default	=> "/etc/cassandra",
    }

    $cassandra_pkg = "dsc20"

    $num_tokens = hiera('cassandra_num_tokens', '256')
    $data_dirs = hiera('cassadndra_data_dirs', ['/var/lib/cassandra/data'])
    $commitlog_directory = hiera('cassandra_commitlog_dir', '/var/lib/cassandra/commitlog')
    $saved_caches = hiera('cassandra_saved_cahes_dir', '/var/lib/cassandra/saved_caches')
    $cluster_name = hiera(cassandra_cluster_name, "Ankus Cassandra Cluster")
    $jmx_port = hiera(cassandra_jmx_port, '7199')
    $max_heap = hiera(cassandra_max_heap, '0')
    $heap_newsize = hiera(cassandra_heap_newsize, '0')
    $authenticator = hiera(cassandra_authenticator, 'AllowAllAuthenticator')
    $authorizer = hiera(cassandra_authorizer, 'AllowAllAuthorizer')
    $partitioner = hiera(cassandra_partitioner, 'org.apache.cassandra.dht.Murmur3Partitioner')
    $disk_failure_policy = hiera(cassandra_disk_failure_policy, 'stop')
}