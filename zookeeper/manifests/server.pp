# == Class: zookeeper::server
#
# Installas and manages zookeeper server
#
# === Parameters
#
# [*myid*]
#   zookeeper id for specified host
#
# [*ensemble*]
#   zookeeper ensemble, array of zookeeper hosts with port numbers
#
# [*kerberos_realm*]
#   kerberos realm name if security is enabled
#
# [*kerberos_domain*]
#   kerberos domain name if security is enabled
#
# [*security*]
#   specifies the security type
#
# === Variables
#
# None
#
# === Examples
#
# include zookeeper::server
#
# === Authors
#
# cloudwick <ashrith@cloudwick.com>
#
# === Copyright
#
# Copyright 2012 Cloudwick Inc, unless otherwise noted.
#
class zookeeper::server(
    $myid = 0,
    $ensemble = hiera('zookeeper_class_ensemble',['localhost:2888:3888']),
    $kerberos_realm = hiera('kerberos_realm', inline_template('<%= @domain.upcase %>')),
    $kerberos_domain = hiera('kerberos_domain', inline_template('<%= @domain %>')),
    $security = hiera('security', 'simple')
  ) inherits zookeeper
  {
  include java

  package { 'zookeeper-server':
    ensure  => installed,
    require => [ File['java-app-dir'], Class[$::hadoop::params::default::repo_class] ]
  }

  service { 'zookeeper-server':
    ensure      => running,
    enable      => true,
    hasrestart  => true,
    hasstatus   => true,
    require     => [ Package['zookeeper-server'], Exec['zookeeper-server-init'] ],
    subscribe   => [ File[ 'zookeeper-conf', 'zookeeper-myid', 'zookeeper-setjavapath' ] ]
  }

  file { '/etc/zookeeper/conf/zoo.cfg':
    alias   => 'zookeeper-conf',
    content => template('zookeeper/zoo.cfg.erb'),
    require => Package['zookeeper-server']
  }

  file { '/var/lib/zookeeper/myid':
    alias   => 'zookeeper-myid',
    content => inline_template('<%= @myid %>'),
    require => Package['zookeeper-server']
  }

  file { '/etc/default/bigtop-utils':
    alias   => 'zookeeper-setjavapath',
    content => template('zookeeper/bigtop-utils.erb'),
    require => Package['zookeeper-server']
  }

  exec { 'zookeeper-server-init':
    command => '/usr/bin/zookeeper-server-initialize',
    user    => 'zookeeper',
    creates => '/var/lib/zookeeper/version-2',
    require => Package['zookeeper-server'],
  }

  if ($security == 'kerberos') {
    require kerberos::client

    kerberos::host_keytab { 'zookeeper':
      spnego => true,
      notify => Service['zookeeper-server']
    }

    Package['zookeeper-server'] -> Kerberos::Host_keytab<| title == 'zookeeper' |>

    file { '/etc/zookeeper/conf/java.env':
      source  => 'puppet:///modules/zookeeper/java.env',
      require => Package['zookeeper-server'],
      notify  => Service['zookeeper-server'],
    }

    file { '/etc/zookeeper/conf/jaas.conf':
      content => template('zookeeper/jaas.conf.erb'),
      require => Package['zookeeper-server'],
      notify  => Service['zookeeper-server'],
    }
  }
}