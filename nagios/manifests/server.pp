# == Class: server
#
# Installs nagios server
#
# === Parameters
#
# None
#
# === Variables
#
# [*nagiosservice*]
# Name of the nagios server service
#
# [*nagiospattern*]
# Name of the nagios server package pattern used to restart the service
#
# [*nagiospackage*]
# Name of the nagios server package to be installed
#
# [*apacheservice*]
# Name of the apache service
#
# [*apachepackage*]
# Name of the apache package to be installed
#
# [*packages*]
# array of packages to be installed on the nrpe server
#
# === Requires
#
# PuppetDB for stored configurations & exported resources.
#
# === Sample Usage
#
# include nagios::server
#
# === Authors
#
# Ashrith <ashrith@cloudwick.com>
#
# === Copyright
#
# Copyright 2012 Cloudwick Technologies, unless otherwise noted.
#

class nagios::server inherits nagios {
  include nagios::params
  include nagios::target

  $adminemail = hiera('admin_email')

  case $operatingsystem {
    /Debian|Ubuntu/: {
      $nagiosservice = "nagios3"
      $nagiospackage = "nagios3"
      $nagiospattern = "nagios3"
      $apacheservice = "apache2"
      $apachepackage = "apache2"
      $packages =  ['nagios3', 'apache2', 'nagios-nrpe-plugin', 'postfix']
    }
    /RedHat|CentOS|Fedora/: {
      $nagiosservice = "nagios"
      $nagiospackage = "nagios"
      $nagiospattern = "nagios"
      $apacheservice = "httpd"
      $apachepackage = "httpd"
      $packages =  ['nagios', 'nagios-devel', 'nagios-plugins-all', 'nagios-plugins-nrpe', 'php', 'net-snmp', 'net-snmp-utils', 'postfix', 'httpd' ]
    }

    default: {err ("operatingsystem $operatingsystem not yet implemented !")}
  }

  package { $packages:
    ensure  =>  installed,
  }

  service {
        $nagiosservice:         #BUG: Fix me! Initial start of nagios failing, even with configurations in place?
         ensure      => running,
         alias       => 'nagios',
         hasstatus   => true,
         hasrestart  => true,
         require     => [ Package[$nagiospackage],
                          File["${nagios::params::rootdir}/nagios.cfg",
                               "${nagios::params::rootdir}/commands/generic-commands.cfg",
                               "${nagios::params::rootdir}/contacts/generic-contact.cfg",
                               "${nagios::params::rootdir}/hosts/generic-host.cfg",
                               "${nagios::params::rootdir}/services/generic-service.cfg",
                               "${nagios::params::rootdir}/timeperiods/generic-timeperiod.cfg"] ];
       'postfix':
       	 ensure		   =>	running,
       	 enable		   =>	true,
       	 hasrestart	 =>	true,
       	 require	   =>	Package["postfix"];
       $apacheservice:
       	 ensure		   =>	running,
       	 enable		   =>	true,
       	 hasrestart	 =>	true,
       	 require	   =>	Package[$apachepackage];
    }

    exec { "nagios-restart":
    	command     => "${nagios::params::basename} -v ${nagios::params::conffile} && /etc/init.d/${nagios::params::basename} restart",
    	require		  => Package[$nagiospackage],
    	path 		    => "/usr/sbin",
    	refreshonly => true,
  	}

  	exec { "nagios-reload":
    	command     => "${nagios::params::basename} -v ${nagios::params::conffile} && /etc/init.d/${nagios::params::basename} reload",
    	require		  => Package[$nagiospackage],
    	path 		    => "/usr/sbin",
    	refreshonly => true,
  	}

    exec { "nagios-fixperms":
  	 	command     => "/bin/chmod -R 755 /etc/${nagios::params::basename}/*",
      notify      =>  Exec["nagios-reload"],
   		refreshonly => true,
  	}

  	exec { "modify-user-account":
		  command	  =>	"/usr/sbin/usermod -a -G nagios apache",
      unless    =>  "/bin/cat /etc/group | /bin/grep nagios | /bin/cut -d: -f4 | /bin/grep apache",
		  user      =>	"root",
		  logoutput	=> true,
		  require	  =>	Package[$apachepackage, $nagiospackage],
	  }

