class hadoop::client inherits hadoop::common-hdfs {

    package { "hadoop-client":
      ensure => installed,
       require => Package["hadoop-hdfs"],
    }

    package { ["hadoop-doc", "hadoop-debuginfo", "hadoop-libhdfs"]:
       ensure => latest,
       require => [File["java-app-dir"], Package["hadoop"], Package["hadoop-hdfs"]],
    }
}