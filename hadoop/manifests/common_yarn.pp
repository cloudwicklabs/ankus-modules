# == Class: hadoop::common_yarn
#
# Abstracts away common configuration for all hadoop yarn nodes
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
class hadoop::common_yarn inherits hadoop::common {
  include hadoop::params::yarn

  package { 'hadoop-yarn':
    ensure  => latest,
    require => Package['hadoop'],
  }

  # required to run MR2 jobs
  package { 'hadoop-mapreduce':
    ensure  => latest,
    require => Package['hadoop']
  }

  file { '/etc/hadoop/conf/yarn-env.sh':
    content => template('hadoop/yarn-env.sh.erb'),
    require => Package['hadoop-yarn']
  }

  file { '/etc/hadoop/conf/yarn-site.xml':
    content => template('hadoop/yarn-site.xml.erb'),
    require => Package['hadoop-yarn']
  }

  file { '/etc/hadoop/conf/container-executor.cfg':
    content => template('hadoop/container-executor.cfg.erb'),
    owner   => root,
    group   => yarn,
    mode    => 400,
    require => Package['hadoop-yarn'],
  }

  file { '/etc/hadoop/conf/mapred-site.xml':
    content => template('hadoop/mapred-site.xml.erb'),
    require => Package['hadoop-yarn'],
  }

  if ($hadoop::params::default::hadoop_security_authentication == 'kerberos') {
    require kerberos::client
    kerberos::host_keytab { 'yarn':
      princs => 'yarn',
      spnego => true,
    }
    Package['hadoop-yarn'] -> Kerberos::Host_keytab<| title == 'yarn' |>
  }
}