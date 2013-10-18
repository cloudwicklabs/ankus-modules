class utilities::repos {
  case $operatingsystem {
    'Ubuntu': {
      include apt
      apt::source { "cloudera_precise":
        location    => "[arch=${::architecture}] http://archive.cloudera.com/cdh4/ubuntu/${::lsbdistcodename}/${::architecture}/cdh",
        release     => "${::lsbdistcodename}-cdh4",
        repos       => " contrib",
        include_src => true
      }
      apt::key { 'cloudera_precise':
        key         => 'D50582E6',
        key_source  => "http://archive.cloudera.com/cdh4/ubuntu/${::lsbdistcodename}/${::architecture}/cdh/archive.key",
        before      => Apt::Source['cloudera_precise'],
      }
      apt::source { "cloudera_impala_precise":
        location    => "[arch=amd64] http://archive.cloudera.com/impala/ubuntu/precise/amd64/impala",
        release     => "precise-impala1",
        repos       => " contrib",
        include_src => true,
        #require         => Apt::Source['cloudera_precise'] # this causes a dependency cycle
      }
      apt::source { "datastax-repo":
        #deb http://debian.datastax.com/community stable main
        location    => "http://debian.datastax.com/community",
        release     => "stable",
        repos       => "main",
        include_src => true
      }
      apt::source { "cloudera_search":
        location    => "[arch=amd64] http://archive.cloudera.com/search/ubuntu/precise/amd64/search",
        release     => "precise-search1",
        repos       => " contrib",
        include_src => true
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
      yumrepo { "datastax-repo":
        descr => "DataStax Repo for Cassandra",
        baseurl => 'http://rpm.datastax.com/community',
        enabled => 1,
        gpgcheck => 0,
        notify => Exec["refresh-yum"],
      }
      yumrepo { "cloudera-search":
        baseurl => "http://archive.cloudera.com/search/redhat/6/x86_64/search/1/",
        descr => "The cloudera-search repository",
        enabled => 1,
        gpgcheck => 0,
        notify => Exec["refresh-yum"],
      }
      exec { "refresh-yum":
        command => "/usr/bin/yum clean all",
        require => [ Yumrepo['cloudera-repo'], Yumrepo['impala-repo'], 
                     Yumrepo['cloudera-search'], Yumrepo['datastax-repo'] ],
        refreshonly => true
      }
    }
    default:  {fail('Supported OS are CentOS, Ubuntu')}
  }
}