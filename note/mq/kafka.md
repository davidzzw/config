###事务

### 幂等

###选举

### 操作

####1 Create a topic

`kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic test`

####2 Query list

`kafka-topics.sh --list --zookeeper localhost:2181`

####3 Send some messages

`kafka-console-producer.sh --broker-list localhost:9092 --topic test`

####4 Start a consumer

`kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --from-beginning`

####5 修改Topic

`kafka-topics.sh --alter --zookeeper localhost:2181 --partitions 11 --topic Demo1`

####6 删除指定Topic

`kafka_2.12-0.11.0.0]# bin/kafka-topics.sh --delete --zookeeper localhost:2181 --topic Demo1 Note中指出该Topic并没有真正的删除，如果真删除，需要把server.properties中的delete.topic.enable置为true`

####7 给指定的Topic增加配置项，如给一个增加max message size值为128000

`kafka-topics.sh --alter --zookeeper localhost:2181 --topic Demo1 --config max.message.bytes=128000 WARNING: Altering topic configuration from this script has been deprecated and may be removed in future releases`

    Going forward, please use kafka-configs.sh for this functionality Updated config for topic "Demo1"
`warning中指出该命令已经过期，将来可能被删除，替代的命令是使用kafka-config.sh`

`新命令如下：kafka-configs.sh --alter --zookeeper localhost:2181 --entity-type topics --entity-name Demo1 --add-config max.message.bytes=12800 Completed Updating config for entity: topic 'Demo1'`

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

`kafka-run-class.sh kafka.tools.ConsumerOffsetChecker --broker-info --group dapan-storm-topology --zookeeper escnode1:2181`

### 日志

`二分法查找`

### partition

####segment

### ISR(In-Sync Replicas)

`ISR中包括：leader和follower`

```
Kafka的ISR的管理最终都会反馈到Zookeeper节点上。具体位置为：/brokers/topics/[topic]/partitions/[partition]/state。目前有两个地方会对这个Zookeeper的节点进行维护：
Controller来维护：Kafka集群中的其中一个Broker会被选举为Controller，主要负责Partition管理和副本状态管理，也会执行类似于重分配partition之类的管理任务。在符合某些特定条件下，Controller下的LeaderSelector会选举新的leader，ISR和新的leader_epoch及controller_epoch写入Zookeeper的相关节点中。同时发起LeaderAndIsrRequest通知所有的replicas。
leader来维护：leader有单独的线程定期检测ISR中follower是否脱离ISR, 如果发现ISR变化，则会将新的ISR的信息返回到Zookeeper的相关节点中。
```



###OSR（Outof-Sync Replicas）

### AR(Assigned Replicas)

`AR=ISR+OSR`

###LEO(LogEndOffset)

`每个partition的log最后一条Message的位置`

###HW(HighWatermark)

`consumer能够看到的此partition的位置`

###LSO

###LW

###Log Retention

###Log Compaction

### 参数



### 面试题

- Kafka的用途有哪些？使用场景如何？
- Kafka中的ISR、AR又代表什么？ISR的伸缩又指什么
- Kafka中的HW、LEO、LSO、LW等分别代表什么？
- Kafka中是怎么体现消息顺序性的？
- Kafka中的分区器、序列化器、拦截器是否了解？它们之间的处理顺序是什么？
- Kafka生产者客户端的整体结构是什么样子的？
- Kafka生产者客户端中使用了几个线程来处理？分别是什么？
- Kafka的旧版Scala的消费者客户端的设计有什么缺陷？
- “消费组中的消费者个数如果超过topic的分区，那么就会有消费者消费不到数据”这句话是否正确？如果不正确，那么有没有什么hack的手段？
- 消费者提交消费位移时提交的是当前消费到的最新消息的offset还是offset+1?
- 有哪些情形会造成重复消费？
- 那些情景下会造成消息漏消费？
- KafkaConsumer是非线程安全的，那么怎么样实现多线程消费？
- 简述消费者与消费组之间的关系
- 当你使用kafka-topics.sh创建（删除）了一个topic之后，Kafka背后会执行什么逻辑？
- topic的分区数可不可以增加？如果可以怎么增加？如果不可以，那又是为什么？
- topic的分区数可不可以减少？如果可以怎么减少？如果不可以，那又是为什么？
- 创建topic时如何选择合适的分区数？
- Kafka目前有那些内部topic，它们都有什么特征？各自的作用又是什么？
- 优先副本是什么？它有什么特殊的作用？
- Kafka有哪几处地方有分区分配的概念？简述大致的过程及原理
- 简述Kafka的日志目录结构
- Kafka中有那些索引文件？
- 如果我指定了一个offset，Kafka怎么查找到对应的消息？
- 如果我指定了一个timestamp，Kafka怎么查找到对应的消息？
- 聊一聊你对Kafka的Log Retention的理解
- 聊一聊你对Kafka的Log Compaction的理解
- 聊一聊你对Kafka底层存储的理解（页缓存、内核层、块层、设备层）
- 聊一聊Kafka的延时操作的原理
- 聊一聊Kafka控制器的作用
- 消费再均衡的原理是什么？（提示：消费者协调器和消费组协调器）
- Kafka中的幂等是怎么实现的
- Kafka中的事务是怎么实现的（这题我去面试6家被问4次，照着答案念也要念十几分钟，面试官简直凑不要脸。实在记不住的话...只要简历上不写精通Kafka一般不会问到，我简历上写的是“熟悉Kafka，了解RabbitMQ....”）
- Kafka中有那些地方需要选举？这些地方的选举策略又有哪些？
- 失效副本是指什么？有那些应对措施？
- 多副本下，各个副本中的HW和LEO的演变过程
- 为什么Kafka不支持读写分离？
- Kafka在可靠性方面做了哪些改进？（HW, LeaderEpoch）
- Kafka中怎么实现死信队列和重试队列？
- Kafka中的延迟队列怎么实现（这题被问的比事务那题还要多！！！听说你会Kafka，那你说说延迟队列怎么实现？）
- Kafka中怎么做消息审计？
- Kafka中怎么做消息轨迹？
- Kafka中有那些配置参数比较有意思？聊一聊你的看法
- Kafka中有那些命名比较有意思？聊一聊你的看法
- Kafka有哪些指标需要着重关注？
- 怎么计算Lag？(注意read_uncommitted和read_committed状态下的不同)
- Kafka的那些设计让它有如此高的性能？
- Kafka有什么优缺点？
- 还用过什么同质类的其它产品，与Kafka相比有什么优缺点？
- 为什么选择Kafka?
- 在使用Kafka的过程中遇到过什么困难？怎么解决的？
- 怎么样才能确保Kafka极大程度上的可靠性？
- 聊一聊你对Kafka生态的理解