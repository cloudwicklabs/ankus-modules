# Class: jmxtrans::params
#
#
class jmxtrans::params {
  include java::params
  $java_home = inline_template("<%= scope.lookupvar('java::params::java_base') %>/jdk<%= scope.lookupvar('java::params::java_version') %>")
  $heap_size = hiera('jmxtrans_heap_size', 512)
  $heap_newgen_size = hiera('jmxtrans_heap_newgen_size', 64)
  $cpu_cores = hiera('jmxtrans_cpu_cores', 1)
  $new_ratio = hiera('jmxtrans_new_ratio', 8)
  $seconds_between_run = hiera('jmxtrans_seconds_between_run', 60)
  $json_dir = hiera('jmxtrans_json_dir', '/var/lib/jmxtrans')
  $redhat_version = "20121016.145842.6a28c97fbb-0"
  $debian_version = "20121016-175251-ab6cfd36e3-1"
}
