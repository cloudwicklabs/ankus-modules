# Class to install logstash indexer which includes including local elasticsearch, redis, kibana
class { 'logstash':
  role => 'indexer'
}
