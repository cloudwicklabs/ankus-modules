# == Class: hadoop::jobtracker
#
# Installs and manages hadoop jobtracker
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
# include hadoop::jobtracker
#
# === Authors
#
# Ashrith <ashrith@cloudwick.com>
#
# === Copyright
#
# Copyright 2012 Cloudwick Inc, unless otherwise noted.
#
class hadoop::jobtracker inherits hadoop::common_mapreduce {
  require hadoop::common_mapreduce

  package { 'hadoop-0.20-mapreduce-jobtracker':
    ensure  => installed,
    require => Package['hadoop-0.20-mapreduce'],
  }

  hadoop::create_dir_with_perm { $hadoop::params::default::mapred_master_dirs:
    user    => 'mapred',
    group   => 'hadoop',
    mode    => 755,
    require => Package['hadoop-0.20-mapreduce']
  }

  service { 'hadoop-0.20-mapreduce-jobtracker':
    ensure    => running,
    hasstatus => true,
    subscribe => [
                    Package['hadoop-0.20-mapreduce-jobtracker'],
                    File['/etc/hadoop/conf/hadoop-env.sh'],
                    File['/etc/hadoop/conf/mapred-site.xml'],
                    File['/etc/hadoop/conf/core-site.xml']
                  ],
    require   => [
                    Package['hadoop-0.20-mapreduce-jobtracker'],
                    Hadoop::Create_dir_with_perm[$hadoop::params::default::mapred_master_dirs]
                  ]
  }

  cron { 'orphanjobsfiles':
    command => 'find /var/log/hadoop/ -type f -mtime +3 -name "job_*_conf.xml" -delete',
    user    => 'root',
    hour    => 3,
    minute  => 0,
  }

  if ($hadoop::params::default::impala == 'enabled') {
    package { 'impala-shell':
      ensure  => latest,
      require => Yumrepo['impala-repo'],
    }
    include hadoop::impala
  }

  if ($hadoop::params::default::hadoop_security_authentication == 'kerberos') {
    Kerberos::Host_keytab <| tag == 'mapred' |> -> Service['hadoop-0.20-mapreduce-jobtracker']
  }

  # log_stash
  if ($hadoop::params::default::log_aggregation == 'enabled') {
    logstash::lumberjack_conf { 'jobtracker':
      logstash_host => $hadoop::params::default::logstash_server,
      logstash_port => 5672,
      daemon_name   => 'lumberjack_jobtracker',
      field         => "jobtracker-${::fqdn}",
      logfiles      => ['/var/log/hadoop-0.20-mapreduce/hadoop*jobtracker*.log'],
      require       => Service['hadoop-0.20-mapreduce-jobtracker']
    }
  }
}