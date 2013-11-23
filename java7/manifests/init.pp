# == Class: java7
#
# This class installs and manages jdk7
#
# === Parameters
#
# None
#
# === Variables
#
# Inherited from java7::params class
#
# === Requires
#
# java7::params
#
# === Sample Usage
#
# include java7
#
# === Authors
#
# Ashrith <ashrith@cloudwick.com>
#
# === Copyright
#
# Copyright 2012 cloudwick technologies, unless otherwise noted.
#

class java7 {

  require java7::params

  file {"$java7::params::java_base":
    ensure => "directory",
    owner => "root",
    group => "root",
    alias => "java-base"
  }

  file { "${java7::params::java_base}/jdk${java7::params::java_version}.tar.gz":
    mode => 0644,
    owner => root,
    group => root,
    source => "puppet:///modules/java7/jdk${java7::params::java_version}.tar.gz",
    alias => "java-source-tgz",
    before => Exec["untar-java"],
    require => File["java-base"]
  }

  exec { "untar jdk${java7::params::java_version}.tar.gz":
    command => "/bin/tar -zxf jdk${java7::params::java_version}.tar.gz",
    cwd => "${java7::params::java_base}",
    creates => "${java7::params::java_base}/jdk${java7::params::java_version}",
    alias => "untar-java",
    refreshonly => true,
    subscribe => File["java-source-tgz"],
    before => File["java7-app-dir"]
  }

  file { "${java7::params::java_base}/jdk${java7::params::java_version}":
    ensure => "directory",
    mode => 0644,
    owner => root,
    group => root,
    alias => "java7-app-dir"
  }

  file { "/etc/profile.d/set_java7_home.sh":
    ensure  =>  present,
    content =>  template("java7/set_java7_home.sh.erb"),
    mode  => 0755,
    owner => root,
    group   => root,
    require =>  File["java7-app-dir"],
  }

  exec { "source-java7":
    command => "/etc/profile.d/set_java7_home.sh | sh",
    user    => 'root',
    group   => 'root',
    logoutput => 'true',
    onlyif => '/usr/bin/test -z $JAVA_HOME', #run only if this command returns 0
    require =>  File ["/etc/profile.d/set_java7_home.sh"],
  }
}