# == Class: hadoop::resourcemanager
#
# Installs and manages hadoop resource manager for yarn based deployments
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
# include hadoop::resourcemanager
#
# === Authors
#
# Ashrith <ashrith@cloudwick.com>
#
# === Copyright
#
# Copyright 2012 Cloudwick Inc, unless otherwise noted.
#
class hadoop::resourcemanager inherits hadoop::common_yarn {
  require hadoop::common_yarn

  package { 'hadoop-yarn-resourcemanager':
    ensure  => latest,
    require => Package['hadoop-yarn'],
  }

  service { 'hadoop-yarn-resourcemanager':
    ensure    => running,
    hasstatus => true,
    subscribe => [
                    Package['hadoop-yarn-resourcemanager'],
                    File['/etc/hadoop/conf/hadoop-env.sh'],
                    File['/etc/hadoop/conf/yarn-site.xml'],
                    File['/etc/hadoop/conf/core-site.xml'],
                    File['/etc/hadoop/conf/mapred-site.xml']
                  ],
    require   => [
                    Package['hadoop-yarn-resourcemanager'],
                    Hadoop::Create_dir_with_perm[$hadoop::params::default::yarn_master_dirs]
                  ],
  }

  hadoop::create_dir_with_perm { $hadoop::params::default::yarn_master_dirs:
    user    => 'yarn',
    group   => 'yarn',
    mode    => '0755',
    require => Package['hadoop-yarn-resourcemanager']
  }

  cron { 'orphanjobsfiles':
    command => 'find /var/log/hadoop/ -type f -mtime +3 -name "job_*_conf.xml" -delete',
    user    => 'root',
    hour    => '3',
    minute  => '0',
  }

  if ($hadoop::params::default::hadoop_security_authentication == 'kerberos') {
    Kerberos::Host_keytab <| tag == 'yarn' |> -> Service['hadoop-yarn-resourcemanager']
  }
}