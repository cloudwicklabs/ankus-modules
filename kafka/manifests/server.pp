# Class: kafka::server
#
#
class kafka::server inherits kafka::params {
  require kafka

  # Params for populating ERb templates
  $log_dir                         = $kafka::params::log_dir
  $jmx_port                        = $kafka::params::jmx_port
  $num_partitions                  = $kafka::params::num_partitions
  $num_network_threads             = $kafka::params::num_network_threads
  $num_io_threads                  = $kafka::params::num_io_threads
  $socket_send_buffer_bytes        = $kafka::params::socket_send_buffer_bytes
  $socket_receive_buffer_bytes     = $kafka::params::socket_receive_buffer_bytes
  $socket_request_max_bytes        = $kafka::params::socket_request_max_bytes
  $log_flush_interval_messages     = $kafka::params::log_flush_interval_messages
  $log_flush_interval_ms           = $kafka::params::log_flush_interval_ms
  $log_retention_hours             = $kafka::params::log_retention_hours
  $log_retention_bytes             = $kafka::params::log_retention_bytes
  $log_segment_bytes               = $kafka::params::log_segment_bytes
  $log_cleanup_interval_mins       = $kafka::params::log_cleanup_interval_mins
  $log_cleanup_policy              = $kafka::params::log_cleanup_policy
  $metrics_dir                     = $kafka::params::metrics_dir
  $server_properties_template      = $kafka::params::server_properties_template
  $default_template                = $kafka::params::default_template
  $java_home                       = $kafka::params::java_home
  $zookeeper_hosts                 = $kafka::params::zookeeper_hosts
  $zookeeper_connection_timeout_ms = $kafka::params::zookeeper_connection_timeout_ms
  $zookeeper_chroot                = $kafka::params::zookeeper_chroot
  $hosts                           = $kafka::params::hosts
  $broker_id                       = $hosts[$::fqdn]['id']
  $kafka_log_dir                   = $kafka::params::kafka_log_dir

  case $::operatingsystem {
    'RedHat', 'CentOS': {
      $defualts_file    = "/etc/sysconfig/kafka"
      $init_script = "kafka-server.RedHat"
    }
    'Debian', 'Ubuntu': {
      $defualts_file    = "/etc/default/kafka-server"
      $init_script = "kafka-server.Debian"
    }
  }

  if ($hosts[$::fqdn]['port']) {
    $broker_port = $hosts[$::fqdn]['port']
  }
  else {
    $broker_port = $kafka::params::default_broker_port
  }

  file { $defualts_file:
    content => template("kafka/kafka.default.erb")
  }

  file { '/etc/kafka/config/server.properties':
    content => template("kafka/server.properties.erb"),
  }

  file { '/etc/init.d/kafka-server':
    source => "puppet:///modules/${module_name}/init.d/${init_script}",
    mode => '0755',
    owner => 'root',
    group => 'root',
  }

  file { $log_dir:
    ensure  => 'directory',
    owner   => 'kafka',
    group   => 'kafka',
    mode    => '0755',
  }

  # If we are using Kafka Metrics Reporter, ensure
  # that the $metrics_dir exists.
  # if ($metrics_dir and !defined(File[$metrics_dir])) {
  #   file { $metrics_dir:
  #     ensure  => 'directory',
  #     owner   => 'kafka',
  #     group   => 'kafka',
  #     mode    => '0755',
  #   }
  # }

  file { "$kafka_log_dir":
    ensure => directory,
    owner  => "kafka",
    group  => "kafka",
  }

  file { "/etc/security/limits.d/kafka.nofiles.conf":
    ensure  => present,
    content => template("kafka/kafka.nofiles.conf.erb")
  }

  # Start the Kafka server.
  # We don't want to subscribe to the config files here.
  # It will be better to manually restart Kafka when
  # the config files changes.
  $kafka_ensure = $enabled ? {
    false   => 'stopped',
    default => 'running',
  }
  service { 'kafka-server':
    ensure     => $kafka_ensure,
    require    => [
                    File['/etc/kafka/config/server.properties'],
                    File['/etc/init.d/kafka-server'],
                    File['/etc/security/limits.d/kafka.nofiles.conf'],
                    File[$kafka_log_dir],
                    File[$defualts_file],
                    File[$log_dir]
                  ],
  }
}