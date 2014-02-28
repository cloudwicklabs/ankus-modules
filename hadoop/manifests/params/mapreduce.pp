# Class: hadoop::params::mapreduce
#
#
class hadoop::params::mapreduce inherits hadoop::params::default {
  #
  # Auto compute configuration params
  #
  # reserved for os + dn + nm
  $reserved_for_stack = {
    4 => '1',
    8 => '2',
    16 => '2',
    24 => '4',
    48 => '6',
    64 => '8',
    72 => '8',
    96 => '12',
    128 => '24',
    256 => '32',
    512 => '64'
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

  # calculate the reserved memory for stack which includes os + dn + nm
  if has_key($reserved_for_stack, $mem) {
    $reserved_for_stack_mem = $reserved_for_stack[$mem]
  } elsif $mem <= 4 {
    $reserved_for_stack_mem = 1
  } elsif $mem >= 512 {
    $reserved_for_stack_mem = 64
  } else {
    $reserved_for_stack_mem = 1
  }

  # calculate the reserved memory for hbase
  if $hadoop::params::default::hbase_deploy != 'disabled' {
    if has_key($reserved_for_hbase, $mem) {
      $reserved_for_hbase_mem = $reserved_for_hbase[$mem]
    } elsif $mem <= 4 {
      $reserved_for_hbase_mem = 1
    } elsif $mem >= 512 {
      $reserved_for_hbase_mem = 64
    } else {
      $reserved_for_hbase_mem = 2
    }
  } else {
    $reserved_for_hbase_mem = 0
  }

  # calculate the usable memory
  $reserved_mem = $reserved_for_stack_mem + $reserved_for_hbase_mem
  $usable_mem   = $mem - $reserved_mem

  if $usable_mem < 2 {
    $final_mem = 2
    $reserved_mem_final = max(0, $final_mem - $reserved_mem)
  } else {
    $final_mem = $usable_mem
    $reserved_mem_final = $reserved_mem
  }
  $final_usable_mem_in_mb = $mem * $gb # get mem in mb

  $map_tasks_maximum_default    = inline_template('<%= [1, processorcount.to_i * 0.80].max.round %>')
  $reduce_tasks_maximum_default = inline_template('<%= [1, processorcount.to_i * 0.20].max.round %>')
  $mapred_child_java_opts       = inline_template('<%= [256, ( @final_usable_mem_in_mb.to_i / (@map_tasks_maximum_default.to_i + @reduce_tasks_maximum_default.to_i))].max -%>')
  $io_sort_mb                   = inline_template('<%= (0.5 * @mapred_child_java_opts.to_f).to_i -%>')
  $io_sort_factor               = inline_template('<%= (@io_sort_mb.to_i / 10).to_i -%>')

  # mapred-site
  $hadoop_mapreduce                                     = $hadoop::params::default::hadoop_deploy['mapreduce']
  $hadoop_mapreduce_framework                           = $hadoop_mapreduce['type']
  $hadoop_mapreduce_master                              = $hadoop_mapreduce['master']
  $hadoop_jobtracker_host                               = $hadoop_mapreduce_master
  $hadoop_jobtracker_rpc_port                           = hiera('hadoop_jobtracker_port', 8021)
  $num_of_nodes                                         = hiera('number_of_nodes')
  $hadoop_config_mapred_child_java_opts                 = hiera('hadoop_config_mapred_child_java_opts', $mapred_child_java_opts)
  $hadoop_config_mapred_child_ulimit                    = (( $hadoop_config_mapred_child_java_opts * 1.5 ) * 1024 )
  $hadoop_config_io_sort_mb                             = hiera('hadoop_config_io_sort_mb', $io_sort_mb)
  $hadoop_config_io_sort_factor                         = hiera('hadoop_config_io_sort_factor', $io_sort_factor)
  $hadoop_config_mapred_job_tracker_handler_count       = hiera('hadoop_config_mapred_job_tracker_handler_count', '10')
  $hadoop_config_mapred_map_tasks_speculative_execution = hiera('hadoop_config_mapred_map_tasks_speculative_execution', true)
  if ($num_of_nodes > '2'){
    $mapred_parallel_copies_default                     = inline_template('<%= [Math.log(@num_of_nodes) * 4].max.round %>')
  }
  else{
    $mapred_parallel_copies_default = '5'
  }
  $hadoop_config_mapred_reduce_parallel_copies              = hiera('hadoop_config_mapred_reduce_parallel_copies', $mapred_parallel_copies_default)
  $hadoop_config_mapred_reduce_tasks_speculative_execution  = hiera('hadoop_config_mapred_reduce_tasks_speculative_execution', false)
  $hadoop_config_mapred_tasktracker_map_tasks_maximum       = hiera('hadoop_config_mapred_tasktracker_map_tasks_maximum', $map_tasks_maximum_default)
  $hadoop_config_mapred_tasktracker_reduce_tasks_maximum    = hiera('hadoop_config_mapred_tasktracker_reduce_tasks_maximum', $reduce_tasks_maximum_default)
  $hadoop_config_mapred_reduce_tasks_default                = $num_of_nodes * $hadoop_config_mapred_tasktracker_reduce_tasks_maximum
  $hadoop_config_mapred_reduce_tasks                        = hiera('hadoop_config_mapred_reduce_tasks', $hadoop_config_mapred_reduce_tasks_default)
  $hadoop_config_tasktracker_http_threads                   = hiera('hadoop_config_tasktracker_http_threads', '40')
  $hadoop_config_use_map_compression                        = hiera('hadoop_config_use_map_compression', false)
  #default value is 0.05 can increase it to 0.8, put this value closer to 1 for faster networks and close to 0 for saturated networks
  $hadoop_config_mapred_reduce_slowstart_completed_maps     = hiera('hadoop_config_mapred_reduce_slowstart_completed_maps', '0.80')
  $hadoop_config_mapred_map_sort_spill_percent              = hiera('hadoop_config_mapred_map_sort_spill_percent', '0.80')
}