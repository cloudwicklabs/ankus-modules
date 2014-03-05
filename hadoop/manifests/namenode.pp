# == Class: hadoop::namenode
#
# Installs and manges hadoop namenode daemon in both ha and non-ha mode
#
# === Parameters
#
# None
#
# === Variables
#
# None
#
# === Examples
#
# include hadoop::namenode
#
# === Authors
#
# Ashrith <ashrith@cloudwick.com>
#
# === Copyright
#
# Copyright 2012 Cloudwick Inc, unless otherwise noted.
#
class hadoop::namenode inherits hadoop::common_hdfs {
  require hadoop::common_hdfs

  $first_namenode = inline_template('<%= @hadoop_namenode_host.to_a[0] %>')

  if ($hadoop::params::default::ha != 'disabled')
  {
    file { $hadoop::params::hdfs::sshfence_keydir:
      ensure  => directory,
      owner   => 'hdfs',
      group   => 'hdfs',
      mode    => '0700',
      require => [
                    Package['hadoop-hdfs-namenode'],
                    File[$hadoop::params::hdfs::sshfence_user_home]
                  ]
    }

    file { $hadoop::params::hdfs::sshfence_user_home:
      owner   => 'hdfs',
      group   => 'hdfs',
      mode    => '0700',
      require => Package['hadoop-hdfs-namenode'],
    }

    file { $hadoop::params::hdfs::sshfence_keypath:
      source  => 'puppet:///modules/hadoop/id_rsa',
      owner   => 'hdfs',
      group   => 'hdfs',
      mode    => '0600',
      before  => Service['hadoop-hdfs-namenode'],
      require => File[$hadoop::params::hdfs::sshfence_keydir],
    }

    file { "${hadoop::params::hdfs::sshfence_keydir}/authorized_keys":
      source  => 'puppet:///modules/hadoop/id_rsa.pub',
      owner   => 'hdfs',
      group   => 'hdfs',
      mode    => '0600',
      before  => Service['hadoop-hdfs-namenode'],
      require => File[$hadoop::params::hdfs::sshfence_keydir],
    }
  }

  package { 'hadoop-hdfs-namenode':
    ensure  => latest,
    require => Package['hadoop-hdfs']
  }

  # required for running jobs from namenode
  package { 'hadoop-client':
    ensure  => latest,
    require => Package['hadoop-hdfs-namenode'],
  }

  hadoop::create_dir_with_perm { $hadoop::params::default::namenode_data_dirs:
    user    => 'hdfs',
    group   => 'hdfs',
    mode    => 700,
    require => Package['hadoop-hdfs-namenode']
  }

  service { 'hadoop-hdfs-namenode':
    ensure    => running,
    hasstatus => true,
    subscribe => [
                    Package['hadoop-hdfs-namenode'],
                    File['/etc/hadoop/conf/core-site.xml'],
                    File['/etc/hadoop/conf/hdfs-site.xml'],
                    File['/etc/hadoop/conf/hadoop-env.sh']
                  ],
    require   => [
                    Package['hadoop-hdfs-namenode'],
                    Hadoop::Create_dir_with_perm[$hadoop::params::default::namenode_data_dirs]
                  ],
  }

  if($hadoop::params::default::hadoop_security_authentication == 'kerberos') {
    include hadoop::kinit
    Exec['HDFS kinit'] -> Exec <| tag == 'namenode-format' |> -> Service['hadoop-hdfs-namenode']
  }
  else {
    Exec <| tag == 'namenode-format' |> -> Service['hadoop-hdfs-namenode']
  }

  if ($hadoop::params::default::hadoop_security_authentication == 'kerberos') {
    file { '/etc/default/hadoop-hdfs-namenode':
      content => template('hadoop/hadoop-hdfs.erb'),
      require => [
                    Package['hadoop-hdfs-namenode'],
                    Kerberos::Host_keytab['hdfs']
                  ]
    }
  }

