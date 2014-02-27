# class hadoop::imapala
#
class hadoop::impala inherits hadoop::common_hdfs {
  include hadoop::params::impala

  package { 'impala':
    ensure  => installed,
    require => [
                  Class[$::hadoop::params::impala::imapal_repo_class],
                  Package['hadoop-hdfs']
                ],
  }

  if ($::fqdn == $jobtracker) {
    # imapala states-store and catalog services
    package { 'impala-state-store':
      ensure  => installed,
      require => Package['impala']
    }

    package { 'impala-catalog':
      ensure  => installed,
      require => Package['impala']
    }

    package { 'impala-shell':
      ensure  => installed,
      require => Package['impala']
    }

    service { 'impala-state-store':
      ensure  => running,
      enable  => true,
      require => [ 
                    Package['impala-state-store'],
                    File["/etc/impala/conf/core-site.xml",
                      "/etc/default/impala",
                      "/etc/impala/conf/hdfs-site.xml",
                      "/etc/impala/conf/hive-site.xml",
                      "/etc/impala/conf/impala-log4j.properties"],
                  ]

    }

    service { 'impala-catalog':
      ensure  => running,
      enable  => true,
      require => [ 
                    Package['impala-catalog'],
                    File["/etc/impala/conf/core-site.xml",
                      "/etc/default/impala",
                      "/etc/impala/conf/hdfs-site.xml",
                      "/etc/impala/conf/hive-site.xml",
                      "/etc/impala/conf/impala-log4j.properties"],
                  ]
    }    

    # exec { "start-impala-statestore":
    #   user    => "root",
    #   command => "GLOG_v=1 nohup /usr/bin/statestored -state_store_port=24000",
    #   unless  => "/bin/ps aux | /bin/grep '[s]tatestored'", #this exec will run unless the command returns 0
    #   require => [ Package["imapala"],
    #                File["/etc/impala/conf/core-site.xml",
    #                     "/etc/impala/conf/hdfs-site.xml",
    #                     "/etc/impala/conf/hive-site.xml",
    #                     "/etc/impala/conf/impala-log4j.properties"],
    #                Exec["usermod-impala"]],
    # }
  } else {
    # all data nodes
    package { 'impala-server':
      ensure => installed,
      require => Package['impala']
    }

    service { 'impala-server':
      ensure  => running,
      enable  => true,
      require => [ 
                    Package['impala-server'],
                    File["/etc/impala/conf/core-site.xml",
                      "/etc/default/impala",
                      "/etc/impala/conf/hdfs-site.xml",
                      "/etc/impala/conf/hive-site.xml",
                      "/etc/impala/conf/impala-log4j.properties"],
                  ]
    }    

    # exec { "start-impalad":
    #  user     => "root",
    #  command  => "GLOG_v=1 nohup /usr/bin/impalad -state_store_host=$jobtracker -nn=$namenode -nn_port=8020 -hostname=$::fqdn -ipaddress=$::ipaddress",
    #  unless   => "/bin/ps aux | /bin/grep '[i]mpalad'",
    #  require  => [ Package["imapala"],
    #                File["/etc/impala/conf/core-site.xml",
    #                    "/etc/impala/conf/hdfs-site.xml",
    #                    "/etc/impala/conf/hive-site.xml",
    #                    "/etc/impala/conf/impala-log4j.properties"],
    #                Exec["usermod-impala"]],
    # }
  }

  file { '/etc/impala/conf':
    ensure => "directory",
    require => Package["impala"],
  }

  file { '/etc/default/impala':
    content => template('hadoop/impala/default.erb'),
    require => Package["impala"],
  }

  file { '/etc/impala/conf/core-site.xml':
    content => template('hadoop/core-site.xml.erb'),
    require => [Package["impala"], File["/etc/impala/conf"]],
  }

  file { '/etc/impala/conf/hdfs-site.xml':
    content => template('hadoop/hdfs-site.xml.erb'),
    require => [Package["impala"], File["/etc/impala/conf"]],
  }

  file { '/etc/impala/conf/hive-site.xml':
      content => template('hadoop/hive-site.xml.erb'),
      require => [Package["impala"], File["/etc/impala/conf"]],
  }

  file { '/etc/impala/conf/impala-log4j.properties':
    content => template('hadoop/impala-log4j.properties.erb'),
    require => [Package['imapala'], File['/etc/impala/conf']],
  }

  exec { 'usermod-impala':
    command => '/usr/sbin/usermod -a -G hadoop impala',
    require => Package['impala'],
  }

  if ( $hadoop_security_authentication == 'kerberos' ) {
    require kerberos::client

    $sec_packages = ["python-devel", "cyrus-sasl-devel", "gcc-c++", "python-setuptools", "openssl-devel", "python-pip"]

    package { $sec_packages:
      ensure => latest,
    }

    exec { "install-ssl":
      command => 'pip install ssl',
      user => "root",
      require => Package[$sec_packages],
    }

    kerberos::host_keytab { 'impala':
      spnego => true,
    }
  }
}