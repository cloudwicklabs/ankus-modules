# == Class kafka
# Installs Kafka package and sets up configs for clients (producer & consumer).
#
# == Parameters:
#   kafka::params
#
# == Requires
#   java
#   zookeeper
#
# == Usage:
#
# # Install the kafka package and configure kafka.
# class { 'kafka':
#     hosts => {
#         'kafka-node01.domain.org' => { 'id' => 1, 'port' => 12345 },
#         'kafka-node02.domain.org' => { 'id' => 2 },
#     },
#     zookeeper_hosts => ['zk-node01:2181', 'zk-node02:2181', 'zk-node03:2181'],
# }
#
# If data is available from hiera
# include kafka
#
# To install kafka server service
# include kafka::server
#
class kafka inherits kafka::params {

  require utilities::packages

  #Params for populating ERb
  $hosts          = $kafka::params::hosts
  $kafka_log_file = $kafka::params::kafka_log_file
  $zookeeper_hosts = $kafka::params::zookeeper_hosts
  $zookeeper_connection_timeout_ms = $kafka::params::zookeeper_connection_timeout_ms
  $consumer_group_id = $kafka::params::consumer_group_id
  $producer_type = $kafka::params::producer_type
  $producer_batch_num_messages = $kafka::params::producer_batch_num_messages

  group { "kafka":
    ensure => present,
    system => true
  }

  user { "kafka":
    comment => "Kafka Daemon User",
    home    => "${kafka::params::kafka_base}/kafka-${kafka::params::kafka_version}",
    ensure  => present,
    shell   => "/bin/bash",
    system  => true,
    gid     => "kafka",
    require => Group["kafka"]
  }

  file { "${kafka::params::kafka_pkgs_home}/kafka-${kafka::params::kafka_version}.tgz":
    mode    => 0644,
    owner   => kafka,
    group   => kafka,
    source  => "puppet:///modules/${module_name}/kafka-${kafka::params::kafka_version}.tgz",
    alias   => "kafka-source-tgz",
    before  => Exec["untar-kafka"],
    require => File["${kafka::params::kafka_pkgs_home}"]
  }

  exec { "untar kafka-${kafka::params::kafka_version}.tgz":
    command     => "/bin/tar -xzf ${kafka::params::kafka_pkgs_home}/kafka-${kafka::params::kafka_version}.tgz -C ${kafka::params::kafka_pkgs_base} && chown -R kafka:kafka kafka-${kafka::params::kafka_version}",
    cwd         => "${kafka::params::kafka_pkgs_base}",
    creates     => "${kafka::params::kafka_pkgs_base}/kafka-${kafka::params::kafka_version}",
    alias       => "untar-kafka",
    refreshonly => true,
    subscribe   => File["kafka-source-tgz"],
    before      => File["kafka-app-dir"]
  }

  file { "${kafka::params::kafka_pkgs_base}/kafka":
    ensure  => "link",
    target  => "${kafka::params::kafka_pkgs_base}/kafka-${kafka::params::kafka_version}",
    mode    => 0644,
    owner   => "kafka",
    group   => "kafka",
    alias   => "kafka-app-dir"
  }

  file { "/etc/kafka":
    ensure  => directory,
    owner   => "kafka",
    group   => "kafka",
    require => File["kafka-app-dir"]
  }

  file { "/etc/kafka/config":
    ensure  => link,
    target  => "${kafka::params::kafka_pkgs_base}/kafka-${kafka::params::kafka_version}/config",
    owner   => "kafka",
    group   => "kafka",
    alias   => "kafka-conf-dir",
    require => File["/etc/kafka"]
  }

  file { '/etc/kafka/config/producer.properties':
    content => template("kafka/producer.properties.erb"),
    require => File["kafka-conf-dir"],
  }

  file { '/etc/kafka/config/consumer.properties':
    content => template("kafka/consumer.properties.erb"),
    require => File["kafka-conf-dir"],
  }

  file { '/etc/kafka/config/log4j.properties':
    content => template("kafka/log4j.properties.erb"),
    require => File["kafka-conf-dir"],
  }
}