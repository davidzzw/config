```
垃圾收集器参数总结
-XX:+<option> 启用选项
-XX:-<option> 不启用选项
-XX:<option>=<number> 
-XX:<option>=<string>
```

### jvm参数

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
* `-XX:+HeapDumpOnOutOfMemoryError`:
* ` -XX:HeapDumpPath=/tmp`
* `-verbose:gc`
* `-XX:+CMSClassUnloadingEnabled `
* `-XX:+PrintInlining`:`来打印编译过程中的内联情况 `

#### 堆外内存

* `-XX:MaxDirectMemorySize `

#### CodeCache

* `-XX:ReservedCodeCacheSize` 
* `-XX:InitialCodeCacheSize` 

* `-XX:+UseCodeCacheFlushing`：`启动CodeCache清理, 释放空间, 一定条件下会导致JIT被关闭 `

```
开启UseCodeCacheFlushing这个参数，会在Code Cache满了时紧急进行清扫工作，它会丢弃一半老的编译代码（discards older half of the compiled code(nmethods) 
开启UseCodeCacheFlushing导致问题 : CodeCache空间降了一半，方法编译工作仍然可能不会重启; flushing可能导致高的cpu使用，从而影响性能下降
```

#### StringTable相关

* `-XX:StringTableSize`:` 设置StringTable的size`
* `XX:+PrintStringTableStatistics`: `在程序结束时打印StringTable的一些使用情况`

#### 编译器相关

* `-Xcomp`:` jvm运行在纯编译模式 `
* `-XX:+TieredCompilation `:`开启分层编译模式 `

####日志相关

* `-XX:+PrintGCDetails`
* `-XX:+PrintGCDateStamps`
* `-Xloggc:/tmp/gc.log` 
* `-XX:+UseGCLogFileRotation`:`这个参数支持GC日志的滚动输出，默认是关闭的，所以大家要想滚动输出GC日志可以通过这个参数来设定GC日志并不是根据时间来进行滚动，而是当文件大小达到多大的时候就切换到下一个GC文件里`
* `-XX:GCLogFileSize=100K`:`就是用来指定当当前GC日志文件大小达到100KB的时候就写入到下一个GC日志文件里，如果当前文件已经是最后一个了，那下一个目标GC日志文件将会是0号GC日志文件`
* `-XX:NumberOfGCLogFiles=100`:`可以通过这个参数来指定要滚动输出的GC日志文件个数，日志名在上面提到的-Xloggc参数指定的路径后面加上序号，默认从0号开始，那什么时候换到下一个文件输出呢？`
* `UseGCLogFileRotation`:`控制打开这个开关，NumberOfGCLogFiles控制滚动的日志个数，GCLogFileSize控制文件达到多少的时候写入到下一个gc日志文件里`
* `-XX:+PrintInterpreter`:`得到运行时日志`

#### 栈帧

* `-XX:+PrintStubCode`:`查看运行时生成的stubs`
* `-XX:+UnlockDiagnosticVMOptions`
* `-XX:+ShowHiddenFrames`
*  `-XX:+UnlockDiagnosticVMOptions`

#### 逃逸

* `-XX:-DoEscapeAnalysis`:`关闭逃逸分析`

####RootType

* `-XX:+UnlockDiagnosticVMOptions` 
* `-XX:+PrintAssmbly`

#### CMS相关参数

- `-XX:+UseCMSCompactAtFullCollection`:`收集开关参数（默认就是开启的)，用于在CMS收集器进行FullGC完开启内存碎片的合并整理过程参数可以使 CMS 在垃圾收集完成后，进行一次内存碎片整理。内存碎片的整理并不是并发进行`

- `-XX:UseCMSInitatingOccupancyOnly`：`表示只在到达阈值的时候，才进行 CMS 回收`

- `-XX:+ParallelCMSThreads`:`CMS默认启动的回收线程数目是(ParallelGCThreads+3)/4，如果你需要明确设定，可以通过-XX:+ParallelCMSThreads来设定，其中-XX:+ParallelGCThreads代表的年轻代的并发收集线程数目`

- `-XX:+CMSClassUnloadingEnabled`：` 允许对元类数据进行回收`

- `-XX:+CMSInitatingPermOccupancyFraction`：`当永久区占用率达到这一百分比后，启动 CMS 回收 (前提是-XX:+CMSClassUnloadingEnabled 激活了)`

