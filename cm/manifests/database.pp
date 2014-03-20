# Creates scm database in postgres
class cm::database inherits utils::database {
  postgresql::server::db { $cm::params::scm_database_name:
    user     => $cm::params::scm_username,
    password => $cm::params::scm_password
  }

  postgresql::server::pg_hba_rule { 'allow scm user':
    description => 'Open up postgresql for access to scm database',
    type        => 'host',
    database    => $cm::params::scm_database_name,
    user        => $cm::params::scm_username,
    address     => '0.0.0.0/0',
    auth_method => 'trust'
  }
}
