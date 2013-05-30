# == Class: hadoop-hue
#
# This module installs and manages hue, Hue is both a Web UI for Hadoop and a
# framework to create interactive Web applications.
#
# === Parameters
#
# None
#
# === Variables
#
# === Requires
#
# Java
# Hadoop
#
# === Sample Usage
#
# include hadoop-hue (on jobtracker)
#
# === Copyright
#
# Copyright 2012 Cloudwick Technologies, unless otherwise noted.
#

#TODO: This can now only be installed on jobtracker and supports only webhdfs

class hadoop-hue (
  $hadoop_oozie_url = "http://localhost:11000/oozie",
  $hadoop_hue_host = hiera('hadoop_hue_host', '0.0.0.0'),
  $hadoop_hue_port = hiera('hadoop_hue_port', "8888"),
  $hadoop_security_authentication = hiera('hadoop_security_authentication', 'simple'),
  )
  {
    $ha = hiera('ha')
    $impala = hiera('impala', 'disabled')
    $hadoop_namenode_host = hiera('hadoop_namenode')
    $hadoop_controller_host = hiera('controller')
    $jobtracker = hiera('mapreduce')
    $hadoop_jobtracker_host = $jobtracker['master_node']
    $first_namenode = inline_template("<%= hadoop_namenode_host.to_a[0] %>")
    $hadoop_namenode_port = hiera('hadoop_namenode_port', '8020')
    if ($ha != "disabled") {
      $hadoop_ha_nameservice_id = hiera('hadoop_ha_nameservice_id', 'ha-nn-uri')
      $default_fs = "hdfs://$hadoop_ha_nameservice_id"
    } else {
      $default_fs = "hdfs://$first_namenode:$hadoop_namenode_port"
    }

    if ($hadoop_security_authentication == "kerberos") {
      require kerberos::client
      kerberos::host_keytab { "hue":
        spnego => false,
      }
    }

    $hue_packages = [ "hue", "hue-server", "hue-plugins", "python-devel", "postgresql-devel", "gcc" ]

    package { $hue_packages:
      ensure => latest,
    }

    file { "/etc/hue/hue.ini":
      content => template("hadoop-hue/hue.ini.erb"),
      require => Package["hue"],
    }

    exec { "copy-hue-plugin":
      command => "/bin/cp /usr/share/hue/desktop/libs/hadoop/java-lib/hue-plugins-*.jar /usr/lib/hadoop-0.20-mapreduce/lib",
      user => "root",
      creates => "/usr/lib/hadoop-0.20-mapreduce/lib/hue-plugins-*.jar",
      refreshonly => true,
      subscribe => Package["hue"],
    }

    exec { "install-psycopg2":
      command => "/usr/share/hue/build/env/bin/easy_install psycopg2",
      user => "root",
      unless => "/bin/rpm -qa | /bin/grep psycopg2 &> /dev/null", #FIXME
      require => Package[$hue_packages],
    }

    exec { "sync-db":
      command => "/usr/share/hue/build/env/bin/hue syncdb --noinput",
      user => "root",
      require => Exec["install-psycopg2"],
    }

    service { "hue":
      ensure => running,
      require => [ Package["hue"], File["/etc/hue/hue.ini"], Exec["sync-db"] ],
      subscribe => [Package["hue"], File["/etc/hue/hue.ini"] ],
      hasrestart => true,
      hasstatus => true,
    }

    Kerberos::Host_keytab <| title == "hue" |> -> Service["hue"]
}