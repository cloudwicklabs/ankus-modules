# Class: storm::parmas
#
#
class storm::params {
  include java::params
  $java_home = inline_template("<%= scope.lookupvar('java::params::java_base') %>/jdk<%= scope.lookupvar('java::params::java_version') %>")
  $packages_base = "/opt"
  $packages_home = "/opt/pacakges"
  $storm_version = "0.8.2-1"
  $zmq_version = "2.1.7"
  $jzmq_version = "2.1.7"

  case $::operatingsystem {
    'RedHat', 'CentOS': {
      $pkg_provider       = 'rpm'
      $storm_package      = "storm-${storm_version}.noarch.rpm"
      $zmq_package        = "libzmq1-${zmq_version}-1.x86_64.rpm"
      $jzmq_package       = "libjzmq-${jzmq_version}-1.x86_64.rpm"
      $tmpsource          = "/tmp/${package_name}"
      $defaults_file_path = '/etc/sysconfig/storm'
    }
    'Debian', 'Ubuntu': {
      $pkg_provider       = 'dpkg'
      $package            = "jmxtrans_${storm_version}.deb"
      $zmq_package        = "libzmq1_${zmq_version}_amd64.deb"
      $jzmq_package       = "libjzmq_${jzmq_version}_amd64.deb"
      $tmpsource          = "/tmp/${package_name}"
      $defaults_file_path = '/etc/default/storm'
    }
    default: {
      fail("${module_name} provides no package for ${::operatingsystem}")
    }
  }
}