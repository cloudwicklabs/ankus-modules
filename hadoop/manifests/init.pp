# == Class: hadoop
#
# This module installs and manages hadoop, framework that allows for
# the distributed processing of large data sets across clusters of computers
# using simple programming models
#
# === Parameters
#
# None
#
# === Variables
#
# *All the variables are fetched from hiera*
#
# [*hadoop_java_home*]
#   parameter which specifies the java installation path, this variable is
#   automatically set based on the java module installation
#
# [*ha*]
#   specifies whether high availability setup is requied or not
#
# [*hadoop_ha_nameservice_id*]
#   specifies the nameservice id of the cluster (only requires if ha is enabled)
#   default value: ha-nn-uri
#
# [*hadoop_namenode_host*]
#   specifies namenode hostname, if ha is enabled requires array of 2 namenodes
#
# [*hadoop_namenode_port*]
#   specifies namenode rpc port
#   default value: 8020
#
# [*hadoop_secondarynamenode_host*]
#   specifies hostname of the secondarynamenode (only if ha is disabled)
#
# [*hadoop_security_authentication*]
#   specifies whether to enable security using kerberos
#   default value: simple
#
# [*kerberos_domain*]
#   if security is enabled, specifies the domain name of kerberos
#
# [*kerberos_realm*]
#   if security is enabled, specifies the realm name of kerberos
#
# [*kerberos_kdc_server*]
#   if security is enabled, specifies the kdc servers hostname
#
# [*hadoop_snappy_codec*]
#   specifies whether to setup snappy codec for compression
#   default value: disabled
#
# [*hadoop_config_fs_inmemory_size_mb*]
#   specifies hadoop configuration parameter fs.inmemory.size.mb
#   default value: 200
#
# [*hadoop_config_io_file_buffer_size*]
#   specifies hadoop configuration parameter io.file.buffer.size
#   default value: 65536
#
# [*data_dirs*]
#   data directories where hadoop will write data to
#
# [*ganglia_server*]
#   specifies hostname of ganglia server required for monitoring
#
# [*hadoop_mapreduce_framework*]
#   specifies mapreduce framework to setup
#   possible values: mr1 | mr2
#
# [*num_of_nodes*]
#   number of worker nodes involved in the installion, req for
#   calculating some hadoop properties
#
# [*zk*]
#   array of zookeeper nodes involved in the cluster(only for ha or hbase)
#
# [*jn*]
#   array of journal nodes involved in the cluster(only for ha)
#
# [*shared_edits_dir*]
#   shared edit dir on journal nodes where namenodes will write there metadata to
#
# [*sshfence_user*]
#   if ha is enabled, specifies username used to perform failover fencing
#   default value: hdfs
#
# [*sshfence_user_home*]
#   if ha is enabled, home directiry of user who will perform ssh fencing
#   default value: /var/lib/hadoop-hdfs
#
# [*sshfence_keydir*]
#   path where sshfence user will store the ssh public and private keys
#   default value: /var/lib/hadoop-hdfs/.ssh
#
# [*sshfence_keypath*]
#   name of the file where, sshfence user's private key is store
#   default value: $sshfence_keydir/id_sshfence
#
# [hdfs_support_append]
#   specifies whether to enable hdfs append feature (req for hbase installation)
#
# [*hadoop_config_dfs_block_size*]
#   specifies the block size for hdfs
#   default value: 64MB
#
# [*hadoop_jobtracker_host*]
#   hostname of the jobtracker (for mr1)
#
# [*hadoop_jobtracker_rpc_port*]
#   rpc port for jobtracker to listen on (for mr1)
#   default: 8021
#
# [*hadoop_resourcemanager_host*]
#   hostname of the resource manager host (for mr2)
#
# [*hadoop_resourcemanager_port*]
#   rpc port of resource manager (for mr2)
#   default value: 8032
#
# [*hadoop_resourcetracker_port*]
#   port number of resource tracker (for mr2)
#   default value: 8031
#
# [*hadoop_resourcescheduler_port*]
#   port number of resource scheduler (for mr2)
#   default value: 8030
#
# [*hadoop_resourceadmin_port*]
#   port number of resoucemanager admin port (for mr2)
#   default value: 8033
#
# [*hadoop_resourcewebapp_port*]
#   port number of resourcemanager web application (for mr2)
#   default value: 8088
#
# [*hadoop_proxyserver_port*]
#   port number of proxyserver (for mr2)
#   deafult value: 8089
#
# [*hadoop_jobhistory_host*]
#   hostname of job history server
#   default value: resourcemanger hostname
#
# [*hadoop_config_mapred_child_java_opts*]
#   configures hadoop property mapred.child.java.opts
#
# [*hadoop_config_io_sort_mb*]
#   configures hadoop property io.sort.mb
#
# [*hadoop_config_io_sort_factor*]
#   configures hadoop property io.sort.factor
#
# [*hadoop_config_mapred_job_tracker_handler_count*]
#   configures hadoop property mapred.job.tracker.handler.count
#
# [*hadoop_config_mapred_map_tasks_speculative_execution*]
#   configures hadoop property mapred.map.tasks.speculative.execution
#
# [*hadoop_config_mapred_reduce_tasks_speculative_execution*]
#   configures hadoop property mapred.reduce.tasks.speculative.execution
#
# [*hadoop_config_tasktracker_http_threads*]
#   configures hadoop property tasktracker.http.threads
#
# [*hadoop_config_use_map_compression*]
#   configures hadoop whether to use map side compression or not
#
# [*hadoop_config_mapred_reduce_slowstart_completed_maps*]
#   configures hadoop property mapred.reduce.slowstart.completed.map
#
# === Requires
#
# Java
# Kerberos (if security is enabled)
#
# === Sample Usage
#
# include hadoop::namenode
# include hadoop::secondarynamenode
# include hadoop::jobtracker
# include hadoop::datanode
# include hadoop::tasktracker
# include hadoop::resourcemanger
# include hadoop::jobhistoryproxyserver
# include hadoop::nodemanager
#
# === Authors
#
# Ashrith <ashrith@cloudwick.com>
#
# === Copyright
#
# Copyright 2012 Cloudwick Technologies, unless otherwise noted.
#

