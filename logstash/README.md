puppet module for logstash
--------------------------

This module will install and manage logstash

###Sample Usage

```
#indexer
class { 'logstash':
  role => 'indexer'
}
#shipper
class { 'logstash':
  role => 'shipper',
  indexer => 'ip_of_indexer'
}
#lumberjack
class { 'logstash::lumberjack':
  logstash_host => 'localhost',
  logfiles => ['/var/log/messages', '/var/log/secure'],
  field => 'lumberjack_host1'
}
```
