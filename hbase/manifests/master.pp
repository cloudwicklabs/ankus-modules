# == Class: hbase::master
#
# This class installs and manages hbase master
#
# === Parameters
#
# [*rootdir*]
#   hbase rootdir, path where hbase writes in hdfs
#
# [*zookeeper_ensemble*]
#   list of zookeeper machines that are required for making
#   hbase highly available
#
# [*heap_size*]
#   heap size of the hbase reagion server
#
# [*auth*]
#   authentication method used either simple or kerberos
#
# === Variables
#
# None.
#
# === Requires
#
# Java Module
# Zookeeper Module
#
# === Examples
#
# include hbase::master
#

class hbase::master(
    $rootdir = hiera('hbase_rootdir', '/hbase'),
    $zookeeper_quorum = hiera('zookeeper_ensemble'),
    $heap_size = hiera('hbase_heap_size', '1024'),
    $auth = hiera('security', 'simple'),
    ) inherits hbase {

    include hbase::client-package
    require hadoop::common-hdfs

    package { "hbase-master":
      ensure => latest,
      require => Package["hbase"]
    }

    file { "/etc/hbase/conf/hbase-site.xml":
      content => template("hbase/hbase-site.xml.erb"),
      require => Package["hbase"],
    }

    file { "/etc/hbase/conf/hbase-env.sh":
      content => template("hbase/hbase-env.sh.erb"),
      require => Package["hbase"],
    }

    service { "hbase-master":
      ensure => running,
      require => Package["hbase-master"],
      subscribe => File["/etc/hbase/conf/hbase-site.xml", "/etc/hbase/conf/hbase-env.sh"],
      hasrestart => true,
      hasstatus => true,
    }

    if($auth == "Kerberos") {

    require kerberos::client
    kerberos::host_keytab { "hbase":
        spnego => true,
    }

    file { "/etc/hbase/conf/jaas.conf":
      content => template("hbase/jaas.conf.erb"),
      require => Package["hbase"],
    }

    Kerberos::Host_keytab <| title == "hbase" |> -> Service["hbase-master"]
  }
}