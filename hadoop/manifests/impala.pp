class hadoop::impala inherits hadoop::common-hdfs {
  #variables to build hive-site.xml
  $hbase_deploy = hiera('hbase_deploy')
  $hbase_install = $hbase_deploy['hbase_install']
  $hadoop_controller = hiera('controller')
  $impala = hiera('impala', 'disabled')
  $jobtracker = $hadoop_mapreduce['master']

  if ($hbase_deploy != "disabled"){
    $hbase_master = $hbase_deploy['master']
    $hbase_zookeeper_quorum = hiera('zookeeper_quorum')
  }

  #impala specific variable
  $namenode = $hadoop_deploy['hadoop_namenode']
  $first_namenode = $namenode[0]
  if ($ha != "disabled") {
    $hadoop_ha_nameservice_id = hiera('hadoop_ha_nameservice_id', 'ha-nn-uri')
    $default_fs = "hdfs://$hadoop_ha_nameservice_id"
  } else {
    $default_fs = "hdfs://$first_namenode:$hadoop_namenode_port"
  }

  package { "impala":
    ensure => latest,
    require => [Yumrepo["impala-repo"], Package["hadoop-hdfs"]],
  }

  if ($::fqdn == $jobtracker) {
    exec { "start-impala-statestore":
      user => "root",
      command => "GLOG_v=1 nohup /usr/bin/statestored -state_store_port=24000",
      unless => "/bin/ps aux | /bin/grep '[s]tatestored'", #this exec will run unless the command returns 0
      require => [ Package["imapala"],
                   File["/etc/impala/conf/core-site.xml",
                        "/etc/impala/conf/hdfs-site.xml",
                        "/etc/impala/conf/hive-site.xml",
                        "/etc/impala/conf/impala-log4j.properties"],
                   Exec["usermod-impala"]],
    }
  } else {
    exec { "start-impalad":
     user => "root",
     command => "GLOG_v=1 nohup /usr/bin/impalad -state_store_host=$jobtracker -nn=$namenode -nn_port=8020 -hostname=$::fqdn -ipaddress=$::ipaddress",
     unless => "/bin/ps aux | /bin/grep '[i]mpalad'",
     require => [ Package["imapala"],
                  File["/etc/impala/conf/core-site.xml",
                       "/etc/impala/conf/hdfs-site.xml",
                       "/etc/impala/conf/hive-site.xml",
                       "/etc/impala/conf/impala-log4j.properties"],
                  Exec["usermod-impala"]],
    }
  }

  file {
    "/etc/impala/conf":
      ensure => "directory",
      require => Package["impala"],
  }

  file {
    "/etc/impala/conf/core-site.xml":
      content => template('hadoop/core-site.xml.erb'),
      require => [Package["hadoop"], File["/etc/impala/conf"]],
  }

  file {
    "/etc/impala/conf/hdfs-site.xml":
      content => template('hadoop/hdfs-site.xml.erb'),
      require => [Package["hadoop"], File["/etc/impala/conf"]],
  }

  file {
    "/etc/impala/conf/hive-site.xml":
      content => template('hadoop/hive-site.xml.erb'),
      require => [Package["hadoop"], File["/etc/impala/conf"]],
  }

  file {
    "/etc/impala/conf/impala-log4j.properties":
      content => template('hadoop/impala-log4j.properties.erb'),
      require => [Package["hadoop"], File["/etc/impala/conf"]],
  }

  exec { "usermod-impala":
    command => "/usr/sbin/usermod -a -G hadoop impala",
    require => Package["impala"],
  }

  #TODO: realize hive conf file from hadoop-hive module
  # File <<| title == 'hive-site-conf' |>> {
  #   require => [Package["hadoop"], File["/etc/impala/conf"]],
  # }

  if ( $hadoop_security_authentication == "kerberos" ) {
    $sec_packages = ["python-devel", "cyrus-sasl-devel", "gcc-c++", "python-setuptools"]

    package { $sec_packages:
      ensure => latest,
    }

    exec { "install-sasl":
      command => "easy_install sasl",
      user => "root",
      require => Package[$sec_packages],
    }
  }
}