class nagios::target inherits nagios {
	include nagios::params

	#TODO: ADD more services, remote services

	@@file { "${nagios::params::rootdir}/services/service-${::fqdn}.cfg":
		ensure 	=> present,
		owner	=> "root",
		group 	=> "root",
		mode 	=> "0755",
		tag 	=>	"nagios-host-file",
	}

	@@nagios_host { $::fqdn:
    ensure        => present,
    alias         => $::hostname,
    address       => $::ipaddress,
    use           => "generic-host-active",
    check_command => 'check-host-alive!3000.0,80%!5000.0,100%!10',
    target        => "${nagios::params::rootdir}/servers/nagios-host.cfg",
	}

  @@nagios_hostextinfo { $::fqdn:
    ensure          => present,
    alias			      => $::hostname,
    icon_image_alt  => $operatingsystem,
    icon_image      => "base/$operatingsystem.png",
    statusmap_image => "base/$operatingsystem.gd2",
    target          => "${nagios::params::rootdir}/servers/nagios-hostextinfo.cfg",
  }

  @@nagios_service { "check_ping_${::fqdn}":
    check_command       => 'check_ping!100.0,20%!500.0,60%',
    host_name           => $::fqdn,
    service_description => 'Ping',
    use                 => "generic-service-active",
    target              => "${nagios::params::rootdir}/services/service-${::fqdn}.cfg",
    require				=> Nagios_host["$::fqdn"],
  }
}