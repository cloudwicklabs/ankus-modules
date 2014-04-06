# * Creates cluster
# * Creates management services
# * Configures management services
define cm::api::cluster($cluster_version = 'CDH4') {
  require cm::api::params
  require cm::api::management_databases
  validate_re($cluster_version, 'CDH4|CDH3')

  # Creates a cluster entity
  curl { "create-cluster-${name}":
    domain       => "http://${::cm::params::cm_server_host}:${::cm::params::cm_api_port}",
    post         => "/api/${::cm::api::params::api_version}/clusters",
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
                      'get' => "/api/${::cm::api::params::api_version}/clusters/${name}/commands",
                      'returns' => '404' # the above url dont exist if the cluster is not created
                    },
    log_to      => "/var/log/ankus/cm_api/create_cluster_${name}"
  }

  # Creates a management service
  curl { "create-mngt-service-${name}":
    domain       => "http://${::cm::params::cm_server_host}:${::cm::params::cm_api_port}",
    put          => "/api/${::cm::api::params::api_version}/cm/service",
    parameters   => "{}",
    request_type => 'json',
    username     => $::cm::params::cm_username,
    password     => $::cm::params::cm_password,
    returns      => '200',
    only_if      => {
                      'get' => "/api/${::cm::api::params::api_version}/cm/service",
                      'returns' => '404'
                    },
    log_to      => "/var/log/ankus/cm_api/create_mngt_service_${name}",
    require     => Curl["create-cluster-${name}"]
  }

  # Enable specified management services
  curl { "create-mngt-services-${name}":
    domain       => "http://${::cm::params::cm_server_host}:${::cm::params::cm_api_port}",
    post         => "/api/${::cm::api::params::api_version}/cm/service/roles",
    parameters   => "{
                      'items' => [
                        {
                          'name' => 'ACTIVITYMONITOR1',
                          'type' => 'ACTIVITYMONITOR',
                          'hostRef' => '${::cm::params::cm_server_host}'
                        },
                        {
                          'name' => 'SERVICEMONITOR1',
                          'type' => 'SERVICEMONITOR',
                          'hostRef' => '${::cm::params::cm_server_host}'
                        },
                        {
                          'name' => 'HOSTMONITOR1',
                          'type' => 'HOSTMONITOR',
                          'hostRef' => '${::cm::params::cm_server_host}'
                        },
                        {
                          'name' => 'EVENTSERVER1',
                          'type' => 'EVENTSERVER',
                          'hostRef' => '${::cm::params::cm_server_host}'
                        },
                                                {
                          'name' => 'ALERTPUBLISHER1',
                          'type' => 'ALERTPUBLISHER',
                          'hostRef' => '${::cm::params::cm_server_host}'
                        }
                      ]
                     }",
    request_type => 'json',
    username     => $::cm::params::cm_username,
    password     => $::cm::params::cm_password,
    returns      => '200',
    only_if      => {
                      'get' => "/api/${::cm::api::params::api_version}/cm/service/roles/ACTIVITYMONITOR1",
                      'returns' => '404'
                    },
    log_to      => "/var/log/ankus/cm_api/create_mngt_services_${name}",
    require     => Curl["create-mngt-service-${name}"]
  }

  # change the base properties for activity monitor
  curl { "configure-activity-monitory-${name}":
    domain       => "http://${::cm::params::cm_server_host}:${::cm::params::cm_api_port}",
    put          => "/api/${::cm::api::params::api_version}/cm/service/roleConfigGroups/MGMT-ACTIVITYMONITOR-BASE/config",
    parameters   => "{
                      'items' => [
                        {
                          'name'  => 'firehose_database_host',
                          'value' => '${::cm::params::cm_server_host}'
                        },
                        {
                          'name'  => 'firehose_database_name',
                          'value' => '${::cm::params::cm_amon_database_name}'
                        },
                        {
                          'name'  => 'firehose_database_user',
                          'value' => '${::cm::params::cm_amon_database_user}'
                        },
                        {
                          'name'  => 'firehose_listen_port',
                          'value' => '${::cm::params::cm_amon_listen_port}'
                        },
                        {
                          'name'  => 'firehose_database_type',
                          'value' => '${::cm::params::cm_amon_database_type}'
                        },
                        {
                          'name'  => 'firehose_database_password',
                          'value' => '${::cm::params::cm_amon_database_password}'
                        }
                      ]
                     }",
    request_type => 'json',
    username     => $::cm::params::cm_username,
    password     => $::cm::params::cm_password,
    returns      => '200',
    log_to      => "/var/log/ankus/cm_api/configure_activity_monitor_${name}",
    require     => Curl["create-mngt-services-${name}"]
  }

  # change the base properties for service monitor
  curl { "configure-service-monitor-${name}":
    domain       => "http://${::cm::params::cm_server_host}:${::cm::params::cm_api_port}",
    put          => "/api/${::cm::api::params::api_version}/cm/service/roleConfigGroups/MGMT-SERVICEMONITOR-BASE/config",
    parameters   => "{
                      'items' => [
                        {
                          'name'  => 'firehose_database_host',
                          'value' => '${::cm::params::cm_server_host}'
                        },
                        {
                          'name'  => 'firehose_database_name',
                          'value' => '${::cm::params::cm_smon_database_name}'
                        },
                        {
                          'name'  => 'firehose_database_user',
                          'value' => '${::cm::params::cm_smon_database_user}'
                        },
                        {
                          'name'  => 'firehose_listen_port',
                          'value' => '${::cm::params::cm_smon_listen_port}'
                        },
                        {
                          'name'  => 'firehose_database_type',
                          'value' => '${::cm::params::cm_smon_database_type}'
                        },
                        {
                          'name'  => 'firehose_database_password',
                          'value' => '${::cm::params::cm_smon_database_password}'
                        },
                        {
                          'name'  => 'firehose_debug_port',
                          'value' => '${::cm::params::cm_smon_debug_port}'
                        },
                      ]
                     }",
    request_type => 'json',
    username     => $::cm::params::cm_username,
    password     => $::cm::params::cm_password,
    returns      => '200',
    log_to      => "/var/log/ankus/cm_api/configure_service_monitor_${name}",
    require     => Curl["create-mngt-services-${name}"]
  }

  # change the base properties for host monitor
  curl { "configure-host-monitor-${name}":
    domain       => "http://${::cm::params::cm_server_host}:${::cm::params::cm_api_port}",
    put          => "/api/${::cm::api::params::api_version}/cm/service/roleConfigGroups/MGMT-HOSTMONITOR-BASE/config",
    parameters   => "{
                      'items' => [
                        {
                          'name'  => 'firehose_database_host',
                          'value' => '${::cm::params::cm_server_host}'
                        },
                        {
                          'name'  => 'firehose_database_name',
                          'value' => '${::cm::params::cm_hmon_database_name}'
                        },
                        {
                          'name'  => 'firehose_database_user',
                          'value' => '${::cm::params::cm_hmon_database_user}'
                        },
                        {
                          'name'  => 'firehose_listen_port',
                          'value' => '${::cm::params::cm_hmon_listen_port}'
                        },
                        {
                          'name'  => 'firehose_database_type',
                          'value' => '${::cm::params::cm_hmon_database_type}'
                        },
                        {
                          'name'  => 'firehose_database_password',
                          'value' => '${::cm::params::cm_hmon_database_password}'
                        }
                      ]
                     }",
    request_type => 'json',
    username     => $::cm::params::cm_username,
    password     => $::cm::params::cm_password,
    returns      => '200',
    log_to      => "/var/log/ankus/cm_api/configure_host_monitor_${name}",
    require     => Curl["create-mngt-services-${name}"]
  }

  # Start management services
  curl { "start-management-services-${name}":
    domain       => "http://${::cm::params::cm_server_host}:${::cm::params::cm_api_port}",
    post         => "/api/${::cm::api::params::api_version}/cm/service/roleCommands/start",
    parameters   => "{
                      'items' => [
                        'ACTIVITYMONITOR1', 'SERVICEMONITOR1', 'HOSTMONITOR1', 'ALERTPUBLISHER1', 'EVENTSERVER1'
                      ]
                     }",
    request_type => 'json',
    username     => $::cm::params::cm_username,
    password     => $::cm::params::cm_password,
    returns      => '200',
    log_to      => "/var/log/ankus/cm_api/start_management_services_${name}",
    require     => Curl["configure-activity-monitory-${name}", "configure-service-monitor-${name}", "configure-host-monitor-${name}"]
  }
}
