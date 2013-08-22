# Class: strom::config
#
#
class storm::config (
  $nimbus_host,
  $zookeeper_hosts,
  $storm_local_dir  = "/var/lib/storm",
  $worker_count     = undef,
  $ui_port          = undef,
  $enable_jmxremote = true
) {

  $java_home = $storm::params::java_home

  file { '/var/cache/storm':
    ensure  => directory,
    owner   => "storm",
    mode    => 770,
    require => Package['storm'],
  }

  file { "/opt/storm/conf/storm.yaml":
    ensure  => present,
    owner => "storm",
    group => "strom",
    content => template('storm/storm.yml.erb') ,
    require => [Package['storm'], File['/var/cache/storm']],
  }

  file { "/opt/storm/RELEASE":
    ensure => present,
    content => "0.8.2",
    owner   => "storm"
  }

  file { $storm::params::defaults_file_path :
    ensure  => present,
    owner => "root",
    content => template('storm/storm.default.erb'),
    require => [Package['storm']],
  }
}