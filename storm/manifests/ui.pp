class storm::ui inherits storm {

  require storm

  service { 'storm-ui':
    ensure  => running,
    hasstatus => true,
    hasrestart => true,
    require => [Package['storm'], File["/opt/storm/conf/storm.yaml", "/etc/sysconfig/storm"]],
  }
}