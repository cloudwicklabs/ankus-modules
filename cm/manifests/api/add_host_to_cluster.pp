# Adds a host to existing cluster
define cm::api::add_host_to_cluster {
  require cm::api::params

  curl { "add-host-${name}-to-cluster":
    domain       => "http://${::cm::params::cm_server_host}:${::cm::params::cm_api_port}",
    post         => "/api/${::cm::api::params::api_version}/clusters/${::cm::api::params::cluster_name}/hosts",
    parameters   => "{
                      'items' => [
                        'hostId' => '${name}'
                      ]
                    }",
    request_type => 'json',
    username     => $::cm::params::cm_username,
    password     => $::cm::params::cm_password,
    returns      => '200',
    only_if      => {
                      'get' => "/api/${::cm::api::params::api_version}/clusters/${::cm::api::params::cluster_name}/hosts",
                      'does_not_contain' => "$..hostId[?(@ == '${name}')]"
                    },
    log_to      => "/var/log/ankus/cm_api/add_host_${name}_to_cluster"
  }
}
