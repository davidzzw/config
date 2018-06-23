```
每个缓存行有一个状态，MSIE，表示4个状态，如果发现是失效的话，就从内存获取数据
CAS比volatile多了cmgx
```

###5.7

```
jmap -histo:live pid
jmap -histo pid | head -n20

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
JAVA_OPTS=" $JAVA_OPTS -XX:+PrintCommandLineFlags -XX:+PrintClassHistogram -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintHeapAtGC -XX:+PrintGCApplicationStoppedTime -Xloggc:${ERROR_LOG_DIR}/gc.log “
JAVA_OPTS=" $JAVA_OPTS -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=2 -XX:GCLogFileSize=1024M "
JAVA_OPTS=“ $JAVA_OPTS -XX:+PrintGCApplicationStoppedTime -XX:+PrintGCApplicationConcurrentTime "
JAVA_OPTS=“ $JAVA_OPTS -Djava.util.concurrent.ThreadJoinPool.common.parallelism=500
JAVA_OPTS=" $JAVA_OPTS -XX:+LogCommercialFeatures -XX:+UnlockCommercialFeatures -XX:+FlightRecorder "

JDK中带有了一堆的工具是可以用来查看运行状况，排查问题的，但对于这些工具还是要比较清楚执行后会发生什么，否则有可能会因为执行了一个命令就导致严重故障，重点讲下影响比较大的jmap。

最主要的危险操作是下面这三种：
1. jmap -dump
这个命令执行，JVM会将整个heap的信息dump写入到一个文件，heap如果比较大的话，就会导致这个过程比较耗时，并且执行的过程中为了保证dump的信息是可靠的，所以会暂停应用。

2. jmap -permstat
这个命令执行，JVM会去统计perm区的状况，这整个过程也会比较的耗时，并且同样也会暂停应用。

3. jmap -histo:live
这个命令执行，JVM会先触发gc，然后再统计信息。

上面的这三个操作都将对应用的执行产生影响，所以建议如果不是很有必要的话，不要去执行。

另外，在排查问题的时候，对于保留现场信息的操作，可以用gcore [pid]直接保留，这个的执行速度会比jmap -dump快不少，之后可以再用jmap/jstack等从core dump文件里提取相应的信息，不过这个操作建议大家先测试下，貌似在有些jdk版本上不work。

之前碰到过一次语言集的问题，我们的Java应用多数在做字符串转码的时候是没有指定编码的，编码信息主要靠启动脚本里面设置LANG来控制，但没想到在某种场景下，竟然有地方设置了LC_ALL，在之前的一篇语言集的文章中，有讲过LC_ALL的优先级是最高的，所以导致启动脚本里设置的LANG失效了，从而导致了乱码，这个Case来看，对于Java应用，还是在启动参数上指定下-Dfile.encoding比较安全一点，避免这种默认的转码依赖系统的配置，很容易踩进坑里。
```



FATAL ERROR in native method: JDWP ExceptionOccurred, jvmtiError=AGENT_ERROR_INVALID_EVENT_TYPE(204)

在类名上加个注解
@JsonNaming(PropertyNamingStrategy.LowerCaseWithUnderscoresStrategy.class)
jmap -histo pid | head -n20 看看你们对象分布
-XX:+PrintStringTableStatistics

idea参数优化
-Xms1024m
-Xmx1024m
-Xmn372m
-XX:MetaspaceSize=256m
-XX:MaxMetaspaceSize=512m
-XX:ReservedCodeCacheSize=240m
-XX:+UseConcMarkSweepGC
-XX:+UseParNewGC
-XX:+CMSParallelRemarkEnabled
-XX:+CMSScavengeBeforeRemark
-XX:CMSInitiatingOccupancyFraction=75
-XX:+UseCMSInitiatingOccupancyOnly
-XX:+UseCMSCompactAtFullCollection
-XX:CMSFullGCsBeforeCompaction=3
-XX:SoftRefLRUPolicyMSPerMB=50
-XX:+HeapDumpOnOutOfMemoryError

-XX:CICompilerCount=2 -XX:InitialHeapSize=31457280 -XX:+ManagementServer -XX:MaxHeapSize=480247808 -XX:MaxNewSize=160038912
-XX:MinHeapDeltaBytes=196608 -XX:NewSize=10485760 -XX:OldSize=20971520 -XX:+UseCompressedClassPointers 
-XX:+UseCompressedOops -XX:+UseFastUnorderedTimeStamps 

