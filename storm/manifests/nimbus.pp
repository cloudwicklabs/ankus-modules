class storm::nimbus inherits storm {

  require storm

  service { 'storm-nimbus':
    ensure  => running,
    hasstatus => false,
    status    => "ps aux | grep java | grep nimbus | grep -qv grep",
    hasrestart => true,
    subscribe => [Package['storm'], File["/opt/storm/conf/storm.yaml", "/etc/sysconfig/storm"]],
  }

  file { "/usr/local/bin/storm":
    ensure => link,
    target => "/opt/storm/bin/storm",
    require => Package['storm'],
  }
}