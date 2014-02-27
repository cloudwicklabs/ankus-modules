# == Define: createDirWithPerm
#
# syncronizes namenode data directories accross two namenodes in high
# availability configuration
#
# Becuase of Bug HDFS-3752
#
# === Parameters:
#
# [*source*]
#   directory source from where to initialize the copy
#
# [*ssh_identity*]
#   ssh private key to ssh into namenode
#
# === Examples
#
#   hadoop::namedir_copy { ['/data/0/hdfs/nn', '/data/1/hdfs/nn']:
#     source       => $ip_address_of_active_namenode,
#     ssh_identity => $sshfence_keypath,
#   }
#
# === Authors
#
# ashrith <ashrith@cloudwick.com>
#
# === Copyright
#
# Copyright 2012 Cloudwick Inc, unless otherwise noted.
#
define hadoop::namedir_copy ($source, $ssh_identity) {
  exec { "copy namedir $title from first namenode":
    command => "/usr/bin/rsync -avz -e '/usr/bin/ssh -oStrictHostKeyChecking=no -i $ssh_identity' '${source}:$title/' '$title/'",
    user    => 'hdfs',
    tag     => 'namenode-format',
    creates => "$title/current/VERSION",
  }
}
