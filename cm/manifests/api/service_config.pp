# config is the configuration to be updated on the server side
#   { "items" => [ { "name" => "hdfs_rootdir", "value" => "/my_hbase" } ] }
# jpath is the path to search for in the response
#   "$..name[?(@ == 'dfs_replication')]"
define cm::api::service_config($service_name, $meta_data) {
  require cm::api::params
  $cluster_name = $::cm::api::params::cluster_name
  $api_version = $::cm::api::params::api_version

  $prop_name = $title
  $prop_value = $meta_data[$title]

  # Updates a service config
  curl { "update-service-config-${prop_name}":
    domain       => "http://${::cm::params::cm_server_host}:${::cm::params::cm_api_port}",
    put          => "/api/${api_version}/clusters/${cluster_name}/services/${service_name}/config",
    parameters   => "{
                      'items' => [
                        {
                          'name' => '${prop_name}',
                          'value' => '${prop_value}'
                        }
                      ]
                     }",
    request_type => 'json',
    username     => $::cm::params::cm_username,
    password     => $::cm::params::cm_password,
    returns      => '200',
    only_if      => {
                      'get' => "/api/${api_version}/clusters/${cluster_name}/services/${service_name}/config",
                      'does_not_contain' => "$..name[?(@ == '${prop_name}')]"
                    },
    log_to      => "/var/log/ankus/cm_api/update_service_config_${service_name}"
  }
}
