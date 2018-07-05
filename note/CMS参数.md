###cms jvm参数

`UseConcMarkSweepGC `:`使用CMS垃圾回收期 `

`ExplicitGCInvokesConcurrent `:`使用CMS收集器来触发Full gc `

`ExplicitGCInvokesConcurrentAndUnloadsClasses: `:`保证当有系统GC调用时，永久代也被包括进CMS垃圾回收的范围内 `

`UseCMSInitiatingOccupancyOnly `:`使用手动定义初始化定义开始CMS收集,禁止hostspot自行触发CMS GC `

```
我们用-XX+UseCMSInitiatingOccupancyOnly标志来命令JVM不基于运行时收集的数据来启动CMS垃圾收集周期。而是，当该标志被开启时，JVM通过CMSInitiatingOccupancyFraction的值进行每一次CMS收集，而不仅仅是第一次。然而，请记住大多数情况下，JVM比我们自己能作出更好的垃圾收集决策。因此，只有当我们充足的理由(比如测试)并且对应用程序产生的对象的生命周期有深刻的认知时，才应该使用该标志。
```

`CMSInitiatingOccupancyFraction `:`使用cms作为垃圾回收，老年代达到多少百分比开始CMS收集 `

`CMSPermGenSweepingEnabled`:`否会清理持久代 `

`CMSInitiatingPermOccupancyFraction `:`设置Perm Gen使用到达多少比率时触发 `

`CMSClassUnloadingEnabled `:`在使用CMS垃圾回收机制的时候是否启用类卸载功能,如果希望对永久代进行垃圾回收，可用设置标志-XX:+CMSClassUnloadingEnabled `

`CMSScheduleRemarkEdenSizeThreshold `:`新生代Eden区的内存使用量大于参数 `

`UseCMSCompactAtFullCollection `:`用于在Full GC之后增加一个碎片整理过程 `

`CMSFullGCsBeforeCompaction `:`多少次后进行内存压缩 `

`CMSScavengeBeforeRemark `:`开启或关闭在CMS重新标记阶段之前的清除（YGC）尝试 `

`CMSParallelRemarkEnabled `:`降低标记停顿 `

`CMSIncrementalMode `:`设置为增量模式 ,用于单CPU情况`

#### **UseCMSCompactAtFullCollection 与 CMSFullGCsBeforeCompaction** 

```
CMS GC要决定是否在full GC时做压缩，会依赖几个条件。其中， 
第一种条件，UseCMSCompactAtFullCollection 与 CMSFullGCsBeforeCompaction 是搭配使用的；前者目前默认就是true了，也就是关键在后者上。 
第二种条件是用户调用了System.gc()，而且DisableExplicitGC没有开启。 
第三种条件是young gen报告接下来如果做增量收集会失败；简单来说也就是young gen预计old gen没有足够空间来容纳下次young GC晋升的对象。 
上述三种条件的任意一种成立都会让CMS决定这次做full GC时要做压缩。 

CMSFullGCsBeforeCompaction 说的是，在上一次CMS并发GC执行过后，到底还要再执行多少次full GC才会做压缩。默认是0，也就是在默认配置下每次CMS GC顶不住了而要转入full GC的时候都会做压缩。 把CMSFullGCsBeforeCompaction配置为10，就会让上面说的第一个条件变成每隔10次真正的full GC才做一次压缩（而不是每10次CMS并发GC就做一次压缩，目前VM里没有这样的参数）。这会使full GC更少做压缩，也就更容易使CMS的old gen受碎片化问题的困扰。 本来这个参数就是用来配置降低full GC压缩的频率，以期减少某些full GC的暂停时间。CMS回退到full GC时用的算法是mark-sweep-compact，但compaction是可选的，不做的话碎片化会严重些但这次full GC的暂停时间会短些；这是个取舍。
```

#### **-XX:CMSInitiatingOccupancyFraction=70 和-XX:+UseCMSInitiatingOccupancyOnly** 

```
两个设置一般配合使用,一般用于『降低CMS GC频率或者增加频率、减少GC时长』的需求
-XX:CMSInitiatingOccupancyFraction=70 是指设定CMS在对内存占用率达到70%的时候开始GC(因为CMS会有浮动垃圾,所以一般都较早启动GC);
-XX:+UseCMSInitiatingOccupancyOnly 只是用设定的回收阈值(上面指定的70%),如果不指定,JVM仅在第一次使用设定值,后续则自动调整.
```

#### **-XX:+CMSScavengeBeforeRemark** 

```
   在CMS GC前启动一次ygc，目的在于减少old gen对ygc gen的引用，降低remark时的开销-----一般CMS的GC耗时 80%都在remark阶段
```



### 周期性Old GC

```
执行的逻辑也叫 BackgroundCollect，对老年代进行回收，在GC日志中比较常见，由后台线程ConcurrentMarkSweepThread循环判断（默认2s）是否需要触发。
```

#### 触发条件

```
如果没有设置 UseCMSInitiatingOccupancyOnly，虚拟机会根据收集的数据决定是否触发（线上环境建议带上这个参数，不然会加大问题排查的难度）
老年代使用率达到阈值 CMSInitiatingOccupancyFraction，默认92%
永久代的使用率达到阈值 CMSInitiatingPermOccupancyFraction，默认92%，前提是开启 CMSClassUnloadingEnabled
新生代的晋升担保失败
```

#### 执行过程

##### 1、InitialMarking（初始化标记，整个过程STW） 

```
标记GC Roots可达的老年代对象；
遍历新生代对象，标记可达的老年代对象；
```

##### 2、Marking（并发标记） 

