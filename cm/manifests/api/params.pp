class cm::api::params inherits cm::params {
  # find out the api version to work with
  $cm_domain = "http://${::cm::params::cm_server_host}:${::cm::params::cm_api_port}"
  $api_version = inline_template("<%= require 'uri'
    open(\"${cm_domain}/api/version\",
      :http_basic_authentication => [\"${::cm::params::cm_username}\", \"${::cm::params::cm_password}\"]
    ).string
  -%>")
}