class hadoop {

  class common {
    include java
    require utilities::repos #contains repositories
    #common variables
    #hadoop-env.sh
    $hadoop_java_home = inline_template("<%= scope.lookupvar('java::params::java_base') %>/jdk<%= scope.lookupvar('java::params::java_version') %>")
    $hadoop_heap_size = hiera('hadoop_heap_size', '1000')
    $hadoop_namenode_opts = hiera('hadoop_namenode_opts', '-Xmx1000m')
    $hadoop_secondarynamenode_opts = hiera('hadoop_secondarynamenode_opts', '-Xmx1000m')
    $hadoop_datanode_opts = hiera('hadoop_datanode_opts', '-Xmx1000m')
    $hadoop_balancer_opts = hiera('hadoop_balancer_opts', '-Xmx1000m')
    $hadoop_jobtracker_opts = hiera('hadoop_jobtracker_opts', '-Xmx1000m')
    $hadoop_tasktracker_opts = hiera('hadoop_tasktracker_opts', '-Xmx1000m')
    #core-site.xml
    $hadoop_deploy = hiera('hadoop_deploy')
    $ha = $hadoop_deploy['hadoop_ha']
    #HUE BEGIN
    $hue = hiera('hue', 'disabled') #flag to setup hue or not (enabled/disabled)
    $impala = hiera('impala', 'disabled')
    #HUE END
    if ($ha != "disabled") {
      $hadoop_ha_nameservice_id = hiera('hadoop_ha_nameservice_id', 'ha-nn-uri')
      $upgradetoha = hiera('upgradetoha', 'false')
    }
    $hadoop_namenode_host = $hadoop_deploy['hadoop_namenode']
    $hadoop_namenode_port = hiera('hadoop_namenode_port', '8020')
    if ($ha == "enabled") {
      $hadoop_namenode_uri = "hdfs://${hadoop_ha_nameservice_id}"
    } else {
      $hadoop_namenode_uri = "hdfs://${hadoop_namenode_host}:${hadoop_namenode_port}"
    }
    $hadoop_security_authentication = hiera('security', 'simple')
    $hadoop_snappy_codec = hiera('hadoop_snappy_codec', 'disabled')
    $hadoop_config_fs_inmemory_size_mb = hiera('hadoop_config_fs_inmemory_size_mb', '200')
    $hadoop_config_io_file_buffer_size = hiera('hadoop_config_io_file_buffer_size', '65536')
    $hadoop_config_hadoop_tmp_dir = hiera('hadoop_config_hadoop_tmp_dir', '/tmp/hadoop-${user.name}')
    $hadoop_config_security_authorization = hiera('hadoop_config_security_authorization', 'false')
    $hadoop_config_io_bytes_per_checksum = hiera('hadoop_config_io_bytes_per_checksum', '512')
    $hadoop_config_fs_trash_interval = hiera('hadoop_config_fs_trash_interval', 0)
    #dirs
    $data_dirs = hiera('storage_dirs', ['/tmp/data'])
    $data_dir1 = inline_template("<%= data_dirs.to_a[0] %>")
    $yarn_data_dirs = append_each("/yarn",$data_dirs)
    $yarn_container_log_dirs = append_each("/yarn-local",$data_dirs)
    $namenode_data_dirs = append_each("/name",$data_dirs)
    $hdfs_data_dirs = append_each("/hdfs",$data_dirs)
    #right now, journal node can only write to 1 dir
    $journal_data_dir = inline_template("<%= data_dirs.to_a[0] %>")
    $jn_data_dir = "$journal_data_dir/jn"
    $mapred_data_dirs = append_each("/mapred", $data_dirs)
    $checkpoint_data_dirs = append_each("/checkpoint",$data_dirs)
    #security
    if ($hadoop_security_authentication == "kerberos") {
      $kerberos_domain     = hiera("hadoop_kerberos_domain", inline_template('<%= domain %>'))
      $kerberos_realm      = hiera("hadoop_kerberos_realm", inline_template('<%= domain.upcase %>'))
      $kerberos_kdc_server = hiera("controller")
      #package["hadoop"] -> class { "hadoop::kerberos": }
      #include hadoop::kerberos
    }
    #hadoop-metrics2.properties
    $monitoring = hiera('monitoring', 'disabled')
    if ($monitoring == 'enabled') {
      $ganglia_server = hiera("ganglia_server")
    }

