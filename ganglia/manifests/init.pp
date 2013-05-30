# == Class: ganglia
#
# This module will install and manages ganglia, which is  is a scalable distributed
# monitoring system for high-performance computing systems such as clusters and Grids.
#
# === Parameters
#
# None
#
# === Variables
#
# None
#
# === Requires
#
# Nothing.
#
# === Sample Usage
#
# to setup ganglia client
# class {'ganglia::client':
#   cluster => 'hadoop_cluster',
#   owner => 'cloudwick',
#   unicast_targets => [ {'ipaddress' => '${controllerip}', 'port' => '8649'} ],
#   network_mode  => 'unicast',
# }
# Or if data is available from hiera
# include ganglia::client
#
# to setup ganglia server and webserver
# class {'ganglia::server':
#     gridname => 'hadoop',
#   }
#   include ganglia::webserver
# Or if data is available from hiera
# include ganglia::server
#
# === Authors
#
# Ashrith <ashrith@cloudwick.com>
#
# === Copyright
#
# Copyright 2012 Cloudwick Technologies, unless otherwise noted.
#


class ganglia {

  package {'rrdtool':
    ensure => 'installed',
  }

}