CATALINA_OPTS="$CATALINA_OPTS 
-Dcom.sun.management.jmxremote
 -Djava.rmi.server.hostname=192.168.220.131 
 -Dcom.sun.management.jmxremote.port=8999 
 -Dcom.sun.management.jmxremote.ssl=false 
 -Dcom.sun.management.jmxremote.authenticate=false"

MaxMetaspaceSize
CompressedClassSpaceSize
Klass Metaspace
NoKlass Metaspace
-XX:CompressedClassSpaceSize
UseLargePagesInMetaspace
InitialBootClassLoaderMetaspaceSize
MetaspaceSize
MaxMetaspaceSize
CompressedClassSpaceSize
MinMetaspaceExpansion
MaxMetaspaceExpansion
MinMetaspaceFreeRatio
MaxMetaspaceFreeRatio

jdk 1.8
MC & MU & CCSC & CCSU
MC表示Klass Metaspace以及NoKlass Metaspace两者总共committed的内存大小，单位是KB，虽然从上面的定义里我们看到了是capacity，但是实质上计算的时候并不是capacity，
而是committed，这个是要注意的MU这个无可厚非，说的就是Klass Metaspace以及NoKlass Metaspace两者已经使用了的内存大小
CCSC表示的是Klass Metaspace的已经被commit的内存大小，单位也是KB
CCSU表示Klass Metaspace的已经被使用的内存大小
M & CCS
M表示的是Klass Metaspace以及NoKlass Metaspace两者总共的使用率，其实可以根据上面的四个指标算出来，即(CCSU+MU)/(CCSC+MC)
CCS表示的是NoKlass Metaspace的使用率，也就是CCSU/CCSC算出来的
PS：所以我们有时候看到M的值达到了90%以上，其实这个并不一定说明metaspace用了很多了，因为内存是慢慢commit的，所以我们的分母是慢慢变大的，
不过当我们committed到一定量的时候就不会再增长了

MCMN & MCMX & CCSMN & CCSMX

MCMN和CCSMN这两个值大家可以忽略，一直都是0

MCMX表示Klass Metaspace以及NoKlass Metaspace两者总共的reserved的内存大小，比如默认情况下Klass Metaspace是通过CompressedClassSpaceSize这个参数来reserved 1G的内存，
NoKlass Metaspace默认reserved的内存大小是2* InitialBootClassLoaderMetaspaceSize
CCSMX表示Klass Metaspace reserved的内存大小

jcmd pid VM.flags
jmap -histo pid > pid.log;head -n20 pid.log
jmap -histo pid > pid.log ;   head -n20 pid.log
jstat -gccause
ps -p pid  -o  etime
jstat -gc pid 3s 3
top -H -p pid

-XX:+UseConcMarkSweepGC
-XX:CMSInitiatingOccupancyFraction=75 
-XX:ConcGCThreads=1 
-XX:ErrorFile=/apps/logs/tomcat/java_error%p.log 
-XX:+ExplicitGCInvokesConcurrent 
-XX:+HeapDumpOnOutOfMemoryError 
-XX:HeapDumpPath=/apps/logs/tomcat 
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
-XX:+PrintGCDateStamps
-XX:+PrintGCDetails 
-XX:+PrintGCTimeStamps 
-XX:+UseCMSInitiatingOccupancyOnly 
-XX:+UseCompressedClassPointers
-XX:+UseCompressedOops 
-XX：ConcGCThreads

标志-XX：ConcGCThreads=<value>(早期JVM版本也叫-XX:ParallelCMSThreads)定义并发CMS过程运行时的线程数。比如value=4意味着CMS周期的所有阶段都以4个线程来执行。
尽管更多的线程会加快并发CMS过程，但其也会带来额外的同步开销。因此，对于特定的应用程序，应该通过测试来判断增加CMS线程数是否真的能够带来性能的提升。
如果还标志未设置，JVM会根据并行收集器中的-XX：ParallelGCThreads参数的值来计算出默认的并行CMS线程数。该公式是ConcGCThreads = (ParallelGCThreads + 3)/4。
因此，对于CMS收集器， -XX:ParallelGCThreads标志不仅影响“stop-the-world”垃圾收集阶段，还影响并发阶段。
总之，有不少方法可以配置CMS收集器的多线程执行。正是由于这个原因,建议第一次运行CMS收集器时使用其默认设置, 然后如果需要调优再进行测试。
只有在生产系统中测量(或类生产测试系统)发现应用程序的暂停时间的目标没有达到 , 就可以通过这些标志应该进行GC调优。

