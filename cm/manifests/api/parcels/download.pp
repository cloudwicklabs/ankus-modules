# Downloads specified parcel and waits until download completes
define cm::api::parcels::download($product_name = 'CDH', $product_version = '') {
  require cm::api::params

  $cluster_name   = $cm::params::cm_cluster_name
  $parcel_version = inline_template("<%=
    require 'rubygems'
    require 'json'
    require 'open-uri'
    JSON.parse(open(\"${cm::api::params::cm_domain}/api/${cm::api::params::api_version}/clusters/${cluster_name}/parcels\",
      :http_basic_authentication => [\"${cm::params::cm_username}\", \"${cm::params::cm_password}\"]).string)['items'].map do |i|
        i['version'] if(i['product'] == '${product_name}' && i['version'] =~ /${product_version}/)
    end.compact!.first
  %>")

  # Issue download
  curl { "download-parcel-${product_name}-${product_version}":
    domain       => "http://${::cm::params::cm_server_host}:${::cm::params::cm_api_port}",
    post         => "/api/${::cm::api::params::api_version}/clusters/${cluster_name}/parcels/products/${product_name}/versions/${parcel_version}/commands/startDownload",
    parameters   => "{}",
    request_type => 'json',
    username     => $::cm::params::cm_username,
    password     => $::cm::params::cm_password,
    returns      => '200',
    only_if      => {
                      'get'            => "/api/${::cm::api::params::api_version}/clusters/${cluster_name}/parcels/products/${product_name}/versions/${parcel_version}",
                      'returns'        => '200',
                      'contains_key'   => "stage",
                      'contains_value' => 'AVAILABLE_REMOTELY'
                    },
    log_to      => "/var/log/ankus/cm_api/parcels_${name}"
  }

  # wait until parcel download get's completed
  wait_for { "${product_name}-${product_version} parcel download completes":
    query             => "/usr/bin/curl --silent -X GET -u \"${::cm::params::cm_username}:${::cm::params::cm_password}\" -i -H \"content-type:application/json\" http://${::cm::params::cm_server_host}:${::cm::params::cm_api_port}/api/${::cm::api::params::api_version}/clusters/${cluster_name}/parcels/products/${product_name}/versions/${parcel_version}",
    regex             => '.*stage.*:.*DOWNLOADED.*',
    giveup_regex      => '.*stage.*:.*DISTRIBUTED.*|.*stage.*:.*ACTIVATED.*',
    polling_frequency => 15,
    max_retries       => 100,
    refreshonly       => true,
    subscribe         => Curl["download-parcel-${product_name}-${product_version}"]
  }
}
