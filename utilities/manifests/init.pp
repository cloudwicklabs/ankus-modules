class utilities {
  case $operatingsystem {
    'Ubuntu': {
      include apt
      apt::source { "cloudera_precise":
        location        => "[arch=${::architecture}] http://archive.cloudera.com/cdh4/ubuntu/${::lsbdistcodename}/${::architecture}/cdh",
        release         => "${::lsbdistcodename}-cdh4",
        repos           => " contrib",
        include_src     => true
      }
      apt::key { 'cloudera_precise':
        key        => 'D50582E6',
        key_source => "http://archive.cloudera.com/cdh4/ubuntu/${::lsbdistcodename}/${::architecture}/cdh/archive.key",
        before => Apt::Source['cloudera_precise'],
      }
      apt::source { "cloudera_impala_precise":
        location        => "[arch=amd64] http://archive.cloudera.com/impala/ubuntu/precise/amd64/impala",
        release         => "precise-impala1",
        repos           => " contrib",
        include_src     => true,
        require         => Apt::Source['cloudera_precise']
      }
    }
    'CentOS': {
      yumrepo { "cloudera-repo":
        descr => "CDH Repository",
        baseurl => 'http://archive.cloudera.com/cdh4/redhat/6/x86_64/cdh/4/',
        enabled => 1,
        gpgcheck => 0,
        notify => Exec["refresh-yum"],
      }
      yumrepo { "impala-repo":
        descr => "Impala Repository",
        baseurl => "http://archive.cloudera.com/impala/redhat/6/x86_64/impala/1/",
        enabled => 1,
        gpgcheck => 0,
        notify => Exec["refresh-yum"],
      }
      exec { "refresh-yum":
        command => "/usr/bin/yum clean all",
        require => [ Yumrepo['cloudera-repo'], Yumrepo['impala-repo'] ],
        refreshonly => true
      }
    }
    default:  {fail('Supported OS are CentOS, Ubuntu')}
  }

  #Add lubmerjack_default to monitor default config files based on OS
  $log_aggregation = hiera('log_aggregation', 'disabled')

  if ($log_aggregation == 'enabled') {
    $logstash_server = hiera('logstash_server')
    #require logstash::lumberjack_def
    logstash::lumberjack_conf { "default":
      logstash_host => $logstash_server,
      logstash_port => 5672,
      daemon_name => 'lumberjack_default',
      field => "default-${::fqdn}",
    }
  }
}