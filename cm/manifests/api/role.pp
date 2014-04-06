# Creates a role with the specified host
# valid_roles = [
#       "NAMENODE", "DATANODE", "SECONDARYNAMENODE", "BALANCER", "HTTPFS",
#       "FAILOVERCONTROLLER", "GATEWAY", "JOURNALNODE", "JOBTRACKER", "TASKTRACKER",
#       "MASTER", "REGIONSERVER", "RESOURCEMANAGER", "NODEMANAGER", "JOBHISTORY",
#       "OOZIE_SERVER", "SERVER", "HUE_SERVER", "BEESWAX_SERVER", "KT_RENEWER", "JOBSUBD",
#       "AGENT", "IMPALAD", "STATESTORE", "HIVESERVER2", "HIVEMETASTORE", "WEBHCAT",
#       "SOLR_SERVER", "SQOOP_SERVER"
#     ]
define cm::api::role($service_name, $role_type, $host_id) {
  include cm::api::params
  $cluster_name = $::cm::api::params::cluster_name
  $api_version = $::cm::api::params::api_version

  # Creates a cluster entity
  curl { "create-role-${service_name}-${name}":
    domain       => "http://${::cm::params::cm_server_host}:${::cm::params::cm_api_port}",
    post         => "/api/${api_version}/clusters/${cluster_name}/services/${service_name}/roles",
    parameters   => "{
                      'items' => [
                        'name' => '${name}',
                        'type' => '${role_type}',
                        'hostRef' => {
                          'hostId' => '${host_id}'
                        }
                      ]
                    }",
    request_type => 'json',
    username     => $::cm::params::cm_username,
    password     => $::cm::params::cm_password,
    returns      => '200',
    only_if      => {
                      'get' => "/api/${api_version}/clusters/${cluster_name}/services/${service_name}/roles/${name}",
                      'returns' => '404'
                    },
    log_to      => "/var/log/ankus/cm_api/create_role_${service_name}_${name}"
  }
}
