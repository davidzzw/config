###GC Roots

```
在Java语言里，可作为GC Roots对象的包括如下几种： 
a.虚拟机栈(栈桢中的本地变量表)中的引用的对象 
b.方法区中的类静态属性引用的对象 
c.方法区中的常量引用的对象 
d.本地方法栈中JNI的引用的对象
Java 方法栈桢中的局部变量
已加载类的静态变量
JNI handles
已启动且未停止的 Java 线程
```

### 可达性分析的算法 存在的问题

```
比如说，在多线程环境下，其他线程可能会更新已经访问过的对象中的引用，从而造成误报（将引用设置为 null）或者漏报（将引用设置为未被访问过的对象）。
误报并没有什么伤害，Java 虚拟机至多损失了部分垃圾回收的机会。漏报则比较麻烦，因为垃圾回收器可能回收事实上仍被引用的对象内存。一旦从原引用访问已经被回收了的对象，则很有可能会直接导致 Java 虚拟机崩溃。
```

###RootType

```
universe              
jni_handles
threads
object_synchronizer   
flat_profiler         
system_dictionary     
class_loader_data     
management            
jvmti                 
code_cache            
```

### SafePoint

```
1、理论上，在解释器的每条字节码的边界都可以放一个safepoint，不过挂在safepoint的调试符号信息要占用内存空间，如果每条机器码后面都加safepoint的话，需要保存大量的运行时数据，所以要尽量少放置safepoint，在safepoint会生成polling代码询问VM是否要“进入safepoint”，polling操作也是有开销的，polling操作会在后续解释。
2、通过JIT编译的代码里，会在所有方法的返回之前，以及所有非counted loop的循环（无界循环）回跳之前放置一个safepoint，为了防止发生GC需要STW时，该线程一直不能暂停。另外，JIT编译器在生成机器码的同时会为每个safepoint生成一些“调试符号信息”，为GC生成的符号信息是OopMap，指出栈上和寄存器里哪里有GC管理的指针。
一般会在如下几个位置选择安全点：
1. 循环的末尾 
2. 方法临返回前 / 调用方法的call指令后 
3. 可能抛异常的位置
safePoint无法解决线程未达到safePoint并处于休眠或等待状态的情况，此时引入safeRegion的概念。
safeRegion是代码中的一块区域或线程的状态，在safeRegion中，线程执行与否不会影响对象引用的状态。线程进入safeRegion会给自己加标记，告诉虚拟机可以进行GC；线程准备离开safeRegion前会询问虚拟机GC是否完成。
怎么解决这个问题呢？在 Java 虚拟机里，传统的垃圾回收算法采用的是一种简单粗暴的方式，那便是 Stop-the-world，停止其他非垃圾回收线程的工作，直到完成垃圾回收。这也就造成了垃圾回收所谓的暂停时间（GC pause）。
Java 虚拟机中的 Stop-the-world 是通过安全点（safepoint）机制来实现的。当 Java 虚拟机收到 Stop-the-world 请求，它便会等待所有的线程都到达安全点，才允许请求 Stop-the-world 的线程进行独占的工作。
这篇博客 [2] 还提到了一种比较另类的解释：安全词。一旦垃圾回收线程喊出了安全词，其他非垃圾回收线程便会一一停下。
当然，安全点的初始目的并不是让其他线程停下，而是找到一个稳定的执行状态。在这个执行状态下，Java 虚拟机的堆栈不会发生变化。这么一来，垃圾回收器便能够“安全”地执行可达性分析。
举个例子，当 Java 程序通过 JNI 执行本地代码时，如果这段代码不访问 Java 对象、调用 Java 方法或者返回至原 Java 方法，那么 Java 虚拟机的堆栈不会发生改变，也就代表着这段本地代码可以作为同一个安全点。
只要不离开这个安全点，Java 虚拟机便能够在垃圾回收的同时，继续运行这段本地代码。
由于本地代码需要通过 JNI 的 API 来完成上述三个操作，因此 Java 虚拟机仅需在 API 的入口处进行安全点检测（safepoint poll），测试是否有其他线程请求停留在安全点里，便可以在必要的时候挂起当前线程。
除了执行 JNI 本地代码外，Java 线程还有其他几种状态：解释执行字节码、执行即时编译器生成的机器码和线程阻塞。阻塞的线程由于处于 Java 虚拟机线程调度器的掌控之下，因此属于安全点。
其他几种状态则是运行状态，需要虚拟机保证在可预见的时间内进入安全点。否则，垃圾回收线程可能长期处于等待所有线程进入安全点的状态，从而变相地提高了垃圾回收的暂停时间。
对于解释执行来说，字节码与字节码之间皆可作为安全点。Java 虚拟机采取的做法是，当有安全点请求时，执行一条字节码便进行一次安全点检测。
执行即时编译器生成的机器码则比较复杂。由于这些代码直接运行在底层硬件之上，不受 Java 虚拟机掌控，因此在生成机器码时，即时编译器需要插入安全点检测，以避免机器码长时间没有安全点检测的情况。HotSpot 虚拟机的做法便是在生成代码的方法出口以及非计数循环的循环回边（back-edge）处插入安全点检测。
那么为什么不在每一条机器码或者每一个机器码基本块处插入安全点检测呢？原因主要有两个。
第一，安全点检测本身也有一定的开销。不过 HotSpot 虚拟机已经将机器码中安全点检测简化为一个内存访问操作。在有安全点请求的情况下，Java 虚拟机会将安全点检测访问的内存所在的页设置为不可读，并且定义一个 segfault 处理器，来截获因访问该不可读内存而触发 segfault 的线程，并将它们挂起。
第二，即时编译器生成的机器码打乱了原本栈桢上的对象分布状况。在进入安全点时，机器码还需提供一些额外的信息，来表明哪些寄存器，或者当前栈帧上的哪些内存空间存放着指向对象的引用，以便垃圾回收器能够枚举 GC Roots。
由于这些信息需要不少空间来存储，因此即时编译器会尽量避免过多的安全点检测。
不过，不同的即时编译器插入安全点检测的位置也可能不同。以 Graal 为例，除了上述位置外，它还会在计数循环的循环回边处插入安全点检测。其他的虚拟机也可能选取方法入口而非方法出口来插入安全点检测。
不管如何，其目的都是在可接受的性能开销以及内存开销之内，避免机器码长时间不进入安全点的情况，间接地减少垃圾回收的暂停时间。
```

