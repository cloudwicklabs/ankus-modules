# == Class: hadoop::common_mapreduce
#
# Abstracts away common configuration for all hadoop mapreduce nodes
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
class hadoop::common_mapreduce inherits hadoop::common {
  include hadoop::params::mapreduce

  package { 'hadoop-0.20-mapreduce':
    ensure  => latest,
    require => Package['hadoop']
  }

  file { '/etc/hadoop/conf/mapred-site.xml':
      content => template('hadoop/mapred-site.xml.erb'),
      require => Package['hadoop']
  }

  file { '/etc/hadoop/conf/taskcontroller.cfg':
    content => template('hadoop/taskcontroller.cfg.erb'),
    require => Package['hadoop']
  }

  if ($hadoop::params::default::hadoop_security_authentication == 'kerberos') {
    require kerberos::client
    kerberos::host_keytab { 'mapred':
      princs => 'mapred',
      spnego => true
    }
    Package['hadoop-0.20-mapreduce'] -> Kerberos::Host_keytab<| title == 'mapred' |>
  }
}