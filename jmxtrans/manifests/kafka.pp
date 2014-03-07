class jmxtrans::kafka {
  $ganglia_server = hiera('controller')

  $jmx_kafka_objects = [
    # Controller Stats
    {
      'name'   => '\"kafka.controller\":type=\"ControllerStats\",name=\"LeaderElectionRateAndTimeMs\"',
      'resultAlias' => 'LeaderElectionRate',
      'attributes'  => {
        'Count' => { 'units' => 'millisecs' },
      }
    },
    {
      'name'   => '\"kafka.controller\":type=\"ControllerStats\",name=\"UncleanLeaderElectionsPerSec\"',
      'resultAlias' => 'UnclearLeaderElectionRate',
      'attributes'  => {
        'Count' => { 'units' => 'secs' },
      }
    },
    {
      'name'   => '\"kafka.controller\":type=\"KafkaController\",name=\"ActiveControllerCount\"',
      'resultAlias' => 'ControllerCount',
      'attributes'  => { 'Value' => {} }
    },
    {
      'name'   => '\"kafka.controller\":type=\"KafkaController\",name=\"OfflinePartitionCount\"',
      'resultAlias' => 'OfflinePartitions',
      'attributes'  => { 'Value' => {} }
    },
    # Network
    {
      'name'   => '\"kafka.network\":type=\"RequestChannel\",name=\"RequestQueueSize\"',
      'resultAlias' => 'ReqQueueSize',
      'attributes'  => { 'Value' => {} }
    },
    # Server
    {
      'name'   => '\"kafka.server\":type=\"BrokerTopicMetrics\",name=\"AllTopicsBytesInPerSec\"',
      'resultAlias' => 'BytesIn',
      'attributes'  => {
        'Count' => { 'units' => 'secs' },
      }
    },
    {
      'name'   => '\"kafka.server\":type=\"BrokerTopicMetrics\",name=\"AllTopicsBytesOutPerSec\"',
      'resultAlias' => 'BytesOut',
      'attributes'  => {
        'Count' => { 'units' => 'secs' },
      }
    },
    {
      'name'   => '\"kafka.server\":type=\"BrokerTopicMetrics\",name=\"AllTopicsFailedFetchRequestsPerSec\"',
      'resultAlias' => 'FetchFailedRequests',
      'attributes'  => {
        'Count' => { 'units' => 'secs' },
      }
    },
    {
      'name'   => '\"kafka.server\":type=\"BrokerTopicMetrics\",name=\"AllTopicsFailedProduceRequestsPerSec\"',
      'resultAlias' => 'FailedProduceRequests',
      'attributes'  => {
        'Count' => { 'units' => 'secs' },
      }
    },
    {
      'name'   => '\"kafka.server\":type=\"BrokerTopicMetrics\",name=\"AllTopicsMessagesInPerSec\"',
      'resultAlias' => 'TopicsMessages',
      'attributes'  => {
        'Count' => { 'units' => 'secs' },
      }
    },
    {
      'name'   => '\"kafka.server\":type=\"DelayedFetchRequestMetrics\",name=\"ConsumerExpiresPerSecond\"',
      'resultAlias' => 'ConsumerExpiries',
      'attributes'  => {
        'Count' => { 'units' => 'secs' },
      }
    },
    {
      'name'   => '\"kafka.server\":type=\"DelayedFetchRequestMetrics\",name=\"FollowerExpiresPerSecond\"',
      'resultAlias' => 'FollowerExpiries',
      'attributes'  => {
        'Count' => { 'units' => 'secs' },
      }
    },
    {
      'name'   => '\"kafka.server\":type=\"DelayedProducerRequestMetrics\",name=\"AllExpiresPerSecond\"',
      'resultAlias' => 'AllExpiries',
      'attributes'  => {
        'Count' => { 'units' => 'secs' },
      }
    },
    {
      'name'   => '\"kafka.server\":type=\"FetchRequestPurgatory\",name=\"NumDeplayedRequests\"',
      'resultAlias' => 'DeplayedRequests',
      'attributes'  => { 'Value' => {} },
    },
    {
      'name'   => '\"kafka.server\":type=\"FetchRequestPurgatory\",name=\"PurgatorySize\"',
      'resultAlias' => 'PurgatorySize',
      'attributes'  => { 'Value' => {} },
    },
    {
      'name'   => '\"kafka.server\":type=\"ProducerRequestPurgatory\",name=\"NumDelayedRequests\"',
      'resultAlias' => 'ProducerRequestsDelayed',
      'attributes'  => { 'Value' => {} },
    },
    {
      'name'   => '\"kafka.server\":type=\"ProducerRequestPurgatory\",name=\"PurgatorySize\"',
      'resultAlias' => 'ProducerPurgatorySize',
      'attributes'  => { 'Value' => {} },
    },
    {
      'name'   => '\"kafka.server\":type=\"ReplicaFetchManager\",name=\"Replica-MaxLag\"',
      'resultAlias' => 'ReplicaMaxLag',
      'attributes'  => { 'Value' => {} },
    },
    {
      'name'   => '\"kafka.server\":type=\"ReplicaFetchManager\",name=\"Replica-MinFetchRate\"',
      'resultAlias' => 'ReplicaMinFetchRate',
      'attributes'  => { 'Value' => {} },
    },
    {
      'name'   => '\"kafka.server\":type=\"ReplicaManager\",name=\"ISRShrinksPerSec\"',
      'resultAlias' => 'ISRShrinks',
      'attributes'  => {
        'Count' => { 'units' => 'secs' },
      },
    },
    {
      'name'   => '\"kafka.server\":type=\"ReplicaManager\",name=\"IsrExpandsPerSec\"',
      'resultAlias' => 'IsrExpands',
      'attributes'  => {
        'Count' => { 'units' => 'secs' },
      },
    },
    {
      'name'   => '\"kafka.server\":type=\"ReplicaManager\",name=\"LeaderCount\"',
      'resultAlias' => 'LeaderCount',
      'attributes'  => {
        'Value' => {},
      },
    },
    {
      'name'   => '\"kafka.server\":type=\"ReplicaManager\",name=\"PartitionCount\"',
      'resultAlias' => 'PartitionCount',
      'attributes'  => {
        'Value' => {},
      },
    },
    {
      'name'   => '\"kafka.server\":type=\"ReplicaManager\",name=\"UnderReplicatedPartitions\"',
      'resultAlias' => 'UnderReplicatedPartitions',
      'attributes'  => {
        'Value' => {},
      },
    },
  ]

  # query cassandra node for its JMX metrics
  jmxtrans::gangliawriter { 'kafka':
      jmx     => "${::fqdn}:9999",
      ganglia => "${ganglia_server}:8649",
      ganglia_group_name => 'kafka',
      objects => $jmx_kafka_objects,
  }
}