###PerfData 

### 开启垃圾回收器参数

- `-UseSerialGC`:`Serial + Serial Old的串行收集器组合进行内存回收（Serial Old，在并发收集发生Concurrent Mode Failure的时候使用。单线程）`
- `-UseParNewGC`:`使用ParNew + Serial Old的收集器组合进行内存回收 （ParNew收集器 -XX:ParallelGCThreads参数来限制垃圾收集的线程数）`
- `-UseParallelGC`:`虚拟机运行在Server模式下的默认值，打开此开关后，使用Parallel Scavenge + Serial Old的收集器组合进行内存回收`
- `-UseParallelOldGC`:`使用Parallel Scavenge + Parallel Old的收集器组合进行垃圾回收`
- `-XX:+UseConcMarkSweepGC`:`CMS收集老年代`
- `-XX:+UseG1GC`:`使用G1回收`

### CMS

####周期性Old GC

```
执行的逻辑也叫 BackgroundCollect，对老年代进行回收，在GC日志中比较常见，由后台线程ConcurrentMarkSweepThread循环判断（默认2s）是否需要触发。
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

##### 5、（STW）重新标记

`重新扫描堆中的对象，进行可达性分析,标记活着的对象。这个阶段扫描的目标是：新生代的对象 + Gc Roots + 前面被标记为dirty的card对应的老年代对象。如果预清理的工作没做好，这一步扫描新生代的时候就会花很多时间，导致这个阶段的停顿时间过长。这个过程是多线程的。`

##### 6、并发清除

`用户线程被重新激活，同时将那些未被标记为存活的对象标记为不可达`

##### 7、并发重置

`CMS内部重置回收器状态，准备进入下一个并发回收周期`

#### 主动Old GC

##### 触发条件

```
YGC过程发生Promotion Failed，进而对老年代进行回收
System.gc()，前提是添加了-XX:+ExplicitGCInvokesConcurrent参数
如果触发了主动Old GC，这时周期性Old GC正在执行，那么会夺过周期性Old GC的执行权（同一个时刻只能有一种在Old GC在运行），并记录 concurrent mode failure 或者 concurrent mode interrupted。
在三种情况下会进行压缩：
其中参数 UseCMSCompactAtFullCollection(默认true)和 CMSFullGCsBeforeCompaction(默认0)，所以默认每次的主动GC都会对老年代的内存空间进行压缩，就是把对象移动到内存的最左边。
当然了，比如执行了 System.gc()，也会进行压缩。
如果新生代的晋升担保会失败。
带压缩动作的算法，称为MSC，标记-清理-压缩，采用单线程，全暂停的方式进行垃圾收集，暂停时间很长很长...
不带压缩动作的执行逻辑叫 ForegroundCollect，整个过程相对周期性Old GC来说，少了Precleaning和AbortablePreclean两个阶段，其它过程都差不多
```

#### 优点  

`并发收集，低停顿`

`理由： 由于在整个过程和中最耗时的并发标记和 并发清除过程收集器程序都可以和用户线程一起工作，所以总体来说，Cms收集器的内存回收过程是与用户线程一起并发执行的`

#### 缺点

* `CMS收集器对CPU资源非常敏感`:`在并发阶段，虽然不会导致用户线程停顿，但是会因为占用了一部分线程使应用程序变慢，总吞吐量会降低，为了解决这种情况，虚拟机提供了一种“增量式并发收集器,的CMS收集器变种， 就是在并发标记和并发清除的时候让GC线程和用户线程交替运行，尽量减少GC 线程独占资源的时间，这样整个垃圾收集的过程会变长，但是对用户程序的影响会减少。（效果不明显，不推荐)`
* `CMS处理器无法处理浮动垃圾 `

​     ` CMS在并发清理阶段线程还在运行， 伴随着程序的运行自然也会产生新的垃圾，这一部分垃圾产生在标记过程之后，CMS无法再当次过程中处理，所以只有等到下次gc时候在清理掉，这一部分垃圾就称作“浮动垃圾`

* `CMS是基于“标记--清除”算法实现的，所以在收集结束的时候会有大量的空间碎片产生。空间碎片太多的时候，将会给大对象的分配带来很大的麻烦，往往会出现老年代还有很大的空间剩余，但是无法找到足够大的连续空间来分配当前对象的，只能提前触发 full gc`

​    `为了解决这个问题，CMS提供了一个开关参数，用于在CMS顶不住要进行full gc的时候开启内存碎片的合并整理过程，内存整理的过程是无法并发的，空间碎片没有了，但是停顿的时间变长了 `

#### 进阶

* `对cms的回收默认值有疑问的， 可以查看该方法https://github.com/dmlloyd/openjdk/blob/jdk9/jdk9/hotspot/src/share/vm/gc/cms/concurrentMarkSweepGeneration.cpp#L265`
* `大家都知道对于设置使用cms回收器的，有一个background式的GC。（不清楚的可以查看笨神的这篇文章http://lovestblog.cn/blog/2015/05/07/system-gc/）`

