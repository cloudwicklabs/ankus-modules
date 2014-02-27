# Class: utils::repos::impala::apt
#
#
class utils::repos::impala::apt {
  include apt
  apt::source { 'cloudera_impala_precise':
    location    => "[arch=amd64] http://archive.cloudera.com/impala/ubuntu/${::lsbdistcodename}/amd64/impala",
    release     => 'precise-impala1',
    repos       => 'contrib',
    include_src => true
  }
}