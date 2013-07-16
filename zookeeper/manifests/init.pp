# == Class: zookeeper
#			zookeeper::client
#			zookeeper::server
#
# This module installs and manages zookeeper, which is a
# centralized service for maintaining configuration information,
# naming, providing distributed synchronization, and providing
# group services for hadoop/hbase
#
# === Parameters
#
# server::myid
#	zookeeper id for specified host
# server::ensemble
#	zookeeper ensemble, array of zookeeper hosts with port numbers
# server::kerberos_realm
#	kerberos realm name if security is enabled
#
# === Variables
#
# Nothing.
#
# === Requires
#
# Java Module
#
# === Examples
#
#	include zookeeper::client
#
#	class { "zookeeper::server":
#		myid 	 => "0",
#		ensemble => ["zk1.cw.com:2888:3888", "zk2.cw.com:2888:3888", "zk3.cw.com:2888:3888"],
#		kerberos_realm => "CW.COM",
#	}
#

class zookeeper {

  require utilities

  class client {
    include java
    package { "zookeeper":
      ensure => installed,
      require => [ File["java-app-dir"], Yumrepo["cloudera-repo"] ]
    }
  }

  class server(
    $myid,
    $ensemble = hiera('zookeeper_class_ensemble',['localhost:2888:3888']),
    $kerberos_realm = hiera('hadoop_kerberos_realm', inline_template('<%= domain.upcase %>')),
    $kerberos_domain = hiera('hadoop_kerberos_domain', inline_template('<%= domain %>')),
    $security = hiera('security', 'simple')
    )
    {
    include java
    package { "zookeeper-server":
      ensure => installed,
      require => [ File["java-app-dir"], Yumrepo["cloudera-repo"] ]
    }

    service { "zookeeper-server":
      enable => true,
      ensure => running,
      hasrestart => true,
      hasstatus => true,
      require => [ Package["zookeeper-server"], Exec["zookeeper-server-init"] ],
      subscribe => [ File[ "zookeeper-conf", "zookeeper-myid", "zookeeper-setjavapath" ] ],
    }

    file { "/etc/zookeeper/conf/zoo.cfg":
      alias => "zookeeper-conf",
      content => template("zookeeper/zoo.cfg.erb"),
      require => Package["zookeeper-server"],
    }

    file { "/var/lib/zookeeper/myid":
      alias => "zookeeper-myid",
      content => inline_template("<%= myid %>"),
      require => Package["zookeeper-server"],
    }

    file { "/etc/default/bigtop-utils":
      alias => "zookeeper-setjavapath",
      content => template("zookeeper/bigtop-utils.erb"),
      require => Package["zookeeper-server"],
    }

    exec { "zookeeper-server-init":
      command => "/usr/bin/zookeeper-server-initialize",
      user => "zookeeper",
      creates => "/var/lib/zookeeper/version-2",
      require => Package["zookeeper-server"],
    }

    #TODO: Add for kerberos
    if ($security == "kerberos") {
      require kerberos::client

      kerberos::host_keytab { "zookeeper":
        spnego => true,
        notify => Service["zookeeper-server"],
      }

      file { "/etc/zookeeper/conf/java.env":
        source  => "puppet:///modules/zookeeper/java.env",
        require => Package["zookeeper-server"],
        notify  => Service["zookeeper-server"],
      }

      file { "/etc/zookeeper/conf/jaas.conf":
        content => template("zookeeper/jaas.conf.erb"),
        require => Package["zookeeper-server"],
        notify  => Service["zookeeper-server"],
      }
    }
  }
}