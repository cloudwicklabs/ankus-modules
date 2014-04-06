class cm::api::params inherits cm::params {
  # find out the api version to work with
  $cluster_name = $::cm::params::cm_cluster_name
  $cm_domain = "http://${::cm::params::cm_server_host}:${::cm::params::cm_api_port}"
  $api_version = inline_template("<%=
    require 'uri'
    begin
      open(\"${cm_domain}/api/version\",
        :http_basic_authentication => [\"${::cm::params::cm_username}\", \"${::cm::params::cm_password}\"]
      ).string
    resuce OpenURI::HTTPError
      nil
    end
  -%>")
}
