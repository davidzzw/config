### 问题

#### 消息堆积

##### rocketmq

* `broker中实际写入消息量和consumeQueue已经消费位移的偏差`
* `consumer端本身已经拉取消息的堆积 `

```
push模式下消息堆积
    1、在18个队列的模式下，假设我们的consumer消费非常慢的话，理论上我们能够堆积100M*18=1800M=1.8G，假设这个consumer同时订阅多个topic的话，假设3个topic，那么就会超过1.8G*3=5.4G。在这种情况下很容易发生gc。 
```

