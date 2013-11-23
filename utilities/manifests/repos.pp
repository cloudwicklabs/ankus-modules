class utilities::repos {
  case $operatingsystem {
    'Ubuntu': {
      include apt
      apt::source { "cloudera_precise":
        location    => "[arch=${::architecture}] http://archive.cloudera.com/cdh4/ubuntu/${::lsbdistcodename}/${::architecture}/cdh",
        release     => "${::lsbdistcodename}-cdh4",
        repos       => " contrib",
        include_src => true,
        notify      => Exec["apt-update"]
      }
      apt::key { "cloudera_precise":
        key         => 'D50582E6',
        key_source  => "http://archive.cloudera.com/cdh4/ubuntu/${::lsbdistcodename}/${::architecture}/cdh/archive.key",
        before      => Apt::Source['cloudera_precise'],
        notify      => Exec["apt-update"]
      }
      apt::source { "cloudera_impala_precise":
        location    => "[arch=amd64] http://archive.cloudera.com/impala/ubuntu/precise/amd64/impala",
        release     => "precise-impala1",
        repos       => " contrib",
        include_src => true,
        notify      => Exec["apt-update"]
        #require         => Apt::Source['cloudera_precise'] # this causes a dependency cycle
      }
      apt::source { "datastax-repo":
        location    => "http://debian.datastax.com/community",
        release     => "stable",
        repos       => "main",
        include_src => true,
        notify      => [Exec["apt-update"], Exec["add-datastax-repo-key"]]
      }
      exec { "add-datastax-repo-key":
        command => "/usr/bin/curl -L http://debian.datastax.com/debian/repo_key | sudo apt-key add -",
        refreshonly => true,
      }
      apt::source { "cloudera_search":
        location    => "[arch=amd64] http://archive.cloudera.com/search/ubuntu/precise/amd64/search",
        release     => "precise-search1",
        repos       => " contrib",
        include_src => true,
        notify      => Exec["apt-update"]
      }
      exec { "apt-update":
        command => "/usr/bin/apt-get update",
        refreshonly => true,
      }
      # apt::source{ "10gen":
      #   location    => 'http://downloads-distro.mongodb.org/repo/debian-sysvinit',
      #   release     => 'dist',
      #   repos       => '10gen',
      #   key         => '7F0CEB10',
      #   key_server  => 'keyserver.ubuntu.com',
      #   include_src => false,
      # }      
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