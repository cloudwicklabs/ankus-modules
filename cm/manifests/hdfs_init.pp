# Initializes & configures hdfs
class cm::hdfs_init inherits cm::params {
  $service_name = 'hdfs-service'
  # intialize hdfs service
  cm::api::service { $service_name:
    service_type => 'HDFS',
    require => Cm::Api::Parcels::Activate['Activate CDH']
  } ->
  # configure root hdfs service
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
  # assign namenode role
  $nn_role = 'namenode001'
  cm::api::role { $nn_role:
    service_name => $service_name,
    role_type    => 'NAMENODE',
    host_id      => $cm::params::namenode_host, # fqdn of the namende host
  } ->
  # configure namenode role
  cm::api::role_config { ['dfs_name_dir_list']:
    service_name => $service_name,
    role_name => $nn_role,
    meta_data => {
                   'dfs_name_dir_list' => $cm::params::dfs_name_dir,
                 },
  } ->
  # format namenode

  # start namenode role
  
}
