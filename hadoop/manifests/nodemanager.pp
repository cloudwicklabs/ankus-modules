# == Class: hadoop::nodemanager
#
# Installs and manages node manager daemon for yarn based deployments
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
# include hadoop::nodemanager
#
# === Authors
#
# Ashrith <ashrith@cloudwick.com>
#
# === Copyright
#
# Copyright 2012 Cloudwick Inc, unless otherwise noted.
#
class hadoop::nodemanager inherits hadoop::common_yarn {
  require hadoop::common_yarn

  package { 'hadoop-yarn-nodemanager':
    ensure  => latest,
    require => Package['hadoop-yarn'],
  }

  service { 'hadoop-yarn-nodemanager':
    ensure    => running,
    hasstatus => true,
    subscribe => [
                    Package['hadoop-yarn-nodemanager'],
                    File['/etc/hadoop/conf/hadoop-env.sh'],
                    File['/etc/hadoop/conf/yarn-site.xml'],
                    File['/etc/hadoop/conf/core-site.xml']
                  ],
    require   => [
                    Package['hadoop-yarn-nodemanager'],
                    File[$hadoop::params::default::yarn_data_dirs]
                  ],
  }

  hadoop::create_dir_with_perm { $hadoop::params::default::yarn_data_dirs:
    user    => 'yarn',
    group   => 'yarn',
    mode    => '0755',
    require => Package['hadoop-yarn-nodemanager']
  }

  hadoop::create_dir_with_perm { $hadoop::params::default::yarn_container_log_dirs:
    user    => 'yarn',
    group   => 'yarn',
    mode    => '0755',
    require => Package['hadoop-yarn-nodemanager']
  }

  if ($hadoop::params::default::hadoop_security_authentication == 'kerberos') {
    Kerberos::Host_keytab <| tag == 'yarn' |> -> Service['hadoop-yarn-nodemanager']
  }

}