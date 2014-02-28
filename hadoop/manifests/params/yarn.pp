# Class: hadoop::params::yarn
#
#
class hadoop::params::yarn inherits hadoop::params::default {
  # yarn-env
  $yarn_heap_size                 = hiera('yarn_heapsize', '1000')
  $yarn_resourcemanager_opts      = hiera('yarn_resourcemanager_opts', '-Xmx1000m')
  $yarn_nodemanager_opts          = hiera('yarn_nodemanager_opts', '-Xmx1000m')
  $yarn_proxyserver_opts          = hiera('yarn_proxyserver_opts', '-Xmx1000m')
  $hadoop_job_historyserver_opts  = hiera('hadoop_job_historyserver_opts', '-Xmx1000m')
  $hadoop_mapred_home             = '/usr/lib/hadoop-mapreduce'
  $hadoop_yarn_home               = '/usr/lib/hadoop-yarn'
  $hadoop_hdfs_home               = '/usr/lib/hadoop-hdfs'
  $hbase_deploy                   = hiera('hbase_deploy', 'disabled')

  #
  # Compute config params
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

  # calculate the minimum container size
  if $mem <= 4 {
    $min_container_size = 256
  } elsif $mem <= 8 {
    $min_container_size = 512
  } elsif $mem <= 24 {
    $min_container_size = 1024
  } else {
    $min_container_size = 2048
  }

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
  if $hbase_deploy != 'disabled' {
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
    $final_mem          = 2
    $reserved_mem_final = max(0, $final_mem - $reserved_mem)
  } else {
    $final_mem          = $usable_mem
    $reserved_mem_final = $reserved_mem
  }
  $final_mem_in_mb = $mem * $gb # get mem in mb

  $disks          = inline_template('<%= `lsblk --noheadings | wc -l`.chomp -%>') # get the number of disks
  $containers     = inline_template('<%= [3, [2 * @physicalprocessorcount.to_i, [(1.8 * @disks.to_f), (@final_mem_in_mb.to_i / @min_container_size.to_i)].min].min].max -%>')
  $container_ram  = abs($final_mem_in_mb/$containers)

  if $container_ram > $gb {
    $container_final_ram = floor($container_ram / 512) * 512
  } else {
    $container_final_ram = $container_ram
  }
  $used_ram                           = inline_template('<%= (@containers.to_i * @container_ram.to_f / @gb.to_f).to_i -%>')
  $container_max_allocation           = $containers * $container_final_ram
  $map_memory                         = floor($container_final_ram / 2)
  $reduce_memory                      = $container_final_ram
  $am_memory                          = min($map_memory, $reduce_memory)
  $mapreduce_map_java_opts            = inline_template('<%= (0.8 * @map_memory).to_i -%>')
  $mapreduce_reduce_java_opts         = inline_template('<%= (0.8 * @reduce_memory).to_i -%>')
  $yarn_app_mapreduce_am_command_opts = inline_template('<%= (0.8 * @am_memory).to_i -%>')
  $mapreduce_task_io_sort_mb          = inline_template('<%= [0.4 * @map_memory, 1024].min.to_i -%>')
  $mapreduce_task_io_sort_factor      = inline_template('<%= @mapreduce_task_io_sort_mb.to_i / 10 -%>')

  notice(" Disks = ${disks}, FinalMemInMB = ${final_mem_in_mb}, MinContainerSize = ${min_container_size} ")
  notice("Number of containers = ${containers}")
  notice("Container RAM = ${container_final_ram} MB")
  notice("Used RAM = ${used_ram} GB")
  notice("Unused RAM = ${reserved_mem_final} GB")
  notice("yarn.scheduler.minimum-allocation-mb = ${container_final_ram}")
  notice("yarn.scheduler.maximum-allocation-mb = ${container_max_allocation}")
  notice("yarn.nodemanager.resource.memory-mb = ${container_max_allocation}")
  notice("mapreduce.map.memory.mb = ${map_memory}")
  notice("mapreduce.map.java.opts = -Xmx${mapreduce_map_java_opts}m")
  notice("mapreduce.reduce.memory.mb = ${reduce_memory}")
  notice("mapreduce.reduce.java.opts=-Xmx${mapreduce_reduce_java_opts}m")
  notice("yarn.app.mapreduce.am.resource.mb = ${am_memory}")
  notice("yarn.app.mapreduce.am.command-opts = -Xmx${yarn_app_mapreduce_am_command_opts}m")
  notice("mapreduce.task.io.sort.mb = ${mapreduce_task_io_sort_mb}")

