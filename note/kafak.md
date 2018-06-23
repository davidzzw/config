###1 Create a topic

kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic test

###2 Query list

kafka-topics.sh --list --zookeeper localhost:2181

###3 Send some messages

kafka-console-producer.sh --broker-list localhost:9092 --topic test

###4 Start a consumer

kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --from-beginning

###5 修改Topic

kafka-topics.sh --alter --zookeeper localhost:2181 --partitions 11 --topic Demo1

###6 删除指定Topic

kafka_2.12-0.11.0.0]# bin/kafka-topics.sh --delete --zookeeper localhost:2181 --topic Demo1
Note中指出该Topic并没有真正的删除，如果真删除，需要把server.properties中的delete.topic.enable置为true

###7 给指定的Topic增加配置项，如给一个增加max message size值为128000

kafka-topics.sh --alter --zookeeper localhost:2181 --topic Demo1 --config max.message.bytes=128000
WARNING: Altering topic configuration from this script has been deprecated and may be removed in future releases.

         Going forward, please use kafka-configs.sh for this functionality Updated config for topic "Demo1".
　warning中指出该命令已经过期，将来可能被删除，替代的命令是使用kafka-config.sh。新命令如下：

kafka-configs.sh --alter --zookeeper localhost:2181 --entity-type topics --entity-name Demo1 --add-config max.message.bytes=12800
Completed Updating config for entity: topic 'Demo1'.

### coordinator

```
确定consumer group位移信息写入__consumers_offsets的哪个分区。具体计算公式：
__consumers_offsets partition# = Math.abs(groupId.hashCode() % groupMetadataTopicPartitionCount)  注意：groupMetadataTopicPartitionCount由offsets.topic.num.partitions指定，默认是50个分区。
该分区leader所在的broker就是被选定的coordinator
```



###协议

```
Heartbeat请求：consumer需要定期给coordinator发送心跳来表明自己还活着
LeaveGroup请求：主动告诉coordinator我要离开consumer group
SyncGroup请求：group leader把分配方案告诉组内所有成员
JoinGroup请求：成员请求加入组
DescribeGroup请求：显示组的所有信息，包括成员信息，协议名称，分配方案，订阅信息等。通常该请求是给管理员使用
```



```
./kafka-run-class.sh kafka.tools.ConsumerOffsetChecker --zookeeper **:2181 --group ** --topic **
./kafka-consumer-groups.sh --zookeeper localhost:2181 --describe --group my-group
```
