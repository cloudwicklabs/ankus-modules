class cm::cluster_init inherits cm::params {
  cm::api::cluster { $cm::params::cm_cluster_name:
    cluster_version => $cm::params::cm_cluster_ver
  }
  
  # Add all the hosts to the cluster
  cm::api::add_host_to_cluster { $::cm::params::cm_nodes:
    require => Cm::Api::Cluster[$cm::params::cm_cluster_name]
  }

  # Configure parcels for the cluster
  class { 'cm::api::parcels::configure':
    require => Cm::Api::Add_host_to_cluster[$::cm::params::cm_nodes]
  }
}
