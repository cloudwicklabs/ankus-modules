# == Class: kerberos
#             kerberos::site
#             kerberos::kdc
#                 kerberos::kdc::admin_server
#             kerberos::client
#             kerberos::server
#
# == Definitions: principal
#                 host_keytab
#
# This module will install and manage kerberos server and clients
#
# === Parameters
#
# [*kerberos_domain*]
#   domain name for the kerberos realm, default value is domain name
#   of the system
#
# [*kerberos_realm*]
#   realm name to be used, it is better to use the uppercase domain name as
#   as kerberos realm name, default value is uppercase of domain name
#
# [*kerberos_kdc_server*]
#   fqdn of kerberos server, deafult value is localhost
#
# [*kerberos_kdc_port*]
#   port number on which kdc server is listening, deafult value is 88
#
# [*keytab_export_dir*]
#   path to the dir where keytab files are stored, defalut value is
#   /var/lib/bigtop_keytabs
#
# === Variables
#
# Nothing.
#
# === Requires
#
# Java
#
# === Sample Usage
#
# Installs fully functional KDC ( kerberos server and admin_server utilities )
#   include kerberos::kdc
#   inlcude kerberos::kdc::admin_server
# (or)
#   *include kerberos::server
#
# Installs kerberos client
# *include kerberos::client
#
# Sets-up keystab file for specified services
# *kerberos::host_keytab { ["host", "hdfs", "mapred"]: }
#

class kerberos {
  class site {
    #TODO: Get values from hiera
    $domain     = hiera('hadoop_kerberos_domain', inline_template('<%= domain %>'))
    $realm      = hiera('hadoop_kerberos_realm', inline_template('<%= domain.upcase %>'))
    $kdc_server = hiera('controller')
    $kdc_port   = hiera('kerberos_kdc_port', '88')
    $admin_port = 749 #BUG: linux daemon packaging doesn't let us tweak this

    $keytab_export_dir = "/var/lib/cw_keytabs"

    case $operatingsystem {
      'Ubuntu': {
          $package_name_kdc    = 'krb5-kdc'
          $service_name_kdc    = 'krb5-kdc'
          $package_name_admin  = 'krb5-admin-server'
          $service_name_admin  = 'krb5-admin-server'
          $package_name_client = 'krb5-user'
          $exec_path           = '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
          $kdc_etc_path        = '/etc/krb5kdc/'
      }
      # default assumes CentOS, Redhat 5 series
      default: {
          $package_name_kdc    = 'krb5-server'
          $service_name_kdc    = 'krb5kdc'
          $package_name_admin  = 'krb5-libs'
          $service_name_admin  = 'kadmin'
          $package_name_client = 'krb5-workstation'
          $exec_path           = '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/kerberos/sbin:/usr/kerberos/bin'
          $kdc_etc_path        = '/var/kerberos/krb5kdc/'
      }
    }

    file { "/etc/krb5.conf":
      content => template('kerberos/krb5.conf.erb'),
      owner => "root",
      group => "root",
      mode => "0644",
    }

    @file { $keytab_export_dir:
      ensure => directory,
      owner  => "root",
      group  => "root",
    }

    # Required for SPNEGO
    @principal { "HTTP":

    }
  }

  class kdc inherits kerberos::site {

    package { $package_name_kdc:
      ensure => installed,
    }

    file { $kdc_etc_path:
    	ensure => directory,
        owner => root,
        group => root,
        mode => "0700",
        require => Package["$package_name_kdc"],
    }

    file { "${kdc_etc_path}/kdc.conf":
      content => template('kerberos/kdc.conf.erb'),
      require => Package["$package_name_kdc"],
      owner => "root",
      group => "root",
      mode => "0644",
    }

    file { "${kdc_etc_path}/kadm5.acl":
      content => template('kerberos/kadm5.acl.erb'),
      require => Package["$package_name_kdc"],
      owner => "root",
      group => "root",
      mode => "0644",
    }

    exec { "kdb5_util":
      path => $exec_path,
      command => "rm -f /etc/kadm5.keytab ; kdb5_util -P cthulhu -r ${realm} create -s && kadmin.local -q 'cpw -pw secure kadmin/admin'",
      creates => "${kdc_etc_path}/stash",
      subscribe => File["${kdc_etc_path}/kdc.conf"],
      # refreshonly => true,
      require => [Package["$package_name_kdc"], File["${kdc_etc_path}/kdc.conf"], File["/etc/krb5.conf"]],
    }

    service { $service_name_kdc:
      ensure => running,
      require => [Package["$package_name_kdc"], File["${kdc_etc_path}/kdc.conf"], Exec["kdb5_util"]],
      subscribe => File["${kdc_etc_path}/kdc.conf"],
      hasrestart => true,
    }


    class admin_server inherits kerberos::kdc {
      $se_hack = "setsebool -P kadmind_disable_trans  1 ; setsebool -P krb5kdc_disable_trans 1"

      package { "$package_name_admin":
        ensure => installed,
        require => Package["$package_name_kdc"],
      }

      service { "$service_name_admin":
        ensure => running,
        require => [Package["$package_name_admin"], Service["$service_name_kdc"]],
        hasrestart => true,
        restart => "${se_hack} ; service ${service_name_admin} restart",
        start => "${se_hack} ; service ${service_name_admin} start",
      }
    }
  }

  class client inherits kerberos::site {

    package { $package_name_client:
      ensure => installed,
    }

  }

  class server {
    include kerberos::client

    class { "kerberos::kdc": }
    ->
    Class["kerberos::client"]

    class { "kerberos::kdc::admin_server": }
    ->
    Class["kerberos::client"]
  }

  define principal {
    require "kerberos::client"

    realize(File[$kerberos::site::keytab_export_dir])

    $principal = "$title/$::fqdn"
    $keytab    = "$kerberos::site::keytab_export_dir/$title.keytab"

    exec { "addprinc.$title":
      path => $kerberos::site::exec_path,
      command => "kadmin -w secure -p kadmin/admin -q 'addprinc -randkey $principal'",
      unless => "kadmin -w secure -p kadmin/admin -q listprincs | grep -q $principal",
      require => Package[$kerberos::site::package_name_client],
    }
    ->
    exec { "xst.$title":
      path    => $kerberos::site::exec_path,
      command => "kadmin -w secure -p kadmin/admin -q 'xst -k $keytab $principal'",
      unless  => "klist -kt $keytab 2>/dev/null | grep -q $principal",
      require => File[$kerberos::site::keytab_export_dir],
    }
  }

  define host_keytab($princs = undef, $spnego = disabled) {
    $keytab = "/etc/$title.keytab"

    $requested_princs = $princs ? {
      undef   => [ $title ],
      default => $princs,
    }

    $internal_princs = $spnego ? {
      /(true|enabled)/ => [ 'HTTP' ],
      default          => [ ],
    }
    realize(Kerberos::Principal[$internal_princs])

    $includes = inline_template("<%=
      [requested_princs, internal_princs].flatten.map { |x|
        \"rkt $kerberos::site::keytab_export_dir/#{x}.keytab\"
      }.join(\"\n\")
    %>")

    kerberos::principal { $requested_princs:
    }

    exec { "ktinject.$title":
      path     => $kerberos::site::exec_path,
      command  => "/usr/bin/ktutil <<EOF
        $includes
        wkt $keytab
EOF
        chown $title $keytab",
      creates => $keytab,
      require => [ Kerberos::Principal[$requested_princs],
                   Kerberos::Principal[$internal_princs] ],
    }
  }
}