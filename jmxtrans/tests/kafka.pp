$jmx_kafka_objects = [
    #BrokerTopicMetrics
    {
        'name'   => '\"kafka.server\":name=\"AllTopicsBytesInPerSec\",type=\"BrokerTopicMetrics\"',
        'resultAlias' => 'AllTopicsBytesInPerSec',
        'attributes'  => {
            'Count' => { 'units' => 'bytes', 'slope' => 'positive' },
        }
    },
    {
        'name'   => '\"kafka.server\":name=\"AllTopicsBytesOutPerSec\",type=\"BrokerTopicMetrics\"',
        'resultAlias' => 'AllTopicsBytesOutPerSec',
        'attributes'  => {
            'Count' => { 'units' => 'bytes', 'slope' => 'positive' }
        }
    },
    {
        'name'   => '\"kafka.server\":name=\"AllTopicsFailedFetchRequestsPerSec\",type=\"BrokerTopicMetrics\"',
        'resultAlias' => 'AllTopicsFailedFetchRequestsPerSec',
        'attributes'  => {
            'Count' => { 'units' => 'requests', 'slope' => 'positive' }
        }
    },
    {
        'name'   => '\"kafka.server\":name=\"AllTopicsFailedProduceRequestsPerSec\",type=\"BrokerTopicMetrics\"',
        'resultAlias' => 'AllTopicsFailedProduceRequestsPerSec',
        'attributes'  => {
            'Count' => { 'units' => 'requests', 'slope' => 'positive' }
        }
    },
    {
        'name'   => '\"kafka.server\":name=\"AllTopicsMessagesInPerSec\",type=\"BrokerTopicMetrics\"',
        'resultAlias' => 'AllTopicsMessagesInPerSec',
        'attributes'  => {
            'Count' => { 'units' => 'messages', 'slope' => 'positive' }
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