class ganglia::webserver {

  case $operatingsystem {
    'Ubuntu': {
      $ganglia_webserver_pkg = 'ganglia-webfrontend'
      $ganglia_webserver_path = '/etc/apache2/sites-enabled/ganglia'
      $ganglia_apache_conf = 'ganglia.Debian.erb'
      $apacheservice = "apache2"
    }
    'CentOS': {
      $ganglia_webserver_pkg = 'ganglia-web'
      $ganglia_webserver_path = '/etc/httpd/conf.d/ganglia.conf'
      $ganglia_apache_conf = 'ganglia.RedHat.erb'
      $apacheservice = "httpd"
    }
  }

  include ganglia

  package {$ganglia_webserver_pkg:
    ensure => present,
    alias  => 'ganglia_webserver'
  }

  exec { "refresh-apache":
    command => "/etc/init.d/${apacheservice} reload",
    refreshonly => true,
  }

  file {$ganglia_webserver_path:
    ensure  => present,
    require => Package['ganglia_webserver'],
    content => template("ganglia/$ganglia_apache_conf"),
    notify  => Exec['refresh-apache']
  }
}
