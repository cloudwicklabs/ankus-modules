# Class: hadoop::params::oozie
#
#
class hadoop::params::oozie inherits hadoop::params::default {
  $hadoop_controller = hiera('controller')
  $jobtracker        = $hadoop::params::default::hadoop_mapreduce['master']
}