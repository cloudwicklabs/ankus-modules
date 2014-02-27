# Class: utils::repos::datastax::yum
#
#
class utils::repos::datastax::yum {
  yumrepo { 'datastax-repo':
    descr => 'DataStax Repo for Cassandra',
    baseurl => 'http://rpm.datastax.com/community',
    enabled => 1,
    gpgcheck => 0
  }
}