# == Class: nrpe
#
# Installs nagios nrpe service
#
# === Parameters
#
# [*nagiosserver*]
#	ip address of the nagios server
#
# [*nsostype*]
#	nagios server os type
#
# [*num_of_nodes*]
# required to calculate warning and critical values for hadoop scripts
#
# === Variables
#
# [*nrpeservice*]
#	Name of the nagios nrpe service
#
# [*nrpepattern*]
#	Name of the nagios nrpe pattern used to restart the service
#
# [*nrpepackage*]
#	Name of the nrpe package to be installed
#
# [*nrpedir*]
#	nrpe configuration directory path
#
# [*nagiosuser*]
#	nagios user name
#
# [*nagiosgroup*]
#	nagios group name
#
# [*pluginsdir*]
#	path where nagios will store the plugins
#
# [*sudopath*]
#	path where nagios binaries will be installed
#
# [*packages*]
#	array of packages to be installed on the nrpe server
#
# === Requires
#
# Nothing.
#
# === Sample Usage
#
# class { "nagios::nrpe":
#			nagiosserver => "ip_of_nagios_server",
#			nsostype	 => "CentOS",
#		}
# (or) include nagios::nrpe (if parameters are available through hiera)
#
# === Authors
#
# Ashrith <ashrith@cloudwick.com>
#
# === Copyright
#
# Copyright 2012 Cloudwick Technologies, unless otherwise noted.
#

