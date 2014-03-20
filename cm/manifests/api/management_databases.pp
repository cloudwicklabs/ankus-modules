class cm::api::management_databases inherits utils::database {
  postgresql::server::db { $cm::params::cm_amon_database_name:
    user     => $cm::params::cm_amon_database_user,
    password => $cm::params::cm_amon_database_password
  }

  postgresql::server::pg_hba_rule { 'allow activity monitor user':
    description => 'Open up postgresql for access to activity monitor database',
    type        => 'host',
    database    => $cm::params::cm_amon_database_name,
    user        => $cm::params::cm_amon_database_user,
    address     => '0.0.0.0/0',
    auth_method => 'trust'
  }

  postgresql::server::db { $cm::params::cm_smon_database_name:
    user     => $cm::params::cm_smon_database_user,
    password => $cm::params::cm_smon_database_password
  }

  postgresql::server::pg_hba_rule { 'allow service monitor user':
    description => 'Open up postgresql for access to service monitor database',
    type        => 'host',
    database    => $cm::params::cm_smon_database_name,
    user        => $cm::params::cm_smon_database_user,
    address     => '0.0.0.0/0',
    auth_method => 'trust'
  }

  postgresql::server::db { $cm::params::cm_hmon_database_name:
    user     => $cm::params::cm_hmon_database_user,
    password => $cm::params::cm_hmon_database_password
  }

  postgresql::server::pg_hba_rule { 'allow host monitor user':
    description => 'Open up postgresql for access to host monitor database',
    type        => 'host',
    database    => $cm::params::cm_hmon_database_name,
    user        => $cm::params::cm_hmon_database_user,
    address     => '0.0.0.0/0',
    auth_method => 'trust'
  }
}
