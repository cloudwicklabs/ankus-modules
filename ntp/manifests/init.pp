# == Class: ntp
#
# This class installs/configures/manages NTP. Only supported on Debian-derived and Red Hat-derived Oses.
#
# === Parameters
#
# [*servers*]
#   An array of NTP servers, with or without +iburst+ and
#   +dynamic+ statements appended. Defaults to the OS's defaults.
#
# [*enable*]
#	Whether to start the NTP service on boot. Defaults to true.
#	Valid values: true and false.
#
# [*ensure*]
#	Whether to run the NTP service. Defaults to running. 
#	Valid values: running and stopped
#
# === Requires
#
# Nothing.
#
# === Example Usage
#
#  class { 'ntp':
#    servers => [ "ntp1.example.com dynamic",
#				  "ntp2.example.com dynamic", ],
#  }
#
#  class {'ntp':
#		enable => false,
#		ensure => running,
#	}
#

class ntp ($servers = undef, $enable = true, $ensure = running) {
	case $operatingsystem {
		centos, redhat: {
			$service_name = 'ntpd'
			#$conf_file = 'ntp.conf.el' 
			$conf_template = 'ntp.conf.el.erb'
			$default_servers = [ "0.centos.pool.ntp.org",
								 "1.centos.pool.ntp.org",
								 "2.centos.pool.ntp.org", ]
		}
		debian, ubuntu: {
			$service_name = 'ntp'
			#$conf_file = 'ntp.conf.debian'
			$conf_template = 'ntp.conf.debian.erb'
			$default_servers = [ "0.debian.pool.ntp.org iburst",
								 "1.debian.pool.ntp.org iburst",
								 "2.debian.pool.ntp.org iburst",
								 "3.debian.pool.ntp.org iburst", ]			
		}
	}

	if $servers == undef {
		$servers_real = $default_servers
	}
	else {
		$servers_real = $servers
	}

	package { 'ntp': 
		ensure => installed,
	}

	service { 'ntp':
		name => $service_name, 
		ensure => running,
		enable => true,
		subscribe => File['ntp.conf'],
	}

	file { 'ntp.conf':
		path => '/etc/ntp.conf',
		ensure => file,
		require => Package['ntp'],
		#source => "puppet:///modules/ntp/${conf_file}",
		content => template("ntp/${conf_template}"),
	} 
}