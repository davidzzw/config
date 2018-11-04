### 源代码

```
classFileParser.cpp
arguments.cpp
management.cpp
frame.hpp/cpp
jni.cpp
init.cpp
```

### 高级特性

```
方法内联（method inlining）
逃逸分析（escape analysis）
标量替换（scalar replacement）
无用代码削除（dead-code elimination）
```

###jvm 对象

```
instanceOopDesc继承oopDesc
oopDesc -> 对象
instanceKlass -> 方法区或者metaspace
KlassKlass -> Class
```

### jvm参数

* -XX:+UseCompressedOops: `压缩对象指针 `
* -XX:+UseCompressedClassPointers: `压缩类指针 `

### MetaSpace

```
jmap -clstats :打印类加载器的统计信息(取代了在JDK8之前打印类加载器信息的permstat)。
jstat -gc :Metaspace的信息也会被打印出来。
jcmd GC.class_stats:这是一个新的诊断命令，可以使用户连接到存活的JVM，转储Java类元数据的详细统计。
```

### 反射的实现

* 通过本地方法来实现反射调用 
* 委派模式 

####采用委派模式的原因

`够在本地实现以及动态实现中切换`

####反射慢的原因

 `逃逸分析不再起效 ` 

`变长参数方法导致的 Object 数组`

`基本类型的自动装箱、拆箱`

`最重要的方法内联` 

#### jvm参数

`-Dsun.reflect.noInflation=true `:`关闭反射调用的 Inflation 机制，从而取消委派实现 `

`-XX:+PrintGC `

`-XX:TypeProfileWidth `:`Java 虚拟机关于每个调用能够记录的类型数目 `

### 逃逸分析

`即时编译器可以根据逃逸分析的结果进行诸如锁消除、栈上分配以及标量替换的优化 `

####即时编译器判断对象逃逸的依据有两个

* 一是看对象是否被存入堆中
* 二是看对象是否作为方法调用的调用者或者参数。 

#### 部分逃逸分析 

`部分逃逸分析是一种附带了控制流信息的逃逸分析。它将判断新建对象真正逃逸的分支，并且支持将新建操作推延至逃逸分支 `

`-XX:-DoEscapeAnalysis `:`关闭默认开启的逃逸分析 `

`-XX:+UnlockExperimentalVMOptions -XX:+UseJVMCICompiler`来启用 Graal

