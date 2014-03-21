# Only works on api version 6 after
define cm::api::install_agent($host_id = 'localhost', $username, $private_key) {
  require cm::api::params

  if ($::cm::api::params::api_version != 'v6') {
    fail("Installing cm agent's remotely is only supported in version 6 of the api")
  }

  curl { "install-agents":
    domain       => "http://${::cm::params::cm_server_host}:${::cm::params::cm_api_port}",
    post         => "/api/${::cm::api::params::api_version}/cm/commands/hostInstall",
    parameters   => "{
                      'userName' => '${username}',
                      'privateKey' => '${private_key}',
                      'hostNames' => [ '${host_id}' ],
                      'sshPort' => 22,
                      'parallelInstallCount' => 10
                    }",
    request_type => 'json',
    username     => $::cm::params::cm_username,
    password     => $::cm::params::cm_password,
    returns      => '200',
    only_if      => {
                      'get' => "/api/${::cm::api::params::api_version}/hosts/${host_id}",
                      'returns' => '404'
                    },
    log_to      => "/var/log/ankus/cm_api/install_host_${host_id}"
  }

  # Should some how wait till all the agent installations got complete
  # wait_for { "install_agent completes":
  #   # TODO: get the command id using "items.map { |i| i['id'] }"
  #   query => "curl -x GET -u admin:admin http://${::cm::params::cm_server_host}:${::cm::params::cm_api_port}/api/${::cm::api_version}/commands/${command_id}",
  #   # regex   => '.*STATE\s*:\s*4\s*RUNNING.*',
  #   regex => '.*sucess.*'
  # }
}
