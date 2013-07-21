class ganglia::client (
  $cluster= hiera('cluster_name', 'hadoop_cluster'),
  $multicast_address = hiera('ganglia_multicast_address', ''),
  $owner = hiera('ganglia_owner', 'unspecified'),
  $send_metadata_interval = hiera('ganglia_send_metadata_interval', 0),
  $udp_port = hiera('ganglia_udp_port', 8649),
  $unicast_listen_port = hiera('ganalia_unicast_listen_port', 8649),
  $unicast_ipaddress = hiera('ganglia_server'),
  $unicast_port = hiera('ganglia_unicast_port', '8649'),
  $network_mode = hiera('ganalia_network_mode', 'unicast'),
  ) {
  include ganglia
  case $operatingsystem {
    'Ubuntu': {
      $ganglia_client_pkg = 'ganglia-monitor'
      $ganglia_client_service = 'ganglia-monitor'
      $ganglia_client_conf = 'gmond.conf.Debian.erb'
    }
    'CentOS': {
      $ganglia_client_pkg = 'ganglia-gmond'
      $ganglia_client_service = 'gmond'
      $ganglia_client_conf = 'gmond.conf.RedHat.erb'
    }
    default:  {fail('no known ganglia monitor package for this OS')}
  }

  package {$ganglia_client_pkg:
    ensure => 'installed',
    alias  => 'ganglia_client',
  }

  service {$ganglia_client_service:
    ensure  => 'running',
    enable  =>  'true',
    alias   => 'ganglia_client',
    status  => 'ps -ef | grep gmond | grep -qv grep',
    require => Package[$ganglia_client_pkg];
  }

  file {'/etc/ganglia/gmond.conf':
    ensure  => present,
    require => Package['ganglia_client'],
    content => template("ganglia/$ganglia_client_conf"),
    notify  => Service[$ganglia_client_service];
  }

}