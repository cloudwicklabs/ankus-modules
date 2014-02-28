# Class: hadoop::params::default
#
#
class hadoop::params::default {
  include ::java::params

  $hadoop_deploy = hiera('hadoop_deploy')

  $cloudera_repo_class = $::osfamily ? {
    /(?i-mx:redhat)/ => 'utils::repos::cloudera::yum',
    /(?i-mx:debian)/ => 'utils::repos::cloudera::apt',
  }

  $hdp_repo_class = $::osfamily ? {
    /(?i-mx:redhat)/ => 'utils::repos::hdp::yum',
    /(?i-mx:debian)/ => 'utils::repos::hdp::apt',
  }

  $deployment_mode = $hadoop_deploy['packages_source']

  $repo_class = $deployment_mode ? {
    cdh  => $cloudera_repo_class,
    hdp  => $hdp_repo_class,
  }

  $ulimits_nofiles = 64000
  $ulimit_nproc    = 32000

  # hadoop-env
  $hadoop_java_home               = "${java::params::java_base}/jdk${java::params::java_version}"
  $hadoop_heap_size               = hiera('hadoop_heap_size', '1000')
  $hadoop_namenode_opts           = hiera('hadoop_namenode_opts', '-Xmx1000m')
  $hadoop_secondarynamenode_opts  = hiera('hadoop_secondarynamenode_opts', '-Xmx1000m')
  $hadoop_datanode_opts           = hiera('hadoop_datanode_opts', '-Xmx1000m')
  $hadoop_balancer_opts           = hiera('hadoop_balancer_opts', '-Xmx1000m')
  $hadoop_jobtracker_opts         = hiera('hadoop_jobtracker_opts', '-Xmx1000m')
  $hadoop_tasktracker_opts        = hiera('hadoop_tasktracker_opts', '-Xmx1000m')

  # core-site
  $ha               = $hadoop_deploy['ha']
  $hadoop_framwork  = $hadoop_deploy['framework'] # == mapreduce or hdp
  if ($ha != 'disabled') {
    $hadoop_ha_nameservice_id = hiera('hadoop_ha_nameservice_id', 'ha-nn-uri')
    $upgradetoha              = hiera('upgradetoha', false)
  }
  $hadoop_namenode_host = $hadoop_deploy['namenode']
  $first_namenode = inline_template("<%= @hadoop_namenode_host.to_a[0] %>")
  $hadoop_namenode_port = hiera('hadoop_namenode_port', '8020')
  if ($ha == 'enabled') {
    $hadoop_namenode_uri = "hdfs://${hadoop_ha_nameservice_id}"
  } else {
    $hadoop_namenode_uri = "hdfs://${first_namenode}:${hadoop_namenode_port}"
  }
  $hadoop_security_authentication       = hiera('security', 'simple')
  $hadoop_snappy_codec                  = hiera('hadoop_snappy_codec', 'disabled')
  $hadoop_config_fs_inmemory_size_mb    = hiera('hadoop_config_fs_inmemory_size_mb', '200')
  $hadoop_config_io_file_buffer_size    = hiera('hadoop_config_io_file_buffer_size', '65536')
  $hadoop_config_hadoop_tmp_dir         = hiera('hadoop_config_hadoop_tmp_dir', "/tmp/hadoop-\${user.name}")
  $hadoop_config_security_authorization = hiera('hadoop_config_security_authorization', false)
  $hadoop_config_io_bytes_per_checksum  = hiera('hadoop_config_io_bytes_per_checksum', '512')
  $hadoop_config_fs_trash_interval      = hiera('hadoop_config_fs_trash_interval', 0)

  # Components
  $hue          = hiera('hue', 'disabled') #flag to setup hue or not (enabled/disabled)
  $impala       = hiera('impala', 'disabled')
  $search       = hiera('search', 'disabled')
  $oozie        = hiera('oozie', 'disabled')
  $hbase_deploy = hiera('hbase_deploy')

  # Dirs
  $data_dirs                = $hadoop_deploy['data_dirs']
  $master_dirs              = $hadoop_deploy['master_dirs']
  $data_dir1                = inline_template('<%= @data_dirs.to_a[0] %>')
  $yarn_master_dirs         = append_each('/yarn', $master_dirs)
  $yarn_data_dirs           = append_each('/yarn', $data_dirs)
  $yarn_container_log_dirs  = append_each('/yarn-local', $data_dirs)
  $namenode_data_dirs       = append_each('/nn', $master_dirs)
  $hdfs_data_dirs           = append_each('/hdfs', $data_dirs)
  #!!!VENDOR BUG:: Journal node can only write to 1 dir
  $journal_data_dir         = inline_template('<%= @master_dirs.to_a[0] %>')
  $jn_data_dir              = "${journal_data_dir}/jn"
  $mapred_data_dirs         = append_each('/mapred', $data_dirs)
  $mapred_master_dirs       = append_each('/mapred', $master_dirs)
  $checkpoint_data_dirs     = append_each('/checkpoint', $master_dirs)

  # Security
  if ($hadoop_security_authentication == 'kerberos') {
    $kerberos_domain     = hiera('kerberos_domain', inline_template('<%= @domain %>'))
    $kerberos_realm      = hiera('kerberos_realm', inline_template('<%= @domain.upcase %>'))
    $kerberos_kdc_server = hiera('controller')
    #package["hadoop"] -> class { "hadoop::kerberos": }
    #include hadoop::kerberos
  }

  # Monitoring
  $monitoring = hiera('monitoring', 'disabled')
  if ($monitoring == 'enabled') {
    $ganglia_server = hiera('ganglia_server')
  }

  # Log aggregation
  $log_aggregation = hiera('log_aggregation', 'disabled')
  if ($log_aggregation == 'enabled') {
    $logstash_server = hiera('logstash_server')
  }

  # Map-reduce
  $hadoop_mapreduce = $hadoop_deploy['mapreduce']
  if ($hadoop_mapreduce != 'disabled') {
    $hadoop_mapreduce_framework = $hadoop_mapreduce['type']
    if $hadoop_framwork == 'hdp' and $hadoop_mapreduce_framework != 'mr2' {
      fail('HDP based hadoop deployments does not support mapreduce1 use yarn instead')
    }
    if ($hadoop_mapreduce_framework == 'mr2') {
      $hadoop_mapred_home = '/usr/lib/hadoop-mapreduce'
    }
  }
}