	  user { "www-data":
	    ensure     => present,
	    groups     => "nagios",
	    membership => minimum,
	    require    => Package[$apachepackage, $nagiospackage],
	  }

  	#TODO:generalize for ubuntu
  	# File {
  	# 	owner	=>	root,
  	# 	group 	=>	root,
  	# 	require	=>	Package["nagios"],
  	# 	source  => undef,
  	# 	content => undef,
  	# }

  	file {
    	"${nagios::params::rootdir}/nagios.cfg":
      		ensure  => present,
      		alias   => "conf-nagios",
      		mode    => "0755",
      		owner	  =>	root,
  			  group 	=>	root,
  			  require	=>	Package[$nagiospackage],
      		notify  => Service[$nagiosservice],
      		content => template("nagios/nagios.cfg.erb");
    	"${nagios::params::rootdir}/servers":
      		ensure  => directory,
      		alias   => "conf-nagios-servers",
      		owner	  =>	root,
  			  group 	=>	root,
  			  require	=>	Package[$nagiospackage],
      		mode    => "0644";
  		"${nagios::params::rootdir}/commands":
			    ensure  => directory,
      		alias   => "conf-nagios-commands",
      		owner	  =>	root,
  		  	group 	=>	root,
  		  	require	=>	Package[$nagiospackage],
      		mode    => "0644";
      "${nagios::params::rootdir}/timeperiods":
      		ensure  => directory,
      		alias   => "conf-nagios-timeperiods",
      		owner	  =>	root,
  	   		group 	=>	root,
  	   		require	=>	Package[$nagiospackage],
      		mode    => "0644";
  		"${nagios::params::rootdir}/contacts":
      		ensure  => directory,
      		alias   => "conf-nagios-contacts",
      		owner	  =>	root,
  	   		group 	=>	root,
  		  	require	=>	Package[$nagiospackage],
      		mode    => "0644";
  		"${nagios::params::rootdir}/services":
      		ensure  => directory,
      		alias   => "conf-nagios-services",
      		owner	  =>	root,
  		  	group 	=>	root,
  		  	require	=>	Package[$nagiospackage],
      		mode    => "0644";
  		"${nagios::params::rootdir}/hosts":
  		  	ensure	=> directory,
  		  	alias 	=> "conf-nagios-hosts",
       		owner  	=>	root,
  		  	group 	=>	root,
  		  	require	=>	Package[$nagiospackage],
  		  	mode 	  => "0644";
   	}

   	#place defaults in place
   	file {
   		"${nagios::params::rootdir}/commands/generic-commands.cfg":
   			ensure	=> present,
   			alias 	=> "generic-commands",
   			mode 	  => "0755",
      	owner	  =>	root,
  			group 	=>	root,
        content => template("nagios/generic-commands.cfg.erb"),
   			require => [ File["conf-nagios-commands"], Package[$nagiospackage] ],
   			notify	=> Exec["nagios-reload"];
		"${nagios::params::rootdir}/contacts/generic-contact.cfg":
   			ensure	=> present,
   			alias 	=> "generic-contact",
   			mode 	  => "0755",
      	owner	  =>	root,
  			group 	=>	root,
        content => template("nagios/generic-contact.cfg.erb"),
   			require => [ File["conf-nagios-contacts"], Package[$nagiospackage] ],
   			notify	=> Exec["nagios-reload"];
   		"${nagios::params::rootdir}/hosts/generic-host.cfg":
   			ensure	=> present,
   			alias 	=> "generic-host",
   			mode 	  => "0755",
      	owner	  =>	root,
  			group 	=>	root,
        content => template("nagios/generic-host.cfg.erb"),
   			require => [ File["conf-nagios-hosts"], Package[$nagiospackage] ],
   			notify	=> Exec["nagios-reload"];
		"${nagios::params::rootdir}/services/generic-service.cfg":
   			ensure	=> present,
   			alias 	=> "generic-service",
   			mode 	  => "0755",
      	owner	  =>	root,
  			group 	=>	root,
        content => template("nagios/generic-service.cfg.erb"),
   			require => [ File["conf-nagios-commands"], Package[$nagiospackage] ],
   			notify	=> Exec["nagios-reload"];
		"${nagios::params::rootdir}/timeperiods/generic-timeperiod.cfg":
   			ensure	=> present,
   			alias 	=> "generic-timeperiod",
   			mode 	  => "0755",
      	owner	  =>	root,
  			group 	=>	root,
        content => template("nagios/generic-timeperiod.cfg.erb"),
   			require => [ File["conf-nagios-commands"], Package[$nagiospackage] ],
   			notify	=> Exec["nagios-reload"];
   	}