JVM参数:
-verbose:gc -Xmx42M -Xmn12M -XX:SurvivorRatio=4 -XX:CMSInitiatingOccupancyFraction=50 -XX:+UseCMSInitiatingOccupancyOnly 
-XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+UseConcMarkSweepGC -XX:+UseParNewGC  
-XX:+HeapDumpOnOutOfMemoryError -Xloggc:D:/logs/gc.log -XX:HeapDumpPath=/D:/dump

-verbose:gc -XX:SurvivorRatio=4 -XX:+PrintGCDetails -XX:+PrintGCDateStamps 
-XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=100 -XX:GCLogFileSize=100K
 -XX:+UseConcMarkSweepGC -XX:+UseParNewGC  
-XX:+HeapDumpOnOutOfMemoryError -Xloggc:D:/logs/gc.log 

-XX:+UseGCLogFileRotation这个参数支持GC日志的滚动输出，默认是关闭的，所以大家
要想滚动输出GC日志可以通过这个参数来设定
GC日志并不是根据时间来进行滚动，而是当文件大小达到多大的时候就切换到下一个GC文件里，
-XX:GCLogFileSize=100K就是用来指定当当前GC日志文件大小达到100KB的时候就写入到下一个GC日志文件里，
如果当前文件已经是最后一个了，那下一个目标GC日志文件将会是0号GC日志文件

-XX:NumberOfGCLogFiles=100可以通过这个参数来指定要滚动输出的GC日志文件个数，
日志名在上面提到的-Xloggc参数指定的路径后面加上序号，默认从0号开始，那什么时候换到下一个文件输出呢？

UseGCLogFileRotation控制打开这个开关，NumberOfGCLogFiles控制滚动的日志个数，GCLogFileSize控制文件达到多少的时候写入到下一个gc日志文件里

XX:+CMSClassUnloadingEnabled 
FooSingleton.class
加载FooSingleton的ClassLoader（defining class loader）
FooSingleton.VALUE所指向的单例对象
加载FooSingleton的ClassLoader所加载的所有其它类也都没有活的实例并且其Class对象没有被活的强引用所引用

UseCMSInitiatingOccupancyOnly

XX:+UseCMSInitiatingOccupancyOnly 如果需要根据 CMSInitiatingOccupancyFraction 的值进行判断，需要设置参数-
-XX:CMSInitiatingOccupancyFraction 判断当前老年代使用率是否大于阈值，则触发 cms gc	
-XX:+CMSClassUnloadingEnabled 希望对永久代进行垃圾收集
-XX:CMSCompactWhenClearAllSoftRefs 默认为 true

Java代码:

        public static void main(String[] args) throws InterruptedException {
        // Eden不够, 但是Old区空间是够的, 所以这时候并不会触发Young GC(Minor GC)
        byte[] byte10m1 = new byte[10 * 1024 * 1024];
    
        System.out.println("hello world");
        Thread.sleep(20000);
    }

-XX:+UseCMSCompactAtFullCollection XX:CMSFullGCsBeforeCompaction=0 而且默认就是开启且每次full 
gc后整理old区内存碎片问题 cms gc不会整理内存碎片，但是full gc会	
​	
1.对象默认都是从Eden区分配，但是遇到大对象会直接在Old区分配，此时不会进行YGC
2.这个大对象是指：大于PretenureSizeThreshold或者大于Eden
3.但是如果遇到待分配对象不是大对象，Eden区剩余空间不足，此时就会发生YGC
4.PretenureSizeThreshold值只是判断条件之一还有其他条件，判断条件的顺序不重要，不会影响最终的YGC的触发
5.注意young GC中有部分存活对象会晋升到old gen，所以young GC后old gen的占用量通常会有所升高

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

可见性：一个线程对主内存的修改可以及时的被其他线程观察到。
有序性：一个线程观察其他线程中的指令执行顺序，由于指令 重排序的存在，该观察结果一般杂乱无序。
原子性：提供了互斥访问。

1、是否可以考虑采用ReentrantLock来实现，但是实际上去实现的时候是有问题的，ReentrantLock的lock和unlock要求必须是在同一线程进行，
而分布式应用中，lock和unlock是两次不相关的请求，因此肯定不是同一线程，因此导致无法使用ReentrantLock。
2、基于数据库表做乐观锁，用于分布式锁。
3、使用memcached的add()方法，用于分布式锁。
4、使用memcached的cas()方法，用于分布式锁。(不常用) 
5、使用redis的setnx()、expire()方法，用于分布式锁。
6、使用redis的setnx()、get()、getset()方法，用于分布式锁。
7、使用redis的watch、multi、exec命令，用于分布式锁。(不常用) 
8、使用zookeeper，用于分布式锁。(不常用) 

