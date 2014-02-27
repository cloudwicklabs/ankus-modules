# == Define: createDirWithPerm
#
# creates directories with parent directories
#
# === Parameters:
#
# [*user*]
#   user to have the permissions to
#
# [*group*]
#   group to have the permissions to
#
# [*mode*]
#   permissions to assign to the creted directory
#
# === Examples
#
#   hadoop::create_dir_with_perm { [ "/data/0/hdfs", "/data/1/hdfs" ]:
#     user  => 'hdfs',
#     group => 'hadoop',
#     mode  => 775
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
define hadoop::create_dir_with_perm($user='hdfs', $group='hadoop', $mode='775') {
  mkdir_p { $name:
    ensure => present
  }

  file { $name:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    mode    => $mode,
    require => Mkdir_p[$name]
  }
}