class ganglia::server (
   $clusters = [{cluster_name => 'hadoop_cluster', cluster_hosts => [{address => "$ipaddress", port => '8649'}]}],
   $gridname = hiera('ganglia_gridname', 'hadoop'),
  ) {
  include ganglia
  include ganglia::client
  include ganglia::webserver

  case $operatingsystem {
    'Ubuntu': {
      $ganglia_server_pkg = 'gmetad'
    }
    'CentOS': {
      $ganglia_server_pkg = 'ganglia-gmetad'
    }
  }

  package {$ganglia_server_pkg:
    ensure => present,
    alias  => 'ganglia_server',
  }

  service { "gmetad":
    ensure  =>  running,
    enable  => true,
    status => 'ps aux | grep gmetad | grep -qv grep',
    require => Package[$ganglia_server_pkg],
  }

  file {'/etc/ganglia/gmetad.conf':
    ensure  => present,
    require => Package['ganglia_server'],
    notify  => Service['gmetad'],
    content => template('ganglia/gmetad.conf.erb');
  }

}