class nagios::nrpe(
  $nagiosserver = hiera('nagios_server'),
  $nsostype = hiera('nagios_server_ostype'),
  $num_of_nodes = hiera('number_of_nodes'),
	) inherits nagios {
	#parameter1: nagiosserver -> nagios server ipaddress (req)
	#parameter2: nsostype -> nagios server os type (req) -> Ex: Centos|RedHat|Ubuntu
	include nagios::params
  #parametes required for monitoring hadoop daemons
  $warning_num_nodes = inline_template("<%= [num_of_nodes.to_i * 0.75].max.round %>")
  $critical_num_nodes = inline_template("<%= [num_of_nodes.to_i * 0.50].max.round %>")
  $ha = hiera('hadoop_ha')
  $mapreduce = hiera('mapreduce')
  $hbase = hiera('hbase_install')
  $hadoop_mapreduce_framework = $mapreduce['type']
  $namnode_host = hiera('hadoop_namenode')
  $second_namenode = inline_template("<%= namnode_host.to_a[1] %>")
  $slaves = hiera('slave_nodes')
  if ($ha == "disabled") {
    $secondarynamenode_host = hiera('hadoop_secondarynamenode')
  }
  if ($hadoop_mapreduce_framework == "mr1") {
    $jobtracker_host = $mapreduce['master_node']
  }
  if ($hbase == 'enabled') {
    $hbase_master = hiera('hbase_master')
  }
  if ($ha == "enabled") or ($hbase == "enabled") {
    $zookeepers = hiera('zookeeper_quorum')
  }
	case $operatingsystem {
		/RedHat|CentOS|Fedora/: {
		  $nrpeservice 	= "nrpe"
			$nrpepattern 	= "nrpe"
			$nrpepackage 	= "nrpe"
			$nrpedir 			= "/etc/nagios"
			$nagiosuser 	= "nagios"
			$nagiosgroup 	= "nagios"
			$pluginsdir 	= "/usr/lib64/nagios/plugins"
			$sudopath 		= "/usr/bin"
			$packages 		= [ 'nrpe', 'nagios-plugins-all', 'nagios-plugins-nrpe', 'openssl', 'nagios-plugins', 'xinetd' ]
		}
	  /Debian|Ubuntu/: {
   	  $nrpeservice  = "nagios-nrpe-server"
      $nrpepattern  = "nrpe"
      $nrpepackage  = "nagios-nrpe-server"
      $nrpedir      = "/etc/nagios"
      $nagiosuser   = "nagios"
      $nagiosgroup  = "nagios"
      $pluginsdir   = "/usr/lib/nagios/plugins"
      $sudopath     = "/usr/bin"
      $packages 	  = [ 'nagios-nrpe-plugin', 'nagios-nrpe-server' ]
	  }
	  default: {err ("operatingsystem $operatingsystem not yet implemented !")}
	}

 	package { $packages:
 		ensure => installed,
 	}

	file { "$nrpedir/nrpe.cfg":
    mode    => "644",
    owner   => $nagiosuser,
    group   => $nagiosgroup,
  	alias		=> "nrpe-config-file",
    content => template("nagios/nrpe.cfg.erb"),
    require => Package[$nrpepackage],
	}

#@BEGIN COMMENT ME!
  file { "$pluginsdir":
    recurse => true,
    owner   => "root",
    group   => "root",
    mode    => "0755",
    source  => "puppet:///modules/nagios/nagios-plugins",
    require => [ File["nrpe-config-file"], Package[$packages] ],
  }

  file { "/etc/sudoers.d/nagios_sudoers":
  	ensure => present,
  	owner => root,
  	group => root,
  	mode => 0440,
  	content => template("nagios/sudoers/redhat/sudoers_nagiosuser.erb"),
  }
#@END COMMENT ME!

	case $operatingsystem {
		/RedHat|CentOS|Fedora/: {
		file { "/etc/xinetd.d":
      ensure  => directory,
      owner   => "root",
      group   => "root",
      alias   => "xinetd-dir",
      require => Package["xinetd"],
		}

		file { "/etc/xinetd.d/nrpe":
      ensure  =>	present,
      mode    =>	"644",
      owner   =>	"root",
      group   =>	"root",
      content =>	template("nagios/nrpe.erb"),
      alias   =>	"nrpe-file",
      require =>	File["xinetd-dir"],
		}

		exec { "add-nrpe-services":
			command		=> "/bin/echo -e 'nrpe\t5666/tcp\t#NRPE' >> /etc/services",
			unless		=> "/bin/grep nrpe /etc/services 2>/dev/null",
			user			=> 'root',
			logoutput	=> true,
			require		=> Package["xinetd"],
		}

		# exec { "open-nrpe-port":
		# 	command		=> "/usr/bin/open port 5666/tcp",
		# 	user			=> 'root',
		# 	logoutput	=> true,
		# 	require		=> Exec["add-nrpe-services"],
		# }

		service { "xinetd":
			ensure		=> running,
			enable		=> true,
			subscribe => File["nrpe-file"],
			require 	=> [ Exec["add-nrpe-services"], File["nrpe-config-file", "nrpe-file"]],
		}

		# service { "$nrpeservice":
    # 	ensure    => running,
    # 	enable    => true,
    # 	pattern   => "$nrpepattern",
    # 	subscribe => File["$nrpedir/nrpe.cfg"],
		# 	require   => [Package[$nrpepackage], Service["xinetd"], File["nrpe-config-file","nrpe-file"]],
		# }
	}
		/Debian|Ubuntu/: {
			service { "$nrpeservice":
				ensure		=>	running,
				enable		=>	true,
				pattern		=>	"$nrpepattern",
				subscribe	=>	File["$nrpedir/nrpe.cfg"],
				require		=>	[ Package[$nrpepackage], File["nrpe-config-file"] ],
			}
		}
	}

	if $nsostype in [ "RedHat", "Fedora", "CentOS" ] {
		#Defaults
		Nagios_service {
			host_name	=>	$::fqdn,
			use 			=>	'generic-service-active',
			target    => "/etc/nagios/services/service-${::fqdn}.cfg",
			require		=>	Nagios_host["$::fqdn"],
		}

		#collect resources from hosts
	  	@@file { "/etc/nagios/services/service-${::fqdn}.cfg":
	  		ensure 	=> present,
	  		owner		=> "root",
	  		group 	=> "root",
	  		mode 		=> "0755",
	  		tag 		=>	"nagios-host-file",
	  	}

	  	@@nagios_host { $::fqdn:
		    ensure        => present,
		    alias         => $::hostname,
		    address       => $::ipaddress,
		    use           => "generic-host-active",
		    check_command => 'check-host-alive!3000.0,80%!5000.0,100%!10',
		    target        => "/etc/nagios/servers/nagios-host.cfg",
	  	}

	    @@nagios_hostextinfo { $::fqdn:
		    ensure          => present,
		    alias						=> $::hostname,
		    icon_image_alt  => $operatingsystem,
		    icon_image      => "base/$operatingsystem.png",
		    statusmap_image => "base/$operatingsystem.gd2",
		    target          => "/etc/nagios/servers/nagios-hostextinfo.cfg",
	    }

	    @@nagios_service { "check_ping_${::fqdn}":
		    check_command       => 'check_ping!100.0,20%!500.0,60%',
		    host_name           => $::fqdn,
		    service_description => 'Ping',
		    use                 => "generic-service-active",
		    target              => "/etc/nagios/services/service-${::fqdn}.cfg",
		    require							=> Nagios_host["$::fqdn"],
	    }
	}
	elsif $nsostype in [ "Ubuntu", "Debian" ] {
		#Defaults
		Nagios_service {
			host_name	=>	$::fqdn,
			use 			=>	'generic-service-active',
			target    => "/etc/nagios3/services/service-${::fqdn}.cfg",
			require		=>	Nagios_host["$::fqdn"],
		}

		#collect resources from hosts
	  	@@file { "/etc/nagios3/services/service-${::fqdn}.cfg":
	  		ensure 	=> present,
	  		owner		=> "root",
	  		group 	=> "root",
	  		mode 		=> "0755",
	  		tag 		=>	"nagios-host-file",
	  	}

	  	@@nagios_host { $::fqdn:
		    ensure        => present,
		    alias         => $::hostname,
		    address       => $::ipaddress,
		    use           => "generic-host-active",
		    check_command => 'check-host-alive!3000.0,80%!5000.0,100%!10',
		    target        => "/etc/nagios3/servers/nagios-host.cfg",
	  	}

	    @@nagios_hostextinfo { $::fqdn:
		    ensure          => present,
		    alias						=> $::hostname,
		    icon_image_alt  => $operatingsystem,
		    icon_image      => "base/$operatingsystem.png",
		    statusmap_image => "base/$operatingsystem.gd2",
		    target          => "/etc/nagios3/servers/nagios-hostextinfo.cfg",
	    }

	    @@nagios_service { "check_ping_${::fqdn}":
		    check_command       => 'check_ping!100.0,20%!500.0,60%',
		    host_name           => $::fqdn,
		    service_description => 'Ping',
		    use                 => "generic-service-active",
		    target              => "/etc/nagios3/services/service-${::fqdn}.cfg",
		    require							=> Nagios_host["$::fqdn"],
	    }
	}
	else {
		err ("operatingsystem $nsostype not valid, please change the parameter value.")
	}

    # Plugins common to all clients

    @@nagios_service{ "check_load_${::fqdn}":
    	check_command				=>	'check_nrpe!check_load!2.0,2.0,0.9 2.0,2.0,1.0',
    	service_description	=>	'Load',
    }

    @@nagios_service{ "check_swap_${::fqdn}":
    	check_command				=>	'check_nrpe!check_swap!20% 10%',
    	service_description	=>	'Swap',
    }

    @@nagios_service{ "check_users_${::fqdn}":
    	check_command				=>	'check_nrpe!check_users',
    	service_description	=>	'Users',
    }

    @@nagios_service{ "check_root_partition_${::fqdn}":
    	check_command				=>	'check_nrpe!check_rootpart',
    	service_description	=>	'Root Partition',
    }

    @@nagios_service{ "check_total_procs_${::fqdn}":
    	check_command				=>	'check_nrpe!check_total_procs',
    	service_description	=>	'Total Processes',
    }

    @@nagios_service{ "check_zombie_procs_${::fqdn}":
    	check_command				=>	'check_nrpe!check_zombie_procs',
    	service_description	=>	'Zombie Processes',
    }

    # Plugins related to hadoop

    if $::fqdn in $slaves {
      @@nagios_service{ "check_datanode_${::fqdn}":
        check_command => 'check_nrpe!check_dn_status',
        service_description =>  'HDFS Datanode Status',
      }
      @@nagios_service{ "check_tasktracker_${::fqdn}":
        check_command => 'check_nrpe!check_tt_status',
        service_description =>  'MapReduce TaskTracker Status',
      }
    }

    if ($ha == "disabled") {
      if ($::fqdn == $secondarynamenode_host) {
        @@nagios_service{ "check_snn_health_${::fqdn}":
          check_command       =>  'check_nrpe!check_snn_status',
          service_description =>  'HDFS SecondaryNameNode Status',
        }
      }
      #TODO monitor journal nodes count
    }
    else {
      # check hadoop_hdfs status from first namenode only
      if ($::fqdn == inline_template("<%= namnode_host.to_a[0] %>")) {
        @@nagios_service{ "check_hadoop_dfs_${::fqdn}":
          check_command       =>  'check_nrpe!check_hadoop_dfs',
          service_description =>  'HDFS Datanodes Status',
        }
      }
      if $::fqdn in $hadoop_namenode {
        @@nagios_service{ "check_nn_health_${::fqdn}":
          check_command       =>  'check_nrpe!check_nn_health',
          service_description =>  'HDFS NameNode Health Status',
        }
      }
      #ha does not require snn
      #make sure to purge snn service if exists
      @@nagios_service{ "check_snn_health_${::fqdn}":
        check_command       =>  'check_nrpe!check_snn_status',
        service_description =>  'HDFS SecondaryNameNode Status',
        ensure => absent,
      }
    }
    if ($::fqdn == $jobtracker_host) {
      @@nagios_service{ "check_jt_status_${::fqdn}":
        check_command       =>  'check_nrpe!check_jt_status',
        service_description =>  'Hadoop Jobtracker Status',
      }
      @@nagios_service{ "check_mr_tts_${::fqdn}":
        check_command       =>  'check_nrpe!check_mr_tts',
        service_description =>  'MapReduce TaskTrackers Status',
      }
    }

    # Plugins related to hbase

    if ($hbase == 'enabled') {
      if($::fqdn == inline_template("<%= hbase_master.to_a[0] %>")) {
        @@nagios_service{ "check_hbase_${::fqdn}":
          check_command => 'check_nrpe!check_hbase_status',
          service_description =>  'HBase RegionServers Status',
        }
      }
      if $::fqdn in $hbase_master {
        @@nagios_service{ "check_hmaster_daemon_${::fqdn}":
          check_command => 'check_nrpe!check_hmaster_daemon',
          service_description =>  'HBase Master Status',
        }
      }
      if $::fqdn in $slaves {
        @@nagios_service{ "check_regionserver_${::fqdn}":
          check_command => 'check_nrpe!check_regionserver_status',
          service_description =>  'HBase RegionServer Status',
        }
      }
    }

    # Zookeepers Daemons count
    if ($hbase == "enabled") {
      #monitor zks port from hbasemaster
      if($::fqdn == inline_template("<%= hbase_master.to_a[0] %>")) {
        @@nagios_service{ "check_zks_status_${::fqdn}":
          check_command       =>  'check_nrpe!check_zk_status',
          service_description =>  'Zookeepers Status',
        }
        @@nagios_service{ "check_hbase_onlineregions_${::fqdn}":
          check_command       =>  'check_nrpe60!check_hbase_onlineregions',
          service_description =>  'HBase Online Regions per RS',
        }
      }
    } elsif ($ha == "enabled") {
      if ($::fqdn == inline_template("<%= namnode_host.to_a[0] %>")) {
        @@nagios_service{ "check_zks_status_${::fqdn}":
          check_command       =>  'check_nrpe!check_zk_status',
          service_description =>  'Zookeepers Status',
        }
      }
    }

    #Zookeepers daemons
    if ($ha == "enabled") or ($hbase == "enabled") {
      if $::fqdn in $zookeepers {
        # check zookeeper process
        @@nagios_service{ "check_zks_daemon_${::fqdn}":
          check_command       =>  'check_nrpe!check_zk_daemon',
          service_description =>  'Zookeepers Daemon Status',
        }
      }
    }

} #end of file