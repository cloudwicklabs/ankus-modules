# Class: hadoop::params::flume
#
#
class hadoop::params::flume inherits hadoop::params::default {
  $packages = $hadoop::params::default::deployment_mode ? {
    cdh => [ 'flume-ng', 'flume-ng-agent', 'flume-ng-doc' ],
    hdp => [ 'flume', 'flume-agent' ]
  }

  $conf = $hadoop::params::default::deployment_mode ? {
    cdh => '/etc/flume/conf/flume.conf',
    hdp => '/etc/flume/conf/flume.conf'
  }

  $service_name = $hadoop::params::default::deployment_mode ? {
    cdh => 'flume-ng-agent',
    hdp => 'flume-agent'
  }
}