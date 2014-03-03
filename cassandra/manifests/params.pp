class cassandra::params {
  include java7::params
  include utils

  $java_home = $::hostname ? {
    default	=> "${java7::params::java7_base}/jdk${java7::params::java7_version}",
  }

  $repo_class = $::osfamily ? {
    /(?i-mx:redhat)/ => 'utils::repos::datastax::yum',
    /(?i-mx:debian)/ => 'utils::repos::datastax::apt',
  }

  $cassandra_base = $::operatingsystem ? {
    /(?i)(centos|redhat)/  => '/etc/cassandra/conf',
    /(?i)(ubuntu|debian)/  => '/etc/cassandra',
  	default	=> '/etc/cassandra',
  }

  $cassandra_deploy               = hiera('cassandra_deploy')
  $seeds                          = $cassandra_deploy['seeds']
  $nodes                          = $cassandra_deploy['nodes']
  $cassandra_pkg                  = hiera('cassandra_pkg', "dsc20")
  $num_tokens                     = hiera('cassandra_num_tokens', '256')
  $data_dirs                      = $cassandra_deploy['data_dirs']
  $commitlog_directory            = $cassandra_deploy['commitlog_dirs']
  $saved_caches                   = $cassandra_deploy['saved_caches_dirs']
  $cluster_name                   = hiera('cassandra_cluster_name', 'Ankus Cassandra Cluster')
  $jmx_port                       = hiera('cassandra_jmx_port', '7199')
  $max_heap                       = hiera('cassandra_max_heap', '0')
  $heap_newsize                   = hiera('cassandra_heap_newsize', '0')
  $authenticator                  = hiera('cassandra_authenticator', 'AllowAllAuthenticator')
  $authorizer                     = hiera('cassandra_authorizer', 'AllowAllAuthorizer')
  $partitioner                    = hiera('cassandra_partitioner', 'org.apache.cassandra.dht.Murmur3Partitioner')
  $disk_failure_policy            = hiera('cassandra_disk_failure_policy', 'stop')
  $read_request_timeout_in_ms     = hiera('cassandra_read_request_timeout_in_ms', '10000')
  $range_request_timeout_in_ms    = hiera('cassandra_range_request_timeout_in_ms', '10000')
  $write_request_timeout_in_ms    = hiera('cassandra_write_request_timeout_in_ms', '10000')
  $truncate_request_timeout_in_ms = hiera('cassandra_truncate_request_timeout_in_ms', '60000')
  $request_timeout_in_ms          = hiera('cassandra_request_timeout_in_ms', '10000')
  $log_aggregation                = hiera('log_aggregation', 'disabled')
  if ($log_aggregation == 'enabled') {
    $logstash_server = hiera('logstash_server')
  }
}
