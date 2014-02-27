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
  $ganglia_web_conf = "/usr/share/ganglia-web/conf.php"

  include ganglia

  include utils::httpd
  include utils::php

  file { "/tmp/ganglia-web-3.5.10.tar":
    mode    => 0644,
    source  => "puppet:///modules/${module_name}/ganglia-web-3.5.10.tar",
    alias   => "ganglia-web-tar"
  }

  exec { "untar ganglia-web-3.5.10.tar":
    command     => "/bin/tar -xf /tmp/ganglia-web-3.5.10.tar -C /usr/share/",
    creates     => "/usr/share/ganglia-web-3.5.10",
    alias       => "untar-ganglia-web",
    refreshonly => true,
    subscribe   => File["ganglia-web-tar"]
  }

  file { "/usr/share/ganglia-web":
    ensure  => "link",
    target  => "/usr/share/ganglia-web-3.5.10",
    mode    => 0644,
    alias   => 'ganglia-web-dir',
    require => Exec["untar-ganglia-web"]
  }

  file { "/var/lib/ganglia":
    ensure  => "directory",
    owner   => "root",
    group   => "root",
    mode    => 0755,
    alias   => "ganglia-lib",
    require => File["ganglia-web-dir"]
  }

  file { ["/var/lib/ganglia/dwoo", "/var/lib/ganglia/dwoo/cache", "/var/lib/ganglia/dwoo/compiled"]:
    ensure  => "directory",
    owner   => "apache",
    group   => "apache",
    mode    => 0755,
    require => [File['ganglia-lib'], Package['httpd']]
  }

  file { "/var/lib/ganglia/rrds":
    ensure  => "directory",
    owner   => "ganglia",
    group   => "ganglia",
    mode    => 0755,
    require => File["ganglia-lib"]
  }

  file { "/var/lib/ganglia/conf":
    ensure  => "directory",
    owner   => "apache",
    group   => "apache",
    mode    => 0755,
    require => [File["ganglia-lib"], Package['httpd']]
  }

  file { $ganglia_web_conf: #/usr/share/ganglia-web/conf.php
    content => template("ganglia/conf.php.erb"),
    require => File["ganglia-web-dir"]
  }

  file {$ganglia_webserver_path: #/etc/httpd/conf.d/ganglia.conf
    ensure  => present,
    content => template("ganglia/$ganglia_apache_conf"),
    notify  => Service['httpd'],
    require => Package['httpd']
  }
}