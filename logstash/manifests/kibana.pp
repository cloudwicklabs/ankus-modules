class logstash::kibana {

  $kibana_home = '/opt/kibana'
  $kibana_user = 'kibana'
  $kibana_group = 'kibana'
  $kibana_etc = '/etc/kibana'
  $kibana_log = '/var/log/kibana'
  $kibana_run = '/var/run/sinatra'
  $elasticsearch_servers = ['localhost:9200']
  $elasticsearch_timeout = '500'
  $kibana_port = '5601'
  $kibana_address = 'locahost'
  $dep_packages = ['ruby', 'ruby-devel', 'rubygems', 'git', 'make', 'gcc-c++']

  package { $dep_packages:
    ensure => installed,
  }

  package { 'bundler':
    ensure => installed,
    provider => gem,
    require => Package[$dep_packages]
  }

  file {
    $kibana_etc:
      ensure => 'directory';
    $kibana_log:
      ensure => 'directory';
  }

  file { [$kibana_run, "$kibana_run/pid"]:
    ensure => directory,
    before => Service['kibana']
  }

  exec { "install_kibana":
    command => 'git clone git://github.com/rashidkpc/Kibana.git kibana',
    cwd => '/opt',
    path => ["/usr/local/sbin","/usr/local/bin","/usr/sbin","/usr/bin","/sbin","/bin"],
    creates => $kibana_home,
    require => Package[$dep_packages]
  }

  exec { "bundle_install":
    command => 'bundle install',
    cwd     => "$kibana_home",
    path    => ["/usr/local/sbin","/usr/local/bin","/usr/sbin","/usr/bin","/sbin","/bin"],
    require => [ Package['bundler'], Exec['install_kibana'] ],
    before => Service['kibana']
  }

  file { "${kibana_home}/KibanaConfig.rb":
    ensure => present,
    content => template("${module_name}/etc/kibana/KibanaConfig.rb.erb"),
    require => Exec['install_kibana'],
    notify => Service['kibana']
  }

  #Service

  file { "${kibana_home}/kibana-daemon.rb":
    alias => 'kibana_daemon',
    ensure => present,
    mode => '0755',
    source => "puppet:///modules/${module_name}/kibana-daemon.rb",
    before => Service['kibana'],
    require => Exec['install_kibana']
  }

  file { '/etc/init.d/kibana':
    alias => 'kibana_init',
    ensure => present,
    mode => '0755',
    content => template("${module_name}/etc/kibana/kibanainit.rb.erb"),
    before => Service['kibana'],
  }

  service { 'kibana':
    ensure => running,
    hasstatus => false,
  }
}