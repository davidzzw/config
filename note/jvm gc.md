###GC Roots

```
在Java语言里，可作为GC Roots对象的包括如下几种： 
a.虚拟机栈(栈桢中的本地变量表)中的引用的对象 
b.方法区中的类静态属性引用的对象 
c.方法区中的常量引用的对象 
d.本地方法栈中JNI的引用的对象
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
```

### 8种原子操作

* `lock（锁定）`：`作用于主内存的变量，它把一个变量标识为一条线程独占的状态`
* `unlock（解锁）`：`作用于主内存的变量，它把一个处于锁定状态的变量释放出来，释放后的变量才可以被其他线程锁定`
* `read（读取）`：`作用于主内存的变量，它把一个变量的值从主内存传输到线程的工作内存中，以便随后的 load 动作使用`
* `load（载入）`：`作用于工作内存的变量，它把 read 操作从主内存中得到的变量值放入工作内存的变量副本中`
* `use（使用）`：`作用于工作内存的变量，它把工作内存中一个变量的值传递给执行引擎，每当虚拟机遇到一个需要使用到变量的值的字节码指令时将会执行这个操作`
* `assign（赋值）`：`作用于工作内存的变量，它把一个从执行引擎接收到的值赋给工作内存的变量，每当虚拟机遇到一个给变量赋值的字节码指令时执行这个操作`
* `store（存储）`：`作用于工作内存的变量，它把工作内存中一个变量的值传送到主内存中，以便随后的 write 操作使用`
* `write（写入）`：`作用于主内存的变量，它把 store 操作从工作内存中得到的变量的值放入主内存的变量中`

### 开启垃圾回收器参数

- `-UseSerialGC`:`Serial + Serial Old的串行收集器组合进行内存回收（Serial Old，在并发收集发生Concurrent Mode Failure的时候使用。单线程）`
- `-UseParNewGC`:`使用ParNew + Serial Old的收集器组合进行内存回收 （ParNew收集器 -XX:ParallelGCThreads参数来限制垃圾收集的线程数）`
- `-UseParallelGC`:`虚拟机运行在Server模式下的默认值，打开此开关后，使用Parallel Scavenge + Serial Old的收集器组合进行内存回收`
- `-UseParallelOldGC`:`使用Parallel Scavenge + Parallel Old的收集器组合进行垃圾回收`
- `-XX:+UseConcMarkSweepGC`:`CMS收集老年代`
- `-XX:+UseG1GC`:`使用G1回收`

### CMS

* ```初始标记```(Stop the World):仅仅是标记一下GC roots 能直接关联的对象，速度很快  
* ```并发标记```:就是进行gc roots tracing测过程 
* ```重新标记```(Stop the World):重新标记阶段就是为了修正并发标记期间因为用户程序继续运行而导致标记产生变动的那一部分对象的标记记录，这个阶段的停顿时间一般会比初始标记阶段的时间稍长，远远比并发标记阶段时间短
* ```并发清除```
* ```重新设置```

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

###垃圾回收器

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
此外除了CMS的GC，其实其他针对old gen的回收器都会在对old gen回收的同时回收young gen。
```

####G1收集器

```
G1收集器是一款面向服务端应用的垃圾收集器。HotSpot团队赋予它的使命是在未来替换掉JDK1.5中发布的CMS收集器。与其他GC收集器相比，G1具备如下特点：

并行与并发：G1能更充分的利用CPU，多核环境下的硬件优势来缩短stop the world的停顿时间。
分代收集：和其他收集器一样，分代的概念在G1中依然存在，不过G1不需要其他的垃圾回收器的配合就可以独自管理整个GC堆。
空间整合：G1收集器有利于程序长时间运行，分配大对象时不会无法得到连续的空间而提前触发一次GC。
可预测的非停顿：这是G1相对于CMS的另一大优势，降低停顿时间是G1和CMS共同的关注点，能让使用者明确指定在一个长度为M毫秒的时间片段内，消耗在垃圾收集上的时间不得超过N毫秒。
在使用G1收集器时，Java堆的内存布局和其他收集器有很大的差别，它将这个Java堆分为多个大小相等的独立区域，虽然还保留新生代和老年代的概念，但是新生代和老年代不再是物理隔离的了，它们都是一部分Region（不需要连续）的集合
```

###永久代、metaspace

```
在PermGen移除前，上述元数据对象都在PermGen里，直接被GC管理着。 
JDK8彻底移除PermGen后，这些对象被挪到GC堆外的一块叫做Metaspace的空间里做特殊管理，仍然间接的受
```