    #log aggregation
    $log_aggregation = hiera('log_aggregation', 'disabled')
    if ($log_aggregation == 'enabled') {
      $logstash_server = hiera('logstash_server')
    }

    #map-reduce
    $hadoop_mapreduce = $hadoop_deploy['mapreduce']
    if ($hadoop_mapreduce != 'disabled') {
      $hadoop_mapreduce_framework = $hadoop_mapreduce['type']
    }

    file {
      "/etc/hadoop/conf/createdir.sh":
      content => template('hadoop/createdir.sh.erb'),
      require => Package["hadoop"],
    }

    exec { "create-root-dir":
      command => "/bin/sh /etc/hadoop/conf/createdir.sh",
      path => "/usr/bin:/usr/sbin:/bin:/usr/local/bin",
      user => root,
      group => root,
      creates => $data_dir1,
      require => File["/etc/hadoop/conf/createdir.sh"],
      #refreshonly => true,
    }

    file {
      "/etc/hadoop/conf/hadoop-env.sh":
        content => template('hadoop/hadoop-env.sh.erb'),
        require => [Package["hadoop"]],
    }

    file {
      "/etc/hadoop/conf/core-site.xml":
        content => template('hadoop/core-site.xml.erb'),
        require => Package["hadoop"],
    }

    if ($monitoring == 'enabled') {
      file {
        "/etc/hadoop/conf/hadoop-metrics2.properties":
          content => template("hadoop/hadoop-metrics2.properties.erb"),
          require => Package["hadoop"],
      }
    }

    file {
      "/etc/hadoop/conf/topology.rb":
        source => "puppet:///modules/hadoop/topology.rb",
        require => Package["hadoop"],
    }

    case $operatingsystem {
      'Ubuntu': {
        package { "hadoop":
          ensure => latest,
          require => [ File["java-app-dir"], Apt::Source['cloudera_precise'] ],
        }
      }
      'CentOS': {
        package { "hadoop":
          ensure => latest,
          require => [ File["java-app-dir"], Yumrepo["cloudera-repo"] ],
        }
      }
    }
  }

  class common-yarn inherits common {

