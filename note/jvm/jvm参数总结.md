`所有参数在globals.hpp`

```
垃圾收集器参数总结
-XX:+<option> 启用选项
-XX:-<option> 不启用选项
-XX:<option>=<number> 
-XX:<option>=<string>
```

### jvm参数

#### 基本参数

* `-XX:+Xmx`: `设置堆内存的最大值`
* `-XX:+Xms`:` 设置堆内存的初始值`
* `-XX:+Xmn`:` 设置新生代的大小`
* `-XX:+Xss`: `设置栈的大小`
* `-XX:+PretenureSizeThreshold`: `直接晋升到老年代的对象大小，设置这个参数后，大于这个参数的对象将直接在老年代分配`
* `-XX:+MaxTenuringThrehold`: `晋升到老年代的对象年龄。每个对象在坚持过一次Minor GC之后，年龄就会加1，当超过这个参数值时就进入老年代`
* `-XX:+UseAdaptiveSizePolicy`:` 在这种模式下，新生代的大小、eden 和 survivor 的比例、晋升老年代的对象年龄等参数会被自动调整，以达到在堆大小、吞吐量和停顿时间之间的平衡点。在手工调优比较困难的场合，可以直接使用这种自适应的方式，仅指定虚拟机的最大堆、目标的吞吐量 (GCTimeRatio) 和停顿时间 (MaxGCPauseMills)，让虚拟机自己完成调优工作`
* `-XX:+SurvivorRattio`: `新生代Eden区域与Survivor区域的容量比值，默认为8，代表Eden: Suvivor= 8: 1`
* `-XX:+ParallelGCThreads`：`设置用于垃圾回收的线程数。通常情况下可以和 CPU 数量相等。但在 CPU 数量比较多的情况下，设置相对较小的数值也是合理的`
* `-XX:+MaxGCPauseMills`：`设置最大垃圾收集停顿时间。它的值是一个大于 0 的整数。收集器在工作时，会调整 Java 堆大小或者其他一些参数，尽可能地把停顿时间控制在 MaxGCPauseMills 以内`
* `-XX:+GCTimeRatio`:`设置吞吐量大小，它的值是一个 0-100 之间的整数。假设 GCTimeRatio 的值为 n，那么系统将花费不超过 1/(1+n) 的时间用于垃圾收集`
* `-XX:+OmitStackTraceInFastThrowr`:
* ` -XX:HeapDumpPath=/tmp`
* `-verbose:gc`
* `-XX:SurvivorRatio`: `Eden 区和 Survivor 区的比例 `
* `-XX:+MaxTenuringThreshold `
* `-XX:TargetSurvivorRatio`:`如果单个 Survivor 区已经被占用了 50%,那么较高复制次数的对象也会被晋升至老年代 `
* `-XX:ErrorFile`

#### Diagnostic Options

- `-XX:+PrintFlagsFinal(默认没有启用)`

