#Sample Usage:
# if all values are specified in hiera
#   include hadoop::namenode

class hadoop::namenode (
  $hadoop_namenode_host = hiera('hadoop_namenode', "$fqdn"),
  $hadoop_namenode_port = hiera('hadoop_namenode_port', 8020),
  $hadoop_security_authentication = hiera('security', 'simple'),
  $data_dirs = hiera('hadoop_data_dirs', ['/tmp/data']),
  $ha = hiera('hadoop_ha','disabled'),
  $zk = hiera('zookeeper_ensemble',''),
  $jn = hiera('journal_quorum', ''),
  ) inherits hadoop::common-hdfs{

    $first_namenode = inline_template("<%= hadoop_namenode_host.to_a[0] %>")

    if ($ha != 'disabled')
    {
      file { $sshfence_keydir:
        ensure  => directory,
        owner   => 'hdfs',
        group   => 'hdfs',
        mode    => '0700',
        require => [ Package["hadoop-hdfs-namenode"], File[$sshfence_user_home]],
      }

      file { $sshfence_user_home:
        owner => 'hdfs',
        group => 'hdfs',
        mode => '0700',
        require => Package["hadoop-hdfs-namenode"],
      }

      file { $sshfence_keypath:
        source  => "puppet:///modules/hadoop/id_rsa",
        owner   => 'hdfs',
        group   => 'hdfs',
        mode    => '0600',
        before  => Service["hadoop-hdfs-namenode"],
        require => File[$sshfence_keydir],
      }

      file { "$sshfence_keydir/authorized_keys":
        source  => "puppet:///modules/hadoop/id_rsa.pub",
        owner   => 'hdfs',
        group   => 'hdfs',
        mode    => '0600',
        before  => Service["hadoop-hdfs-namenode"],
        require => File[$sshfence_keydir],
      }
    }

    package { "hadoop-hdfs-namenode":
      ensure => latest,
      require => Package["hadoop-hdfs"],
    }

    #this package is required to run jobs from namenode
    package { "hadoop-client":
      ensure => latest,
      require => Package["hadoop-hdfs-namenode"],
    }

    service { "hadoop-hdfs-namenode":
      ensure => running,
      hasstatus => true,
      subscribe => [Package["hadoop-hdfs-namenode"], File["/etc/hadoop/conf/core-site.xml"], File["/etc/hadoop/conf/hdfs-site.xml"], File["/etc/hadoop/conf/hadoop-env.sh"]],
      require => [Package["hadoop-hdfs-namenode"]],
    }
    #********************
    #TODO: namenode format requires kinit -k -t hdfs.keytab hdfs/fully.qualified.domain.name@YOUR- REALM.COM
    #CHECK IF THIS WORKS
    if($hadoop_security_authentication == "kerberos") {
        include hadoop::kinit
        Exec["HDFS kinit"] -> Exec <| tag == "namenode-format" |> -> Service["hadoop-hdfs-namenode"]
    }
    else {
        Exec <| tag == "namenode-format" |> -> Service["hadoop-hdfs-namenode"]
    }

    if ($hadoop_security_authentication == "kerberos") {
      file {
        "/etc/default/hadoop-hdfs-namenode":
         content => template('hadoop/hadoop-hdfs.erb'),
         require => [Package["hadoop-hdfs-namenode"], Kerberos::Host_keytab["hdfs"]],
      }
    }

    if ($ha != "disabled") {
      package { "hadoop-hdfs-zkfc":
        ensure => latest,
        require => Package["hadoop-hdfs"],
      }

      service { "hadoop-hdfs-zkfc":
        ensure => running,
        hasstatus => true,
        subscribe => [Package["hadoop-hdfs-zkfc"], File["/etc/hadoop/conf/core-site.xml"], File["/etc/hadoop/conf/hdfs-site.xml"], File["/etc/hadoop/conf/hadoop-env.sh"]],
        require => [Package["hadoop-hdfs-zkfc"]],
      }
      #CHECK IF THIS WORKS
      if($hadoop_security_authentication == "kerberos") {
        include hadoop::kinit
        Exec["HDFS kinit"] -> Service <| title == "hadoop-hdfs-zkfc" |> -> Service <| title == "hadoop-hdfs-namenode" |>
      }
      else {
      Service <| title == "hadoop-hdfs-zkfc" |> -> Service <| title == "hadoop-hdfs-namenode" |>
      }
    }

    #configuration specific to namenode1
    if ($::fqdn == $first_namenode) {
      exec { "namenode format":
        user => "hdfs",
        command => "/bin/bash -c 'yes Y | hdfs namenode -format >> /var/lib/hadoop-hdfs/nn.format.log 2>&1'",
        creates => "${namenode_data_dirs[0]}/current/VERSION",
        group => 'hadoop',
        logoutput => true,
        require => [ Package["hadoop-hdfs-namenode"], File[$namenode_data_dirs], File["/etc/hadoop/conf/hdfs-site.xml"] ],
        tag     => "namenode-format",
      }
      #automatic ha failover
      if ($ha != "disabled") {
        exec { "namenode zk format":
          user => "hdfs",
          command => "/bin/bash -c 'yes N | hdfs zkfc -formatZK >> /var/lib/hadoop-hdfs/zk.format.log 2>&1 || :'",
          require => [ Package["hadoop-hdfs-zkfc"], File["/etc/hadoop/conf/hdfs-site.xml"] ],
          tag     => "namenode-format",
        }
        #Refactor: this is req when upgrading a cluster from non-ha to ha
        if ($::fqdn == $first_namenode and $upgradetoha == "true") {
          exec { "stop namenode":
            user => root,
            command => "/sbin/service hadoop-hdfs-namenode stop",
            tag => "stop-namenode",
          }
          exec { "upgrade to ha":
            user => "root",
            command => "/bin/bash -c 'yes Y | hdfs namenode -initializeSharedEdits >> /var/lib/hadoop-hdfs/nn.upgradetoha.log 2>&1'",
            logoutput => true,
            # require => Exec["stop namenode"],
            tag => "upgrade-to-ha",
          }
        }
        Service <| title == "zookeeper-server" |> -> Exec <| title == "namenode zk format" |>
        Exec <| title == "namenode zk format" |>  -> Service <| title == "hadoop-hdfs-zkfc" |>
        if ( $::fqdn == $first_namenode and $upgradetoha == "true" ) {
          Exec <| title == "stop-namenode" |> -> Exec <| title == "upgrade-to-ha" |> -> Service <| title == "hadoop-hdfs-zkfc" |>
        }
      }
    }
    #for standby namenode copy active namenode metadata
    elsif ($::fqdn != $first_namenode) {
      hadoop::namedir_copy { $namenode_data_dirs:
        source       => $first_namenode,
        ssh_identity => $sshfence_keypath,
        require      => [File[$sshfence_keypath], File[$namenode_data_dirs]],
      }
    }

    file { $namenode_data_dirs:
      ensure => directory,
      owner => hdfs,
      group => hdfs,
      mode => 700,
      require => [Package["hadoop-hdfs-namenode"], Exec["create-root-dir"]],
    }

    #Becuase of Bug HDFS-3752
    define hadoop::namedir_copy ($source, $ssh_identity) {
      exec { "copy namedir $title from first namenode":
        command => "/usr/bin/rsync -avz -e '/usr/bin/ssh -oStrictHostKeyChecking=no -i $ssh_identity' '${source}:$title/' '$title/'",
        user    => "hdfs",
        tag     => "namenode-format",
        creates => "$title/current/VERSION",
      }
    }

    define hadoop::create_hdfs_dirs($hdfs_dirs_meta, $auth="simple") {
      $user = $hdfs_dirs_meta[$title][user]
      $perm = $hdfs_dirs_meta[$title][perm]

      #for security
      if ($auth == "kerberos") {
        include hadoop::kinit
        Exec["HDFS kinit"] -> Exec["HDFS init $title"]
      }

      exec { "HDFS init $title":
        user => "hdfs",
        command => "/bin/bash -c 'hadoop fs -mkdir $title && hadoop fs -chmod $perm $title && hadoop fs -chown $user $title'",
        unless => "/bin/bash -c 'hadoop fs -ls $name >/dev/null 2>&1'",
        require => Service["hadoop-hdfs-namenode"],
      }
      Exec <| title == "activate nn1" |>  -> Exec["HDFS init $title"]
    }

    #creating hdfs directories required for all services
    if ($::fqdn == $first_namenode) {
      hadoop::create_hdfs_dirs { [ "/mapred", "/tmp", "/system", "/user", "/hbase", "/benchmarks", "/user/hive", "/user/root", "/user/history", "/user/hue", "/user/oozie", "/tmp/hadoop-mapred", "/tmp/hadoop-mapred/mapred", "/tmp/hadoop-mapred/mapred/staging" ]:
        auth           => hiera('security'),
        hdfs_dirs_meta => { "/tmp"                              => { perm => "777", user => "hdfs"   },
                            "/mapred"                           => { perm => "755", user => "mapred" },
                            "/mapred/system"                    => { perm => "755", user => "mapred" },
                            "/system"                           => { perm => "755", user => "hdfs"   },
                            "/user"                             => { perm => "755", user => "hdfs"   },
                            "/hbase"                            => { perm => "755", user => "hbase"  },
                            "/benchmarks"                       => { perm => "777", user => "hdfs"   },
                            "/user/jenkins"                     => { perm => "777", user => "jenkins"},
                            "/user/history"                     => { perm => "777", user => "mapred" },
                            "/user/root"                        => { perm => "777", user => "root"   },
                            "/user/hive"                        => { perm => "777", user => "hive"   },
                            "/user/oozie"                       => { perm => "777", user => "oozie"  },
                            "/user/hue"                         => { perm => "777", user => "hue"    },
                            "/tmp/hadoop-mapred"                => { perm => "777", user => "hdfs"   },
                            "/tmp/hadoop-mapred/mapred"         => { perm => "777", user => "hdfs"   },
                            "/tmp/hadoop-mapred/mapred/staging" => { perm => "777", user => "hdfs"   },
                          },
        }
    }

  #log_stash
  if ($log_aggregation == 'enabled') {
    #require logstash::lumberjack_def
    logstash::lumberjack_conf { 'namenode':
      logstash_host => $logstash_server,
      logstash_port => 5672,
      daemon_name => 'lumberjack_namenode',
      field => "namenode-${::fqdn}",
      logfiles => ['/var/log/hadoop-hdfs/hadoop-hdfs-namenode*.log'],
      require => Service['hadoop-hdfs-namenode']
    }
  }
 }