class jmxtrans::cassandra {
  $ganglia_server = hiera('controller')

  $jmx_cassandra_objects = [
      # Commit Log
      {
          'name'   => 'org.apache.cassandra.db:type=Commitlog',
          'resultAlias' => 'Commitlog',
          'attributes'  => {
              'CompletedTasks'        => { 'units' => 'tasks', 'slope' => 'positive' },
              'PendingTasks'          => { 'units' => 'tasks', 'slope' => 'both' },
              'TotalCommitlogSize'    => { 'units' => 'bytes', 'slope' => 'positive' },
          }
      },
      # Compaction Manager
      {
          'name'   => 'org.apache.cassandra.db:type=CompactionManager',
          'resultAlias' => 'CompactionManager',
          'attributes'  => {
              'PendingTasks'      => { 'units' => 'tasks', 'slope' => 'both' },
              'CompletedTasks'    => { 'units' => 'tasks', 'slope' => 'positive' },
          }
      },
      # StorageProxy
      {
          'name'   => 'org.apache.cassandra.db:type=StorageProxy',
          'resultAlias' => 'StorageProxy',
          'attributes'  => {
              'HintsInProgress'          => { 'units' => 'hints' },
              'RangeOperations'          => { 'units' => 'operations' },
              'ReadOperations'           => { 'units' => 'operations' },
              'WriteOperations'          => { 'units' => 'operations' },
              'RecentRangeLatencyMicros' => { 'units' => 'micros' } ,
              'RecentWriteLatencyMicros' => { 'units' => 'micros' } ,
              'RecentReadLatencyMicros'  => { 'units' => 'micros' } ,
              'TotalHints'               => { 'units' => 'hints' } ,
              'TotalRangeLatencyMicros'  => { 'units' => 'micros' } ,
              'TotalWriteLatencyMicros'  => { 'units' => 'micros' } ,
              'TotalReadLatencyMicro'    => { 'units' => 'micros' } ,
          }
      },
      # StorageService
      {
          'name'   => 'org.apache.cassandra.db:type=StorageService',
          'resultAlias' => 'StorageService',
          'attributes'  => {
              'ExceptionCount'    => { 'units' => 'exceptions' } ,
              'Load'              => { } ,
          }
      },
      # MessagingService
      {
          'name'   => 'org.apache.cassandra.net:type=MessagingService',
          'resultAlias' => 'MessagingService',
          'attributes'  => {
              'RecentTotalTimouts' => { 'units' => 'timeouts' } ,
              'TotalTimeouts'      => { 'units' => 'timeouts' } ,
          }
      },
      # Stage/MutationStage
      {
          'name'   => 'org.apache.cassandra.request:type=MutationStage',
          'resultAlias' => 'Stage.MutationStage',
          'attributes'  => {
              'ActiveCount'           => { 'units' => 'tasks' } ,
              'CompletedTasks'        => { 'units' => 'tasks' } ,
              'CurrentlyBlockedTasks' => { 'units' => 'tasks' } ,
              'PendingTasks'          => { 'units' => 'tasks' } ,
              'TotalBlockedTasks'     => { 'units' => 'tasks' } ,
          }
      },
      # Stage/ReadRepairStage
      {
          'name'   => 'org.apache.cassandra.request:type=ReadRepairStage',
          'resultAlias' => 'Stage.ReadRepairStage',
          'attributes'  => {
              'ActiveCount'           => { 'units' => 'tasks' } ,
              'CompletedTasks'        => { 'units' => 'tasks' } ,
              'CurrentlyBlockedTasks' => { 'units' => 'tasks' } ,
              'PendingTasks'          => { 'units' => 'tasks' } ,
              'TotalBlockedTasks'     => { 'units' => 'tasks' } ,
          }
      },
      # Stage/ReadStage
      {
          'name'   => 'org.apache.cassandra.request:type=ReadStage',
          'resultAlias' => 'Stage.ReadStage',
          'attributes'  => {
              'ActiveCount'           => { 'units' => 'tasks' } ,
              'CompletedTasks'        => { 'units' => 'tasks' } ,
              'CurrentlyBlockedTasks' => { 'units' => 'tasks' } ,
              'PendingTasks'          => { 'units' => 'tasks' } ,
              'TotalBlockedTasks'     => { 'units' => 'tasks' } ,
          }
      },
      # Stage/ReplicateOnWriteStage
      {
          'name'   => 'org.apache.cassandra.request:type=ReplicateOnWriteStage',
          'resultAlias' => 'Stage.ReplicateOnWriteStage',
          'attributes'  => {
              'ActiveCount'           => { 'units' => 'tasks' } ,
              'CompletedTasks'        => { 'units' => 'tasks' } ,
              'CurrentlyBlockedTasks' => { 'units' => 'tasks' } ,
              'PendingTasks'          => { 'units' => 'tasks' } ,
              'TotalBlockedTasks'     => { 'units' => 'tasks' } ,
          }
      },
      # Stage/RequestResponseStage
      {
          'name'   => 'org.apache.cassandra.request:type=RequestResponseStage',
          'resultAlias' => 'Stage.RequestResponseStage',
          'attributes'  => {
              'ActiveCount'           => { 'units' => 'tasks' } ,
              'CompletedTasks'        => { 'units' => 'tasks' } ,
              'CurrentlyBlockedTasks' => { 'units' => 'tasks' } ,
              'PendingTasks'          => { 'units' => 'tasks' } ,
              'TotalBlockedTasks'     => { 'units' => 'tasks' } ,
          }
      },
      # Internal/AntiEntropySessions
      {
          'name'   => 'org.apache.cassandra.internal:type=AntiEntropySessions',
          'resultAlias' => 'Internal.AntiEntropySessions',
          'attributes'  => {
              'ActiveCount'           => { 'units' => 'tasks' } ,
              'CompletedTasks'        => { 'units' => 'tasks' } ,
              'CurrentlyBlockedTasks' => { 'units' => 'tasks' } ,
              'PendingTasks'          => { 'units' => 'tasks' } ,
              'TotalBlockedTasks'     => { 'units' => 'tasks' } ,
          }
      },
      # Internal/AntiEntropyStage
      {
          'name'   => 'org.apache.cassandra.internal:type=AntiEntropyStage',
          'resultAlias' => 'Internal.AntiEntropyStage',
          'attributes'  => {
              'ActiveCount'           => { 'units' => 'tasks' } ,
              'CompletedTasks'        => { 'units' => 'tasks' } ,
              'CurrentlyBlockedTasks' => { 'units' => 'tasks' } ,
              'PendingTasks'          => { 'units' => 'tasks' } ,
              'TotalBlockedTasks'     => { 'units' => 'tasks' } ,
          }
      },
      # Internal/FlushWriter
      {
          'name'   => 'org.apache.cassandra.internal:type=FlushWriter',
          'resultAlias' => 'Internal.FlushWriter',
          'attributes'  => {
              'ActiveCount'           => { 'units' => 'tasks' } ,
              'CompletedTasks'        => { 'units' => 'tasks' } ,
              'CurrentlyBlockedTasks' => { 'units' => 'tasks' } ,
              'PendingTasks'          => { 'units' => 'tasks' } ,
              'TotalBlockedTasks'     => { 'units' => 'tasks' } ,
          }
      },
      # Internal/GossipStage
      {
          'name'   => 'org.apache.cassandra.internal:type=GossipStage',
          'resultAlias' => 'Internal.GossipStage',
          'attributes'  => {
              'ActiveCount'           => { 'units' => 'tasks' } ,
              'CompletedTasks'        => { 'units' => 'tasks' } ,
              'CurrentlyBlockedTasks' => { 'units' => 'tasks' } ,
              'PendingTasks'          => { 'units' => 'tasks' } ,
              'TotalBlockedTasks'     => { 'units' => 'tasks' } ,
          }
      },
      # Internal/HintedHandoff
      {
          'name'   => 'org.apache.cassandra.internal:type=HintedHandoff',
          'resultAlias' => 'Internal.FlushWriter',
          'attributes'  => {
              'ActiveCount'           => { 'units' => 'tasks' } ,
              'CompletedTasks'        => { 'units' => 'tasks' } ,
              'CurrentlyBlockedTasks' => { 'units' => 'tasks' } ,
              'PendingTasks'          => { 'units' => 'tasks' } ,
              'TotalBlockedTasks'     => { 'units' => 'tasks' } ,
          }
      },
      # Internal/InternalResponseStage
      {
          'name'   => 'org.apache.cassandra.internal:type=InternalResponseStage',
          'resultAlias' => 'Internal.InternalResponseStage',
          'attributes'  => {
              'ActiveCount'           => { 'units' => 'tasks' } ,
              'CompletedTasks'        => { 'units' => 'tasks' } ,
              'CurrentlyBlockedTasks' => { 'units' => 'tasks' } ,
              'PendingTasks'          => { 'units' => 'tasks' } ,
              'TotalBlockedTasks'     => { 'units' => 'tasks' } ,
          }
      },
      # Internal/MemtablePostFlusher
      {
          'name'   => 'org.apache.cassandra.internal:type=MemtablePostFlusher',
          'resultAlias' => 'Internal.MemtablePostFlusher',
          'attributes'  => {
              'ActiveCount'           => { 'units' => 'tasks' } ,
              'CompletedTasks'        => { 'units' => 'tasks' } ,
              'CurrentlyBlockedTasks' => { 'units' => 'tasks' } ,
              'PendingTasks'          => { 'units' => 'tasks' } ,
              'TotalBlockedTasks'     => { 'units' => 'tasks' } ,
          }
      },
      # Internal/MigrationStage
      {
          'name'   => 'org.apache.cassandra.internal:type=MigrationStage',
          'resultAlias' => 'Internal.MigrationStage',
          'attributes'  => {
              'ActiveCount'           => { 'units' => 'tasks' } ,
              'CompletedTasks'        => { 'units' => 'tasks' } ,
              'CurrentlyBlockedTasks' => { 'units' => 'tasks' } ,
              'PendingTasks'          => { 'units' => 'tasks' } ,
              'TotalBlockedTasks'     => { 'units' => 'tasks' } ,
          }
      },
      # Internal/MiscStage
      {
          'name'   => 'org.apache.cassandra.internal:type=MiscStage',
          'resultAlias' => 'Internal.MiscStage',
          'attributes'  => {
              'ActiveCount'           => { 'units' => 'tasks' } ,
              'CompletedTasks'        => { 'units' => 'tasks' } ,
              'CurrentlyBlockedTasks' => { 'units' => 'tasks' } ,
              'PendingTasks'          => { 'units' => 'tasks' } ,
              'TotalBlockedTasks'     => { 'units' => 'tasks' } ,
          }
      },
      # Internal/StreamStage
      {
          'name'   => 'org.apache.cassandra.internal:type=StreamStage',
          'resultAlias' => 'Internal.StreamStage',
          'attributes'  => {
              'ActiveCount'           => { 'units' => 'tasks' } ,
              'CompletedTasks'        => { 'units' => 'tasks' } ,
              'CurrentlyBlockedTasks' => { 'units' => 'tasks' } ,
              'PendingTasks'          => { 'units' => 'tasks' } ,
              'TotalBlockedTasks'     => { 'units' => 'tasks' } ,
          }
      },
      # JAVA HEAP
      {
          'name'   => 'java.lang:type=Memory',
          'resultAlias' => 'Heap',
          'attributes'  => {
              'HeapMemoryUsage'       => { 'units' => 'gb' } ,
              'NonHeapMemoryUsage'    => { 'units' => 'gb' } ,
          }
      },
      # JAVA GC
      {
          'name'   => 'java.lang:type=GarbageCollector,name=*',
          'resultAlias' => 'GC',
          'attributes'  => {
              'CollectionCount'   => { 'units' => 'ms' } ,
              'CollectionTime'    => { 'units' => 'ms' } ,
          }
      },
      # JAVA Threading
      {
          'name'   => 'java.lang:type=Threading',
          'resultAlias' => 'Threading',
          'attributes'  => {
              'DaemonThreadCount'         => { 'units' => 'count' } ,
              'PeakThreadCount'           => { 'units' => 'count' } ,
              'ThreadCount'               => { 'units' => 'count' } ,
              'TotalStartedThreadCount'   => { 'units' => 'count' } ,
          }
      },
      #
      # Metrics for Individual Column Families, Replace keyspace and columnfamily
      #
      {
          'name'   => 'org.apache.cassandra.db:type=ColumnFamilies,keyspace=system_auth,columnfamily=users',
          'resultAlias' => 'ColumnFamilies_Users',
          'attributes'  => {
              'BloomFilterDiskSpaceUsed'          => { },
              'BloomFilterFalsePositives'         => { },
              'BloomFilterFalseRatio'             => { },
              'CompressionRatio'                  => { },
              'LiveDiskSpaceUsed'                 => { },
              'TotalDiskSpaceUsed'                => { },
              'LiveSSTableCount'                  => { },
              'MinRowSize'                        => { },
              'MeanRowSize'                       => { },
              'MaxRowSize'                        => { },
              'MemtableColumnsCount'              => { },
              'MemtableDataSize'                  => { },
              'MemtableSwitchCount'               => { },
              'RecentBloomFilterFalsePositives'   => { },
              'RecentBloomFilterFalseRatio'       => { },
              'UnleveledSSTables'                 => { },
              'RecentReadLatencyMicros'           => { },
              'RecentWriteLatencyMicros'          => { },
              'TotalReadLatencyMicros'            => { },
              'TotalWriteLatencyMicros'           => { },
              'PendingTasks'                      => { },
              'ReadCount'                         => { },
              'WriteCount'                        => { },
          }
      },
      #
      # Custom metrics for row cache and key cache
      #
      # # Caches/MyColumnFamily1/RowCache
      # {
      #     'name'   => 'org.apache.cassandra.db:type=Caches,keyspace=my_ketspaces,cache=MyColumnFamily1RowCache',
      #     'resultAlias' => 'Caches/MyColumnFamily1/RowCache',
      #     'attributes'  => {
      #         'Capacity',
      #         'Hits',
      #         'RecentHitRate',
      #         'Requests',
      #         'Size',
      #     }
      # },
      # # Caches/MyColumnFamily1/KeyCache
      # {
      #     'name'   => 'org.apache.cassandra.db:type=Caches,keyspace=my_ketspaces,cache=MyColumnFamily1KeyCache',
      #     'resultAlias' => 'Caches/MyColumnFamily1/KeyCache',
      #     'attributes'  => {
      #         'Capacity',
      #         'Hits',
      #         'RecentHitRate',
      #         'Requests',
      #         'Size',
      #     }
      # },
  ]

  # query cassandra node for its JMX metrics
  jmxtrans::gangliawriter { 'cassandra':
      jmx     => "${::fqdn}:7199",
      ganglia => "${ganglia_server}:8649",
      ganglia_group_name => 'cassandra',
      objects => $jmx_cassandra_objects,
  }
}
