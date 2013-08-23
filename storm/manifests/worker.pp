# Class: name
#
#
class storm::worker inherits storm {
  require storm

  service { 'storm-supervisor':
    ensure  => running,
    hasstatus => false,
    status    => "ps aux | grep java | grep supervisor | grep -qv grep",
    hasrestart => true,
    subscribe => [Package['storm'], File["/opt/storm/conf/storm.yaml", "/etc/sysconfig/storm"]],
  }
}