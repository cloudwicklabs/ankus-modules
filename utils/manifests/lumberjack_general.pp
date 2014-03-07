class utils::lumberjack_general {
  #Add lubmerjack_default to monitor default config files based on OS
  $log_aggregation = hiera('log_aggregation', 'disabled')

  if ($log_aggregation == 'enabled') {
    $logstash_server = hiera('logstash_server')
    logstash::lumberjack_conf { "default":
      logstash_host => $logstash_server,
      logstash_port => 5672,
      daemon_name => 'lumberjack_default',
      field => "default-${::fqdn}",
    }
  }
}
