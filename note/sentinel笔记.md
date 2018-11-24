```
ContextUtil
CtSph
FlowSlot
AbstractLinkedProcessorSlot
HotParamSlotChainBuilder
DefaultProcessorSlotChain
```

####执行逻辑

* `CtSph -> entry`

* `CtSph-> lookProcessChain` 

* `SlotChainProvider -> newSlotChain`

* `SlotChainBuilder -> build`

* `chain -> entry` 

  

#### slot

* `DefaultSlotChainBuilder -> build`

```
chain.addLast(new NodeSelectorSlot());
chain.addLast(new ClusterBuilderSlot());
chain.addLast(new LogSlot());
chain.addLast(new StatisticSlot());
chain.addLast(new SystemSlot());
chain.addLast(new AuthoritySlot());
chain.addLast(new FlowSlot());
chain.addLast(new DegradeSlot());
```

### 限流

#### 基于QPS/并发数的流量控制

* `直接拒绝 （CONTROL_BEHAVIOR_DEFAULT）` 
* `冷启动（CONTROL_BEHAVIOR_WARM_UP） `
* `匀速器 (CONTROL_BEHAVIOR_RATE_LIMITER)（漏桶算法 ）`

### 熔断降级

* `平均响应时间(DEGRADE_GRADE_RT)  `
* `异常比例 (DEGRADE_GRADE_EXCEPTION)` 