    #variables specific to mr2
    #yarn-site.xml
    $hadoop_mapreduce = $hadoop_deploy['mapreduce']
    $hadoop_mapreduce_framework = $hadoop_mapreduce['type']
    $hadoop_mapreduce_master = $hadoop_mapreduce['master']
    $hadoop_resourcemanager_host = $hadoop_mapreduce_master
    $hadoop_resourcemanager_port = hiera('hadoop_resourcemanager_port', 8032)
    $hadoop_resourcetracker_port = hiera('hadoop_resourcetracker_port', 8031)
    $hadoop_resourcescheduler_port = hiera('hadoop_resourcescheduler_port', 8030)
    $hadoop_resourceadmin_port = hiera('hadoop_resourceadmin_port', 8033)
    $hadoop_resourcewebapp_port = hiera('hadoop_resourcewebapp_port', 8088)
    $hadoop_proxyserver_port = hiera('hadoop_proxyserver_port', 8089)
    #mapred-site.xml
    $hadoop_jobhistory_host = $hadoop_mapreduce_master
    $num_of_nodes = hiera('number_of_nodes')
    $hadoop_config_mapred_tasktracker_map_tasks_maximum_default =  inline_template("<%= [1, processorcount.to_i * 0.80].max.round %>")
    $hadoop_config_mapred_tasktracker_map_tasks_maximum = hiera('hadoop_config_mapred_tasktracker_map_tasks_maximum', "$hadoop_config_mapred_tasktracker_map_tasks_maximum_default")
    $hadoop_config_mapred_tasktracker_reduce_tasks_maximum_default =  inline_template("<%= [1, processorcount.to_i * 0.20].max.round %>")
    $hadoop_config_mapred_tasktracker_reduce_tasks_maximum = hiera('hadoop_config_mapred_tasktracker_map_tasks_maximum', "$hadoop_config_mapred_tasktracker_reduce_tasks_maximum_default")
    $hadoop_config_mapred_reduce_tasks_default = $num_of_nodes * $hadoop_config_mapred_tasktracker_reduce_tasks_maximum
    $hadoop_config_mapred_reduce_tasks = hiera('hadoop_config_mapred_reduce_tasks', "$hadoop_config_mapred_reduce_tasks_default")
    #$hadoop_config_mapred_child_java_opts_default = inline_template("<%= memorytotal.to_i %>")
    $hadoop_config_mapred_child_java_opts = hiera('hadoop_config_mapred_child_java_opts', '1024')
    $hadoop_config_mapred_child_ulimit = (( $hadoop_config_mapred_child_java_opts * 1.5 ) * 1024 )
    $hadoop_config_io_sort_mb = hiera('hadoop_config_io_sort_mb', '128')
    $hadoop_config_io_sort_factor = hiera('hadoop_config_io_sort_factor', '64')
    $hadoop_config_mapred_job_tracker_handler_count = hiera('hadoop_config_mapred_job_tracker_handler_count', '10')
    $hadoop_config_mapred_map_tasks_speculative_execution = hiera('hadoop_config_mapred_map_tasks_speculative_execution', 'true')
    if ($num_of_nodes > "2"){
      $mapred_parallel_copies_default = inline_template("<%= [Math.log(num_of_nodes) * 4].max.round %>")
    }
    else{
      $mapred_parallel_copies_default = "5"
    }
    $hadoop_config_mapred_reduce_parallel_copies = hiera('hadoop_config_mapred_reduce_parallel_copies', "$mapred_parallel_copies_default")
    $hadoop_config_mapred_reduce_tasks_speculative_execution = hiera('hadoop_config_mapred_reduce_tasks_speculative_execution', 'false')
    $hadoop_config_tasktracker_http_threads = hiera('hadoop_config_tasktracker_http_threads', '64')
    $hadoop_config_use_map_compression = hiera('hadoop_config_use_map_compression', 'false')
    #default value is 0.05 can increase it to 0.8, put this value closer to 1 for faster networks and close to 0 for saturated networks
    $hadoop_config_mapred_reduce_slowstart_completed_maps = hiera('hadoop_config_mapred_reduce_slowstart_completed_maps', '0.05')

    package { "hadoop-yarn":
      ensure => latest,
      require => [File["java-app-dir"], Package["hadoop"]],
    }

    file { "/etc/hadoop/conf/yarn-site.xml":
        content => template('hadoop/yarn-site.xml.erb'),
        require => [Package["hadoop"]],
    }

    file { "/etc/hadoop/conf/container-executor.cfg":
      content => template('hadoop/container-executor.cfg.erb'),
      owner => root,
      group => yarn,
      mode => 400,
      require => [Package["hadoop"]],
    }

    file { "/etc/hadoop/conf/mapred-site.xml":
        content => template('hadoop/mapred-site.xml.erb'),
        require => Package['hadoop'],
    }

