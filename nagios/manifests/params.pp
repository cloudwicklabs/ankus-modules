class nagios::params {
  $basename = $operatingsystem ? {
    /Debian|Ubuntu/ => "nagios3",
    /RedHat|CentOS|Fedora/ => "nagios",
  }

  $user1 = $operatingsystem ? {
    /Debian|Ubuntu/ => "/usr/lib/nagios/plugins",
    /RedHat|CentOS|Fedora/ => $architecture ? {
      'x86_64' => "/usr/lib64/nagios/plugins",
      default  => "/usr/lib/nagios/plugins",
    },
  }

  $p1file = $operatingsystem ? {
    /Debian|Ubuntu/ => "/usr/lib/nagios3/p1.pl",
    /RedHat|CentOS|Fedora/ => "/usr/sbin/p1.pl",
  }

  $resourcedir = "/etc/nagios.d"
  $rootdir     = "/etc/${basename}"
  $conffile    = "${rootdir}/nagios.cfg"
}