define cm::api::parcels($cluster_name = 'test_cluster') {
  require cm::api::params
  notify { $::cm::api::params::cm_domain: }
  # root of the cdh version to use
  $cdh_version = 4
  # get the cdh parcel version to download
  $parcel_version = inline_template("<%=
    require 'rubygems'
    require 'json'
    require 'open-uri'
    JSON.parse(open(\"${cm::api::params::cm_domain}/api/${cm::api::params::api_version}/clusters/${cluster_name}/parcels\", :http_basic_authentication => [\"${cm::params::cm_username}\", \"${cm::params::cm_password}\"]).string)['items'].map do |i|
      i['version'] if(i['product'] == 'CDH' && i['version'] =~ /${cdh_version}/)
    end.compact!
  %>")

  curl { "download-parcel-CDH":
    domain       => "http://${::cm::params::cm_server_host}:${::cm::params::cm_api_port}",
    post         => "/api/${::cm::api::params::api_version}/clusters/${cluster_name}/parcels/products/CDH/versions/${parcel_version}/commands/startDownload",
    parameters   => "{
                      'items' => [
                        'hostId' => '${name}',
                        'hostname' => '${host_name}',
                        'ipAddress' => '${ip_address}',
                        'rackId' => '${rack_id}'
                      ]
                    }",
    request_type => 'json',
    username     => $::cm::params::cm_username,
    password     => $::cm::params::cm_password,
    returns      => '200',
    only_if      => {
                      'get'            => "/api/${::cm::api::params::api_version}/clusters/${cluster_name}/parcels/products/CDH/versions/${parcel_version}",
                      'returns'        => '200',
                      'contains_key'   => "stage",
                      'contains_value' => 'AVAILABLE_REMOTELY'
                    },
    log_to      => "/var/log/ankus/cm_api/parcels_${name}"
  }

  # wait until parcel download get's completed
  wait_for { "CDH parcel download completes":
    query             => "/usr/bin/curl --silent -X GET -u \"${::cm::params::cm_username}:${::cm::params::cm_password}\" -i -H \"content-type:application/json\" http://${::cm::params::cm_server_host}:${::cm::params::cm_api_port}/api/${::cm::api::params::api_version}/clusters/${cluster_name}/parcels/products/CDH/versions/${parcel_version}",
    regex             => '.*stage.*:.*DOWNLOADED.*',
    polling_frequency => 10,
    max_retries       => 100,
    subscribe         => Curl['download-parcel-CDH']
  }
}
