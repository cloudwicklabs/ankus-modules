# Class: hadoop::oozie_client
#
# Oozie client is a command-line utility that interacts with the Oozie server via the Oozie
# web-services API
#
class hadoop::oozie_client
  include java
  include hadoop::params::oozie

  package { 'oozie-client':
    ensure  => installed,
    require => [ File['java-app-dir'], Class[$::hadoop::params::default::repo_class] ]
  }
}