class logstash::service {

  include java
  # Write defaults file if we have one
  file { "${logstash::params::defaults_location}/logstash":
    ensure => present,
    source => "puppet:///modules/logstash/logstash.defaults",
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    before => Service[ 'logstash' ],
    notify => Service[ 'logstash' ],
  }

  $configdir = "${logstash::params::configdir}/conf.d"

  case $::operatingsystem {
    'RedHat', 'CentOS': {
      $initscript = template("${module_name}/etc/init.d/logstash.init.RedHat.erb")
    }
    'Debian', 'Ubuntu': {
      $initscript = template("${module_name}/etc/init.d/logstash.init.Debian.erb")
    }
    default: {
      fail("\"${module_name}\" provides no default init file
            for \"${::operatingsystem}\"")
    }
  }

  # Place built in init file
  file { '/etc/init.d/logstash':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => $initscript,
    before  => Service[ 'logstash' ]
  }

  # Use the single instance
  service { 'logstash':
    ensure => running,
    enable => true,
    require => File["java-app-dir"]
  }
}
