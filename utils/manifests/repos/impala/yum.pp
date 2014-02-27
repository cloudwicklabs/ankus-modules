# Class: utils::repos::impala::yum
#
#
class utils::repos::impala::yum {
  yumrepo { "impala-repo":
    descr     => "Impala Repository",
    baseurl   => "http://archive.cloudera.com/impala/redhat/${::operatingsystemmajrelease}/x86_64/impala/1/",
    enabled   => 1,
    gpgcheck  => 0
  }
}