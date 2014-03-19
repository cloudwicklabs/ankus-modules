class cm::cluster_init inherits cm::params {
  cm::api::cluster { $cm::params::cm_cluster_name:
    cluster_version => $cm::params::cm_cluster_ver
  }
}