#### CMS gc次数

```
CMS并发GC过程中出现了concurrent mode failure的话那么接下来就会做一次mark-sweep-compact的full GC，这个是完全stop-the-world的
正是这个特征，使得CMS的每个并发GC周期总共会更新full GC计数器两次，initial mark与final re-mark各一次；如果出现concurrent mode failure，则接下来的full GC自己算一次
```

#### cms gc与full gc区别

```
在CMS中，full gc 也叫 The foreground collector，对应的 cms gc 叫 The background collector，在真正执行 full gc 之前会判断一下 cms gc 的执行状态，如果 cms gc 正处于执行状态，调用report_concurrent_mode_interruption()方法，通知事件 concurrent mode failure
这里可以发现是 full gc 导致了concurrent mode failure，而不是因为concurrent mode failure 错误导致触发 full gc，真正触发 full gc 的原因可能是 ygc 时发生的promotion failure。
其实这里还有concurrent mode interrupted，这是由于外部因素触发了 full gc，比如执行了System.gc()，导致了这个原因。
```

`CMS GC（并发模式）不是full GC。CMS GC只收集old gen，并且可以与minor GC（通常是ParNew）并发进行。如果启用了CMSScavengeBeforeRemark 则在CMS remark阶段前会触发一次minor GC`

#### 部分参数详解

##### UseCMSCompactAtFullCollection 与 CMSFullGCsBeforeCompaction

```
CMS GC要决定是否在full GC时做压缩，会依赖几个条件。其中， 
第一种条件，UseCMSCompactAtFullCollection 与 CMSFullGCsBeforeCompaction 是搭配使用的；前者目前默认就是true了，也就是关键在后者上。 
第二种条件是用户调用了System.gc()，而且DisableExplicitGC没有开启。 
第三种条件是young gen报告接下来如果做增量收集会失败；简单来说也就是young gen预计old gen没有足够空间来容纳下次young GC晋升的对象。 
上述三种条件的任意一种成立都会让CMS决定这次做full GC时要做压缩。 
CMSFullGCsBeforeCompaction 说的是，在上一次CMS并发GC执行过后，到底还要再执行多少次full GC才会做压缩。默认是0，也就是在默认配置下每次CMS GC顶不住了而要转入full GC的时候都会做压缩。 把CMSFullGCsBeforeCompaction配置为10，就会让上面说的第一个条件变成每隔10次真正的full GC才做一次压缩（而不是每10次CMS并发GC就做一次压缩，目前VM里没有这样的参数）。这会使full GC更少做压缩，也就更容易使CMS的old gen受碎片化问题的困扰。 本来这个参数就是用来配置降低full GC压缩的频率，以期减少某些full GC的暂停时间。CMS回退到full GC时用的算法是mark-sweep-compact，但compaction是可选的，不做的话碎片化会严重些但这次full GC的暂停时间会短些；这是个取舍。
```

##### CMSInitiatingOccupancyFraction=70和UseCMSInitiatingOccupancyOnly

```
两个设置一般配合使用,一般用于『降低CMS GC频率或者增加频率、减少GC时长』的需求
-XX:CMSInitiatingOccupancyFraction=70 是指设定CMS在对内存占用率达到70%的时候开始GC(因为CMS会有浮动垃圾,所以一般都较早启动GC);
-XX:+UseCMSInitiatingOccupancyOnly 只是用设定的回收阈值(上面指定的70%),如果不指定,JVM仅在第一次使用设定值,后续则自动调整
```

##### CMSScavengeBeforeRemark

```
在CMS GC前启动一次ygc，目的在于减少old gen对ygc gen的引用，降低remark时的开销-----一般CMS的GC耗时 80%都在remark阶段
```

####总结

```
1. Full GC == Major GC指的是对老年代/永久代的stop the world的GC
2. Full GC的次数 = 老年代GC时 stop the world的次数
3. Full GC的时间 = 老年代GC时 stop the world的总时间
4. CMS 不等于Full GC，我们可以看到CMS分为多个阶段，只有stop the world的阶段被计算到了Full GC的次数和时间，而和业务线程并发的GC的次数和时间则不被认为是Full GC
5. Full GC本身不会先进行Minor GC，我们可以配置，让Full GC之前先进行一次Minor GC，因为老年代很多对象都会引用到新生代的对象，先进行一次Minor GC可以提高老年代GC的速度。比如老年代使用CMS时，设置CMSScavengeBeforeRemark优化，让CMS remark之前先进行一次Minor GC
```

### G1

