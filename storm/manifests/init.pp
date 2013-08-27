class storm(
  $nimbus_host      = hiera(storm_nimbus_host, "localhost"),
  $zookeeper_hosts  = hiera(zookeeper_quoram, ["localhost"]),
  $storm_local_dir  = hiera(storm_local_dir, "/var/lib/storm"),
  $worker_count     = hiera(storm_worker_count, undef),
  $ui_port          = hiera(storm_ui_port, 8080),
  $enable_jmxremote = true
  ) inherits storm::params {

  class { 'storm::install': }

  class { "storm::config":
    nimbus_host      => $nimbus_host,
    zookeeper_hosts  => $zookeeper_hosts,
    storm_local_dir  => $storm_local_dir,
    worker_count     => $worker_count,
    ui_port          => $ui_port,
    enable_jmxremote => $enable_jmxremote,
    require         => Class["storm::install"],
  }
}