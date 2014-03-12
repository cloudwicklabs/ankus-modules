class cm::server_init.pp inherits cm::api::params {
  # Create cluster entity
  cm::api::cluster { 'test_cluster':
    $cluster_version => 'CDH4',
    $api_version     => $::cm::api::params::api_version
  }
}
