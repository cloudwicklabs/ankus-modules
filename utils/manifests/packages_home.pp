# Class: utils::packages_home
#
#
class utils::packages_home inherits utils::params {
  # A place where all the packages managed by ankus lives in
  file { ["${utilities::params::packages_base}", "${utilities::params::packages_home}"]:
    ensure => directory,
  }
}