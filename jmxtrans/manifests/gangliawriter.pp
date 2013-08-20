define jmxtrans::gangliawriter (
  $jmx,
  $objects,
  $ganglia,
  $ganglia_group_name = '',
  $result_alias = '',
  $jmx_alias = '',
  $jmx_username='',
  $jmx_password='')
{
  include jmxtrans

  file { "/var/lib/jmxtrans/ganglia.${name}.json":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('jmxtrans/gangliawriter.json.erb'),
    require => Package[$jmxtrans::package_name]
  }
}