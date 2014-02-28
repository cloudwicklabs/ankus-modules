# Class: hadoop::params::hbase
#
#
class hadoop::params::hbase inherits hadoop::params::default {

  $hbase_deploy               = hiera('hbase_deploy', 'disabled')
  if ($hbase_deploy != "disabled") {
    $hbase_master             = $hbase_deploy['hbase_master']
    $hbase_zookeeper_quorum   = hiera('zookeeper_quorum')
  }

  # reserved for hbase
  $reserved_for_hbase = {
    4 => '1',
    8 => '1',
    16 => '2',
    24 => '4',
    48 => '8',
    64 => '8',
    72 => '8',
    96 => '16',
    128 => '24',
    256 => '32',
    512 => '64'
  }
  $gb = 1024

  $mem = inline_template('<%= (@memorytotal).scan(/\\d+[.,]\\d+/).first.to_f.ceil -%>')

  # calculate the reserved memory for hbase
  if has_key($reserved_for_hbase, $mem) {
    $reserved_for_hbase_mem = $reserved_for_hbase[$mem]
  } elsif $mem <= 4 {
    $reserved_for_hbase_mem = 1
  } elsif $mem >= 512 {
    $reserved_for_hbase_mem = 64
  } else {
    $reserved_for_hbase_mem = 2
  }

  $reserved_for_hbase_mem_in_mb = $reserved_for_hbase_mem * $gb

  $rootdir                                  = hiera('hbase_rootdir', '/hbase')
  $zookeeper_quorum                         = hiera('zookeeper_ensemble')
  $heap_size                                = hiera('hbase_heap_size', $reserved_for_hbase_mem_in_mb)

  $hbase_master_java_heap_size_max          = hiera(hbase_master_java_heap_size_max)
  $hbase_master_java_heap_size_new          = hiera(hbase_master_java_heap_size_new)
  $hbase_master_gc_tuning_options           = hiera(hbase_master_gc_tuning_options)
  $hbase_master_gc_log_opts                 = hiera(hbase_master_gc_log_opts)
  $hbase_regionserver_java_heap_size_max    = hiera(hbase_regionserver_java_heap_size_max)
  $hbase_regionserver_java_heap_size_new    = hiera(hbase_regionserver_java_heap_size_new)
  $hbase_regionserver_gc_tuning_opts        = hiera(hbase_regionserver_gc_tuning_opts)
  $hbase_regionserver_gc_log_opts           = hiera(hbase_regionserver_gc_log_opts)
  $hbase_regionserver_lease_period          = hiera(hbase_regionserver_lease_period)
  $hbase_regionserver_handler_count         = hiera(hbase_regionserver_handler_count)
  $hbase_regionserver_split_limit           = hiera(hbase_regionserver_split_limit)
  $hbase_regionserver_msg_period            = hiera(hbase_regionserver_msg_period)
  $hbase_regionserver_log_flush_period      = hiera(hbase_regionserver_log_flush_period)
  $hbase_regionserver_logroll_period        = hiera(hbase_regionserver_logroll_period)
  $hbase_regionserver_split_check_period    = hiera(hbase_regionserver_split_check_period)
  $hbase_regionserver_worker_period         = hiera(hbase_regionserver_worker_period)
  $hbase_regionserver_balancer_period       = hiera(hbase_regionserver_balancer_period)
  $hbase_regionserver_balancer_slop         = hiera(hbase_regionserver_balancer_slop)
  $hbase_regionserver_max_filesize          = hiera(hbase_regionserver_max_filesize)
  $hbase_regionserver_hfile_block_size      = hiera(hbase_regionserver_hfile_block_size)
  $hbase_regionserver_required_codecs       = hiera(hbase_regionserver_required_codecs)
  $hbase_regionserver_block_cache_size      = hiera(hbase_regionserver_block_cache_size)
  $hbase_regionserver_hash_type             = hiera(hbase_regionserver_hash_type)
  $hbase_zookeeper_max_client_connections   = hiera(hbase_zookeeper_max_client_connections)
  $hbase_client_write_buffer                = hiera(hbase_client_write_buffer)
  $hbase_client_pause_period_ms             = hiera(hbase_client_pause_period_ms)
  $hbase_client_retry_count                 = hiera(hbase_client_retry_count)
  $hbase_client_scanner_prefetch_rows       = hiera(hbase_client_scanner_prefetch_rows)
  $hbase_client_max_keyvalue_size           = hiera(hbase_client_max_keyvalue_size)
  $hbase_memstore_flush_upper_heap_pct      = hiera(hbase_memstore_flush_upper_heap_pct)
  $hbase_memstore_flush_lower_heap_pct      = hiera(hbase_memstore_flush_lower_heap_pct)
  $hbase_memstore_flush_size_trigger        = hiera(hbase_memstore_flush_size_trigger)
  $hbase_memstore_preflush_trigger          = hiera(hbase_memstore_preflush_trigger)
  $hbase_memstore_flush_stall_trigger       = hiera(hbase_memstore_flush_stall_trigger)
  $hbase_memstore_mslab_enabled             = hiera(hbase_memstore_mslab_enabled)
  $hbase_compaction_files_trigger           = hiera(hbase_compaction_files_trigger)
  $hbase_compaction_pause_trigger           = hiera(hbase_compaction_pause_trigger)
  $hbase_compaction_pause_time              = hiera(hbase_compaction_pause_time)
  $hbase_compaction_max_combine_files       = hiera(hbase_compaction_max_combine_files)
  $hbase_compaction_period                  = hiera(hbase_compaction_period)
  $hbase_master_port                        = hiera(hbase_master_port)
  $hbase_master_dash_port                   = hiera(hbase_master_dash_port)
  $hbase_master_jmx_dash_port               = hiera(hbase_master_jmx_dash_port)
  $hbase_regionserver_port                  = hiera(hbase_regionserver_port)
  $hbase_regionserver_dash_port             = hiera(hbase_regionserver_dash_port)
  $hbase_regionserver_jmx_dash_port         = hiera(hbase_regionserver_jmx_dash_port)
}