# Class: hadoop::flume
#
#
class hadoop::flume inherits hadoop::params::flume {
  require hadoop::common_hdfs
  include $::hadoop::params::default::repo_class
  include java

  package { $hadoop::params::flume::packages :
    ensure  => installed,
    require => [
                  Class[$::hadoop::params::default::repo_class],
                  File['java-app-dir'],
                ],
  }

  file { '/etc/flume/conf/flume-env.sh':
    content => template('hadoop/flume/flume-env.sh.erb'),
    require => Package[$hadoop::params::flume::packages]
  }

  service { $hadoop::params::flume::service_name:
    ensure  => running,
    enable  => true,
    require => File['/etc/flume/conf/flume-env.sh'],
  }
}