# Class: hadoop::params::hue
#
#
class hadoop::params::hue inherits hadoop::params::default {

  $hadoop_oozie_url = "http://localhost:11000/oozie"
  $hadoop_hue_host = hiera('hadoop_hue_host', '0.0.0.0')
  $hadoop_hue_port = hiera('hadoop_hue_port', "8888")
  $hadoop_controller = hiera('controller')
  $hadoop_security_authentication = $hadoop::params::default::hadoop_security_authentication
  $default_fs = $hadoop::params::default::hadoop_namenode_uri

  $first_namenode = inline_template("<%= @hadoop_namenode_host.to_a[0] %>")
}