* `初始标记（stop the world）`：`这是一个stop the world事件，使用G1回收器，背负着一个常规的年轻代收集。标记那些有引用到年老代的对象的survivor区(根区)`
* ```根区扫描``` ：`为到年老代的引用扫描survivor区,这个发生在应用继续运行时。这个阶段在年轻代收集前必须完成`
* ```并发标记``` ：`遍历整个堆寻找活跃对象，这个发生在应用运行时，这个阶段可以被年轻代垃圾回收打断`
* `重新标记(stop the world)`：`完全标记堆中的活跃对象，使用一个叫作snapshot-at-the-beginning(SATB)的比CMS收集器的更快的算法`
* `清理stop the world和并发)`：`在活跃对象上执行审计操作和释放区域空间(stop the world)；净化已记忆集合(stop the world)；重置空间区域和返回它们到空闲列表(并发)`
* `复制(stop the world)`：`这些是stop the world暂停为了疏散或者复制活跃对象到新的未使用的区域。这个可以由被记录为[GC Pause (young)]的年轻代区域或者被记录为[GC Pause (mixed)]年轻代和年老代区域完成`

#### 优点

* `并行于并发`：`G1能充分利用CPU、多核环境下的硬件优势，使用多个CPU（CPU或者CPU核心）来缩短stop-The-World停顿时间。部分其他收集器原本需要停顿[Java](http://lib.csdn.net/base/java)线程执行的GC动作，G1收集器仍然可以通过并发的方式让java程序继续执行`
* `分代收集`：`虽然G1可以不需要其他收集器配合就能独立管理整个GC堆，但是还是保留了分代的概念。它能够采用不同的方式去处理新创建的对象和已经存活了一段时间，熬过多次GC的旧对象以获取更好的收集效果`
* `空间整合`：`与CMS的“标记--清理”算法不同，G1从整体来看是基于“标记整理”算法实现的收集器；从局部上来看是基于“复制”算法实现的`
* `可预测的停顿`：`这是G1相对于CMS的另一个大优势，降低停顿时间是G1和ＣＭＳ共同的关注点，但Ｇ１除了追求低停顿外，还能建立可预测的停顿时间模型，能让使用者明确指定在一个长度为M毫秒的时间片段内`

`初始标记阶段仅仅只是标记一下GC Roots能直接关联到的对象，并且修改TAMS的值，让下一个阶段用户程序并发运行时，能在正确可用的Region中创建新对象，这一阶段需要停顿线程，但是耗时很短，并发标记阶段是从GC Root开始对堆中对象进行可达性分析，找出存活的对象，这阶段时耗时较长，但可与用户程序并发执行。而最终标记阶段则是为了修正在并发标记期间因用户程序继续运作而导致标记产生变动的那一部分标记记录，虚拟机将这段时间对象变化记录在线程Remenbered Set Logs里面，最终标记阶段需要把Remembered Set Logs的数据合并到Remembered Set Logs里面，最终标记阶段需要把Remembered Set Logs的数据合并到Remembered Set中，这一阶段需要停顿线程，但是可并行执行。最后在筛选回收阶段首先对各个Region的回收价值和成本进行排序，根据用户所期望的GC停顿时间来制定回收计划`

#### 年轻代收集

G1的年轻代回收做以下总结：

- `堆空间是一块单独的内存空间被分割成多个区域`
- `年轻代内存是由一组非连续的区域组成。这使得需要重调大小变得容易`
- `年轻代垃圾回收是stop the world事件，所有应用线程都会因此操作暂停`
- `年轻代垃圾收集使用多线程并行回收`
- `活跃对象被复制到新的Survivor区或者年老代区域`

#### 年老代垃圾回收总结

并发标记阶段

> - 当应用运行时，并发的计算活性信
> - 在疏散暂停期间，活性信息鉴定哪些区被最好的回收
> - 没有像CMS一样的清除操作

重新标记阶段

> - 使用比在CMS中使用的算法更快的Snapshot-at-the-Beginning(SATB)算法
> - 完全空的区域会被回收掉

复制/清理阶段

> - 年轻代和年老代被同时回收
> - 年老代区域基于它们的活性被选择

### 垃圾回收器

#### Serial收集器

```
Serial收集器是最古老的收集器，它的缺点是当Serial收集器想进行垃圾回收的时候，必须暂停用户的所有进程，即stop the world。到现在为止，它依然是虚拟机运行在client模式下的默认新生代收集器，与其他收集器相比，对于限定在单个CPU的运行环境来说，Serial收集器由于没有线程交互的开销，专心做垃圾回收自然可以获得最高的单线程收集效率。
Serial Old是Serial收集器的老年代版本，它同样是一个单线程收集器，使用”标记－整理“算法。这个收集器的主要意义也是被Client模式下的虚拟机使用。在Server模式下，它主要还有两大用途：一个是在JDK1.5及以前的版本中与Parallel Scanvenge收集器搭配使用，另外一个就是作为CMS收集器的后备预案，在并发收集发生Concurrent Mode Failure的时候使用。
通过指定-UseSerialGC参数，使用Serial + Serial Old的串行收集器组合进行内存回收。
```

#### ParNew收集器

