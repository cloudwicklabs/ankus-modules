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
      }
      yumrepo { "impala-repo":
        descr => "Impala Repository",
        baseurl => "http://archive.cloudera.com/impala/redhat/6/x86_64/impala/1/",
        enabled => 1,
        gpgcheck => 0,
      }
      exec { "refresh-yum":
        command => "/usr/bin/yum clean all",
        require => [ Yumrepo['cloudera-repo'], Yumrepo['impala-repo'] ],
      }
    }
  }
}