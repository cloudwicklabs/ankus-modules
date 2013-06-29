class logstash::config($role, $indexer) {
  # File defaults
  File {
    owner => $logstash::params::logstash_user,
    group => $logstash::params::logstash_group
  }

  # Manage the single config dir
  file { "${logstash::configdir}":
    ensure => directory,
  }

  file { "${logstash::configdir}/conf.d":
    ensure  => directory,
    mode    => '0640',
    purge   => true,
    recurse => true,
    require => File["${logstash::configdir}"],
    notify  => Service['logstash']
  }

  $tmp_dir = "${logstash::params::installpath}/tmp"

  # Create the tmp dir
  exec { 'create_tmp_dir':
    cwd     => '/',
    path    => ['/usr/bin', '/bin'],
    command => "mkdir -p ${tmp_dir}",
    creates => $tmp_dir;
  }

  file { $tmp_dir:
    ensure  => directory,
    mode    => '0640',
    require => Exec[ 'create_tmp_dir' ]
  }

  if $role == 'indexer' {
    file { "${logstash::configdir}/conf.d/indexer.conf":
      ensure => present,
      content => template("${module_name}/etc/indexer.conf.erb"),
      require => File["${logstash::configdir}/conf.d"]
    }

    #ssl files used for lumberjack communication
    file { '/etc/ssl/logstash.pub':
      ensure => file,
      source => "puppet:///modules/${module_name}/lumberjack/logstash.pub",
    }

    file { '/etc/ssl/logstash.key':
      ensure => file,
      source => "puppet:///modules/${module_name}/lumberjack/logstash.key"
    }
  } else
  {
    case $::operatingsystem {
      'RedHat', 'CentOS': {
        $logs_path = "['/var/log/secure', '/var/log/messages']"
      }
      'Debian', 'Ubuntu': {
        $logs_path = "['/var/log/dmesg', '/var/log/syslog']"
      }
      default: {
        fail("\"${module_name}\" provides no default init file
              for \"${::operatingsystem}\"")
      }
    }
    file { "${logstash::configdir}/conf.d/shipper.conf":
      ensure => present,
      content => template("${module_name}/etc/shipper.conf.erb"),
      require => File["${logstash::configdir}/conf.d"]
    }
  }
}
