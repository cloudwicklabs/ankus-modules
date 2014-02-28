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

class hadoop::hue inherits hadoop::params::hue {

  if ($hadoop::params::default::hadoop_security_authentication == 'kerberos') {
    require kerberos::client

    kerberos::host_keytab { 'hue':
      spnego => false,
    }
  }

  $hue_packages = $::operatingsystem ? {
    /CentOS|RedHat/ => [ 'hue', 'hue-server', 'hue-plugins', 'python-psycopg2', 'postgresql-devel' ],
    /Ubuntu/        => [ 'hue', 'hue-server', 'hue-plugins', 'python-psycopg2', 'build-dep' ],
  }

  $syncdb_cmd_flag = $hadoop::params::default::deployment_mode ? {
    cdh => '/usr/share/hue/build/env',
    hdp => '/usr/lib/hue/build/env',
  }

  $syncdb_cmd = $hadoop::params::default::deployment_mode ? {
    cdh => "/usr/share/hue/build/env/bin/hue syncdb --noinput && touch ${syncdb_cmd_flag}/SYNC_COMPLETE",
    hdp => "/usr/lib/hue/build/env/bin/hue syncdb --noinput && touch ${syncdb_cmd_flag}/SYNC_COMPLETE",
  }

  $hue_config = $hadoop::params::default::deployment_mode ? {
    cdh => '/etc/hue/hue.ini',
    hdp => '/etc/hue/conf/hue.ini',
  }

  package { $hue_packages:
    ensure  => latest,
    require => [ File['java-app-dir'], Class[$::hadoop::params::default::repo_class] ]
  }

  file { $hue_config:
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

  exec { 'sync-db':
    command => $syncdb_cmd,
    user    => 'root',
    creates => "${syncdb_cmd_flag}/SYNC_COMPLETE",
    require => Package[$hue_packages]
  }

  service { 'hue':
    ensure      => running,
    require     => [ Package['hue'], File[$hue_config] ],
    subscribe   => File[$hue_config],
    hasrestart  => true,
    hasstatus   => true,
  }

  Kerberos::Host_keytab <| title == 'hue' |> -> Service['hue']
}