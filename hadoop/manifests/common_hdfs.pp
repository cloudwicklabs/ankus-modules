# == Class: hadoop::common_hdfs
#
# Abstracts away common configuration for all hadoop hdfs nodes
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
# include hadoop
#
# === Authors
#
# Ashrith <ashrith@cloudwick.com>
#
# === Copyright
#
# Copyright 2012 Cloudwick Inc, unless otherwise noted.
#
class hadoop::common_hdfs inherits hadoop::params::hdfs {
  require hadoop::common

  package { 'hadoop-hdfs':
    ensure  => latest,
    require => Package['hadoop'],
  }

  file { '/etc/hadoop/conf/hdfs-site.xml':
    content => template('hadoop/hdfs-site.xml.erb'),
    require => Package['hadoop'],
  }

  if ($hadoop::params::default::hadoop_security_authentication == 'kerberos') {
    require kerberos::client
    kerberos::host_keytab { 'hdfs':
      princs => 'hdfs',
      spnego => true,
    }
    Package['hadoop-hdfs'] -> Kerberos::Host_keytab<| title == 'hdfs' |>
  }
}