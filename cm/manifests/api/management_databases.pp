class cm::api::management_databases {
  postgres::server::db { $cm::params::cm_amon_database_name:
    user     => $cm::params::cm_amon_database_user,
    password => $cm::params::cm_amon_database_password
  }

  postgres::server::pg_hba_rule { 'allow activity monitor user':
    description => 'Open up postgresql for access to activity monitor database',
    type        => 'host',
    database    => $cm::params::cm_amon_database_name,
    user        => $cm::params::cm_amon_database_user,
    address     => '127.0.0.1/32',
    auth_method => 'trust'
  }

  postgres::server::db { $cm::params::cm_smon_database_name:
    user     => $cm::params::cm_smon_database_user,
    password => $cm::params::cm_smon_database_password
  }

  postgres::server::pg_hba_rule { 'allow service monitor user':
    description => 'Open up postgresql for access to service monitor database',
    type        => 'host',
    database    => $cm::params::cm_smon_database_name,
    user        => $cm::params::cm_smon_database_user,
    address     => '127.0.0.1/32',
    auth_method => 'trust'
  }

  postgres::server::db { $cm::params::cm_hmon_database_name:
    user     => $cm::params::cm_hmon_database_user,
    password => $cm::params::cm_hmon_database_password
  }

  postgres::server::pg_hba_rule { 'allow host monitor user':
    description => 'Open up postgresql for access to host monitor database',
    type        => 'host',
    database    => $cm::params::cm_hmon_database_name,
    user        => $cm::params::cm_hmon_database_user,
    address     => '127.0.0.1/32',
    auth_method => 'trust'
  }
}
