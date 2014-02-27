# == Class: hadoop::jobhistoryproxyserver
#
# Installs and manages hadoop job history server for yarn deployments
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
class hadoop::jobhistoryproxyserver inherits hadoop::common_yarn {
  include hadoop::parms::yarn

  package { 'hadoop-mapreduce-historyserver':
    ensure  => latest,
    require => Package['hadoop-mapreduce'],
  }

  service { 'hadoop-mapreduce-historyserver':
    ensure    => running,
    hasstatus => true,
    subscribe => [
                    Package['hadoop-mapreduce-historyserver'],
                    File['/etc/hadoop/conf/hadoop-env.sh'],
                    File['/etc/hadoop/conf/yarn-site.xml'],
                    File['/etc/hadoop/conf/core-site.xml'],
                    File['/etc/hadoop/conf/mapred-site.xml']
                  ]
    require   => Package['hadoop-mapreduce-historyserver']
  }

  package { 'hadoop-yarn-proxyserver':
    ensure  => latest,
    require => Package['hadoop-yarn'],
  }

  service { 'hadoop-yarn-proxyserver':
    ensure    => running,
    hasstatus => true,
    subscribe => [
                    Package['hadoop-yarn-proxyserver'],
                    File['/etc/hadoop/conf/hadoop-env.sh'],
                    File['/etc/hadoop/conf/yarn-site.xml'],
                    File['/etc/hadoop/conf/core-site.xml']
                  ],
    require   => Package['hadoop-yarn-proxyserver']
  }

  if($hadoop::params::default::hadoop_security_authentication == 'kerberos') {
    Kerberos::Host_keytab <| tag == 'yarn' |> -> Service['hadoop-mapreduce-historyserver', 'hadoop-yarn-proxyserver']
  }
}