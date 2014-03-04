$jmx_kafka_objects = [
  #BrokerTopicMetrics
  {
    'name'   => '\"kafka.server\":name=\"AllTopicsBytesInPerSec\",type=\"BrokerTopicMetrics\"',
    'resultAlias' => 'AllTopicsBytesInPerSec',
    'attributes'  => {
      'Count' => { 'units' => 'bytes' },
    }
  },
  {
    'name'   => '\"kafka.server\":name=\"AllTopicsMessagesInPerSec\",type=\"BrokerTopicMetrics\"',
    'resultAlias' => 'AllTopicsMessagesInPerSec',
    'attributes'  => {
      'Count' => { 'units' => 'bytes' },
    }
  },
  {
    'name'   => '\"kafka.network\":name=\"{Produce|Fetch-consumer|Fetch-follower}-RequestsPerSec\",type=\"RequestMetrics\"',
    'resultAlias' => 'RequestRate',
    'attributes'  => {
      'Count' => { 'units' => 'requests' },
    }
  },
  {
    'name'   => '\"kafka.server\":name=\"AllTopicsBytesOutPerSec\",type=\"BrokerTopicMetrics\"',
    'resultAlias' => 'AllTopicsBytesOutPerSec',
    'attributes'  => {
      'Count' => { 'units' => 'bytes' },
    }
  },
  {
    'name'   => '\"kafka.log\":name=\"LogFlushRateAndTimeMs\",type=\"LogFlushStats\"',
    'resultAlias' => 'LogFlushRateAndTime',
    'attributes'  => {
      'Count' => { 'units' => 'millisecs' },
    }
  },
  {
    'name'   => '\"kafka.server\":name=\"UnderReplicatedPartitions\",type=\"ReplicaManager\"',
    'resultAlias' => 'UnderReplicatedPartitions',
    'attributes'  => {
      'Count' => { 'units' => 'number' },
    }
  },
  {
    'name'   => '\"kafka.controller\":name=\"ActiveControllerCount\",type=\"KafkaController\"',
    'resultAlias' => 'IsControllerActiveOnBroker',
    'attributes'  => {
      'Count' => { 'units' => '#_of_controllers' },
    }
  },
  {
    'name'   => '\"kafka.controller\":name=\"LeaderElectionRateAndTimeMs\",type=\"ControllerStats\"',
    'resultAlias' => 'LeaderElectionRate',
    'attributes'  => {
      'Count' => { 'units' => 'millisecs' },
    }
  },
  {
    'name'   => '\"kafka.controller\":name=\"UncleanLeaderElectionsPerSec\",type=\"ControllerStats\"',
    'resultAlias' => 'UncleanLeaderElectionRate',
    'attributes'  => {
      'Count' => { 'units' => 'count' },
    }
  },
  # mostly even across brokers
  {
    'name'   => '\"kafka.server\":name=\"PartitionCount\",type=\"ReplicaManager\"',
    'resultAlias' => 'PartitionCounts',
    'attributes'  => {
      'Count' => { 'units' => '#_of_partitions' },
    }
  },
  # mostly even across brokers
  {
    'name'   => '\"kafka.server\":name=\"LeaderCount\",type=\"ReplicaManager\"',
    'resultAlias' => 'LeaderReplicaCounts',
    'attributes'  => {
      'Count' => { 'units' => '#_of_replicas' },
    }
  },
  # If a broker goes down, ISR for some of the partitions will shrink. When that
  # broker is up again, ISR will be expanded once the replicas are fully caught
  # up. Other than that, the expected value for both ISR shrink rate and
  # expansion rate is 0.
  {
    'name'   => '\"kafka.server\":name=\"ISRShrinksPerSec\",type=\"ReplicaManager\"',
    'resultAlias' => 'ISRShrinksPerSec',
    'attributes'  => {
      'Count' => { 'units' => 'secs' },
    }
  },
  {
    'name'   => '\"kafka.server\":name=\"ISRExpandsPerSec\",type=\"ReplicaManager\"',
    'resultAlias' => 'ISRExpandsPerSec',
    'attributes'  => {
      'Count' => { 'units' => 'secs' },
    }
  },
  # Max lag in messages btw follower and leader replicas
  {
    'name'   => '\"kafka.server\":name=\"([-.\\w]+)-MaxLag\",type=\"ReplicaFetcherManager\"',
    'resultAlias' => 'MessagesLagBwFollowerAndLeader',
    'attributes'  => {
      'Count' => { 'units' => 'messages' },
    }
  },
  # Lag in messages per follower replica
  {
    'name'   => '\"kafka.server\":name=\"([-.\\w]+)-ConsumerLag\",type=\"FetcherLagMetrics\"',
    'resultAlias' => 'MessagesLagPerFollowerReplica',
    'attributes'  => {
      'Count' => { 'units' => 'messages' },
    }
  },
  # Requests waiting in the producer purgatory
  {
    'name'   => '\"kafka.server\":name=\"PurgatorySize\",type=\"ProducerRequestPurgatory\"',
    'resultAlias' => 'ProducerPurgatorySize',
    'attributes'  => {
      'Count' => { 'units' => 'requests' },
    }
  },
  # Requests waiting in the fetch purgatory
  {
    'name'   => '\"kafka.server\":name=\"PurgatorySize\",type=\"FetchRequestPurgatory\"',
    'resultAlias' => 'FetchRequestPurgatory',
    'attributes'  => {
      'Count' => { 'units' => 'requests' },
    }
  },
  # Request total time
  {
    'name'   => '\"kafka.network\":name=\"{Produce|Fetch-Consumer|Fetch-Follower}-TotalTimeMs\",type=\"RequestMetrics\"',
    'resultAlias' => 'RequestTotalTime',
    'attributes'  => {
      'Count' => { 'units' => 'ms' },
    }
  },
  # Time the request waiting in the request queue
  {
    'name'   => '\"kafka.network\":name=\"{Produce|Fetch-Consumer|Fetch-Follower}-QueueTimeMs\",type=\"RequestMetrics\"',
    'resultAlias' => 'RequestTotalTimeInQueue',
    'attributes'  => {
      'Count' => { 'units' => 'ms' },
    }
  },
  # Time the request being processed at the leader
  {
    'name'   => '\"kafka.network\":name=\"{Produce|Fetch-Consumer|Fetch-Follower}-LocalTimeMs\",type=\"RequestMetrics\"',
    'resultAlias' => 'RequestTotalTimeAtLeader',
    'attributes'  => {
      'Count' => { 'units' => 'ms' },
    }
  },
  # Time the request waits for the follower
  {
    'name'   => '\"kafka.network\":name=\"{Produce|Fetch-Consumer|Fetch-Follower}-RemoteTimeMs\",type=\"RequestMetrics\"',
    'resultAlias' => 'RequestTotalTimeForFollower',
    'attributes'  => {
      'Count' => { 'units' => 'ms' },
    }
  },
  # Time to send the response
  {
    'name'   => '\"kafka.network\":name=\"{Produce|Fetch-Consumer|Fetch-Follower}-ResponseSendTimeMs\",type=\"RequestMetrics\"',
    'resultAlias' => 'ResponseTime',
    'attributes'  => {
      'Count' => { 'units' => 'ms' },
    }
  },
  # Number of messages the consumer lags behind the broker among all partitions consumed
  {
    'name'   => '\"kafka.network\":name=\"([-.\\w]+)-MaxLag\",type=\"ConsumerFetcherManager\"',
    'resultAlias' => 'MessagesConsumerLag',
    'attributes'  => {
      'Count' => { 'units' => 'messages' },
    }
  },
  # The min fetch rate among all fetchers to brokers in a consumer
  {
    'name'   => '\"kafka.network\":name=\"([-.\\w]+)-MinFetch\",type=\"ConsumerFetcherManager\"',
    'resultAlias' => 'MinFetchRate',
    'attributes'  => {
      'Count' => { 'units' => 'messages' },
    }
  },
  #

  # {
  #     'name'   => 'kafka:type=kafka.LogFlushStats',
  #     'attrs'  => {
  #         'FlushesPerSecond' => { 'units' => 'flushes' }, # 'both' is ganglia default slope value. Leaving it off here.
  #         'NumFlushes'       => { 'units' => 'flushes', slope => 'positive' },
  #         'AvgFlushMs'       => { 'units' => 'ms' },
  #         'MaxFlushMs'       => { 'units' => 'ms' },
  #         'TotalFlushMs'     => { 'units' => 'ms', 'slope' => 'positive' },
  #     }
  # },
  # {
  #     'name'   => 'kafka:type=kafka.SocketServerStats',
  #     'attrs'  => {
  #         'BytesReadPerSecond'       => { 'units' => 'bytes'},
  #         'BytesWrittenPerSecond'    => { 'units' => 'bytes'},

  #         'ProduceRequestsPerSecond' => { 'units' => 'requests'},
  #         'AvgProduceRequestMs'      => { 'units' => 'requests'},
  #         'MaxProduceRequestMs'      => { 'units' => 'requests'},
  #         'TotalProduceRequestMs'    => { 'units' => 'ms' }

  #         'FetchRequestsPerSecond'   => { 'units' => 'requests' },
  #         'AvgFetchRequestMs'        => { 'units' => 'ms' },
  #         'MaxFetchRequestMs'        => { 'units' => 'ms' },
  #         'TotalFetchRequestMs'      => { 'units' => 'ms' },
  #     }
  # }
]

  # query kafka1 broker for its JMX metrics
  jmxtrans::gangliawriter { 'kafka1':
    jmx     => 'localhost:9999',
    ganglia => 'localhost:8649',
    ganglia_group_name => 'kafka',
    objects => $jmx_kafka_objects,
  }

# query kafka2 broker for its JMX metrics
# jmxtrans::gangliawriter { 'kafka2':
#     jmx     => 'kafka2:9999',
#     ganglia => '192.168.10.50:8469',
#     ganglia_group_name => 'kafka',
#     objects => $jmx_kafka_objects,
# }
