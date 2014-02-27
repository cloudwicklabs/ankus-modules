# Class: utils::repos::cloudera::
#
# manages the yum repository of cloudera cdh
#
# === Parameters:
#
# None.
#
class utils::repos::cloudera::yum {
  yumrepo { 'cloudera':
    descr     => 'CDH Repository',
    baseurl   => "http://archive.cloudera.com/cdh4/redhat/${::operatingsystemmajrelease}/x86_64/cdh/4/",
    enabled   => 1,
    gpgcheck  => 0
  }
}