# == Class:
# hadoop-oozie::server
# hadoop-oozie::client
#
# This module installs and manages oozie, which is a workflow scheduler system to manage Hadoop jobs
# (MapReduce, Streaming, Pipes, Pig, Hive, Sqoop, etc).
#
# Oozie client is a command-line utility that interacts with the Oozie server via the Oozie
# web-services API
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
    require utilities
    package { "oozie-client":
      ensure => latest,
    }
  }

  class server(
    $kerberos_realm = hiera('hadoop_kerberos_realm', ''),
    $hadoop_controller = hiera('controller'),
    $hadoop_security_authentication = hiera('security')
    ) {
    require utilities
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
      alias   => 'oozie-conf',
      content => template("hadoop-oozie/oozie-site.xml.erb"),
      require => Package["oozie"],
      notify  => Service["oozie"]
    }

    file { "/etc/oozie/conf/oozie-env.sh":
      alias   => 'oozie-env',
      content => template("hadoop-oozie/oozie-env.sh.erb"),
      require => Package["oozie"],
      notify  => Service["oozie"]
    }

    exec { "Oozie DB init":
      command => "/etc/init.d/oozie init && touch DB_INIT_COMPLETE",
      cwd     => "/var/lib/oozie",
      creates => "/var/lib/oozie/DB_INIT_COMPLETE",
      require => Package["oozie"],
    }

    service { "oozie":
      ensure => running,
      require => [ Package["oozie"], Exec["Oozie DB init"], File["oozie-conf"], File["oozie-env"] ],
      hasrestart => true,
      hasstatus => true,
    }

    #
    # Oozie web interface
    #
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

    #
    # Install Oozie ShareLin in HDFS - contains all of the necessary JARs to enable workflow jobs to run
    #                                  streaming, DistCp, Pig, Hive, and Sqoop actions.
    #

    #FIX ME: This fails (datanodes should be up and running to do this.)
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