```
ParNew收集器是Serial收集器新生代的多线程实现，注意在进行垃圾回收的时候依然会stop the world，只是相比较Serial收集器而言它会运行多条进程进行垃圾回收。
ParNew收集器在单CPU的环境中绝对不会有比Serial收集器更好的效果，甚至由于存在线程交互的开销，该收集器在通过超线程技术实现的两个CPU的环境中都不能百分之百的保证能超越Serial收集器。当然，随着可以使用的CPU的数量增加，它对于GC时系统资源的利用还是很有好处的。它默认开启的收集线程数与CPU的数量相同，在CPU非常多（譬如32个，现在CPU动辄4核加超线程，服务器超过32个逻辑CPU的情况越来越多了）的环境下，可以使用-XX:ParallelGCThreads参数来限制垃圾收集的线程数。
-UseParNewGC: 打开此开关后，使用ParNew + Serial Old的收集器组合进行内存回收，这样新生代使用并行收集器，老年代使用串行收集器。
```

#### Parallel Scavenge收集器

```
Parallel是采用复制算法的多线程新生代垃圾回收器，似乎和ParNew收集器有很多的相似的地方。但是Parallel Scanvenge收集器的一个特点是它所关注的目标是吞吐量(Throughput)。所谓吞吐量就是CPU用于运行用户代码的时间与CPU总消耗时间的比值，即吞吐量=运行用户代码时间 / (运行用户代码时间 + 垃圾收集时间)。停顿时间越短就越适合需要与用户交互的程序，良好的响应速度能够提升用户的体验；而高吞吐量则可以最高效率地利用CPU时间，尽快地完成程序的运算任务，主要适合在后台运算而不需要太多交互的任务。
Parallel Old收集器是Parallel Scavenge收集器的老年代版本，采用多线程和”标记－整理”算法。这个收集器是在jdk1.6中才开始提供的，在此之前，新生代的Parallel Scavenge收集器一直处于比较尴尬的状态。原因是如果新生代Parallel Scavenge收集器，那么老年代除了Serial Old(PS MarkSweep)收集器外别无选择。由于单线程的老年代Serial Old收集器在服务端应用性能上的”拖累“，即使使用了Parallel Scavenge收集器也未必能在整体应用上获得吞吐量最大化的效果，又因为老年代收集中无法充分利用服务器多CPU的处理能力，在老年代很大而且硬件比较高级的环境中，这种组合的吞吐量甚至还不一定有ParNew加CMS的组合”给力“。直到Parallel Old收集器出现后，”吞吐量优先“收集器终于有了比较名副其实的应用，在注重吞吐量及CPU资源敏感的场合，都可以优先考虑Parallel Scavenge加Parallel Old收集器。
-UseParallelGC: 虚拟机运行在Server模式下的默认值，打开此开关后，使用Parallel Scavenge + Serial Old的收集器组合进行内存回收。-UseParallelOldGC: 打开此开关后，使用Parallel Scavenge + Parallel Old的收集器组合进行垃圾回收
```

#### CMS收集器

```
CMS(Concurrent Mark Swep)收集器是一个比较重要的回收器，现在应用非常广泛，我们重点来看一下，CMS一种获取最短回收停顿时间为目标的收集器，这使得它很适合用于和用户交互的业务。从名字(Mark Swep)就可以看出，CMS收集器是基于标记清除算法实现的。它的收集过程分为四个步骤：
初始标记(initial mark)
并发标记(concurrent mark)
重新标记(remark)
并发清除(concurrent sweep)
注意初始标记和重新标记还是会stop the world，但是在耗费时间更长的并发标记和并发清除两个阶段都可以和用户进程同时工作。
不过由于CMS收集器是基于标记清除算法实现的，会导致有大量的空间碎片产生，在为大对象分配内存的时候，往往会出现老年代还有很大的空间剩余，但是无法找到足够大的连续空间来分配当前对象，不得不提前开启一次Full GC。为了解决这个问题，CMS收集器默认提供了一个-XX:+UseCMSCompactAtFullCollection收集开关参数（默认就是开启的)，用于在CMS收集器进行FullGC完开启内存碎片的合并整理过程，内存整理的过程是无法并发的，这样内存碎片问题倒是没有了，不过停顿时间不得不变长。虚拟机设计者还提供了另外一个参数-XX:CMSFullGCsBeforeCompaction参数用于设置执行多少次不压缩的FULL GC后跟着来一次带压缩的（默认值为0，表示每次进入Full GC时都进行碎片整理）。
不幸的是，它作为老年代的收集器，却无法与jdk1.4中已经存在的新生代收集器Parallel Scavenge配合工作，所以在jdk1.5中使用cms来收集老年代的时候，新生代只能选择ParNew或Serial收集器中的一个。ParNew收集器是使用-XX:+UseConcMarkSweepGC选项启用CMS收集器之后的默认新生代收集器，也可以使用-XX:+UseParNewGC选项来强制指定它。
由于CMS收集器现在比较常用，下面我们再额外了解一下CMS算法的几个常用参数：
UseCMSInitatingOccupancyOnly：表示只在到达阈值的时候，才进行 CMS 回收。
CMS默认启动的回收线程数目是(ParallelGCThreads+3)/4，如果你需要明确设定，可以通过-XX:+ParallelCMSThreads来设定，其中-XX:+ParallelGCThreads代表的年轻代的并发收集线程数目。
CMSClassUnloadingEnabled： 允许对元类数据进行回收。
CMSInitatingPermOccupancyFraction：当永久区占用率达到这一百分比后，启动 CMS 回收 (前提是-XX:+CMSClassUnloadingEnabled 激活了)。
CMSIncrementalMode：使用增量模式，比较适合单 CPU。
UseCMSCompactAtFullCollection参数可以使 CMS 在垃圾收集完成后，进行一次内存碎片整理。内存碎片的整理并不是并发进行的。
UseFullGCsBeforeCompaction：设定进行多少次 CMS 垃圾回收后，进行一次内存压缩。
一些建议
对于Native Memory:
使用了NIO或者NIO框架（Mina/Netty）
使用了DirectByteBuffer分配字节缓冲区
使用了MappedByteBuffer做内存映射
由于Native Memory只能通过FullGC回收，所以除非你非常清楚这时真的有必要，否则不要轻易调用System.gc()。
另外为了防止某些框架中的System.gc调用（例如NIO框架、Java RMI），建议在启动参数中加上-XX:+DisableExplicitGC来禁用显式GC。这个参数有个巨大的坑，如果你禁用了System.gc()，那么上面的3种场景下的内存就无法回收，可能造成OOM，如果你使用了CMS GC，那么可以用这个参数替代：-XX:+ExplicitGCInvokesConcurrent。
此外除了CMS的GC，其实其他针对old gen的回收器都会在对old gen回收的同时回收young gen
```

