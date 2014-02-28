# == Define: hadoop::create_hdfs_dirs
#
# creates directories with specified permissions in HDFS (hadoop distributed
# filesystems)
#
# === Parameters:
#
# [*hdfs_dirs_meta*]
#   hash of directories metadata like owner to the directory and permissions
#
# [*auth*]
#   authentication type enabled on the system, available authentication plugins
#   'simple' and 'kerberos'
#
# === Examples
#
#   hadoop::create_hdfs_dirs { [ "/mapred", "/tmp" ]:
#     auth           => 'simple',
#     hdfs_dirs_meta => {
#                         "/tmp"     => { perm => "777", user => "hdfs"   },
#                         "/mapred"  => { perm => "755", user => "mapred" },
#                       }
#   }
#
# === Authors
#
# ashrith <ashrith@cloudwick.com>
#
# === Copyright
#
# Copyright 2012 Cloudwick Inc, unless otherwise noted.
#
define hadoop::create_hdfs_dirs($hdfs_dirs_meta, $auth='simple') {
  $user = $hdfs_dirs_meta[$title][user]
  $perm = $hdfs_dirs_meta[$title][perm]

  if ($auth == 'kerberos') {
    require hadoop::kinit
    Exec['HDFS kinit'] -> Exec["HDFS init ${title}"]
  }

  exec { "HDFS init ${title}":
    user    => 'hdfs',
    command => "/bin/bash -c 'hadoop fs -mkdir -p ${title} && hadoop fs -chmod ${perm} ${title} && hadoop fs -chown ${user} ${title}'",
    unless  => "/bin/bash -c 'hadoop fs -ls ${name} >/dev/null 2>&1'",
    require => Service['hadoop-hdfs-namenode'],
  }
  Exec <| title == 'activate nn1' |>  -> Exec["HDFS init ${title}"]
}