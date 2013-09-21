class kafka::params {
  include java::params
  include utilities::params
  
  $kafka_pkgs_base = $::hostname ? {
    default => $utilities::params::packages_base
  }
  $kafka_pkgs_home = $::hostname ? {
    default => "${kafka_pkgs_base}/packages"
  }
  $kafka_version = $::hostname ? {
    default => '0.8.0'
  }
  $default_broker_port = hiera(kafka_broker_port, 9092)
  $default_hosts = {
      "${::fqdn}" => {
          'port' => $default_broker_port,
          'id'   => 1,
      },
  }
  $hosts                           = hiera(kafka_hosts, $default_hosts)
  $kafka_log_dir                   = "/var/log/kafka"
  $kafka_log_file                  = "${kafka_log_dir}/kafka.log"
  $zookeeper_hosts                 = hiera(zookeeper_ensemble,['localhost:2181'])
  $zookeeper_connection_timeout_ms = hiera(kafka_zookeeper_connection_timeout, 1000000)
  $consumer_group_id               = hiera(kafka_consumer_group_id, 'test-consumer-group')
  $producer_type                   = hiera(kafka_producer_type, 'async')
  $producer_batch_num_messages     = hiera(kafka_producer_batch_messages, 200)
  $jmx_port                        = hiera(kafka_jmx_port, 9999)
  $log_dir                         = hiera(kafka_data_dir, '/var/spool/kafka')
  $num_partitions                  = hiera(kafka_num_partitions, 1)
  $num_network_threads             = hiera(kafka_num_network_threads, 2)
  $num_io_threads                  = hiera(kafka_num_io_threads, 2)
  $socket_send_buffer_bytes        = hiera(kafka_socket_send_buffer_bytes, 1048576)
  $socket_receive_buffer_bytes     = hiera(kafka_socket_receive_buffer_bytes, 1048576)
  $socket_request_max_bytes        = hiera(kafka_socket_request_max_bytes, 104857600)
  $log_flush_interval_messages     = hiera(kafka_log_flush_interval_messages, 10000)
  $log_flush_interval_ms           = hiera(kafka_log_flush_interval_ms, 1000)
  $log_retention_hours             = 168     # 1 week
  $log_retention_bytes             = undef
  $log_segment_bytes               = 536870912
  $log_cleanup_policy              = 'delete'
  $log_cleanup_interval_mins       = 1
  # $metrics_dir                     = hiera(kafka_metrics_dir, 'disabled')
  $java_home                       = inline_template("<%= scope.lookupvar('java::params::java_base') %>/jdk<%= scope.lookupvar('java::params::java_version') %>")
}