#### G1收集器

```
G1收集器是一款面向服务端应用的垃圾收集器。HotSpot团队赋予它的使命是在未来替换掉JDK1.5中发布的CMS收集器。与其他GC收集器相比，G1具备如下特点：

并行与并发：G1能更充分的利用CPU，多核环境下的硬件优势来缩短stop the world的停顿时间。
分代收集：和其他收集器一样，分代的概念在G1中依然存在，不过G1不需要其他的垃圾回收器的配合就可以独自管理整个GC堆。
空间整合：G1收集器有利于程序长时间运行，分配大对象时不会无法得到连续的空间而提前触发一次GC。
可预测的非停顿：这是G1相对于CMS的另一大优势，降低停顿时间是G1和CMS共同的关注点，能让使用者明确指定在一个长度为M毫秒的时间片段内，消耗在垃圾收集上的时间不得超过N毫秒。
在使用G1收集器时，Java堆的内存布局和其他收集器有很大的差别，它将这个Java堆分为多个大小相等的独立区域，虽然还保留新生代和老年代的概念，但是新生代和老年代不再是物理隔离的了，它们都是一部分Region（不需要连续）的集合
```

### 永久代、metaspace

```
在PermGen移除前，上述元数据对象都在PermGen里，直接被GC管理着。 
JDK8彻底移除PermGen后，这些对象被挪到GC堆外的一块叫做Metaspace的空间里做特殊管理，仍然间接的受
```

### YGC

#### 老年代引用年轻代对象

```
Minor GC 的另外一个好处是不用对整个堆进行垃圾回收。但是，它却有一个问题，那就是老年代的对象可能引用新生代的对象。也就是说，在标记存活对象的时候，我们需要扫描老年代中的对象。如果该对象拥有对新生代对象的引用，那么这个引用也会被作为 GC Roots
```

#### 卡表

```
HotSpot 给出的解决方案是一项叫做卡表（Card Table）的技术。该技术将整个堆划分为一个个大小为 512 字节的卡，并且维护一个卡表，用来存储每张卡的一个标识位。这个标识位代表对应的卡是否可能存有指向新生代对象的引用。如果可能存在，那么我们就认为这张卡是脏的。
在进行 Minor GC 的时候，我们便可以不用扫描整个老年代，而是在卡表中寻找脏卡，并将脏卡中的对象加入到 Minor GC 的 GC Roots 里。当完成所有脏卡的扫描之后，Java 虚拟机便会将所有脏卡的标识位清零。
由于 Minor GC 伴随着存活对象的复制，而复制需要更新指向该对象的引用。因此，在更新引用的同时，我们又会设置引用所在的卡的标识位。这个时候，我们可以确保脏卡中必定包含指向新生代对象的引用。
在 Minor GC 之前，我们并不能确保脏卡中包含指向新生代对象的引用。其原因和如何设置卡的标识位有关。
首先，如果想要保证每个可能有指向新生代对象引用的卡都被标记为脏卡，那么 Java 虚拟机需要截获每个引用型实例变量的写操作，并作出对应的写标识位操作。
这个操作在解释执行器中比较容易实现。但是在即时编译器生成的机器码中，则需要插入额外的逻辑。这也就是所谓的写屏障（write barrier，注意不要和 volatile 字段的写屏障混淆）。
写屏障需要尽可能地保持简洁。这是因为我们并不希望在每条引用型实例变量的写指令后跟着一大串注入的指令。
因此，写屏障并不会判断更新后的引用是否指向新生代中的对象，而是宁可错杀，不可放过，一律当成可能指向新生代对象的引用。
虽然写屏障不可避免地带来一些开销，但是它能够加大 Minor GC 的吞吐率（ 应用运行时间 /(应用运行时间 + 垃圾回收时间) ）。总的来说还是值得的。不过，在高并发环境下，写屏障又带来了虚共享（false sharing）问题 [2]。
在介绍对象内存布局中我曾提到虚共享问题，讲的是几个 volatile 字段出现在同一缓存行里造成的虚共享。这里的虚共享则是卡表中不同卡的标识位之间的虚共享问题。
在 HotSpot 中，卡表是通过 byte 数组来实现的。对于一个 64 字节的缓存行来说，如果用它来加载部分卡表，那么它将对应 64 张卡，也就是 32KB 的内存。
如果同时有两个 Java 线程，在这 32KB 内存中进行引用更新操作，那么也将造成存储卡表的同一部分的缓存行的写回、无效化或者同步操作，因而间接影响程序性能。
为此，HotSpot 引入了一个新的参数 -XX:+UseCondCardMark，来尽量减少写卡表的操作。
```

