define cm::api::cluster($cluster_version = 'CDH4', $api_version = 'v5') {
  include cm::params
  validate_re($cluster_version, 'CDH4|CDH3')

  curl { "create-cluster-${name}":
    domain       => "http://${::cm::params::cm_server_host}:${::cm::params::cm_server_port}",
    post         => "/api/${api_version}/clusters",
    parameters   => "{
                      'items' => [
                        'name' => '${name}',
                        'version' => '${cluster_version}'
                      ]
                    }",
    request_type => 'json',
    username     => $::cm::params::cm_username,
    password     => $::cm::params::cm_password,
    returns      => '200',
    only_if      => {
                      'get' => "/api/${api_version}/clusters/${name}/commands",
                      'returns' => '404' # the above url dont exist if the cluster is not created
                    },
    log_to      => "/var/log/ankus/cm_api/create_cluster_${name}"
  }
}
