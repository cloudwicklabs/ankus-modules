# Class: hadoop-search
# 
# Installs and manages Cloudera Search
#
class hadoop-search {
  require utilities::repos
  include java

  case $operatingsystem {
    'Ubuntu': {
      package { "solr":
        ensure => latest,
        require => [ File["java-app-dir"], Apt::Source['cloudera_search'] ],
      }
    }
    'CentOS': {
      package { "hadoop":
        ensure => latest,
        require => [ File["java-app-dir"], Yumrepo["cloudera-search"] ],
      }
    }
  }
}