# Initializes & configures hdfs
class cm::hdfs_init inherits cm::params {
  $service_name = 'hdfs-service'
  # intialize service
  cm::api::service { $service_name:
    service_type => 'HDFS',
  } ->
  # configure root service
  cm::api::service_config { ['hadoop_security_authentication', 'hadoop_security_authorization', 'dfs_block_size', 'dfs_replication_min', 'dfs_replication', 'dfs_permissions']:
    service_name => $service_name,
    meta_data    => {
                      'hadoop_security_authentication' => 'simple',
                      'hadoop_security_authorization'  => 'false',
                      'dfs_block_size'                 => '134217728',
                      'dfs_replication_min'            => '1',
                      'dfs_replication'                => '3',
                      'dfs_permissions'                => 'true'
                    },
  } ->
  cm::api::role { 'namenode001':
    service_name => $service_name,
    role_type    => 'NAMENODE',
    host_id      => $cm::params::namenode_host, # fqdn of the namende host
  }
}
