define logstash::lumberjack_conf (
  $logstash_host,
  $logstash_port = 5672,
  $daemon_name = 'lumberjack_default',
  $field = 'lumberjack_host1',
  $logfiles = undef
) {

  require logstash::lumberjack

  if $logstash_host == undef {
    fail("\"${logstash_host}\" requires hostname|ip of indexer")
  }
  if $field == undef {
    $lumberjack_tag_fields = 'lumberjack_host'
  } else {
    $lumberjack_tag_fields = $lj_fields
  }

  case $::operatingsystem {
    'RedHat', 'CentOS': {
      $package = 'lumberjack-0.0.30-1.x86_64.rpm'
      $package_name = inline_template("<%= @package[0..-5] %>")
      $initfile = template("${module_name}/etc/lumberjack/init.d/lumberjack.init.RedHat.erb")
      $defaults_file_path = "/etc/sysconfig/${daemon_name}"
      # if no logfiles are passed, monitor system default log files
      if ! $logfiles {
        $logfiles_path = [ '/var/log/messages', '/var/log/secure' ]
      } else {
        $logfiles_path = $logfiles
      }
      $defaults_file = template("${module_name}/etc/lumberjack/defaults/lumberjack.defaults.RedHat.erb")
    }
    'Debian', 'Ubuntu': {
      $package = 'lumberjack_0.0.30_amd64.deb'
      $package_name = inline_template("<%= @package[0..-5] %>")
      $initfile = template("${module_name}/etc/lumberjack/init.d/lumberjack.init.Debian.erb")
      $defaults_file_path = "/etc/default/${daemon_name}"
      if ! $logfiles {
        $logfiles_path = [ '/var/log/syslog', '/var/log/dmesg', '/var/log/auth.log' ]
      } else {
        $logfiles_path = $logfiles
      }
      $defaults_file = template("${module_name}/etc/lumberjack/defaults/lumberjack.defaults.Debian.erb")
    }
    default: {
      fail("${module_name} provides no package for ${::operatingsystem}")
    }
  }

  file { "/etc/init.d/$daemon_name":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => $initfile,
    before  => Service[$daemon_name]
  }

  file { $defaults_file_path:
    ensure => present,
    owner => 'root',
    group => 'root',
    mode => '0755',
    content => $defaults_file,
    before => Service[$daemon_name]
  }

  service { $daemon_name:
    enable => true,
    ensure => running,
    hasrestart => true,
    hasstatus => true,
    require => Package[$package_name]
  }

}
