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
	require nagios::params
}