  if ($hadoop::params::default::ha != 'disabled') {
    package { 'hadoop-hdfs-zkfc':
      ensure  => latest,
      require => Package['hadoop-hdfs'],
    }

    service { 'hadoop-hdfs-zkfc':
      ensure    => running,
      hasstatus => true,
      subscribe => [
                      Package['hadoop-hdfs-zkfc'],
                      File['/etc/hadoop/conf/core-site.xml'],
                      File['/etc/hadoop/conf/hdfs-site.xml'],
                      File['/etc/hadoop/conf/hadoop-env.sh']
                    ],
      require   => Package['hadoop-hdfs-zkfc'],
    }

    if($hadoop::params::default::hadoop_security_authentication == 'kerberos') {
      include hadoop::kinit
      Exec['HDFS kinit'] -> Service <| title == 'hadoop-hdfs-zkfc' |> -> Service <| title == 'hadoop-hdfs-namenode' |>
    }
    else {
      Service <| title == 'hadoop-hdfs-zkfc' |> -> Service <| title == 'hadoop-hdfs-namenode' |>
    }

    logstash::lumberjack_conf { 'zkfc':
      logstash_host => $hadoop::params::default::logstash_server,
      logstash_port => 5672,
      daemon_name   => 'lumberjack_zkfc',
      field         => "hdfs-zkfc-${::fqdn}",
      logfiles      => ['/var/log/hadoop-hdfs/hadoop*zkfc*.log'],
      require       => Service['hadoop-hdfs-zkfc']
    }
  }

  #configuration specific to active namenode
  if ($::fqdn == $first_namenode) {
    exec { 'namenode format':
      user      => 'hdfs',
      command   => '/bin/bash -c \'yes Y | hdfs namenode -format >> /var/lib/hadoop-hdfs/nn.format.log 2>&1\'',
      creates   => "${namenode_data_dirs[0]}/current/VERSION",
      group     => 'hadoop',
      logoutput => true,
      require   => [
                      Package['hadoop-hdfs-namenode'],
                      Hadoop::Create_dir_with_perm[$hadoop::params::default::namenode_data_dirs],
                      File['/etc/hadoop/conf/hdfs-site.xml']
                    ],
      tag       => 'namenode-format',
    }
    #automatic ha failover
    if ($hadoop::params::default::ha != 'disabled') {
      exec { 'namenode zk format':
        user    => 'hdfs',
        command => '/bin/bash -c \'yes N | hdfs zkfc -formatZK >> /var/lib/hadoop-hdfs/zk.format.log 2>&1 || :\'',
        require => [ Package['hadoop-hdfs-zkfc'], File['/etc/hadoop/conf/hdfs-site.xml'] ],
        tag     => 'namenode-format',
      }
      #Refactor: this is req when upgrading a cluster from non-ha to ha
      if ($::fqdn == $first_namenode and $hadoop::params::default::upgradetoha == true) {
        exec { 'stop namenode':
          user    => root,
          command => '/sbin/service hadoop-hdfs-namenode stop',
          tag     => 'stop-namenode',
        }
        exec { 'upgrade to ha':
          user      => 'root',
          command   => '/bin/bash -c \'yes Y | hdfs namenode -initializeSharedEdits >> /var/lib/hadoop-hdfs/nn.upgradetoha.log 2>&1\'',
          logoutput => true,
          # require => Exec["stop namenode"],
          tag       => 'upgrade-to-ha',
        }
      }
      Service <| title == 'zookeeper-server' |> -> Exec <| title == 'namenode zk format' |>
      Exec <| title == 'namenode zk format' |>  -> Service <| title == 'hadoop-hdfs-zkfc' |>
      if ( $::fqdn == $first_namenode and $hadoop::params::default::upgradetoha == true ) {
        Exec <| title == 'stop-namenode' |> -> Exec <| title == 'upgrade-to-ha' |> -> Service <| title == 'hadoop-hdfs-zkfc' |>
      }
    }
  }
  #for standby namenode copy active namenode metadata
  elsif ($::fqdn != $first_namenode) {
    hadoop::namedir_copy { $hadoop::params::default::namenode_data_dirs:
      source       => $first_namenode,
      ssh_identity => $hadoop::params::hdfs::sshfence_keypath,
      require      => [
                        File[$hadoop::params::hdfs::sshfence_keypath],
                        Hadoop::Create_dir_with_perm[$hadoop::params::default::namenode_data_dirs]
                      ],
    }
  }

