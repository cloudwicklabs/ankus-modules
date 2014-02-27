# == Define: utils::limits::conf
#
# Modifies entries in /etc/security.limits.conf to bump up the soft, hard and 
# noproc limits for user's and processes
#
# === Parameters:
#
# [*domain*]
#   user or groupname to modify the value for
#
# [*type*]
#   type of the limit (hard/soft)
#
# [*item*]
#   core, data, fsize, memlock, nofile, rss, stack, nproc, maxlogins, 
#   maxsyslogins, priority, locks, sigpending, msqqueue, nice, rtprio
#
# === Examples
#
#   utils::limits::conf { 'hadoop-nofile-soft':
#       type  => soft,
#       item  => nofile,
#       value => 64000;
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
define utils::limits::conf (
    $domain,
    $type   = soft,
    $item   = nofile,
    $value  = 64000
) {

    # guid of this entry
    $key = "${domain}/${type}/${item}"

    # augtool> match /files/etc/security/limits.conf/domain[.="root"][./type="hard" and ./item="nofile" and ./value="10000"]
    $context = '/files/etc/security/limits.conf'

    $path_list  = "domain[.=\"${domain}\"][./type=\"${type}\" and ./item=\"${item}\"]"
    $path_exact = "domain[.=\"${domain}\"][./type=\"${type}\" and ./item=\"${item}\" and ./value=\"${value}\"]"

    augeas {
        "limits_conf/${key}":
            context => $context,
            onlyif  => "match ${path_exact} size != 1",
            changes => [
                # remove all matching to the $domain, $type, $item, for any $value
                "rm ${path_list}",
                # insert new node at the end of tree
                "set domain[last()+1] ${domain}",
                # assign values to the new node
                "set domain[last()]/type ${type}",
                "set domain[last()]/item ${item}",
                "set domain[last()]/value ${value}",
                ],
    }

}
