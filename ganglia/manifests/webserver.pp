class ganglia::webserver {

  $ganglia_webserver_pkg = 'ganglia-web'
  include ganglia

  package {$ganglia_webserver_pkg:
    ensure => present,
    alias  => 'ganglia_webserver',
  }

  file {'/etc/httpd/conf.d/ganglia.conf':
     ensure  => present,
     require => Package['ganglia_webserver'],
     content => template('ganglia/ganglia.erb');
   }
}
