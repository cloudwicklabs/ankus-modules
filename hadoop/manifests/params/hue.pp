# Class: hadoop::params::hue
#
#
class hadoop::params::hue inherits hadoop::params::default {

  $hadoop_oozie_url = "http://localhost:11000/oozie"
  $hadoop_hue_host = hiera('hadoop_hue_host', '0.0.0.0')
  $hadoop_hue_port = hiera('hadoop_hue_port', "8888")
  $hadoop_controller = hiera('controller')
  $hadoop_security_authentication = $hadoop::params::default::hadoop_security_authentication
}