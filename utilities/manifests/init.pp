class utilities {
  case $operatingsystem {
    'Ubuntu': {
      #TODO
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
  }
  #log_stash
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