# Class: utils::packages_home
#
#
class utils::packages_home inherits utils::params {
  # A place where all the packages managed by ankus lives in
  file { ["${utils::params::packages_base}", "${utils::params::packages_home}"]:
    ensure => directory,
  }
}
