# Class to install logstash shipper, which would ship events off to logstash indexer
class { 'logstash':
  role => 'shipper',
  #fqdn|ip of logstash indexer
  indexer => 'localhost',
}