- `-XX:+CMSIncrementalMode`：`使用增量模式，比较适合单 CPU``

- ``-XX:+UseCMSCompactAtFullCollection`:`

- `-XX:+UseFullGCsBeforeCompaction`：`设定进行多少次 CMS 垃圾回收后，进行一次内存压缩`

- `-XX：ConcGCThreads`:

  ```
  标志-XX：ConcGCThreads=<value>(早期JVM版本也叫-XX:ParallelCMSThreads)定义并发CMS过程运行时的线程数。比如value=4意味着CMS周期的所有阶段都以4个线程来执行。
  尽管更多的线程会加快并发CMS过程，但其也会带来额外的同步开销。因此，对于特定的应用程序，应该通过测试来判断增加CMS线程数是否真的能够带来性能的提升。
  如果还标志未设置，JVM会根据并行收集器中的-XX：ParallelGCThreads参数的值来计算出默认的并行CMS线程数。该公式是ConcGCThreads = (ParallelGCThreads + 3)/4。
  因此，对于CMS收集器， -XX:ParallelGCThreads标志不仅影响“stop-the-world”垃圾收集阶段，还影响并发阶段。
  总之，有不少方法可以配置CMS收集器的多线程执行。正是由于这个原因,建议第一次运行CMS收集器时使用其默认设置, 然后如果需要调优再进行测试。
  只有在生产系统中测量(或类生产测试系统)发现应用程序的暂停时间的目标没有达到 , 就可以通过这些标志应该进行GC调优
  ```

- `-XX:+UseCMSInitiatingOccupancyOnly`: `如果需要根据 CMSInitiatingOccupancyFraction 的值进行判断，需要设置参数--XX:CMSInitiatingOccupancyFraction`

- `-XX:CMSInitiatingOccupancyFraction`:` 判断当前老年代使用率是否大于阈值，则触发 cms gc`

- `-XX:+CMSClassUnloadingEnabled`:` 希望对永久代进行垃圾收集`

- `-XX:CMSCompactWhenClearAllSoftRefs`:` 默认为 true`

- `-XX:CMSFullGCsBeforeCompaction=0` :`而且默认就是开启且每次full gc后整理old区内存碎片问题 cms gc不会整理内存碎片，但是full gc会`

#### G1相关参数



### 查看jvm启动参数

`java -XX:+PrintFlagsFinal -version `:`查看jvm所有参数`

`java -XX:+PrintFlagsFinal -version |grep MetaspaceSize `：`查看某个jvm参数默认值`

`jinfo -flags pid`:`查看jvm启动参数`

`jps -v |grep pid`: `查看jvm启动参数不全`

`jcmd pid VM.flags`:`查看jvm启动参数`

###示例一

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
-Xms3g -Xmx3g -XX:NewSize=1g -XX:MaxNewSize=1g -XX:PermSize=256m -XX:MaxPermSize=256m -XX:+UseConcMarkSweepGC -XX:CMSFullGCsBeforeCompaction=5 -XX:+UseCMSCompactAtFullCollection -XX:+CMSParallelRemarkEnabled -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=70 -XX:+DisableExplicitGC -XX:+UseCompressedOops -XX:+DoEscapeAnalysis -XX:MaxTenuringThreshold=10 -verbose:gc -Xloggc:/alidata1/admin/logs/gc.log -XX:+PrintGCDetails
####################CMS
ERROR_LOG_DIR="/data/www/wifiin/logs/jvm"
JAVA_OPTS=" $JAVA_OPTS -server "
JAVA_OPTS=" $JAVA_OPTS -Xmx4000M -Xms4000M -Xmn600M "
JAVA_OPTS=" $JAVA_OPTS -XX:LargePageSizeInBytes=128M -XX:MaxDirectMemorySize=512m "
JAVA_OPTS=" $JAVA_OPTS -XX:+UseConcMarkSweepGC " 
JAVA_OPTS=" $JAVA_OPTS -XX:+CMSScavengeBeforeRemark -XX:+CMSParallelRemarkEnabled -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=75 "
JAVA_OPTS=" $JAVA_OPTS -XX:+AlwaysPreTouch -XX:+UseStringDeduplication -XX:MaxTenuringThreshold=2 -XX:+CMSClassUnloadingEnabled -XX:-UseCounterDecay -XX:+ExplicitGCInvokesConcurrentAndUnloadsClasses -XX:+ExplicitGCInvokesConcurrent -XX:SoftRefLRUPolicyMSPerMB=0 -XX:-OmitStackTraceInFastThrow -XX:-UseBiasedLocking -XX:+UseCodeCacheFlushing -XX:+UseLargePages "
JAVA_OPTS=" $JAVA_OPTS -XX:ErrorFile=${ERROR_LOG_DIR}/hs_err_%p.log "
JAVA_OPTS=" $JAVA_OPTS -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=${ERROR_LOG_DIR} “
JAVA_OPTS=“ $JAVA_OPTS -XX:+ParallelRefProcEnabled "
JAVA_OPTS=" $JAVA_OPTS -Djava.security.egd=file:/dev/urandom “
JAVA_OPTS=" $JAVA_OPTS -XX:+UseNUMA"
JAVA_OPTS=" $JAVA_OPTS -Djava.rmi.server.hostname=127.0.0.1 -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=8888 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false "
JAVA_OPTS=" $JAVA_OPTS -XX:+PrintCommandLineFlags -XX:+PrintClassHistogram
-XX:+PrintGCDetails -XX:+PrintGCDateStamps 
-XX:+PrintHeapAtGC
-XX:+PrintGCApplicationStoppedTime 
-Xloggc:${ERROR_LOG_DIR}/gc.log “
JAVA_OPTS=" $JAVA_OPTS 
-XX:+UseGCLogFileRotation 
-XX:NumberOfGCLogFiles=2 
-XX:GCLogFileSize=1024M "
JAVA_OPTS=“ $JAVA_OPTS 
-XX:+PrintGCApplicationStoppedTime 
-XX:+PrintGCApplicationConcurrentTime"
JAVA_OPTS=“ $JAVA_OPTS 
-Djava.util.concurrent.ThreadJoinPool.common.parallelism=500
JAVA_OPTS=" $JAVA_OPTS 
-XX:+LogCommercialFeatures 
-XX:+UnlockCommercialFeatures
-XX:+FlightRecorder "
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



