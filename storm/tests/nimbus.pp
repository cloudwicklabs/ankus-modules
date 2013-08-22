class { "storm":
  nimbus_host     => "nimbus.mydomain.org"
  zookeeper_hosts => ["zk1.mydomain.org", "zk2.mydomain.org"],
  worker_count    => $processorcount - 2, # use all but 2 processors on each worker machine
  ui_port         => 6999,
}

include storm::nimbus
include storm::ui