    if ($hadoop_security_authentication == "kerberos") {
      require kerberos::client
      kerberos::host_keytab { "yarn":
         princs => "yarn",
         spnego => true,
      }
      Package["hadoop-yarn"] -> Kerberos::Host_keytab<| title == "yarn" |>
    }
  }

  class common-hdfs inherits common {

    #variables common to hdfs
    if ($ha != 'disabled' ) {
      #core-site.xml
      $hadoop_ha_nameservice_id = hiera('hadoop_ha_nameservice_id', 'ha-nn-uri')
      #hdfs-site.xml
      $zk = hiera('zookeeper_ensemble')
      $jn = hiera('journal_quorum')
      $shared_edits_dir = hiera('hadoop_ha_shared_edits_dir', 'hdfs_shared')
      $journal_shared_edits_dir = $hadoop_ha ? {
        "disabled" => "",
        default => "qjournal://${jn}/${shared_edits_dir}"
      }
      $sshfence_user = hiera('hadoop_ha_sshfence_user', 'hdfs')
      $sshfence_user_home = hiera('hadoop_ha_sshfence_user_home', '/var/lib/hadoop-hdfs')
      $sshfence_keydir    = "$sshfence_user_home/.ssh"
      $sshfence_keypath   = "$sshfence_keydir/id_sshfence"
    }

    #hdfs-site.xml
    $hdfs_support_append = hiera('hadoop_support_append', 'true')
    $hadoop_config_dfs_block_size = hiera('hadoop_config_dfs_block_size', '67108864')
    $hadoop_config_dfs_replication = hiera('hadoop_config_dfs_replication', '3')
    $hadoop_config_dfs_permissions_supergroup = hiera('hadoop_config_dfs_permissions_supergroup', 'hadoop')
    $hadoop_config_dfs_datanode_max_transfer_threads = hiera('hadoop_config_dfs_datanode_max_transfer_threads', '4096')
    $hadoop_config_dfs_datanode_du_reserved = hiera('hadoop_config_dfs_datanode_du_reserved', '0')
    $hadoop_config_dfs_datanode_balance_bandwidthpersec = hiera('hadoop_config_dfs_datanode_balance_bandwidthpersec', '1048576')
    $hadoop_config_dfs_permissions_enabled = hiera('hadoop_config_dfs_permissions_enabled', 'true')
    $hadoop_config_dfs_namenode_safemode_threshold_pct = hiera('hadoop_config_dfs_namenode_safemode_threshold_pct', '099f')
    $hadoop_config_dfs_namenode_replication_min = hiera('hadoop_config_dfs_namenode_replication_min', '1')
    $hadoop_config_dfs_namenode_safemode_extension = hiera('hadoop_config_dfs_namenode_safemode_extension', '30000')
    $hadoop_config_dfs_df_interval = hiera('hadoop_config_dfs_df_interval', '60000')
    $hadoop_config_dfs_client_block_write_retries = hiera('hadoop_config_dfs_client_block_write_retries', '3')
    $num_of_nodes = hiera('number_of_nodes')
    if ($ha == "disabled") {
      $hadoop_secondarynamenode_host = $hadoop_deploy['hadoop_secondarynamenode']
      $hadoop_secondarynamenode_port = hiera('hadoop_secondarynamenode_port', 50090)
    }
    #for security
    # if ($auth == "kerberos" and $ha != "disabled") {
    #   fail("High-availability secure clusters are not currently supported")
    # }

    package { "hadoop-hdfs":
      ensure => latest,
      require => [File["java-app-dir"], Package["hadoop"]],
    }

    file {
      "/etc/hadoop/conf/hdfs-site.xml":
        content => template('hadoop/hdfs-site.xml.erb'),
        require => [Package["hadoop"]],
    }

    if ($hadoop_security_authentication == "kerberos") {
      require kerberos::client
      kerberos::host_keytab { "hdfs":
         princs => "hdfs",
         spnego => true,
      }
      Package["hadoop-hdfs"] -> Kerberos::Host_keytab<| title == "hdfs" |>
    }
  }

  class common-mapreduce inherits common-hdfs {

