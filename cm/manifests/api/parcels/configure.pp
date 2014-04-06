# Downloads, distributes and activates parcels
class cm::api::parcels::configure inherits cm::api::params {
  # valid product name ['CDH', 'ACCUMULO', 'SOLR', 'IMPALA', 'SPARK']
  cm::api::parcels::download { 'Download CDH':
    product_name => 'CDH',
    product_version => '4'
  }
  cm::api::parcels::download { 'Download IMPALA':
    product_name => 'IMPALA'
  }
  cm::api::parcels::distribute { 'Distribute CDH':
    product_name => 'CDH',
    product_version => '4'
  }
  cm::api::parcels::distribute { 'Distribute IMPALA':
    product_name => 'IMPALA'
  }
  cm::api::parcels::activate { 'Activate CDH':
    product_name => 'CDH',
    product_version => '4'
  }
  cm::api::parcels::activate { 'Distribute IMPALA':
    product_name => 'IMPALA'
  }
}
