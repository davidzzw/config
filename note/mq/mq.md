### 问题

#### 消息堆积

##### rocketmq

* `broker中实际写入消息量和consumeQueue已经消费位移的偏差`
* `consumer端本身已经拉取消息的堆积 `

```
push模式下消息堆积
1、在18个队列的模式下，假设我们的consumer消费非常慢的话，理论上我们能够堆积100M*18=1800M=1.8G，假设这个consumer同时订阅多个topic的话，假设3个topic，那么就会超过1.8G*3=5.4G。在这种情况下很容易发生gc。 
```

```
多中心多活、灰度发布、熔断机制、消息存活期、流量的权重、消息去重、惊群效应问题的解决、背压模式、消息服务治理、MQTT消息服务
```

