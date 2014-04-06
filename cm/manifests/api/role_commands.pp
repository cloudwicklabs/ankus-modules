# Execute role commands and wait for the command to complete
define cm::api::role_commands($service_name, $role_name, $wait_for = false) {
  require cm::api::params

  $cluster_name   = $cm::params::cm_cluster_name
  $command_name   = $title
  
  exec { "execute-role-command-${command_name}":

  }

  curl { "execute-role-command-${command_name}":
    domain       => "http://${::cm::params::cm_server_host}:${::cm::params::cm_api_port}",
    post         => "/api/${::cm::api::params::api_version}/clusters/${cluster_name}/services/${service_name}/roleCommands/${command_name}",
    parameters   => "{
                      'items' => [
                        '${role_name}'
                      ]
                    }",
    request_type => 'json',
    username     => $::cm::params::cm_username,
    password     => $::cm::params::cm_password,
    returns      => '200',
    only_if      => {
                      'get'            => "/api/${::cm::api::params::api_version}/clusters/${cluster_name}/parcels/products/${product_name}/versions/${parcel_version}",
                      'returns'        => '200',
                      'contains_key'   => "stage",
                      'contains_value' => 'AVAILABLE_REMOTELY'
                    },
    log_to      => "/var/log/ankus/cm_api/parcels_${name}"
  }

  if ($wait_for == true) {
    # wait until parcel download get's completed
    wait_for { "${product_name}-${product_version} parcel download completes":
      query             => "/usr/bin/curl --silent -X GET -u \"${::cm::params::cm_username}:${::cm::params::cm_password}\" -i -H \"content-type:application/json\" http://${::cm::params::cm_server_host}:${::cm::params::cm_api_port}/api/${::cm::api::params::api_version}/clusters/${cluster_name}/parcels/products/${product_name}/versions/${parcel_version}",
      regex             => '.*stage.*:.*DOWNLOADED.*',
      giveup_regex      => '.*stage.*:.*DISTRIBUTED.*|.*stage.*:.*ACTIVATED.*',
      polling_frequency => 15,
      max_retries       => 100,
      refreshonly       => true,
      subscribe         => Curl["download-parcel-${product_name}-${product_version}"]
    }
  }
}
