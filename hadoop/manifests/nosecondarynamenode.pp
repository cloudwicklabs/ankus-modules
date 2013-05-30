class hadoop::nosecondarynamenode inherits hadoop::common-hdfs {
  service { "hadoop-hdfs-secondarynamenode":
    ensure => "stopped",
  }
  package { "hadoop-hdfs-secondarynamenode":
    ensure => "absent",
    require => Service["hadoop-hdfs-secondarynamenode"],
  }
}