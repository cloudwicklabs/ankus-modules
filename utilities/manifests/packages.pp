# Class: utilities::packages
#
#
class utilities::packages inherits utilities::params {
  # A place where all the packages managed by ankus lives in
  file { ["${utilities::params::packages_base}", "${utilities::params::packages_home}"]:
    ensure => directory,
  }
}