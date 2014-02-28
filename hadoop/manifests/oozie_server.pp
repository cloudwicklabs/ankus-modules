# Class: hadoop::oozie_server
#
# Installs and manages oozie, which is a workflow scheduler system to manage Hadoop jobs
# (MapReduce, Streaming, Pipes, Pig, Hive, Sqoop, etc).
#
class hadoop::oozie_server inherits hadoop::params::oozie {
  include java
  include $::hadoop::params::default::repo_class

  if($hadoop::params::default::hadoop_security_authentication == "kerberos") {
    require kerberos::client

    kerberos::host_keytab { "oozie":
      spnego => true,
    }

    Kerberos::Host_keytab <| title == "oozie" |> -> Service["oozie"]
  }

  package { oozie:
    ensure  => installed,
    require => [ File['java-app-dir'], Class[$::hadoop::params::default::repo_class] ]
  }

  file { '/etc/oozie/conf/oozie-site.xml':
    alias   => 'oozie-conf',
    content => template("hadoop/oozie/oozie-site.xml.erb"),
    require => Package['oozie'],
    notify  => Service['oozie']
  }

  if ($hadoop::params::default::deployment_mode == 'cdh') {
    file { '/etc/oozie/conf/oozie-env.sh':
      alias   => 'oozie-env',
      content => template('hadoop/oozie/oozie-env.sh.erb'),
      require => Package['oozie'],
      notify  => Service['oozie']
    }

    exec { 'Oozie DB init':
      command => '/etc/init.d/oozie init && touch DB_INIT_COMPLETE',
      cwd     => '/var/lib/oozie',
      creates => '/var/lib/oozie/DB_INIT_COMPLETE',
      require => Package['oozie']
    }
  } else {
    file { '/usr/lib/oozie/libtools/postgresql-8.4-703.jdbc3.jar':
      source  => 'puppet:///modules/hadoop/postgresql-8.4-703.jdbc3.jar',
      alias   => 'postgresql-oozie-jar',
      owner   => 'oozie',
      group   => 'root',
      require =>  Package['oozie']
    }

    file { '/usr/lib/oozie/libext':
      ensure  => directory,
      owner   => 'oozie',
      group   => 'root',
      require => Package['oozie']
    }

    file { '/usr/lib/oozie/libext/postgresql-8.4-703.jdbc3.jar':
      source  => 'puppet:///modules/hadoop/postgresql-8.4-703.jdbc3.jar',
      owner   => 'oozie',
      group   => 'root',
      alias   => 'postgresql-oozie-jar-libext',
      require =>  [ Package['oozie'], File['/usr/lib/oozie/libext'] ]
    }    

    file { '/etc/oozie/conf/oozie-env.sh':
      alias   => 'oozie-env',
      content => template('hadoop/oozie/oozie-env.sh.hdp.erb'),
      require => Package['oozie'],
      notify  => Service['oozie']
    }

    exec { 'oozie-prepare-war':
      command   => 'bash -c \'/usr/lib/oozie/bin/oozie-setup.sh prepare-war && touch DB_PREPARE_WAR\'',
      cwd       => '/usr/lib/oozie',
      creates   => '/usr/lib/oozie/DB_PREPARE_WAR',
      logoutput => on_failure,
      path      => '/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin',
      require   => [ Package['oozie'], File['postgresql-oozie-jar-libext'] ]
    }

    exec { 'Oozie DB init':
      command   => 'bash -c \'/usr/lib/oozie/bin/ooziedb.sh create -sqlfile oozie.sql -run && touch DB_INIT_COMPLETE\'',
      cwd       => '/usr/lib/oozie',
      logoutput => on_failure,
      creates   => '/usr/lib/oozie/DB_INIT_COMPLETE',
      path      => '/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin',
      require   => [ Exec['oozie-prepare-war'], File['postgresql-oozie-jar'] ]
    }
  }

  service { 'oozie':
    ensure      => running,
    require     => [ Package['oozie'], Exec['Oozie DB init'], File['oozie-conf'], File['oozie-env'] ],
    hasrestart  => true,
    hasstatus   => true,
  }

  #
  # Oozie web interface
  #
  file { '/var/lib/oozie/ext-2.2.tar.gz':
    source  => 'puppet:///modules/hadoop/ext-2.2.tar.gz',
    alias   => 'ext-source-tgz',
    owner   => 'oozie',
    group   => 'root',
    require => Package['oozie'],
  }

  exec { 'untar ext-2.2.tar.gz':
    command     => '/bin/tar -zxf ext-2.2.tar.gz',
    cwd         => '/var/lib/oozie',
    creates     => '/var/lib/oozie/ext-2.2',
    alias       => 'untar-ext',
    refreshonly => true,
    subscribe   => File['ext-source-tgz'],
    require     => File['ext-source-tgz'],
  }

  #
  # Install Oozie ShareLin in HDFS - contains all of the necessary JARs to enable workflow jobs to run
  #                                  streaming, DistCp, Pig, Hive, and Sqoop actions.
  #

  #FIX ME: This fails (datanodes should be up and running to do this.)
  #exec { "untar-oozie-share-lib":
  #  command => "/bin/tar -xzf oozie-sharelib.tar.gz",
  #  cwd => "/usr/lib/oozie",
  #  creates => "/usr/lib/oozie/share",
  #  alias => "untar-oozie-share",
  #  require => Package["oozie"],
  #}

  #exec { "copy-sharelib-to-hdfs":
  #  user => "oozie",
  #  command => "/bin/bash -c 'hadoop fs -put /usr/lib/oozie/share /user/oozie/share'",
  #  refreshonly => true,
  #  subscribe => Exec["untar-oozie-share"],
  #}
}