# curl { "add-host-${name}-to-cluster":
#   domain       => "http://${::cm::params::cm_server_host}:${::cm::params::cm_api_port}",
#   post         => "/api/${::cm::api::params::api_version}/clusters/${::cm::api::params::cluster_name}/hosts",
#   parameters   => "{
#                     'items' => [
#                       'hostId' => '${name}'
#                     ]
#                   }",
#   request_type => 'json',
#   username     => $::cm::params::cm_username,
#   password     => $::cm::params::cm_password,
#   returns      => '200',
#   only_if      => {
#                     'get' => "/api/${::cm::api::params::api_version}/clusters/${::cm::api::params::cluster_name}/hosts",
#                     'does_not_contain' => "$..hostId[?(@ == '${name}')]"
#                   },
#   log_to      => "/var/log/ankus/cm_api/add_host_${name}_to_cluster"
# }
define cm::api::commands::format_hdfs($service_name, $role_name) {
  require cm::api::params

  cm_command { 'format_namenode':
    url => "http://${::cm::params::cm_server_host}:${::cm::params::cm_api_port}",
    post => "/api/${::cm::api::params::api_version}/clusters/${::cm::api::params::cluster_name}/services/${service_name}/roleCommands/hdfsFormat",
    username     => $::cm::params::cm_username,
    password     => $::cm::params::cm_password,
    params   => "{'items' => [ '${role_name}' ] }",
    wait => true
  }
}
