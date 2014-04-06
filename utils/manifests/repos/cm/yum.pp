# Class: utils::repos::cm::yum
#
# manages the yum repository of cloudera manager
#
# === Parameters:
#
# None.
#
class utils::repos::cm::yum {
  $cm_version = hiera('cloudera_manager_version', 5)

  yumrepo { 'cloudera-manager':
    descr          => 'Cloudera Manager Repository',
    enabled        => 1,
    gpgcheck       => 1,
    gpgkey         => "http://archive.cloudera.com/cm${cm_version}/redhat/${::operatingsystemmajrelease}/${::architecture}/cm/RPM-GPG-KEY-cloudera",
    baseurl        => "http://archive.cloudera.com/cm${cm_version}/redhat/${::operatingsystemmajrelease}/${::architecture}/cm/${cm_version}/",
    priority       => 50,
    protect        => 0
  }
}
