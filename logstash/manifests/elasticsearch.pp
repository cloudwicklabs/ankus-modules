class logstash::elasticsearch {
  # variables
  $version = '0.20.6'
  $tarchive = "elasticsearch-${version}.tar.gz"
  $tmptarchive = "/tmp/${tarchive}"
  $tmpdir = "/tmp/elasticsearch-${version}"
  $dbdir = '/var/lib/elasticsearch'
  $logdir = '/var/log/elasticsearch'
  $rundir = '/var/run/elasticsearch'
  $sharedirv = "/usr/share/elasticsearch-${version}"
  $sharedir = '/usr/share/elasticsearch'
  $etcdir = '/etc/elasticsearch'
  $configfile = "$etcdir/elasticsearch.yml"
  $logconfigfile = "$etcdir/logging.yml"

  case $::operatingsystem {
    'RedHat', 'CentOS': {
      $defaultsfile = '/etc/sysconfig/elasticsearch'
      $defaultsfile_source = "puppet:///modules/${module_name}/elasticsearch.defaults.RedHat"
      $initscript = template("${module_name}/etc/elasticsearch/init.d/elasticsearch.init.RedHat.erb")
    }
    'Debian', 'Ubuntu': {
      $defaultsfile = '/etc/default/elasticsearch'
      $defaultsfile_source = "puppet:///modules/${module_name}/elasticsearch.defaults.Debian"
      $initscript = template("${module_name}/etc/elasticsearch/init.d/elasticsearch.init.Debian.erb")
    }
    default: {
      fail("\"${module_name}\" provides no package default value for \"${::operatingsystem}\"")
    }
  }

  File { before => Service['elasticsearch'] }

  group { 'elasticsearch':
    ensure => present,
    system => true,
  }

  user { 'elasticsearch':
    ensure => present,
    system => true,
    home => $sharedir,
    shell => '/bin/false',
    gid => 'elasticsearch',
    require => Group['elasticsearch']
  }

  file {
    $dbdir:
      ensure => directory,
      owner => 'elasticsearch',
      group => 'elasticsearch',
      mode => '0755',
      require => User['elasticsearch'];
    $logdir:
      ensure => directory,
      owner => 'elasticsearch',
      group => 'elasticsearch',
      mode => '0755',
      require => User['elasticsearch'];
    $rundir:
      ensure => directory,
      owner => 'elasticsearch',
      group => 'elasticsearch',
      mode => '0755',
      require => User['elasticsearch'];
  }

  file { $tmptarchive:
    ensure => present,
    source => "puppet:///modules/${module_name}/${tarchive}",
    owner => 'elasticsearch',
    mode => '0644'
  }

  exec { 'extract_es':
    command => "/bin/tar xzf ${tmptarchive} -C /usr/share/",
    cwd => '/tmp',
    creates => $sharedirv,
    require => File[$tmptarchive]
  }

  file { $sharedir:
    ensure  => link,
    target  => $sharedirv,
    owner => 'elasticsearch',
    group => 'elasticsearch',
    require => Exec['extract_es'],
  }

  file { "$sharedir/elasticsearch.in.sh":
    ensure  => link,
    target  => "$sharedir/bin/elasticsearch.in.sh",
    require => File[$sharedir],
  }

  file { '/usr/bin/elasticsearch':
    ensure => link,
    target => "$sharedirv/bin/elasticsearch",
    require => Exec['extract_es'],
  }

  file { $etcdir:
    ensure => directory
  }

  file { $configfile:
    ensure => present,
    content  => template("${module_name}/etc/elasticsearch/elasticsearch.yml.erb"),
    owner  => root,
    group  => root,
  }

  file { $logconfigfile:
    ensure => present,
    content  => template("${module_name}/etc/elasticsearch/logging.yml.erb"),
    owner  => root,
    group  => root,
  }

  file { $defaultsfile:
    ensure => present,
    source => $defaultsfile_source,
  }

  file { '/etc/init.d/elasticsearch':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => $initscript,
    before  => Service[ 'elasticsearch' ]
  }

  service { 'elasticsearch':
    ensure   => running,
    enable   => true,
  }
}