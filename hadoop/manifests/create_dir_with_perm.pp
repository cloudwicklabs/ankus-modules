# Define: createDirWithPerm creates directories with parent directories
# Parameters: user and group permission for the directories being created
#
define hadoop::create_dir_with_perm($user="hdfs", $group="hadoop", $mode="775") {
  mkdir_p { $name:
    ensure => present
  }

  file { $name:
    ensure => directory,
    owner => $user,
    group => $group,
    mode => $mode,
    require => Mkdir_p[$name]
  }
}