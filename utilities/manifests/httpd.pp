class utilities::httpd {
  if $::osfamily == 'RedHat' or $::operatingsystem == 'amazon' {
    $apache_name          = 'httpd'
    $user                 = 'apache'
    $group                = 'apache'
    $httpd_dir            = '/etc/httpd'
    $conf_file            = 'httpd.conf'
  } elsif $::osfamily == 'Debian' {
    $user             = 'www-data'
    $group            = 'www-data'
    $apache_name      = 'apache2'
    $httpd_dir        = '/etc/apache2'
    $conf_file        = 'apache2.conf'
  }

  package { 'httpd':
    ensure => installed,
    name   => $apache_name,
  }

  group { $group:
    ensure  => present,
    require => Package['httpd']
  }

  user { $user:
    ensure  => present,
    gid     => $group,
    require => Package['httpd'],
    before  => Service['httpd'],
  }

  service { 'httpd':
    ensure    => true,
    name      => $apache_name,
    enable    => true,
  }
}