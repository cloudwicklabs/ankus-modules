# Creates and manages hosts
# name => fqdn (host_id)
# host_name => "fqdn"
# ip_address
define cm::api::host($host_name, $ip_address, $rack_id = '/default_rack') {
  require cm::api::params

  # Creates a host entity
  curl { "create-host-${name}":
    domain       => "http://${::cm::params::cm_server_host}:${::cm::params::cm_api_port}",
    post         => "/api/${::cm::api::params::api_version}/hosts",
    parameters   => "{
                      'items' => [
                        'hostId'     => '${name}',
                        'hostname'   => '${host_name}',
                        'ipAddress'  => '${ip_address}',
                        'rackId'     => '${rack_id}'
                      ]
                    }",
    request_type => 'json',
    username     => $::cm::params::cm_username,
    password     => $::cm::params::cm_password,
    returns      => '200',
    only_if      => {
                      'get' => "/api/${::cm::api::params::api_version}/hosts/${name}",
                      'returns' => '404' # the above url dont exist if the cluster is not created
                    },
    log_to      => "/var/log/ankus/cm_api/create_host_${name}"
  }
}
