curl { 'test':
  domain       => "http://localhost:7180",
  get         => "/api/v6/clusters/test_cluster/parcels/products/CDH/versions/4.6.0-1.cdh4.6.0.p0.26",
  parameters   => "{}",
  request_type => 'json',
  username     => "admin",
  password     => "admin",
  returns      => '200',
  only_if      => {
                    'get' => "/api/v6/clusters/test_cluster/parcels/products/CDH/versions/4.6.0-1.cdh4.6.0.p0.26",
                    'returns' => '200',
                    'contains_key'   => "stage",
                    'contains_value' => 'AVAILABLE_REMOTELY'
                  },
  log_to      => '/var/log/ankus/cm_api/test'
}