    #varibles specific to mapreduce
    #mapred-site.xml
    $hadoop_mapreduce = $hadoop_deploy['mapreduce']
    $hadoop_mapreduce_framework = $hadoop_mapreduce['type']
    $hadoop_mapreduce_master = $hadoop_mapreduce['master']
    $hadoop_jobtracker_host = $hadoop_mapreduce_master
    $hadoop_jobtracker_rpc_port = hiera('hadoop_jobtracker_port', 8021)
    $num_of_nodes = hiera('number_of_nodes')
    $hadoop_config_mapred_child_java_opts = hiera('hadoop_config_mapred_child_java_opts', '200')
    $hadoop_config_mapred_child_ulimit = (( $hadoop_config_mapred_child_java_opts * 1.5 ) * 1024 )
    $hadoop_config_io_sort_mb = hiera('hadoop_config_io_sort_mb', '100')
    $hadoop_config_io_sort_factor = hiera('hadoop_config_io_sort_factor', '10')
    $hadoop_config_mapred_job_tracker_handler_count = hiera('hadoop_config_mapred_job_tracker_handler_count', '10')
    $hadoop_config_mapred_map_tasks_speculative_execution = hiera('hadoop_config_mapred_map_tasks_speculative_execution', 'true')
    if ($num_of_nodes > "2"){
      $mapred_parallel_copies_default = inline_template("<%= [Math.log(num_of_nodes) * 4].max.round %>")
    }
    else{
      $mapred_parallel_copies_default = "5"
    }
    $hadoop_config_mapred_reduce_parallel_copies = hiera('hadoop_config_mapred_reduce_parallel_copies', "$mapred_parallel_copies_default")
    $hadoop_config_mapred_reduce_tasks_speculative_execution = hiera('hadoop_config_mapred_reduce_tasks_speculative_execution', 'false')
    $hadoop_config_mapred_tasktracker_map_tasks_maximum_default =  inline_template("<%= [1, processorcount.to_i * 0.80].max.round %>")
    $hadoop_config_mapred_tasktracker_map_tasks_maximum = hiera('hadoop_config_mapred_tasktracker_map_tasks_maximum', "$hadoop_config_mapred_tasktracker_map_tasks_maximum_default")
    $hadoop_config_mapred_tasktracker_reduce_tasks_maximum_default =  inline_template("<%= [1, processorcount.to_i * 0.20].max.round %>")
    $hadoop_config_mapred_tasktracker_reduce_tasks_maximum = hiera('hadoop_config_mapred_tasktracker_reduce_tasks_maximum', "$hadoop_config_mapred_tasktracker_reduce_tasks_maximum_default")
    $hadoop_config_mapred_reduce_tasks_default = $num_of_nodes * $hadoop_config_mapred_tasktracker_reduce_tasks_maximum
    $hadoop_config_mapred_reduce_tasks = hiera('hadoop_config_mapred_reduce_tasks', "$hadoop_config_mapred_reduce_tasks_default")
    $hadoop_config_tasktracker_http_threads = hiera('hadoop_config_tasktracker_http_threads', '40')
    $hadoop_config_use_map_compression = hiera('hadoop_config_use_map_compression', 'false')
    #default value is 0.05 can increase it to 0.8, put this value closer to 1 for faster networks and close to 0 for saturated networks
    $hadoop_config_mapred_reduce_slowstart_completed_maps = hiera('hadoop_config_mapred_reduce_slowstart_completed_maps', '0.05')
    $hadoop_config_mapred_map_sort_spill_percent = hiera('hadoop_config_mapred_map_sort_spill_percent', '0.80')

    package { "hadoop-0.20-mapreduce":
      ensure => latest,
      require => [File["java-app-dir"], Package["hadoop"]],
    }

    file { "/etc/hadoop/conf/mapred-site.xml":
        content => template('hadoop/mapred-site.xml.erb'),
        require => [Package["hadoop"]],
    }

    file { "/etc/hadoop/conf/taskcontroller.cfg":
      content => template('hadoop/taskcontroller.cfg.erb'),
      require => [Package["hadoop"]],
    }

    file { $mapred_data_dirs:
      ensure => directory,
        owner => mapred,
        group => hadoop,
        mode => 755,
        require => [ Package["hadoop-0.20-mapreduce"], Exec["create-root-dir"]],
    }

    if ($hadoop_security_authentication == "kerberos") {
      require kerberos::client
      kerberos::host_keytab { "mapred":
         princs => "mapred",
         spnego => true,
      }
      Package["hadoop-0.20-mapreduce"] -> Kerberos::Host_keytab<| title == "mapred" |>
    }
  }
}