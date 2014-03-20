# Base class for managing postgresql databases and service
class utils::database {
  $postgresql_password = hiera('postgresql_password', 'Change3E')

  # install pstgresql and make to listen on all interfaces
  class { 'postgresql::server':
    postgres_password => $postgresql_password,
    listen_addresses => '*',
    pg_hba_conf_defaults => false,
  }

  # install postgresql devel packages
  class { 'postgresql::lib::devel':
  }

  # Setup rules for postgres connections
  postgresql::server::pg_hba_rule { 'allow local connections for postgres':
    description => "Open up postgresql local using ident",
    type => 'local',
    database => 'all',
    user => 'postgres',
    auth_method => 'ident',
    order => 10
  }

  postgresql::server::pg_hba_rule { 'allow local connections':
    description => "Open up postgresql local using password",
    type => 'local',
    database => 'all',
    user => 'all',
    auth_method => 'md5',
    order => 20
  }

  postgresql::server::pg_hba_rule { 'ipv4 local connections':
    description => "Open up postgresql for access to all databases on local ipv4 connections",
    type => 'host',
    database => 'all',
    user => 'all',
    address => '127.0.0.1/32',
    auth_method => 'trust'
  }

  postgresql::server::pg_hba_rule { 'ipv6 local connections':
    description => "Open up postgresql for access to all databases on local ipv6 connections",
    type => 'host',
    database => 'all',
    user => 'all',
    address => '::1/128',
    auth_method => 'trust'
  }

  # create a database for puppetdb
  postgresql::server::db { 'puppetdb':
    user => 'puppetdb',
    password => $postgresql_password
  }

  postgresql::server::pg_hba_rule { 'allow puppetdb to access puppetdb database':
    description => "Open up postgresql for acess from 127.0.0.1 to puppetdb user",
    type => 'host',
    database => 'puppetdb',
    user => 'puppetdb',
    address => '0.0.0.0/0',
    auth_method => 'trust'
  }
}
