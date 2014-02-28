# Class: hadoop::oozie_client
#
# Oozie client is a command-line utility that interacts with the Oozie server via the Oozie
# web-services API
#
class hadoop::oozie_client inherits hadoop::params::oozie {
  include java
  include $::hadoop::params::default::repo_class

  package { 'oozie-client':
    ensure  => installed,
    require => [ File['java-app-dir'], Class[$::hadoop::params::default::repo_class] ]
  }
}