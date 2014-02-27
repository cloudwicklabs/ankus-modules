# == Class: utils::repos::hdp::apt
#
# manages the apt repository of hortonworks hdp
#
# === Parameters:
#
# None.
#
class utils::repos::hdp::apt {
  include apt

  apt::source{ 'hdp':
    location    => 'http://public-repo-1.hortonworks.com/HDP/ubuntu12/2.x',
    release     => 'HDP',
    repos       => 'main',
    key         => '07513CAD',
    key_server  => 'pgp.mit.edu',
    include_src => false,
  }

  apt::source{ 'hdp_utils':
    location    => 'http://public-repo-1.hortonworks.com/HDP-UTILS-1.1.0.16/repos/ubuntu12',
    release     => 'HDP-UTILS',
    repos       => 'main',
    key         => '07513CAD',
    key_server  => 'pgp.mit.edu',
    include_src => false,
  }
}