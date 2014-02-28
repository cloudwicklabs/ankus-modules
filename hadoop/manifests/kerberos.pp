# == Class: hadoop::kerberos
#
# Initializes kerberos tickets for specified principles
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
# include hadoop::kerberos
#
# === Authors
#
# Ashrith <ashrith@cloudwick.com>
#
# === Copyright
#
# Copyright 2012 Cloudwick Inc, unless otherwise noted.
#
class hadoop::kerberos inherits hadoop::params::default {
  require kerberos::client

  kerberos::host_keytab { 'hdfs':
    princs => [ 'host', 'hdfs' ],
    spnego => true,
  }

  if ($hadoop::params::default::hadoop_mapreduce_framework == 'mr1') {
    kerberos::host_keytab { 'mapreduce':
      princs => 'mapred',
      spnego => true,
    }
  }
  if($hadoop::params::default::hadoop_mapreduce_framework == 'mr2') {
    kerberos::host_keytab { 'yarn':
      princs => 'yarn',
      spnego => true,
    }
  }
}