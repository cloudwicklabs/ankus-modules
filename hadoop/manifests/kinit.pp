# == Class: hadoop::kinit
#
# Initializes kerberos tickets for hdfs user
#
# === Parameters
#
# None
#
# === Variables
#
# None
#
# === Examples
#
# include hadoop::kinit
#
# === Authors
#
# Ashrith <ashrith@cloudwick.com>
#
# === Copyright
#
# Copyright 2012 Cloudwick Inc, unless otherwise noted.
#
class hadoop::kinit {
  #include hadoop::kerberos

  exec { 'HDFS kinit':
    command => "/usr/bin/kinit -kt /etc/hdfs.keytab hdfs/${::fqdn} && /usr/bin/kinit -R",
    user    => 'hdfs',
    require => Kerberos::Host_keytab['hdfs'],
  }
}