缓存系统不得不考虑的另一个问题是缓存穿透与失效时的雪崩效应。缓存穿透是指查询一个一定不存在的数据，由于缓存是不命中时被动写的，
并且出于容错考虑，如果从存储层查不到数据则不写入缓存，这将导致这个不存在的数据每次请求都要到存储层去查询，失去了缓存的意义。
有很多种方法可以有效地解决缓存穿透问题，最常见的则是采用布隆过滤器，将所有可能存在的数据哈希到一个足够大的bitmap中，
一个一定不存在的数据会被这个bitmap拦截掉，从而避免了对底层存储系统的查询压力。在数据魔方里，我们采用了一个更为简单粗暴的方法，
如果一个查询返回的数据为空（不管是数据不存在，还是系统故障），我们仍然把这个空结果进行缓存，但它的过期时间会很短，最长不超过五分钟。
缓存失效时的雪崩效应对底层系统的冲击非常可怕。遗憾的是，这个问题目前并没有很完美的解决方案。大多数系统设计者考虑用加锁或者队列的方式保证缓存的单线程（进程）写，
从而避免失效时大量的并发请求落到底层存储系统上。在数据魔方中，我们设计的缓存过期机制理论上能够将各个客户端的数据失效时间均匀地分布在时间轴上，
一定程度上能够避免缓存同时失效带来的雪崩效应。

#-javaagent:/data/encrypt/GameLoader.jar
SERVER_ARG="-Xbootclasspath/a:$JAVA_HOME/lib/tools.jar:/data/hotswap/ProfilerSDK-0.0.1-SNAPSHOT-shaded.jar
-Dfile.encoding=UTF-8 -XX:+PerfDisableSharedMem
-XX:+PrintSafepointStatistics -XX:PrintSafepointStatisticsCount=1
-XX:+UnlockDiagnosticVMOptions -XX:-DisplayVMOutput -XX:+LogVMOutput -XX:LogFile=/dev/shm/vm_$SERVER_ID.log 
-javaagent:/data/encrypt/GameLoader.jar 
-Dgmweb.monitor.game=yhjy
-Dgmweb.monitor.plat=${platform}
-Dgmweb.monitor.serverid=$SERVER_ID
-Dgmweb.monitor.type=game
-server -Xms8192M -Xmx8192M -XX:NewRatio=2 
-Djava.awt.headless=true -Dgamedir=$GAME_PATH $ARGS 
-XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:+CMSScavengeBeforeRemark -XX:+ParallelRefProcEnabled 
-XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=75 -XX:+ExplicitGCInvokesConcurrent 
-XX:-UseBiasedLocking -XX:-UseCounterDecay -XX:AutoBoxCacheMax=1000000 
-XX:+PrintGCDetails -Xloggc:/dev/shm/gc_$SERVER_ID.log -XX:+PrintGCApplicationStoppedTime -XX:+PrintGCDateStamps 
-XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=10 -XX:GCLogFileSize=10m 
-XX:-OmitStackTraceInFastThrow -XX:ErrorFile=${LOG_DIR}hs_err_%p.log -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=${LOG_DIR}"

 -Djava.util.Arrays.useLegacyMergeSort=true/false
 System.setProperty("java.util.Arrays.useLegacyMergeSort","rue/false")

 对cms的回收默认值有疑问的，
 可以查看该方法https://github.com/dmlloyd/openjdk/blob/jdk9/jdk9/hotspot/src/share/vm/gc/cms/concurrentMarkSweepGeneration.cpp#L265
  大家都知道对于设置使用cms回收器的，有一个background式的GC。（不清楚的可以查看笨神的这篇文章http://lovestblog.cn/blog/2015/05/07/system-gc/）

相关参数
l  /proc/sys/vm/dirty_expire_centisecs
数据存在的时间超过了dirty_expire_centisecs（默认30s）时间
l  /proc/sys/vm/dirty_background_ratio  
脏页率超过dirty_background_ratio指标会启动pdflush开始Flush Dirty PageCache
l  /proc/sys/vm/dirty_ratio
脏页率超过dirty_ratio指标会阻塞所有的写操作来进行Flush

https://yq.aliyun.com/articles/62538 