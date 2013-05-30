# == Class: nagios
#
# Install and manages nagios monitoring and alerting service
#
# === Parameters
#
# None.
#
# === Variables
#
# None.
#
# === Requires
#
# PuppetDB for stored-configs
#
# === Sample Usage
#
# include nagios
#
# === Authors
#
# Ashrith <ashrith@cloudwick.com>
#
# === Copyright
#
# Copyright 2012 Cloudwick Technologies, unless otherwise noted.
#

class nagios {
	include nagios::params

#   Nagios_host {
#     ensure                => present,
#     alias                 => $hostname,
#     address               => $ipaddress,
#     max_check_attempts    => 5,
#     check_period          => 24x7,
# #    contact_groups        => "localadmins",
#     notification_interval => 30,
#     notification_period   => 24x7,
#     notify                => Exec["nagios-fixperms"],
#     target                => "/etc/nagios/hosts.cfg",
#   }

#   Nagios_contact {
#     notify => Exec["nagios-fixperms"],
#     target => "/etc/nagios/contacts.cfg",
#   }

#   Nagios_contactgroup {
#     notify => Exec["nagios-fixperms"],
#     target => "/etc/nagios/contactgroups.cfg",
#   }

#   Nagios_command {
#     notify => Exec["nagios-fixperms"],
#     target => "/etc/nagios/commands.cfg",
#   }

#   Nagios_hostgroup {
#     notify => Exec["nagios-fixperms"],
#     target => "/etc/nagios/hostgroups.cfg",
#   }

#   Nagios_service {
#     ensure                => "present",
#     max_check_attempts    => 5,
#     normal_check_interval => 10,
#     retry_check_interval  => 1,
#     check_period          => 24x7,
#     notification_interval => 120,
#     notification_period   => 24x7,
#     notification_options  => "w,u,c,r,f",
#     contact_groups        => "localadmins",
#     notify                => Exec["nagios-fixperms"],
#   }

#   Nagios_servicegroup {
#     notify => Exec["nagios-fixperms"],
#     target => "/etc/nagios/servicegroups.cfg",
#   }
}
