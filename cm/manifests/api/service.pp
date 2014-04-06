# Creates and manages service entity in cm
define cm::api::service($service_type, $api_version = 'v5') {
  require cm::api::params

  curl { "create-service-${name}":
    domain       => "http://${::cm::params::cm_server_host}:${::cm::params::cm_api_port}",
    post         => "/api/${::cm::api::params::api_version}/clusters/${::cm::api::params::cluster_name}/services",
    parameters   => "{
                      'items' => [
                        'name' => '${name}',
                        'type' => '${service_type}'
                      ]
                    }",
    request_type => 'json',
    username     => $::cm::params::cm_username,
    password     => $::cm::params::cm_password,
    returns      => '200',
    only_if      => {
                      'get' => "/api/${::cm::api::params::api_version}/clusters/${::cm::api::params::cluster_name}/services/${name}",
                      'returns' => '404'
                    },
    log_to      => "/var/log/ankus/cm_api/create_service_${name}"
  }
}