```
该阶段GC线程和应用线程并发执行，遍历InitialMarking阶段标记出来的存活对象，然后继续递归标记这些对象可达的对象。
因为该阶段并发执行的，在运行期间可能发生新生代的对象晋升到老年代、或者是直接在老年代分配对象、或者更新老年代对象的引用关系等等，对于这些对象，都是需要进行重新标记的，否则有些对象就会被遗漏，发生漏标的情况。
为了提高重新标记的效率，该阶段会把上述对象所在的Card标识为Dirty，后续只需扫描这些Dirty Card的对象，避免扫描整个老年代。
```

##### 3、Precleaning（预清理） 

```
通过参数 CMSPrecleaningEnabled选择关闭该阶段，默认启用，主要做两件事情：
处理新生代已经发现的引用，比如在并发阶段，在Eden区中分配了一个A对象，A对象引用了一个老年代对象B（这个B之前没有被标记），在这个阶段就会标记对象B为活跃对象。
在并发标记阶段，如果老年代中有对象内部引用发生变化，会把所在的Card标记为Dirty（其实这里并非使用CardTable，而是一个类似的数据结构，叫ModUnionTalble），通过扫描这些Table，重新标记那些在并发标记阶段引用被更新的对象（晋升到老年代的对象、原本就在老年代的对象）
```

##### 4、AbortablePreclean（可中断的预清理） 

```
该阶段并发执行，在之前的并行阶段（GC线程和应用线程同时执行，好比你妈在打扫房间，你还在扔纸屑），可能产生新的引用关系如下：
老年代的新对象被GC Roots引用
老年代的未标记对象被新生代对象引用
老年代已标记的对象增加新引用指向老年代其它对象
新生代对象指向老年代引用被删除
也许还有其它情况..
上述对象中可能有一些已经在Precleaning阶段和AbortablePreclean阶段被处理过，但总存在没来得及处理的，所以还有进行如下的处理：
遍历新生代对象，重新标记
根据GC Roots，重新标记
遍历老年代的Dirty Card，重新标记，这里的Dirty Card大部分已经在clean阶段处理过
在第一步骤中，需要遍历新生代的全部对象，如果新生代的使用率很高，需要遍历处理的对象也很多，这对于这个阶段的总耗时来说，是个灾难（因为可能大量的对象是暂时存活的，而且这些对象也可能引用大量的老年代对象，造成很多应该回收的老年代对象而没有被回收，遍历递归的次数也增加不少），如果在AbortablePreclean阶段中能够恰好的发生一次YGC，这样就可以避免扫描无效的对象。
如果在AbortablePreclean阶段没来得及执行一次YGC，怎么办？
CMS算法中提供了一个参数： CMSScavengeBeforeRemark，默认并没有开启，如果开启该参数，在执行该阶段之前，会强制触发一次YGC，可以减少新生代对象的遍历时间，回收的也更彻底一点。
不过，这种参数有利有弊，利是降低了Remark阶段的停顿时间，弊的是在新生代对象很少的情况下也多了一次YGC，最可怜的是在AbortablePreclean阶段已经发生了一次YGC，然后在该阶段又傻傻的触发一次。
```

### 主动Old GC

#### 触发条件 

```
YGC过程发生Promotion Failed，进而对老年代进行回收
System.gc()，前提是添加了-XX:+ExplicitGCInvokesConcurrent参数
如果触发了主动Old GC，这时周期性Old GC正在执行，那么会夺过周期性Old GC的执行权（同一个时刻只能有一种在Old GC在运行），并记录 concurrent mode failure 或者 concurrent mode interrupted。
在三种情况下会进行压缩：
其中参数 UseCMSCompactAtFullCollection(默认true)和 CMSFullGCsBeforeCompaction(默认0)，所以默认每次的主动GC都会对老年代的内存空间进行压缩，就是把对象移动到内存的最左边。
当然了，比如执行了 System.gc()，也会进行压缩。
如果新生代的晋升担保会失败。
```

```
带压缩动作的算法，称为MSC，标记-清理-压缩，采用单线程，全暂停的方式进行垃圾收集，暂停时间很长很长...
不带压缩动作的执行逻辑叫 ForegroundCollect，整个过程相对周期性Old GC来说，少了Precleaning和AbortablePreclean两个阶段，其它过程都差不多。
```

### cms gc与full gc区别

```
在CMS中，full gc 也叫 The foreground collector，对应的 cms gc 叫 The background collector，在真正执行 full gc 之前会判断一下 cms gc 的执行状态，如果 cms gc 正处于执行状态，调用report_concurrent_mode_interruption()方法，通知事件 concurrent mode failure
这里可以发现是 full gc 导致了concurrent mode failure，而不是因为concurrent mode failure 错误导致触发 full gc，真正触发 full gc 的原因可能是 ygc 时发生的promotion failure。
其实这里还有concurrent mode interrupted，这是由于外部因素触发了 full gc，比如执行了System.gc()，导致了这个原因。
```

### 总结

```
1. Full GC == Major GC指的是对老年代/永久代的stop the world的GC
2. Full GC的次数 = 老年代GC时 stop the world的次数
3. Full GC的时间 = 老年代GC时 stop the world的总时间
4. CMS 不等于Full GC，我们可以看到CMS分为多个阶段，只有stop the world的阶段被计算到了Full GC的次数和时间，而和业务线程并发的GC的次数和时间则不被认为是Full GC
5. Full GC本身不会先进行Minor GC，我们可以配置，让Full GC之前先进行一次Minor GC，因为老年代很多对象都会引用到新生代的对象，先进行一次Minor GC可以提高老年代GC的速度。比如老年代使用CMS时，设置CMSScavengeBeforeRemark优化，让CMS remark之前先进行一次Minor GC。
```

