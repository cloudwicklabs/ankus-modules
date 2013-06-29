class logstash::redis {
  # packages
  case $::operatingsystem {
    'RedHat', 'CentOS': {
      $redis_package = [ 'redis' ]
      $redis_conf = '/etc/redis.conf'
      $redis_service = 'redis'
    }
    'Debian', 'Ubuntu': {
      $redis_package = [ 'redis-server' ]
      $redis_conf = '/etc/redis/redis.conf'
      $redis_service = 'redis-server'
    }
    default: {
      fail("\"${module_name}\" provides no package default value for \"${::operatingsystem}\"")
    }
  }

  package { $redis_package:
    ensure => installed,
  }

  file { $redis_conf:
    ensure   => file,
    content  => template("${module_name}/etc/redis/redis.conf.erb"),
    owner    => 'root',
    group    => 'root',
    mode     => '0444',
    require  => Package[$redis_package],
    notify   => Service[$redis_service],
  }

  service { $redis_service:
    ensure => 'running',
    enable => true,
  }
}