#### 新生代晋升到老年代的条件

* `Eden区满时，进行Minor GC，当Eden和一个Survivor区中依然存活的对象无法放入到Survivor中，则通过分配担保机制提前转移到老年代中`
* `若对象体积太大, 新生代无法容纳这个对象，-XX:PretenureSizeThreshold即对象的大小大于此值, 就会绕过新生代, 直接在老年代分配, 此参数只对Serial及ParNew两款收集器有效`
* `长期存活的对象将进入老年代`

        `虚拟机对每个对象定义了一个对象年龄（Age）计数器。当年龄增加到一定的临界值时，就会晋升到老年代中，该临界值由参数：-XX:MaxTenuringThreshold来设置`

        `如果对象在Eden出生并在第一次发生MinorGC时仍然存活，并且能够被Survivor中所容纳的话，则该对象会被移动到Survivor中，并且设Age=1；以后每经历一次Minor GC，该对象还存活的话Age=Age+1`

* `动态对象年龄判定`

`虚拟机并不总是要求对象的年龄必须达到MaxTenuringThreshold才能晋升到老年代，如果在Survivor区中相同年龄（设年龄为age）的对象的所有大小之和超过Survivor空间的一半，年龄大于或等于该年龄（age）的对象就可以直接进入老年代，无需等到MaxTenuringThreshold中要求的年龄`

* `如果单个 Survivor 区已经被占用了 50%（对应虚拟机参数 -XX:TargetSurvivorRatio），那么较高复制次数的对象也会被晋升至老年代 `

### FGC

`FGC列表示的是full GC次数，对应的jvmstat计数器是sun.gc.collector.1.invocations `

`HotSpot VM的full GC就是full GC，用同一种收集算法处理整个堆，不需要用两个不同的收集器来收集young gen和old gen（以及perm gen）`

### System.gc

```
在HotSpot VM里，System.gc()默认触发的是一次full GC，stop-the-world，收集全堆。如果配置了+UseConcMarkSweepGC并且开启了+ExplicitGCInvokesConcurrent 或 
-XX:+ExplicitGCInvokesConcurrentAndUnloadsClasses，则System.gc()会触发一次CMS GC，并发模式，只收集old gen。如果开启了+DisableExplicitGC则System.gc()不执行任何GC就直接返回。 
通常HotSpot VM会立即执行System.gc()触发的GC。但如果调用System.gc()的时候有线程正在JNI critical section中（也就是执行了JNI的xxxCritical系函数GetStringCritical、GetPrimitiveArrayCritical，而还没释放定住的资源ReleaseStringCritical、ReleasePrimitiveArrayCritical时），则HotSpot VM会先记下这个请求并让System.gc()返回，然后等所有JNI critical section都退出后再补一次full GC。如果配置了+UseConcMarkSweepGC并且开启了+GCLockerInvokesConcurrent的话则这种延迟触发的GC会是CMS GC，并发模式，只收集old gen
```

### promotion failed和concurrent mode failure

* ` promotion failed是说，担保机制确定老年代是否有足够的空间容纳新来的对象，如果担保机制说有，但是真正分配的时候发现由于碎片导致找不到连续的空间而失败`
* `concurrent mode failure是指并发周期还没执行完，用户线程就来请求比预留空间更大的空间了，即后台线程的收集没有赶上应用线程的分配速度`

### Java中的内存划分

#### 程序计数器：（线程私有）

```
每个线程拥有一个程序计数器，在线程创建时创建，指向下一条指令的地址,执行本地方法时，其值为undefined
```

#### 虚拟机栈：（线程私有）

```
每个方法被调用的时候都会创建一个栈帧，用于存储局部变量表、操作栈、动态链接、方法出口等信息。局部变量表存放的是：编译期可知的基本数据类型、对象引用类型。
每个方法被调用直到执行完成的过程，就对应着一个栈帧在虚拟机中从入栈到出栈的过程。
在Java虚拟机规范中，对这个区域规定了两种异常情况：
（1）如果线程请求的栈深度太深，超出了虚拟机所允许的深度，就会出现StackOverFlowError（比如无限递归。因为每一层栈帧都占用一定空间，而 Xss 规定了栈的最大空间，超出这个值就会报错）
（2）虚拟机栈可以动态扩展，如果扩展到无法申请足够的内存空间，会出现OOM
```

#### 本地方法栈

```
（1）本地方法栈与java虚拟机栈作用非常类似，其区别是：java虚拟机栈是为虚拟机执行java方法服务的，而本地方法栈则为虚拟机执使用到的Native方法服务。
（2）Java虚拟机没有对本地方法栈的使用和数据结构做强制规定，Sun HotSpot虚拟机就把java虚拟机栈和本地方法栈合二为一。
（3）本地方法栈也会抛出StackOverFlowError和OutOfMemoryError。
```

#### 堆：即堆内存（线程共享）

