class ganglia::webserver {

  case $operatingsystem {
    'Ubuntu': {
      $ganglia_webserver_pkg = 'ganglia-webfrontend'
      $ganglia_webserver_path = '/etc/apache2/sites-enabled/ganglia'
      $ganglia_apache_conf = 'ganglia.Debian.erb'
    }
    'CentOS': {
      $ganglia_webserver_pkg = 'ganglia-web'
      $ganglia_webserver_path = '/etc/httpd/conf.d/ganglia.conf'
      $ganglia_apache_conf = 'ganglia.RedHat.erb'
    }
  }

  include ganglia

  package {$ganglia_webserver_pkg:
    ensure => present,
    alias  => 'ganglia_webserver',
  }

  file {$ganglia_webserver_path:
     ensure  => present,
     require => Package['ganglia_webserver'],
     content => template("ganglia/$ganglia_apache_conf");
  }
}