  # file { $namenode_data_dirs:
  #   ensure => directory,
  #   owner => hdfs,
  #   group => hdfs,
  #   mode => 700,
  #   require => [Package["hadoop-hdfs-namenode"], Exec["create-root-dir"]],
  # }

  #creating hdfs directories required for all services
  if ($::fqdn == $first_namenode) {
    if ($hadoop::params::default::hadoop_mapreduce != 'disabled') {
      if ($hadoop::params::default::hadoop_mapreduce_framework == 'mr1') {
        hadoop::create_hdfs_dirs { [ '/mapred', '/tmp', '/system', '/user', '/hbase', '/benchmarks', '/user/hive', '/user/root', '/user/history', '/user/hue', '/user/oozie', '/solr' ]:
          auth           => hiera('security'),
          hdfs_dirs_meta => {
                              '/tmp'             => { perm => '777', user => 'hdfs'   },
                              '/mapred'          => { perm => '755', user => 'mapred' },
                              '/mapred/system'   => { perm => '755', user => 'mapred' },
                              '/system'          => { perm => '755', user => 'hdfs'   },
                              '/user'            => { perm => '755', user => 'hdfs'   },
                              '/hbase'           => { perm => '755', user => 'hbase'  },
                              '/benchmarks'      => { perm => '777', user => 'hdfs'   },
                              '/user/history'    => { perm => '777', user => 'mapred' },
                              '/user/root'       => { perm => '755', user => 'root'   },
                              '/user/hive'       => { perm => '755', user => 'hive'   },
                              '/user/oozie'      => { perm => '755', user => 'oozie'  },
                              '/user/hue'        => { perm => '755', user => 'hue'    },
                              '/solr'            => { perm => '755', user => 'solr'   },
                            },
        }
      }
      elsif ($hadoop::params::default::hadoop_mapreduce_framework == 'mr2') {
        hadoop::create_hdfs_dirs { [ '/tmp', '/user', '/hbase', '/benchmarks', '/user/hive', '/user/root', '/user/history', '/user/hue', '/user/oozie', '/var', '/var/log', '/var/log/hadoop-yarn', '/solr' ]:
          auth           => hiera('security'),
          hdfs_dirs_meta => {
                              '/tmp'                  => { perm => '1777', user => 'hdfs' },
                              '/user'                 => { perm => '755', user => 'hdfs'  },
                              '/hbase'                => { perm => '755', user => 'hbase' },
                              '/benchmarks'           => { perm => '777', user => 'hdfs'  },
                              '/user/history'         => { perm => '777', user => 'yarn'  },
                              '/user/root'            => { perm => '755', user => 'root'  },
                              '/user/hive'            => { perm => '755', user => 'hive'  },
                              '/user/oozie'           => { perm => '755', user => 'oozie' },
                              '/user/hue'             => { perm => '755', user => 'hue'   },
                              '/var'                  => { perm => '755', user => 'yarn'  },
                              '/var/log'              => { perm => '755', user => 'yarn'  },
                              '/var/log/hadoop-yarn'  => { perm => '755', user => 'yarn'  },
                              '/solr'                 => { perm => '755', user => 'solr'  },
                            },
        }
      }
    }
  }

  #log_stash
  if ($hadoop::params::default::log_aggregation == 'enabled') {
    #require logstash::lumberjack_def
    logstash::lumberjack_conf { 'namenode':
      logstash_host => $hadoop::params::default::logstash_server,
      logstash_port => 5672,
      daemon_name   => 'lumberjack_namenode',
      field         => "namenode-${::fqdn}",
      logfiles      => ['/var/log/hadoop-hdfs/hadoop-hdfs-namenode*.log'],
      require       => Service['hadoop-hdfs-namenode']
    }
  }
}