> 用于查看所有可设置的参数及最终值(`JDK 6 update 21开始才可以用`），默认是不包括diagnostic或experimental系的。如果要在-XX:+PrintFlagsFinal的输出里看到这两种参数的信息，分别需要显式指定-XX:+UnlockDiagnosticVMOptions / -XX:+UnlockExperimentalVMOptions(`-XX:+PrintCommandLineFlags 这个参数的作用是显示出VM初始化完毕后所有跟最初的默认值不同的参数及它们的值`)

#### 编译

* `-Xint`:`解释模式`
* `-Xcomp`:`编译模式`
* `-Xmixed`:`混合模式`
* `-XX:+PrintInterpreter`:`为非编译的方法应用解释器`

##### Compilation Policy Options

* `-XX:CompileThreshold`:`方法触发编译时的调用次数，默认是10000`

- `-XX:OnStackReplacePercentage`:`方法中循环执行部分代码的执行次数触发OSR编译时的阈值，默认是140`

#### 堆外内存

* `-XX:MaxDirectMemorySize `

#### CodeCache

##### Codecache Size Options

- `-XX:InitialCodeCacheSize`：`用于设置初始CodeCache大小`

- `-XX:ReservedCodeCacheSize`:`用于设置Reserved code cache的最大大小，通常默认是240M`

- `-XX:CodeCacheExpansionSize`:`用于设置code cache的expansion size，通常默认是64K`

##### Codecache Flush Options

* `-XX:+UseCodeCacheFlushing`：`启动CodeCache清理, 释放空间, 一定条件下会导致JIT被关闭 `

```
开启UseCodeCacheFlushing这个参数，会在Code Cache满了时紧急进行清扫工作，它会丢弃一半老的编译代码（discards older half of the compiled code(nmethods) 
开启UseCodeCacheFlushing导致问题 : CodeCache空间降了一半，方法编译工作仍然可能不会重启; flushing可能导致高的cpu使用，从而影响性能下降
```

####PerfData(/tmp/hsperfdata_<user>/<pid>)
- `-XX:+PrintCodeCache(默认没有启用)`:`-XX:+PrintCodeCache用于jvm关闭时输出code cache的使用情况`

- `-XX:+PrintCodeCacheOnCompilation(默认没有启用)`:`用于在方法每次被编译时输出code cache的使用情`

* `-XX:-UsePerfData`:`如果关闭了UsePerfData这个参数，那么jvm启动过程中perf memory都不会被创建，jvm运行过程中自然不会再将这些性能数据保存起来，默认情况是是打开的`


* `-XX:+PerfDisableSharedMem`:`该参数决定了存储PerfData的内存是不是可以被共享，也就是说不管这个参数设置没设置，jvm在启动的时候都会分配一块内存来存PerfData，只是说这个PerfData是不是其他进程可见的问题，如果设置了这个参数，说明不能被共享，此时其他进程将访问不了该内存，这样一来，譬如我们jps，jstat等都无法工作。默认这个参数是关闭的，也就是默认支持共享的方式`
* `-XX:PerfDataSamplingInterval`:`由于这个文件是通过mmap的方式映射到了内存里，而jstat是直接通过DirectByteBuffer的方式从PerfData里读取的，所以只要内存里的值变了，那我们从jstat看到的值就会发生变化，内存里的值什么时候变，取决于-XX:PerfDataSamplingInterval这个参数，默认是50ms，也就是说50ms更新一次值，基本上可以认为是实时的了`
* `-XX:PerfDataMemorySize`：`指定/tmp/hsperfdata_<user>下perfData文件的大小，默认是32KB，如果用户设置了该值，jvm里会自动和os的page size对齐，比如linux下pagesize默认是4KB，那如果你设置了31KB，那自动会分配32KB`
* `-XX:+PerfDataSaveToFile`：`是否在进程退出的时候将PerfData里的数据保存到一个特定的文件里，文件路径由下面的参数指定，否则就在当前目录下`
* `-XX:PerfDataSaveFile`：`指定保存PerfData文件的路径`

#### Safepoint

* `-XX:+PrintSafepointStatistics`
* `-XX:+UseCountedLoopSafepoints`
* `–XX:PrintSafepointStatisticsCount=1` 

#### 卡表

* `-XX:+UseCondCardMark`:`减少写卡表的操作 `

#### StringTable相关

* `-XX:StringTableSize`:` 设置StringTable的size`
* `XX:+PrintStringTableStatistics`: `在程序结束时打印StringTable的一些使用情况`

#### 编译器相关

* `-Xcomp`:` jvm运行在纯编译模式 `
* `-XX:+TieredCompilation `:`开启分层编译模式 `
* ` -XX:-UseCounterDecay`：`禁止JIT调用计数器衰减。默认情况下，每次GC时会对调用计数器进行砍半的操作，导致有些方法一直是个温热，可能永远都达不到C2编译的1万次的阀值`

#### 日志相关

* `-XX:+PrintGCDetails`
* `-XX:+PrintGCDateStamps`
* `-Xloggc:/tmp/gc.log` 
* `-XX:LogFile`
* `-XX:+UseGCLogFileRotation`:`这个参数支持GC日志的滚动输出，默认是关闭的，所以大家要想滚动输出GC日志可以通过这个参数来设定GC日志并不是根据时间来进行滚动，而是当文件大小达到多大的时候就切换到下一个GC文件里`
* `-XX:GCLogFileSize=100K`:`就是用来指定当当前GC日志文件大小达到100KB的时候就写入到下一个GC日志文件里，如果当前文件已经是最后一个了，那下一个目标GC日志文件将会是0号GC日志文件`
* `-XX:NumberOfGCLogFiles=100`:`可以通过这个参数来指定要滚动输出的GC日志文件个数，日志名在上面提到的-Xloggc参数指定的路径后面加上序号，默认从0号开始，那什么时候换到下一个文件输出呢？`
* `UseGCLogFileRotation`:`控制打开这个开关，NumberOfGCLogFiles控制滚动的日志个数，GCLogFileSize控制文件达到多少的时候写入到下一个gc日志文件里`
* `-XX:+PrintInterpreter`:`得到运行时日志`
* `-XX:+PrintGCApplicationStoppedTime`
* `-XX:+LogVMOutput `
* `-XX:-DisplayVMOutput`

#### 装箱拆箱

* ` -XX:AutoBoxCacheMax`:`选项来指定high的值，当第一次使用Integer类型数据时，会加载IntegerCache这个静态内部类对象，然后在执行类的静态初始化，这个初始化会获取JVM的属性设置`

#### 栈帧

* `-XX:+PrintStubCode`:`查看运行时生成的stubs`
* `-XX:+UnlockDiagnosticVMOptions`
* `-XX:+ShowHiddenFrames`
* `-XX:+UseTLAB`

#### 逃逸

* `-XX:-DoEscapeAnalysis `:`关闭默认开启的逃逸分析 `
* `-XX:+UnlockExperimentalVMOptions` 
* ` -XX:+UseJVMCICompiler`:`来启用 Graal`

#### 内联

* `-XX:+PrintCompilation` :`确认某个方法有没有被JIT编译` 
* `-XX:+PrintInlining`:`来打印编译过程中的内联情况 `
* `-XX:MaxInlineLevel`:`针对嵌套调用的最大内联深度，默认为9`

- `-XX:MaxInlineSize`:`方法可以被内联的最大bytecode大小，默认为35`

- `-XX:MinInliningThreshold`:`方法可以被内联的最小调用次数，默认为250`

- `-XX:+InlineSynchronizedMethods`:`是否允许内联synchronized methods，默认为true`

####  RootType

* `-XX:+UnlockDiagnosticVMOptions` 
* `-XX:+PrintAssmbly`

#### 指针

- `-XX:+UseCompressedOops`: `压缩对象指针 `
- `-XX:+UseCompressedClassPointers`: `压缩类指针 `

#### CMS相关参数

* `-XX:+UseConcMarkSweepGC `:`使用CMS垃圾回收期 `
* `-XX:+ExplicitGCInvokesConcurrent `:`使用CMS收集器来触发Full gc `

- `-XX:UseCMSInitatingOccupancyOnly`：`表示只在到达阈值的时候，才进行CMS回收`
- `-XX:+CMSIncrementalMode`：`使用增量模式，比较适合单CPU`
- `-XX:+CMSParallelRemarkEnabled `:`降低标记停顿 `

##### 线程

- `-XX:+ParallelCMSThreads`:`CMS默认启动的回收线程数目是(ParallelGCThreads+3)/4，如果你需要明确设定，可以通过-XX:+ParallelCMSThreads来设定，其中-XX:+ParallelGCThreads代表的年轻代的并发收集线程数目`

- `-XX：ConcGCThreads`:

  ```
  标志-XX：ConcGCThreads=<value>(早期JVM版本也叫-XX:ParallelCMSThreads)定义并发CMS过程运行时的线程数。比如value=4意味着CMS周期的所有阶段都以4个线程来执行。
  尽管更多的线程会加快并发CMS过程，但其也会带来额外的同步开销。因此，对于特定的应用程序，应该通过测试来判断增加CMS线程数是否真的能够带来性能的提升。
  如果还标志未设置，JVM会根据并行收集器中的-XX：ParallelGCThreads参数的值来计算出默认的并行CMS线程数。该公式是ConcGCThreads = (ParallelGCThreads + 3)/4。
  因此，对于CMS收集器， -XX:ParallelGCThreads标志不仅影响“stop-the-world”垃圾收集阶段，还影响并发阶段。
  总之，有不少方法可以配置CMS收集器的多线程执行。正是由于这个原因,建议第一次运行CMS收集器时使用其默认设置, 然后如果需要调优再进行测试。
  只有在生产系统中测量(或类生产测试系统)发现应用程序的暂停时间的目标没有达到 , 就可以通过这些标志应该进行GC调优
  ```

- `CMSParallelInitialMarkEnabled`:``

- `-XX:+UseCMSInitiatingOccupancyOnly`: `如果需要根据 CMSInitiatingOccupancyFraction 的值进行判断，需要设置参数CMSInitiatingOccupancyFraction,使用手动定义初始化定义开始CMS收集,禁止hostspot自行触发CMS GC`

`我们用-XX+UseCMSInitiatingOccupancyOnly标志来命令JVM不基于运行时收集的数据来启动CMS垃圾收集周期。而是，当该标志被开启时，JVM通过CMSInitiatingOccupancyFraction的值进行每一次CMS收集，而不仅仅是第一次。然而，请记住大多数情况下，JVM比我们自己能作出更好的垃圾收集决策。因此，只有当我们充足的理由(比如测试)并且对应用程序产生的对象的生命周期有深刻的认知时，才应该使用该标志`

- `-XX:CMSInitiatingOccupancyFraction`:` 判断当前老年代使用率是否大于阈值，则触发cms gc`
- `-XX:CMSCompactWhenClearAllSoftRefs`:` 默认为true`

##### YGC

* `-XX:CMSScavengeBeforeRemark `:`开启或关闭在 CMS-remark 阶段之前的清除（Young GC）尝试`
* ​

##### 方法区

- `-XX:+CMSClassUnloadingEnabled`：` 允许对元类数据进行回收`
- `-XX:+CMSPermGenSweepingEnabled`:`是否会清理持久代`
- `-XX:+ExplicitGCInvokesConcurrentAndUnloadsClasses`: `保证当有系统GC调用时，永久代也被包括进CMS垃圾回收的范围内 `
- `-XX:+CMSInitatingPermOccupancyFraction`：`当永久区占用率达到这一百分比后，启动CMS回收 (前提是-XX:+CMSClassUnloadingEnabled 激活了)`
- `-XX:+CMSInitiatingPermOccupancyFraction `:`设置Perm Gen使用到达多少比率时触发 `
- `-XX:+CMSClassUnloadingEnabled`:` 在使用CMS垃圾回收机制的时候是否启用类卸载功能,如果希望对永久代进行垃圾回收，可用设置标志-XX:+CMSClassUnloadingEnabled`

##### 可中断预清理

- `-XX:+CMSScheduleRemarkEdenSizeThreshold `:`新生代Eden区的内存使用量大于参数 `
- `CMSScheduleRemarkEdenPenetration`
- `CMSMaxAbortablePrecleanLoops`
- `CMSMaxAbortablePrecleanTime`

##### 压缩

- `-XX:+UseCMSCompactAtFullCollection`:`收集开关参数（默认就是开启的)，用于在CMS收集器进行FullGC完开启内存碎片的合并整理过程参数可以使 CMS 在垃圾收集完成后，进行一次内存碎片整理。内存碎片的整理并不是并发进行`
- `-XX:+UseCMSCompactAtFullCollection `:`用于在Full GC之后增加一个碎片整理`
- `-XX:CMSFullGCsBeforeCompaction=0` :`而且默认就是开启且每次full gc后整理old区内存碎片问题 cms gc不会整理内存碎片，但是full gc会`
- `-XX:+UseFullGCsBeforeCompaction`：`设定进行多少次CMS 垃圾回收后，进行一次内存压缩`
- `-XX:+CMSScavengeBeforeRemark `:`开启或关闭在CMS重新标记阶段之前的清除（YGC）尝试,CMS remark阶段前会触发一次minor GC `

#### G1相关参数

#### vm

* `-XX:+ParallelRefProcEnabled `:` 这个选项可以用HotSpot VM的任何一种垃圾回收器上，他会是用多个的引用处理线程，而不是单个线程。这个选项不会启用多线程运行方法的finalizer。他会使用很多线程去发现需要排队通知的finalizable对象`

#### 循环预测（Loop Prediction）

* `-XX:+UseLoopPredicate`

#### UseParallelGC 或 UseParallelOldGC

* `-XX:+ScavengeBeforeFullGC `:`当它启用并且当前在使用 +UseParallelGC或+UseParallelOldGC时触发full GC就会先用PSScavenge来收集一次young gen（也就是做一次minor GC），然后再用PSMarkSweep（如果用+UseParallelOldGC）或PSParallelCompact（如果用+UseParallelOldGC）来收集一到多次全堆`

#### System.gc

* `-XXnoSystemGC`
* `-XXfullSystemGC`
* `-XX:-UseCounterDecay`:`禁用计数器衰减的`

#### 锁

* `-XX:-UseBiasedLocking`:`禁用偏向锁`

#### 编码

* `-Dfile.encoding=UTF-8`

#### 时区



### 查看jvm启动参数

`java -XX:+PrintFlagsFinal -version `:`查看jvm所有参数`

`java -XX:+PrintFlagsFinal -version |grep MetaspaceSize `：`查看某个jvm参数默认值`

`jinfo -flags pid`:`查看jvm启动参数`

`jps -v |grep pid`: `查看jvm启动参数不全`

`jcmd pid VM.flags`:`查看jvm启动参数`

### 查看停顿–安全点停顿日志

要查看安全点停顿，可以打开安全点日志，通过设置JVM参数 `-XX:+PrintGCApplicationStoppedTime` 会打出系统停止的时间，添加`-XX:+PrintSafepointStatistics -XX:PrintSafepointStatisticsCount=1` 这两个参数会打印出详细信息，可以查看到使用偏向锁导致的停顿，时间非常短暂，但是争用严重的情况下，停顿次数也会非常多；

注意：安全点日志不能一直打开： 
1. 安全点日志默认输出到stdout，一是stdout日志的整洁性，二是stdout所重定向的文件如果不在/dev/shm，可能被锁。 
2. 对于一些很短的停顿，比如取消偏向锁，打印的消耗比停顿本身还大。 
3. 安全点日志是在安全点内打印的，本身加大了安全点的停顿时间。

所以安全日志应该只在问题排查时打开。 
如果在生产系统上要打开，再再增加下面四个参数： 
`-XX:+UnlockDiagnosticVMOptions -XX: -DisplayVMOutput -XX:+LogVMOutput -XX:LogFile=/dev/shm/vm.log`

打开Diagnostic（只是开放了更多的flag可选，不会主动激活某个flag），关掉输出VM日志到stdout，输出到独立文件,/dev/shm目录（内存文件系统）

### 查看Code Cache的使用情况

#### -XX:+PrintCodeCache

```
CodeHeap 'non-profiled nmethods': size=120032Kb used=2154Kb max_used=2160Kb free=117877Kb
bounds [0x00000001178ea000, 0x0000000117b5a000, 0x000000011ee22000]
CodeHeap 'profiled nmethods': size=120028Kb used=10849Kb max_used=11005Kb free=109178Kb
bounds [0x00000001103b3000, 0x0000000110e73000, 0x00000001178ea000]
CodeHeap 'non-nmethods': size=5700Kb used=1177Kb max_used=1239Kb free=4522Kb
bounds [0x000000010fe22000, 0x0000000110092000, 0x00000001103b3000]
total_blobs=5638 nmethods=4183 adapters=435
compilation: enabled
            stopped_count=0, restarted_count=0
full_count=0
```

- jvm启动参数加上-XX:+PrintCodeCache，可以在jvm关闭时输出code cache的使用情况
- 这里分了non-profiled nmethods、profiled nmethods、non-nmethods三部分来展示
- 其中size就是限制的最大大小，used表示实际使用量，max_used就是使用大小的high water mark，free由size-used得来

#### jcmd pid Compiler.codecache

```
/ # jcmd 1 Compiler.codecache
1:
CodeHeap 'non-profiled nmethods': size=120036Kb used=1582Kb max_used=1582Kb free=118453Kb
bounds [0x00007f1e42226000, 0x00007f1e42496000, 0x00007f1e4975f000]
CodeHeap 'profiled nmethods': size=120032Kb used=9621Kb max_used=9621Kb free=110410Kb
bounds [0x00007f1e3acee000, 0x00007f1e3b65e000, 0x00007f1e42226000]
CodeHeap 'non-nmethods': size=5692Kb used=1150Kb max_used=1198Kb free=4541Kb
bounds [0x00007f1e3a75f000, 0x00007f1e3a9cf000, 0x00007f1e3acee000]
total_blobs=5610 nmethods=4369 adapters=412
compilation: enabled
            stopped_count=0, restarted_count=0
full_count=0
```

> 使用jcmd的Compiler.codecache也可以查看code cache的使用情况，输出跟-XX:+PrintCodeCache相同

#### jcmd pid VM.native_memory

```
/ # jcmd 1 VM.native_memory
1:

Native Memory Tracking:

Total: reserved=1928023KB, committed=231182KB
-                 Java Heap (reserved=511488KB, committed=140288KB)
                          (mmap: reserved=511488KB, committed=140288KB)

-                     Class (reserved=1090832KB, committed=46608KB)
                          (classes #8218)
                          ( instance classes #7678, array classes #540)
                          (malloc=1296KB #19778)
                          (mmap: reserved=1089536KB, committed=45312KB)
                          ( Metadata:   )
                          (   reserved=40960KB, committed=39680KB)
                          (   used=38821KB)
                          (   free=859KB)
                          (   waste=0KB =0.00%)
                          ( Class space:)
                          (   reserved=1048576KB, committed=5632KB)
                          (   used=5190KB)
                          (   free=442KB)
                          (   waste=0KB =0.00%)

-                   Thread (reserved=37130KB, committed=2806KB)
                          (thread #36)
                          (stack: reserved=36961KB, committed=2636KB)
                          (malloc=127KB #189)
                          (arena=42KB #70)

-                     Code (reserved=248651KB, committed=15351KB)
                          (malloc=963KB #4600)
                          (mmap: reserved=247688KB, committed=14388KB)

-                       GC (reserved=21403KB, committed=7611KB)
                          (malloc=5419KB #9458)
                          (mmap: reserved=15984KB, committed=2192KB)

-                 Compiler (reserved=150KB, committed=150KB)
                          (malloc=20KB #447)
                          (arena=131KB #5)

-                 Internal (reserved=3744KB, committed=3744KB)
                          (malloc=1696KB #6416)
                          (mmap: reserved=2048KB, committed=2048KB)

-                     Other (reserved=24KB, committed=24KB)
                          (malloc=24KB #2)

-                   Symbol (reserved=10094KB, committed=10094KB)
                          (malloc=7305KB #219914)
                          (arena=2789KB #1)

-   Native Memory Tracking (reserved=4130KB, committed=4130KB)
                          (malloc=12KB #158)
                          (tracking overhead=4119KB)

-               Arena Chunk (reserved=177KB, committed=177KB)
                          (malloc=177KB)

-                   Logging (reserved=7KB, committed=7KB)
                          (malloc=7KB #264)

-                 Arguments (reserved=18KB, committed=18KB)
                          (malloc=18KB #500)

-                   Module (reserved=165KB, committed=165KB)
                          (malloc=165KB #1699)

-                 Safepoint (reserved=4KB, committed=4KB)
                          (mmap: reserved=4KB, committed=4KB)

-                   Unknown (reserved=4KB, committed=4KB)
                          (mmap: reserved=4KB, committed=4KB)
```

> 使用jcmd的VM.native_memory也可以查看code cache的使用情况(`Code部分`)，Compiler部分为Memory tracking used by the compiler when generating code

#### 使用MemoryPoolMXBean查看

```
  public void testGetCodeCacheUsage(){
      ManagementFactory.getPlatformMXBeans(MemoryPoolMXBean.class)
              .stream()
              .filter(e -> MemoryType.NON_HEAP == e.getType())
              .filter(e -> e.getName().startsWith("CodeHeap"))
              .forEach(e -> {
                  LOGGER.info("name:{},info:{}",e.getName(),e.getUsage());
              });
  }
```

> MemoryPoolMXBean包含了HEAP及NON_HEAP，其中code cache属于NON_HEAP，其输出如下：

```
12:21:10.728 [main] INFO com.example.CodeCacheTest - name:CodeHeap 'non-nmethods',info:init = 2555904(2496K) used = 1117696(1091K) committed = 2555904(2496K) max = 5836800(5700K)
12:21:10.743 [main] INFO com.example.CodeCacheTest - name:CodeHeap 'profiled nmethods',info:init = 2555904(2496K) used = 1543808(1507K) committed = 2555904(2496K) max = 122908672(120028K)
12:21:10.743 [main] INFO com.example.CodeCacheTest - name:CodeHeap 'non-profiled nmethods',info:init = 2555904(2496K) used = 319616(312K) committed = 2555904(2496K) max = 122912768(120032K)
```

### 示例一

```
-XX:+UseParNewGC  
-XX:+UseConcMarkSweepGC
-XX:CMSInitiatingOccupancyFraction=75 
-XX:ConcGCThreads=1 
-XX:+ExplicitGCInvokesConcurrent 
-XX:InitialHeapSize=4G
-XX:+ManagementServer
-XX:MaxHeapSize=4G
-XX:NewSize=2G
-XX:MaxNewSize=2G
-XX:MaxTenuringThreshold=6 
-XX:OldPLABSize=16 
-XX:ParallelGCThreads=4 
-XX:+ParallelRefProcEnabled 
-XX:+PrintGCApplicationStoppedTime
-XX:+UseCMSInitiatingOccupancyOnly 
-XX:+UseCompressedClassPointers
-XX:+UseCompressedOops 
-XX：ConcGCThreads
-verbose:gc 
-XX:SurvivorRatio=4 
-XX:+UseGCLogFileRotation
-XX:NumberOfGCLogFiles=100 
-XX:GCLogFileSize=100K
-Xloggc:D:/logs/gc.log 
-XX:+PrintGCDetails 
-XX:+PrintGCDateStamps 
-XX:+PrintGCTimeStamps 
-XX:ErrorFile=/apps/logs/tomcat/java_error%p.log 
-XX:+HeapDumpOnOutOfMemoryError 
-XX:HeapDumpPath=/apps/logs/tomcat 
```

### 示例二

```
-Xms3g -Xmx3g -XX:NewSize=1g -XX:MaxNewSize=1g -XX:PermSize=256m -XX:MaxPermSize=256m 
-XX:LargePageSizeInBytes=128M 
-XX:MaxDirectMemorySize=512m
-XX:+UseConcMarkSweepGC
-XX:+CMSScavengeBeforeRemark 
-XX:+CMSParallelRemarkEnabled 
-XX:+UseCMSInitiatingOccupancyOnly
-XX:CMSInitiatingOccupancyFraction=75
-XX:CMSFullGCsBeforeCompaction=5
-XX:+UseCMSCompactAtFullCollection 
-XX:+AlwaysPreTouch 
-XX:+UseStringDeduplication 
-XX:MaxTenuringThreshold=2 
-XX:+CMSClassUnloadingEnabled 
-XX:-UseCounterDecay 
-XX:+ExplicitGCInvokesConcurrentAndUnloadsClasses 
-XX:+ExplicitGCInvokesConcurrent 
-XX:SoftRefLRUPolicyMSPerMB=0 
-XX:-OmitStackTraceInFastThrow 
-XX:-UseBiasedLocking 
-XX:+UseCodeCacheFlushing 
-XX:+UseLargePages
-XX:ErrorFile=${ERROR_LOG_DIR}/hs_err_%p.log
-XX:+HeapDumpOnOutOfMemoryError 
-XX:HeapDumpPath=${ERROR_LOG_DIR}
-XX:+ParallelRefProcEnabled
-Djava.security.egd=file:/dev/urandom
-XX:+UseNUMA
-Djava.rmi.server.hostname=127.0.0.1
-Dcom.sun.management.jmxremote
-Dcom.sun.management.jmxremote.port=8888 
-Dcom.sun.management.jmxremote.authenticate=false 
-Dcom.sun.management.jmxremote.ssl=false
-Djava.util.concurrent.ThreadJoinPool.common.parallelism=500
-verbose:gc
-XX:+PrintCommandLineFlags
-XX:+PrintClassHistogram
-XX:+PrintGCDetails
-XX:+PrintGCDateStamps 
-XX:+PrintHeapAtGC
-XX:+PrintGCApplicationStoppedTime 
-Xloggc:${ERROR_LOG_DIR}/gc.log
-XX:+UseGCLogFileRotation 
-XX:NumberOfGCLogFiles=2 
-XX:GCLogFileSize=1024M
-XX:+PrintGCApplicationConcurrentTime
-XX:+LogCommercialFeatures 
-XX:+UnlockCommercialFeatures 
-XX:+FlightRecorder
-XX:+DisableExplicitGC 
-XX:+UseCompressedOops
-XX:+DoEscapeAnalysis
```

### 示例三

```
-Xmx4096M -Xms4096M -Xmn1536M 
-XX:MaxMetaspaceSize=512M -XX:MetaspaceSize=512M 
-XX:+UseConcMarkSweepGC 
-XX:+UseCMSInitiatingOccupancyOnly 
-XX:CMSInitiatingOccupancyFraction=70 
-XX:+ExplicitGCInvokesConcurrentAndUnloadsClasses 
-XX:+CMSClassUnloadingEnabled 
-XX:+ParallelRefProcEnabled 
-XX:+CMSScavengeBeforeRemark 
-XX:ErrorFile=/home/admin/logs/xelephant/hs_err_pid%p.log 
-Xloggc:/home/admin/logs/xelephant/gc.log 
-XX:HeapDumpPath=/home/admin/logs/xelephant 
-XX:+PrintGCDetails 
-XX:+PrintGCDateStamps 
-XX:+HeapDumpOnOutOfMemoryError
```

### 案例一	

* `对象默认都是从Eden区分配，但是遇到大对象会直接在Old区分配，此时不会进行YGC`
* `这个大对象是指：大于PretenureSizeThreshold或者大于Eden`
* `但是如果遇到待分配对象不是大对象，Eden区剩余空间不足，此时就会发生YGC`
* `PretenureSizeThreshold值只是判断条件之一还有其他条件，判断条件的顺序不重要，不会影响最终的YGC的触发`
* `意young GC中有部分存活对象会晋升到old gen，所以young GC后old gen的占用量通常会有所升高`

```
// 利用GC回收前与回收后的差值计算对象的大小：
class Foo{ // 32位OS类定义引用占8 byte,64位OS占用16 byte
   int x;  // 4 byte
   byte b; // 1 byte
}

public class Demo {
  public static void main(String args[]) {
    Foo foo= new Foo();
    Runtime.getRuntime().gc();
    long gcing = Runtime.getRuntime().freeMemory();
    Foo foo2= new Foo();
    long gced = Runtime.getRuntime().freeMemory();
    // 64位打印24，32位打印16 （注:是因为JVM底层内存都是以8 byte对齐的,即8的倍数）
    System.out.println("Memory used:"+(gcing -gced )); 
  }
}
```



