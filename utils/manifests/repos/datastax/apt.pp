# Class: utils::repos::datastax::apt
#
#
class utils::repos::datastax::apt {
  include apt
  apt::source { 'datastax-repo':
    location    => 'http://debian.datastax.com/community',
    release     => 'stable',
    repos       => 'main',
    include_src => true,
    key         => 'F4D5DAA8',
    key_source  => 'http://debian.datastax.com/debian/repo_key'
  }
}