# Class: utils::repos::cm::apt
#
# manages the apt repository of cloudera manager
#
# === Parameters:
#
# None.
#
class utils::repos::cm::apt {
  $cm_version = hiera('cloudera_manager_version', 4)

  apt::source { 'cloudera-manager':
    location    => "[arch=${::architecture}] http://archive.cloudera.com/cm${cm_version}/ubuntu/${::lsbdistcodename}/${::architecture}/cm",
    release     => "${::lsbdistcodename}-cm${cm_version}",
    repos       => "contrib",
    include_src => true,
  }

  apt::key { 'cloudera-manager':
    key         => 'D50582E6',
    key_source  => "http://archive.cloudera.com/cm${cm_version}/ubuntu/${::lsbdistcodename}/${::architecture}/cm/archive.key",
    before      => Apt::Source['cloudera-manager']
  }
}
