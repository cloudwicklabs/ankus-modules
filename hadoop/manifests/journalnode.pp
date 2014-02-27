# == Class: hadoop::journalnode
#
# Installs and manages hadoop journal node for ha based deployments
#
# === Parameters
#
# None
#
# === Variables
#
# None
#
# === Examples
#
# include hadoop::journalnode
#
# === Authors
#
# Ashrith <ashrith@cloudwick.com>
#
# === Copyright
#
# Copyright 2012 Cloudwick Inc, unless otherwise noted.
#
class hadoop::journalnode inherits hadoop::common_hdfs {
  include hadoop::params::yarn

  package { 'hadoop-hdfs-journalnode':
    ensure  => latest,
    require => Package['hadoop-hdfs']
  }

  hadoop::create_dir_with_perm { $hadoop::params::default::jn_data_dir:
    user    => 'hdfs',
    group   => 'hdfs',
    mode    => 700,
    require => Package['hadoop-hdfs-journalnode']
  }

  service { 'hadoop-hdfs-journalnode':
    ensure      => running,
    enable      => true,
    hasrestart  => true,
    hasstatus   => true,
    require     => [
                      Package['hadoop-hdfs-journalnode'],
                      Hadoop::Create_dir_with_perm[$hadoop::params::default::jn_data_dir]
                    ]
  }

  if ($hadoop::params::default::hadoop_security_authentication == 'kerberos') {
    Kerberos::Host_keytab <| tag == 'hdfs' |> -> Service['hadoop-hdfs-journalnode']
  }
}