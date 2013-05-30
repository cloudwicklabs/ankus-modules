# == Class: hadoop-oozie
#
# This module installs and manages oozie, which is a workflow scheduler system to manage Hadoop jobs.
#
# === Parameters
#
# [*kerberos_realm*]
#   name of the kerberos realm used to setup the kerberos,
#   requires only if kerberos is used as authetication service
#   for hadoop
#
# === Variables
#
# None
#
# === Requires
#
# Java
# Hadoop
#
# === Sample Usage
#
# include hadoop-oozie::server
# include hadoop-oozie::client
#
# === Copyright
#
# Copyright 2012 Cloudwick Technologies, unless otherwise noted.
#

class hadoop-oozie {

  class client(
    $kerberos_realm = hiera('hadoop_kerberos_realm', '')
    ) {
    package { "oozie-client":
      ensure => latest,
    }
  }

  class server(
    $kerberos_realm = hiera('hadoop_kerberos_realm', ''),
    $hadoop_controller = hiera('controller'),
    $hadoop_security_authentication = hiera('security')
    ) {

    if($hadoop_security_authentication == "kerberos") {
      require kerberos::client
      kerberos::host_keytab { "oozie":
        spnego => true,
      }
      Kerberos::Host_keytab <| title == "oozie" |> -> Service["oozie"]
    }

    package { "oozie":
      ensure => latest,
    }

    file { "/etc/oozie/conf/oozie-site.xml":
      content => template("hadoop-oozie/oozie-site.xml.erb"),
      require => Package["oozie"],
    }

    exec { "Oozie DB init":
      command => "/etc/init.d/oozie init && touch DB_INIT_COMPLETE",
      cwd     => "/var/lib/oozie",
      creates => "/var/lib/oozie/DB_INIT_COMPLETE",
      require => Package["oozie"],
    }

    service { "oozie":
      ensure => running,
      require => [ Package["oozie"], Exec["Oozie DB init"] ],
      hasrestart => true,
      hasstatus => true,
    }

    #oozie web interface
    file { "/var/lib/oozie/ext-2.2.tar.gz":
      source => "puppet:///modules/hadoop-oozie/ext-2.2.tar.gz",
      alias => "ext-source-tgz",
      require => Package["oozie"],
    }

    exec { "untar ext-2.2.tar.gz":
      command => "/bin/tar -zxf ext-2.2.tar.gz",
      cwd => "/var/lib/oozie",
      creates => "/var/lib/oozie/ext-2.2",
      alias => "untar-ext",
      refreshonly => true,
      subscribe => File["ext-source-tgz"],
      require => File["ext-source-tgz"],
    }
    #FIX: This fails (datanodes should be up and running to do this.)
    #exec { "untar-oozie-share-lib":
    #  command => "/bin/tar -xzf oozie-sharelib.tar.gz",
    #  cwd => "/usr/lib/oozie",
    #  creates => "/usr/lib/oozie/share",
    #  alias => "untar-oozie-share",
    #  require => Package["oozie"],
    #}

    #exec { "copy-sharelib-to-hdfs":
    #  user => "oozie",
    #  command => "/bin/bash -c 'hadoop fs -put /usr/lib/oozie/share /user/oozie/share'",
    #  refreshonly => true,
    #  subscribe => Exec["untar-oozie-share"],
    #}
  }
}
