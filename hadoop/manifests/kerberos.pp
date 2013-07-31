#security
class hadoop::kerberos {
  require kerberos::client

  $hadoop_deploy = hiera('hadoop_deploy')
  $hadoop_mapreduce = $hadoop_deploy['mapreduce']
  $hadoop_mapreduce_framework = $hadoop_mapreduce['type']

  kerberos::host_keytab { "hdfs":
    princs => [ "host", "hdfs" ],
    spnego => true,
  }

  if ($hadoop_mapreduce_framework == "mr1") {
  kerberos::host_keytab { "mapreduce":
  	princs => "mapred",
  	spnego => true,
  }
  }
  if($hadoop_mapreduce_framework == "mr2") {
  kerberos::host_keytab { "yarn":
    princs => "yarn",
    spnego => true,
  }
  }
}