# Creates scm database in postgres
class cm::database {
  postgres::server::db { $cm::params::scm_database_name:
    user     => $scm_username,
    password => $scm_password
  }

  postgres::server::pg_hba_rule { 'allow scm user':
    description => 'Open up postgresql for access to scm database',
    type        => 'host',
    database    => $cm::params::scm_database_name,
    user        => $cm::params::scm_username,
    address     => '127.0.0.1/32',
    auth_method => 'trust'
  }
}
