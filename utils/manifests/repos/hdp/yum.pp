# == Class: utils::repos::hdp::yum
#
# manages the yum repository of hortonworks hdp
#
# === Parameters:
#
# None.
#
class utils::repos::hdp::yum {
  yumrepo { 'hdp':
    baseurl   => "http://public-repo-1.hortonworks.com/HDP/centos${::operatingsystemmajrelease}/2.x/GA",
    descr     => 'Hortonworks HDP Repo V 2.x',
    enabled   => '1',
    gpgkey    => "http://public-repo-1.hortonworks.com/HDP/centos${::operatingsystemmajrelease}/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins",
    gpgcheck  => '1',
    priority  => '1'
  }
  yumrepo { 'hdp_utils':
    baseurl   => "http://public-repo-1.hortonworks.com/HDP-UTILS-1.1.0.16/repos/centos${::operatingsystemmajrelease}",
    descr     => 'Hortonworks HDP UTILS Repo',
    enabled   => '1',
    gpgkey    => "http://public-repo-1.hortonworks.com/HDP/centos${::operatingsystemmajrelease}/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins",
    gpgcheck  => '1',
    priority  => '1'
  }
  yumrepo { 'hdp_updates':
    baseurl   => "http://public-repo-1.hortonworks.com/HDP/centos${::operatingsystemmajrelease}/2.x/updates/2.0.6.1",
    descr     => 'Hortonworks HDP UTILS Repo',
    enabled   => '1',
    gpgkey    => "http://public-repo-1.hortonworks.com/HDP/centos${::operatingsystemmajrelease}/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins",
    gpgcheck  => '1',
    priority  => '1'
  }
}