class logstash::params {
  include java::params

  $ensure = 'present'
  $configdir = '/etc/logstash'
  $logdir = '/var/log/logstash/'
  $logstash_user  = 'root'
  $logstash_group = 'root'
  $jarfile = 'puppet:///modules/logstash/logstash-1.1.13-flatjar.jar'
  $java_home = inline_template("<%= scope.lookupvar('java::params::java_base') %>/jdk<%= scope.lookupvar('java::params::java_version') %>")
  $java_bin = "$java_home/bin/java"

  # packages
  case $::operatingsystem {
    'RedHat', 'CentOS': {
      $package     = [ 'logstash' ]
      $installpath = '/opt/logstash'
    }
    'Debian', 'Ubuntu': {
      $package     = [ 'logstash' ]
      $installpath = '/opt/logstash'
    }
    default: {
      fail("\"${module_name}\" provides no package default value for \"${::operatingsystem}\"")
    }
  }

  # service parameters
  case $::operatingsystem {
    'RedHat', 'CentOS': {
      $service_name       = 'logstash'
      $service_hasrestart = true
      $service_hasstatus  = true
      $service_pattern    = $service_name
      $defaults_location  = '/etc/sysconfig'
    }
    'Debian', 'Ubuntu': {
      $service_name       = 'logstash'
      $service_hasrestart = true
      $service_hasstatus  = true
      $service_pattern    = $service_name
      $defaults_location  = '/etc/default'
    }
    default: {
      fail("\"${module_name}\" provides no service parameters for \"${::operatingsystem}\"")
    }
  }

}
