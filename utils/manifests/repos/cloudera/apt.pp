# Class: utils::repos::cloudera::apt
#
# manages the apt repository of cloudera cdh
#
# === Parameters:
#
# None.
#
class utils::repos::cloudera::apt {
  apt::source { 'cloudera':
    location    => "[arch=${::architecture}] http://archive.cloudera.com/cdh4/ubuntu/${::lsbdistcodename}/${::architecture}/cdh",
    release     => "${::lsbdistcodename}-cdh4",
    repos       => 'contrib',
    include_src => true
  }
  apt::key { 'cloudera':
    key         => 'D50582E6',
    key_source  => "http://archive.cloudera.com/cdh4/ubuntu/${::lsbdistcodename}/${::architecture}/cdh/archive.key",
    before      => Apt::Source['cloudera']
  }
}