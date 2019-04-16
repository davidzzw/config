### 应用运行时间

`ps -p pid  -o  etime`

###jstat排查问题

* `jstat -gcutil pid`
* `jstat -gc 4210 2s 3`
* `java -XX:+PrintFlagsFinal -version |grep JVMParamName`:` 获取JVM参数的默认值`
* `jstat -gccause`
* `jstat -gccapacity `

### 定位并分析耗cpu最多的线程

* `jps`：`列出相关的java进程, 以及对应的pid也可以使用如下命令来尝试 ps aux | grep java --color   `
* `top -Hp <pid>`:`按ctrl+t, 按时间消耗来进行排序`
* `ps -eLf | awk '$2 ~/<pid>/ {print "pid:", $2, " lwp:", $4, " pcpu:", $5}' | sort -k6nr    `
* `ps -eLf | head -n 1         `
* `top -Hp 9179 -d 1 -n 1 `
* `ps -Lfp pid `
* `ps -mp pid -o THREAD，tid，time `

### OOM

#### CodeCache

#### 堆外内存

####64m

###jmap排查问题

* `jmap -dump:format=b,file=filename.hprof pid`:`这个命令执行，JVM会将整个heap的信息dump写入到一个文件，heap如果比较大的话，就会导致这个过程比较耗时，并且执行的过程中为了保证dump的信息是可靠的，所以会暂停应用`
* `jmap -permstat`:`这个命令执行，JVM会去统计perm区的状况，这整个过程也会比较的耗时，并且同样也会暂停应用`
* `jmap -histo:live pid`:`这个命令执行，JVM会先触发gc，然后再统计信息`
* `jmap -histo pid | head -n20`:`对象分布`
* `jmap -histo pid > pid.log; head -n20 pid.log`
* `jmap -histo pid > pid.log; head -n20 pid.log`
* `jmap -clstats pid  `

```
上面的这三个操作都将对应用的执行产生影响，所以建议如果不是很有必要的话，不要去执行。
另外，在排查问题的时候，对于保留现场信息的操作，可以用gcore [pid]直接保留，这个的执行速度会比jmap -dump快不少，之后可以再用jmap/jstack等从core dump文件里提取相应的信息，不过这个操作建议大家先测试下，貌似在有些jdk版本上不work。
之前碰到过一次语言集的问题，我们的Java应用多数在做字符串转码的时候是没有指定编码的，编码信息主要靠启动脚本里面设置LANG来控制，但没想到在某种场景下，竟然有地方设置了LC_ALL，在之前的一篇语言集的文章中，有讲过LC_ALL的优先级是最高的，所以导致启动脚本里设置的LANG失效了，从而导致了乱码，这个Case来看，对于Java应用，还是在启动参数上指定下-Dfile.encoding比较安全一点，避免这种默认的转码依赖系统的配置，很容易踩进坑里
```

### jstat metaspace jdk 1.8

`MC & MU & CCSC & CCSU`

* `MC表示Klass Metaspace以及NoKlass Metaspace两者总共committed的内存大小，单位是KB，虽然从上面的定义里我们看到了是capacity，但是实质上计算的时候并不是capacity而是committed，这个是要注意的MU这个无可厚非，说的就是Klass Metaspace以及NoKlass Metaspace两者已经使用了的内存大小`
* `CCSC表示的是Klass Metaspace的已经被commit的内存大小，单位也是KB`
* `CCSU表示Klass Metaspace的已经被使用的内存大小`

`M & CCS`

* `M表示的是Klass Metaspace以及NoKlass Metaspace两者总共的使用率，其实可以根据上面的四个指标算出来，即(CCSU+MU)/(CCSC+MC)`
* `CCS表示的是NoKlass Metaspace的使用率，也就是CCSU/CCSC算出来的`

`PS：所以我们有时候看到M的值达到了90%以上，其实这个并不一定说明metaspace用了很多了，因为内存是慢慢commit的，所以我们的分母是慢慢变大的，不过当我们committed到一定量的时候就不会再增长了`

`MCMN & MCMX & CCSMN & CCSMX`

* `MCMN和CCSMN这两个值大家可以忽略，一直都是0`
* `MCMX表示Klass Metaspace以及NoKlass Metaspace两者总共的reserved的内存大小，比如默认情况下Klass Metaspace是通过CompressedClassSpaceSize这个参数来reserved 1G的内存`
* `NoKlass Metaspace默认reserved的内存大小是2* InitialBootClassLoaderMetaspaceSize`
* `CCSMX表示Klass Metaspace reserved的内存大小`

`MC & MU & CCSC & CCSU`

* `MC表示Klass Metaspace以及NoKlass Metaspace两者总共committed的内存大小，单位是KB，虽然从上面的定义里我们看到了是capacity，但是实质上计算的时候并不是capacity，而是committed，这个是要注意的MU这个无可厚非，说的就是Klass Metaspace以及NoKlass Metaspace两者已经使用了的内存大小`
* `CCSC表示的是Klass Metaspace的已经被commit的内存大小，单位也是KB`
* `CCSU表示Klass Metaspace的已经被使用的内存大小`

`M & CCS`

* `M表示的是Klass Metaspace以及NoKlass Metaspace两者总共的使用率，其实可以根据上面的四个指标算出来，即(CCSU+MU)/(CCSC+MC)`
* `CCS表示的是NoKlass Metaspace的使用率，也就是CCSU/CCSC算出来的`

`PS：所以我们有时候看到M的值达到了90%以上，其实这个并不一定说明metaspace用了很多了，因为内存是慢慢commit的，所以我们的分母是慢慢变大的，不过当我们committed到一定量的时候就不会再增长了`

`MCMN & MCMX & CCSMN & CCSMX`

* `MCMN和CCSMN这两个值大家可以忽略，一直都是0`
* `MCMX表示Klass Metaspace以及NoKlass Metaspace两者总共的reserved的内存大小，比如默认情况下Klass Metaspace是通过CompressedClassSpaceSize这个参数来reserved 1G的内存，NoKlass Metaspace默reserved的内存大小是2* InitialBootClassLoaderMetaspaceSizeCCSMX表示Klass Metaspace reserved的内存大小`

### jcmd

* `jcmd pid GC.class_stats | awk '{print $13}' | sort | uniq -c | sort -nrk1 > topclass.txt `

*查看Code Cache大小*

* `jinfo -flag ReservedCodeCacheSize pid`

###hprof（Heap/CPU Profiling Tool）

`hprof能够展现CPU使用率，统计堆内存使用情况`

* `java -agentlib:hprof[=options] ToBeProfiledClass`
* `java -Xrunprof[:options] ToBeProfiledClass`
* `javac -J-agentlib:hprof[=options] ToBeProfiledClass`