```
（1）堆是java虚拟机所管理的内存区域中最大的一块，java堆是被所有线程共享的内存区域，在java虚拟机启动时创建，堆内存的唯一目的就是存放对象实例几乎所有的对象实例都在堆内存分配。
（2）堆是GC管理的主要区域，从垃圾回收的角度看，由于现在的垃圾收集器都是采用的分代收集算法，因此java堆还可以初步细分为新生代和老年代。
（3）Java虚拟机规定，堆可以处于物理上不连续的内存空间中，只要逻辑上连续的即可。在实现上既可以是固定的，也可以是可动态扩展的。如果在堆内存没有完成实例分配，并且堆大小也无法扩展，就会抛出OutOfMemoryError异常。
```

#### 方法区：（线程共享）

```
（1）用于存储已被虚拟机加载的类信息、常量、静态变量、即时编译器编译后的代码等数据。
（2）Sun HotSpot虚拟机把方法区叫做永久代（Permanent Generation），方法区中最终要的部分是运行时常量池。
```

#### Code Cache

```
Code Cache代码缓存区，它主要用于存放JIT所编译的代码。CodeCache代码缓冲区的大小在client模式下默认最大是32m，在server模式下默认是48m，这个值也是可以设置的，它所对应的JVM参数为ReservedCodeCacheSize 和 InitialCodeCacheSize
```

#### 常量池

##### class文件常量池

##### 运行时常量池

```
JDK1.6之前字符串常量池位于方法区之中。
JDK1.7字符串常量池已经被挪到堆之中。
可通过参数-XX:PermSize和-XX:MaxPermSize设置
常量池（Constant Pool）：常量池数据编译期被确定，是Class文件中的一部分。存储了类、方法、接口等中的常量，当然也包括字符串常量。
字符串池/字符串常量池（String Pool/String Constant Pool）：是常量池中的一部分，存储编译期类中产生的字符串类型数据。
运行时常量池（Runtime Constant Pool）：方法区的一部分，所有线程共享。虚拟机加载Class后把常量池中的数据放入到运行时常量池。常量池：可以理解为Class文件之中的资源仓库，它是Class文件结构中与其他项目资源关联最多的数据类型。
常量池中主要存放两大类常量：字面量（Literal）和符号引用（Symbolic Reference）。
字面量：文本字符串、声明为final的常量值等。
符号引用：类和接口的完全限定名（Fully Qualified Name）、字段的名称和描述符（Descriptor）、方法的名称和描述符。
```

##### 字符串常量池

#### 虚拟机栈(stack)

```
1.Java虚拟机栈是线程私有的，它的生命周期与线程相同。
每一个方法被调用直至执行完成的过程，就对应着一个栈帧在虚拟机栈中从入栈到出栈的过程。
虚拟机栈是执行Java方法的内存模型(也就是字节码)服务：每个方法在执行的同时都会创建一个栈帧，用于存储 局部变量表、操作数栈、动态链接、方法出口等信息。
局部变量表：32位变量槽，存放了编译期可知的各种基本数据类型、对象引用、returnAddress类型。
操作数栈：基于栈的执行引擎，虚拟机把操作数栈作为它的工作区，大多数指令都要从这里弹出数据、执行运算，然后把结果压回操作数栈。
动态连接：每个栈帧都包含一个指向运行时常量池（方法区的一部分）中该栈帧所属方法的引用。持有这个引用是为了支持方法调用过程中的动态连接。Class文件的常量池中有大量的符号引用，字节码中的方法调用指令就以常量池中指向方法的符号引用为参数。这些符号引用一部分会在类加载阶段或第一次使用的时候转化为直接引用，这种转化称为静态解析。另一部分将在每一次的运行期间转化为直接应用，这部分称为动态连接
方法出口：返回方法被调用的位置，恢复上层方法的局部变量和操作数栈，如果无返回值，则把它压入调用者的操作数栈。
局部变量表所需的内存空间在编译期间完成分配，当进入一个方法时，这个方法需要在帧中分配多大的局部变量空间是完全确定的。
在方法运行期间不会改变局部变量表的大小。主要存放了编译期可知的各种基本数据类型、对象引用 （reference类型）、returnAddress类型）。
```

### 类加载机制

![image-20200225023731970](/Users/zhangzewei/Library/Application Support/typora-user-images/image-20200225023731970.png)

```虚拟机把描述类的数据从Class文件加载到内存，并对数据进行校验、转换解析和初始化，最终形成可以被虚拟机直接使用的的Java类型，这就是虚拟机的类加载机制。```

```
虚拟机栈(JVM stack)中引用的对象(准确的说是虚拟机栈中的栈帧(frames)) 
我们知道，每个方法执行的时候，jvm都会创建一个相应的栈帧(栈帧中包括操作数栈、局部变量表、运行时常量池的引用)，栈帧中包含这在方法内部使用的所有对象的引用(当然还有其他的基本类型数据)，当方法执行完后，该栈帧会从虚拟机栈中弹出，这样一来，临时创建的对象的引用也就不存在了，或者说没有任何gc roots指向这些临时对象，这些对象在下一次GC时便会被回收掉
方法区中类静态属性引用的对象 
静态属性是该类型(class)的属性，不单独属于任何实例，因此该属性自然会作为gc roots。只要这个class存在，该引用指向的对象也会一直存在。class 也是会被回收的，在面后说明
本地方法栈(Native Stack)引用的对象
一个class要被回收准确的说应该是卸载，必须同时满足以下三个条件
堆中不存在该类的任何实例
加载该类的classloader已经被回收
该类的java.lang.Class对象没有在任何地方被引用，也就是说无法通过反射再带访问该类的信息
```

