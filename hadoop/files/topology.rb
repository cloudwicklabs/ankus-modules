#!/usr/bin/env ruby
# ---
# This script is used by hadoop to determine network/rack topology.
# It should be specified in core-site.xml via topology.script.name property
# ---
location = {
	'192.168.1.0/32' => '/rack/1',
	'10.0.1.0/32' => '/rack/2',
	'192.168.1.123' => 'rack/3',
}

if ARGV.length == 1
	puts '/default-rack'
else
	puts ARGV.map { |ip| location[ip] || '/default-rack' }.join(' ')
end