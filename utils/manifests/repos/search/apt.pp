# Class: utils::repos::search::apt
#
#
class utils::repos::search::apt {
  include apt
  apt::source { 'cloudera_search':
    location    => "[arch=amd64] http://archive.cloudera.com/search/ubuntu/${::lsbdistcodename}/amd64/search",
    release     => 'precise-search1',
    repos       => 'contrib',
    include_src => true,
  }
}