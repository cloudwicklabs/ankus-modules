# Class to install lumberjack agent, which would ship events off to logstash indexer
class { 'logstash::lumberjack':
  logstash_host => 'localhost',
  logfiles => ['/var/log/messages', '/var/log/secure'],
  field => 'lumberjack_host1'
}

