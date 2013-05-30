define hadoop::create_hdfs_dirs($hdfs_dirs_meta, $auth="simple") {
    $user = $hdfs_dirs_meta[$title][user]
    $perm = $hdfs_dirs_meta[$title][perm]

    if ($auth == "kerberos") {
      require hadoop::kinit
      Exec["HDFS kinit"] -> Exec["HDFS init $title"]
    }

    exec { "HDFS init $title":
      user => "hdfs",
      command => "/bin/bash -c 'hadoop fs -mkdir $title && hadoop fs -chmod $perm $title && hadoop fs -chown $user $title'",
      unless => "/bin/bash -c 'hadoop fs -ls $name >/dev/null 2>&1'",
      require => Service["hadoop-hdfs-namenode"],
    }
    Exec <| title == "activate nn1" |>  -> Exec["HDFS init $title"]
}