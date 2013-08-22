Dependencies:
============
JAVA
ZOOKEEPER

Sample Usage:
============
All storm nodes (nimbus, supervisor, ui) should include `storm` class, this ensures that all nodes share the same storm.yaml config file.

```puppet
class { "storm":
  nimbus_host     => "nimbus.mydomain.org"
  zookeeper_hosts => ["zk1.mydomain.org", "zk2.mydomain.org"],
  worker_count    => $processorcount - 2, # use all but 2 processors on each worker machine
  ui_port         => 6999,
}
```

Storm Nimbus Master:

```puppet
include storm::nimbus
```

Storm Supervisor workers:

```puppet
include storm::worker
```

Storm UI:

```puppet
include storm::ui
```