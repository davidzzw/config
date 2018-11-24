#### 加载

#### 链接（验证、准备、解析） 

####初始化

```
gcCause.hpp
```

###栈

####栈帧

`栈轨迹跟弹出方法栈帧 是两个概念`
`调用栈`

`支持虚拟机进行方法调用和方法执行的数据结构`

`存储了方法的局部变量表、操作数栈、动态连接、方法返回地址等信息`

####局部变量表

####操作数栈

###jvm如何调用java方法

#### 入口：JavaCalls

#### 实际例程：CallStub

#### Stub Rountines

#### 栈顶缓存（Tos）

### 虚方法

`行为如同“final”的方法都无法覆写，也就无法进行子类型多态；声明为final或private的方法都被属于这类。所以除了静态方法之外，声明为final或者private的实例方法也是非虚方法。其它实例方法都是虚方法`

### 方法调用

#### 直接调用

`这些指令与包含目标方法类名、方法名以及方法描述符的符号引用捆绑。在实际运行之前，Java 虚拟机将根据这个符号引用链接到具体的目标方法。`

#####invokestatic

`用于调用类（静态）方法` 

#####invokespecial

`用于调用实例方法，特化于super方法调用、private方法调用与构造器调用 `

#####invokevirtual

`用于调用一般实例方法（包括声明为final但不为private的实例方法）`

#####invokeinterface

`用于调用接口方法 `

###间接调用

####invokedynamic

##### 方法句柄（MethodHandle）

```
方法句柄是一个强类型的，能够被直接执行的引用。该引用可以指向常规的静态方法或者实例方法，也可以指向构造器或者字段。当指向字段时，方法句柄实则指向包含字段访问字节码的虚构方法，语义上等价于目标字段的 getter 或者 setter 方法。
对于用 invokestatic 调用的静态方法，我们需要使用 Lookup.findStatic 方法；对于用 invokevirutal 调用的实例方法，以及用 invokeinterface 调用的接口方法，我们需要使用 findVirtual 方法；对于用 invokespecial 调用的实例方法，我们则需要使用 findSpecial 方法。
方法句柄的类型（MethodType）是由所指向方法的参数类型以及返回类型组成的。它是用来确认方法句柄是否适配的唯一关键。当使用方法句柄时，我们其实并不关心方法句柄所指向方法的类名或者方法名。
```

`-Djdk.internal.lambda.dumpProxyClasses=/DUMP/PATH`:`导出这些具体的适配器类`

`-Djava.lang.invoke.MethodHandle.CUSTOMIZE_THRESHOLD`:`方法句柄的执行次数超过一个阈值时进行优化`

`-Djava.lang.invoke.MethodHandle.DUMP_CLASS_FILES=true`:`这个适配器是一个 LambdaForm,我们可以通过添加虚拟机参数将之导出成 class 文件`

* 逃逸分析能够去除这些额外的新建实例开销，但是它也不是时时奏效

```
invokedynamic 指令所执行的方法句柄能够内联
接下来的对 accept 方法的调用也能内联
```

`ConstantCallsite`

### 进入HSDB

`java -cp .;"%JAVA_HOME%/lib/sa-jdi.jar" sun.jvm.hotspot.HSDB`

### 源码

```
Instrumentation
ClassFileTransformer
TransformerManager
classFileParser.cpp
arguments.cpp
management.cpp
frame.hpp/cpp
jni.cpp
init.cpp
```

### 高级特性

#### 方法内联（method inlining）

####逃逸分析（escape analysis）

#### 标量替换（scalar replacement）

#### 无用代码削除（dead-code elimination）

### jvm 对象

```
instanceOopDesc继承oopDesc
oopDesc -> 对象
instanceKlass -> 方法区或者metaspace
KlassKlass -> Class
```

### MetaSpace

```
jmap -clstats :打印类加载器的统计信息(取代了在JDK8之前打印类加载器信息的permstat)
jstat -gc :Metaspace的信息也会被打印出来
jcmd GC.class_stats:这是一个新的诊断命令，可以使用户连接到存活的JVM，转储Java类元数据的详细统计
```

### 反射的实现

- `通过本地方法来实现反射调用 `
- `委派模式 `

#### 采用委派模式的原因

`够在本地实现以及动态实现中切换`

#### 反射慢的原因

 `逃逸分析不再起效 ` 

`变长参数方法导致的 Object 数组`

`基本类型的自动装箱、拆箱`

`最重要的方法内联` 

#### jvm参数

`-Dsun.reflect.noInflation=true `:`关闭反射调用的 Inflation 机制，从而取消委派实现 `

`-XX:TypeProfileWidth `:`Java 虚拟机关于每个调用能够记录的类型数目 `

### 逃逸分析

`即时编译器可以根据逃逸分析的结果进行诸如锁消除、栈上分配以及标量替换的优化 `

#### 即时编译器判断对象逃逸的依据有两个

- `一是看对象是否被存入堆中`
- `二是看对象是否作为方法调用的调用者或者参数`

#### 部分逃逸分析

`部分逃逸分析是一种附带了控制流信息的逃逸分析。它将判断新建对象真正逃逸的分支，并且支持将新建操作推延至逃逸分支 `

`-XX:-DoEscapeAnalysis `:`关闭默认开启的逃逸分析 `

`-XX:+UnlockExperimentalVMOptions` ` -XX:+UseJVMCICompiler来启用 Graal`

```
解释执行
即时执行
静态绑定
```

### SA([Serviceability Agent](http://openjdk.java.net/groups/hotspot/docs/Serviceability.html) )

```
HotSpot有一套私有API提供了对JVM内部数据结构的审视功能，称为Serviceability Agent。它是一套Java API，虽然HotSpot是用C++写的，但SA提供了HotSpot中重要数据结构的Java镜像类，所以可以直接写Java代码来查看一个跑在HotSpot上的Java进程的内部状态。它也提供了一些封装好的工具，可以直接在命令行上跑，包括下面提到的ClassDump工具
```

