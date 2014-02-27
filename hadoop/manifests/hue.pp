# == Class: hadoop::hue
#
# Installs and manages hue, Hue is both a Web UI for Hadoop and a
# framework to create interactive Web applications.
#
# === Parameters
#
# None
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
# include hadoop::hue (on jobtracker)
#
# === Copyright
#
# Copyright 2012 Cloudwick Technologies, unless otherwise noted.
#

#TODO: This can now only be installed on jobtracker and supports only webhdfs

class hadoop-hue {
  include hadoop::params::hue

  if ($hadoop_security_authentication == "kerberos") {
    require kerberos::client

    kerberos::host_keytab { "hue":
      spnego => false,
    }
  }

  $hue_packages = [ "hue", "hue-server", "hue-plugins" ]

  package { $hue_packages:
    ensure  => latest,
    require => [ File['java-app-dir'], Class[$::hadoop::params::default::repo_class] ]
  }

  file { '/etc/hue/hue.ini':
    content => template('hadoop/hue/hue.ini.erb'),
    require => Package['hue'],
  }

  if ($hadoop::params::default::hadoop_mapreduce_framework == 'mr1') {
    exec { 'copy-hue-plugin':
      command     => '/bin/cp /usr/share/hue/desktop/libs/hadoop/java-lib/hue-plugins-*.jar /usr/lib/hadoop-0.20-mapreduce/lib',
      user        => 'root',
      creates     => '/usr/lib/hadoop-0.20-mapreduce/lib/hue-plugins-*.jar',
      refreshonly => true,
      subscribe   => Package['hue'],
      before      => Service['hue']
    }
  }

  # exec { 'install-psycopg2':
  #   command => '/usr/share/hue/build/env/bin/easy_install psycopg2',
  #   user    => 'root',
  #   unless  => '/bin/rpm -qa | /bin/grep psycopg2 &> /dev/null', #FIXME
  #   require => Package[$hue_packages],
  # }

  # exec { 'sync-db':
  #   command => '/usr/share/hue/build/env/bin/hue syncdb --noinput',
  #   user    => 'root',
  #   require => Exec['install-psycopg2'],
  # }

  service { 'hue':
    ensure      => running,
    require     => [ Package['hue'], File['/etc/hue/hue.ini'] ],
    subscribe   => File['/etc/hue/hue.ini'],
    hasrestart  => true,
    hasstatus   => true,
  }

  Kerberos::Host_keytab <| title == 'hue' |> -> Service['hue']
}