	# file { "${nagios::params::rootdir}/servers/host-nagioserver.cfg":
	# 	ensure		=>	present,
	# 	owner		=>	"root",
	# 	mode 		=>	"0644",
 #  		group 		=>	"root",
 #  		require		=>	Package["nagios"],
	# 	before		=>	[ Nagios_host["localhost"], Nagios_hostextinfo["localhost"], Nagios_service["localhost"] ],
	# }

 #  nagios_host { "localhost":
 #   		ensure			=>	present,
 #   		address 		=>	$ipaddress,
 #   		use 			=>	"generic-host-active",
 #   		alias			=>	$hostname,
 #   		target			=>	"${nagios::params::rootdir}/servers/host-nagioserver.cfg",
 #   		notify			=>	Exec["nagios-reload"],
	# }

	# nagios_hostextinfo { "localhost":
	# 	ensure		=>	present,
	# 	icon_image_alt	=>	$operatingsystem,
	# 	icon_image 		=>	"base/$operatingsystem.png",
	# 	statusmap_image	=>	"base/$operatingsystem.gd2",
	# 	target			=>	"${nagios::params::rootdir}/servers/host-nagioserver.cfg",
	# }

	# nagios_service { "localhost":
	# 	use  					=> "generic-service-active",
	# 	service_description		=> 'ssh',
	# 	check_command			=> 'check_ssh',
	# 	target					=> "${nagios::params::rootdir}/servers/host-nagioserver.cfg",
	# }

  #COLLECT RESOURCES AND POPULATE RESPECTIVE FILES
  #File <<| tag == 'nagios-host-file' |>>
  Nagios_command <<||>> {
   notify   => Exec['nagios-fixperms'],
   require  => File['conf-nagios-commands'],
  }
  Nagios_host <<||>> {
    notify  => Exec['nagios-fixperms'],
    require => File['conf-nagios-hosts', 'conf-nagios-servers'],
  }
  Nagios_service <<||>> {
    notify  => Exec['nagios-fixperms'],
    require => File['conf-nagios-services'],
  }
  Nagios_servicegroup <<||>> {
    notify  => Exec['nagios-fixperms'],
    require => File['conf-nagios-services'],
  }
  Nagios_hostextinfo <<||>> {
    notify  => Exec['nagios-fixperms'],
    require => File['conf-nagios-hosts', 'conf-nagios-servers'],
  }

  # @@nagios_servicegroup { 'nagios':
  #   # alias  => 'nagios',
  #   target => "${nagios::targets}/servicegroup/nagios.cfg",
  # }
  # @@nagios_command { 'check_http_name_auth':
  #   command_line => '/usr/lib/nagios/plugins/check_http -H $ARG1$ -I $HOSTADDRESS$ -e \'HTTP/1.1 401\'',
  #   target       => "${nagios::targets}/command/check_http_name_auth.cfg",
  # }
  # @@nagios_service { 'check_nagios3_${::fqdn}':
  #   service_description => 'Nagios3 Web',
  #   check_command       => "check_http_name_auth!${::fqdn}",
  #   host_name           => $::fqdn,
  #   use                 => 'generic-service',
  #   servicegroups       => 'nagios',
  #   target              => "${nagios::targets}/host/${::fqdn}.cfg",
  # }

} #end of file