  #yarn-site.xml
  $hadoop_mapreduce                                       = $hadoop::params::default::hadoop_deploy['mapreduce']
  $hadoop_mapreduce_framework                             = $hadoop_mapreduce['type']
  $hadoop_mapreduce_master                                = $hadoop_mapreduce['master']
  $hadoop_resourcemanager_host                            = $hadoop_mapreduce_master
  $hadoop_resourcemanager_port                            = hiera('hadoop_resourcemanager_port', 8032)
  $hadoop_resourcetracker_port                            = hiera('hadoop_resourcetracker_port', 8031)
  $hadoop_resourcescheduler_port                          = hiera('hadoop_resourcescheduler_port', 8030)
  $hadoop_resourceadmin_port                              = hiera('hadoop_resourceadmin_port', 8033)
  $hadoop_resourcewebapp_port                             = hiera('hadoop_resourcewebapp_port', 8088)
  $hadoop_proxyserver_port                                = hiera('hadoop_proxyserver_port', 8089)
  $hadoop_journalnode_port                                = hiera('hadoop_journalnode_port', 8485)
  $hadoop_jobhistory_host                                 = hiera('hadoop_jobhistory_host', $hadoop_mapreduce_master)
  $hadoop_jobhistory_port                                 = hiera('hadoop_jobhistory_port', '10020')
  $hadoop_jobhistory_webapp_port                          = hiera('hadoop_jobhistory_webapp_port', '19888')
  $hadoop_config_yarn_nodemanager_resource_memory_mb      = hiera('hadoop_config_yarn_nodemanager_resource_memory_mb', $container_max_allocation) #8048
  $hadoop_config_yarn_scheduler_minimum_allocation_mb     = hiera('hadoop_config_yarn_scheduler_minimum_allocation_mb', $container_final_ram) # 1024
  $hadoop_config_yarn_scheduler_maximum_allocation_mb     = hiera('hadoop_config_yarn_scheduler_maximum_allocation_mb', $container_max_allocation) #10240
  $hadoop_config_yarn_nodemanager_vmem_pmem_ratio         = hiera('hadoop_config_yarn_nodemanager_vmem_pmem_ratio', 2.1)

  # mapred-site.xml
  $hadoop_config_mapreduce_map_memory_mb                  = hiera('hadoop_config_mapreduce_map_memory_mb', $map_memory) #2048
  $hadoop_config_mapreduce_reduce_memory_mb               = hiera('hadoop_config_mapreduce_reduce_memory_mb', $reduce_memory) #4096
  $hadoop_config_mapreduce_map_java_opts                  = hiera('hadoop_config_mapreduce_map_java_opts', $mapreduce_map_java_opts) # 1536
  $hadoop_config_mapreduce_reduce_java_opts               = hiera('hadoop_config_mapreduce_reduce_java_opts', $mapreduce_reduce_java_opts) #3556
  $hadoop_config_mapreduce_task_io_sort_mb                = hiera('hadoop_config_mapreduce_task_io_sort_mb', $mapreduce_task_io_sort_mb) #512
  $hadoop_config_mapreduce_task_io_sort_factor            = hiera('hadoop_config_mapreduce_task_io_sort_factor', $mapreduce_task_io_sort_factor) #100
  $hadoop_config_mapreduce_reduce_shuffle_parallelcopies  = hiera('hadoop_config_mapreduce_reduce_shuffle_parallelcopies', 50)

  #TODO: Validate whether these are required
  $num_of_nodes = hiera('number_of_nodes')
  $hadoop_config_mapred_map_tasks_speculative_execution = hiera('hadoop_config_mapred_map_tasks_speculative_execution', true)
  if ($num_of_nodes > '2'){
    $mapred_parallel_copies_default = inline_template('<%= [Math.log(num_of_nodes) * 4].max.round %>')
  }
  else{
    $mapred_parallel_copies_default = '5'
  }
  $hadoop_config_mapred_reduce_parallel_copies = hiera('hadoop_config_mapred_reduce_parallel_copies', $mapred_parallel_copies_default)
  $hadoop_config_mapred_reduce_tasks_speculative_execution = hiera('hadoop_config_mapred_reduce_tasks_speculative_execution', false)
  $hadoop_config_tasktracker_http_threads = hiera('hadoop_config_tasktracker_http_threads', '64')
  $hadoop_config_use_map_compression = hiera('hadoop_config_use_map_compression', false)
  # default value is 0.05 can increase it to 0.8, put this value closer to 1 for faster networks and close to 0 for saturated networks
  $hadoop_config_mapred_reduce_slowstart_completed_maps = hiera('hadoop_config_mapred_reduce_slowstart_completed_maps', '0.05')
}