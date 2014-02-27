# Class: utils::repos::search::yum
#
#
class utils::repos::search::yum {
  yumrepo { "cloudera-search":
    baseurl => "http://archive.cloudera.com/search/redhat/6/x86_64/search/1/",
    descr => 'cloudera-search repository',
    enabled => 1,
    gpgcheck => 0
  }
}