class storm::ui inherits storm {

  require storm

  service { 'storm-ui':
    ensure  => running,
    enable    => true,
    hasstatus => false,
    status    => "ps aux | grep java | grep ui | grep -qv grep",
    hasrestart => true,
    subscribe => [Package['storm'], File["/opt/storm/conf/storm.yaml", "/etc/sysconfig/storm"]],
  }
}