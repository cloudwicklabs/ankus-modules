# Class: name
#
#
class storm::worker inherits storm {
  require storm

  service { 'storm-supervisor':
    ensure  => running,
    hasstatus => true,
    hasrestart => true,
    require => [Package['storm'], File["/opt/storm/conf/storm.yaml", "/etc/sysconfig/storm"]],
  }
}