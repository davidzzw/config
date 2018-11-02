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

