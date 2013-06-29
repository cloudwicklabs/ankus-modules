class logstash::package {

  # Create directory to place the jar file
  exec { 'create_install_dir':
    cwd     => '/',
    path    => ['/usr/bin', '/bin'],
    command => "mkdir -p ${logstash::params::installpath}",
    creates => $logstash::params::installpath;
  }

  # Create log directory
  exec { 'create_log_dir':
    cwd     => '/',
    path    => ['/usr/bin', '/bin'],
    command => "mkdir -p ${logstash::params::logdir}",
    creates => $logstash::params::logdir;
  }

  # Place the jar file
  $filenameArray = split($logstash::params::jarfile, '/')
  $basefilename = $filenameArray[-1]

  file { "${logstash::installpath}/${basefilename}":
    ensure  => present,
    source  => $logstash::params::jarfile,
    require => Exec['create_install_dir'],
    backup  => false
  }

  # Create symlink
  file { "${logstash::installpath}/logstash.jar":
    ensure  => 'link',
    target  => "${logstash::installpath}/${basefilename}",
    require => File["${logstash::installpath}/${basefilename}"],
    backup  => false
  }
}