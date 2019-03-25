#### 加载

#### 链接（验证、准备、解析） 

####初始化

`gcCause.hpp`

#### 符号引用

```
顺着这条线索把能传递引用到的常量池项都找出来，会看到（按深度优先顺序排列）：   #2 = Methodref          #3.#17         //  X.bar:()V
   #3 = Class              #18            //  X
  #18 = Utf8               X
  #17 = NameAndType        #13:#6         //  bar:()V
  #13 = Utf8               bar
   #6 = Utf8               ()V
把引用关系画成一棵树的话：     #2 Methodref X.bar:()V
     /                     \
#3 Class X       #17 NameAndType bar:()V
    |                /             \
#18 Utf8 X    #13 Utf8 bar     #6 Utf8 ()V
标记为Utf8的常量池项在Class文件中实际为CONSTANT_Utf8_info，是以略微修改过的UTF-8编码的字符串文本。这样就清楚了对不对？由此可以看出，Class文件中的invokevirtual指令的操作数经过几层间接之后，最后都是由字符串来表示的。这就是Class文件里的“符号引用”的实态：带有类型（tag） / 结构（符号间引用层次）的字符串。
```

#### 直接引用

```
Sun Classic VM:（以32位Sun JDK 1.0.2在x86上为例）         HObject             ClassObject
                       -4 [ hdr            ]
--> +0 [ obj     ] --> +0 [ ... fields ... ]
    +4 [ methods ] \
                    \         methodtable            ClassClass
                     > +0  [ classdescriptor ] --> +0 [ ... ]
                       +4  [ vtable[0]       ]      methodblock
                       +8  [ vtable[1]       ] --> +0 [ ... ]
                       ... [ vtable...       ]（请留心阅读上面链接里关于虚方法表与JVM的部分。Sun的元祖JVM也是用虚方法表的喔。）元祖JVM在做类加载的时候会把Class文件的各个部分分别解析（parse）为JVM的内部数据结构。例如说类的元数据记录在ClassClass结构体里，每个方法的元数据记录在各自的methodblock结构体里，等等。在刚加载好一个类的时候，Class文件里的常量池和每个方法的字节码（Code属性）会被基本原样的拷贝到内存里先放着，也就是说仍然处于使用“符号引用”的状态；直到真的要被使用到的时候才会被解析（resolve）为直接引用。假定我们要第一次执行到foo()方法里调用bar()方法的那条invokevirtual指令了。此时JVM会发现该指令尚未被解析（resolve），所以会先去解析一下。通过其操作数所记录的常量池下标0x0002，找到常量池项#2，发现该常量池项也尚未被解析（resolve），于是进一步去解析一下。通过Methodref所记录的class_index找到类名，进一步找到被调用方法的类的ClassClass结构体；然后通过name_and_type_index找到方法名和方法描述符，到ClassClass结构体上记录的方法列表里找到匹配的那个methodblock；最终把找到的methodblock的指针写回到常量池项#2里。也就是说，原本常量池项#2在类加载后的运行时常量池里的内容跟Class文件里的一致，是：[00 03] [00 11]（tag被放到了别的地方；小细节：刚加载进来的时候数据仍然是按高位在前字节序存储的）而在解析后，假设找到的methodblock*是0x45762300，那么常量池项#2的内容会变为：[00 23 76 45]（解析后字节序使用x86原生使用的低位在前字节序（little-endian），为了后续使用方便）这样，以后再查询到常量池项#2时，里面就不再是一个符号引用，而是一个能直接找到Java方法元数据的methodblock*了。这里的methodblock*就是一个“直接引用”。解析好常量池项#2之后回到invokevirtual指令的解析。回顾一下，在解析前那条指令的内容是：[B6] [00 02]
而在解析后，这块代码被改写为：[D6] [06] [01]其中opcode部分从invokevirtual改写为invokevirtual_quick，以表示该指令已经解析完毕。原本存储操作数的2字节空间现在分别存了2个1字节信息，第一个是虚方法表的下标（vtable index），第二个是方法的参数个数。这两项信息都由前面解析常量池项#2得到的methodblock*读取而来。也就是：invokevirtual_quick vtable_index=6, args_size=1这里例子里，类X对应在JVM里的虚方法表会是这个样子的：[0]: java.lang.Object.hashCode:()I
[1]: java.lang.Object.equals:(Ljava/lang/Object;)Z
[2]: java.lang.Object.clone:()Ljava/lang/Object;
[3]: java.lang.Object.toString:()Ljava/lang/String;
[4]: java.lang.Object.finalize:()V
[5]: X.foo:()V
[6]: X.bar:()V所以JVM在执行invokevirtual_quick要调用X.bar()时，只要顺着对象引用查找到虚方法表，然后从中取出第6项的methodblock*，就可以找到实际应该调用的目标然后调用过去了。假如类X还有子类Y，并且Y覆写了bar()方法，那么类Y的虚方法表就会像这样：[0]: java.lang.Object.hashCode:()I
[1]: java.lang.Object.equals:(Ljava/lang/Object;)Z
[2]: java.lang.Object.clone:()Ljava/lang/Object;
[3]: java.lang.Object.toString:()Ljava/lang/String;
[4]: java.lang.Object.finalize:()V
[5]: X.foo:()V
[6]: Y.bar:()V
于是通过vtable_index=6就可以找到类Y所实现的bar()方法。所以说在解析/改写后的invokevirtual_quick指令里，虚方法表下标（vtable index）也是一个“直接引用”的表现。关于这种“_quick”指令的设计，可以参考远古的JVM规范第1版的第9章。这里有一份拷贝：http://www.cs.miami.edu/~burt/reference/java/language_vm_specification.pdf在现在的HotSpot VM里，围绕常量池、invokevirtual的解析（再次强调是resolve）的具体实现方式跟元祖JVM不一样，但是大体的思路还是相通的。HotSpot VM的运行时常量池有ConstantPool和ConstantPoolCache两部分，有些类型的常量池项会直接在ConstantPool里解析，另一些会把解析的结果放到ConstantPoolCache里。
```

`符号引用通常是设计字符串的——用文本形式来表示引用关系。而直接引用是JVM（或其它运行时环境）所能直接使用的形式。它既可以表现为直接指针（如上面常量池项#2解析为methodblock*），也可能是其它形式（例如invokevirtual_quick指令里的vtable index）。关键点不在于形式是否为“直接指针”，而是在于JVM是否能“直接使用”这种形式的数据。`

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

####方法内联（method inlining）

####逃逸分析（escape analysis）

####标量替换（scalar replacement）

####无用代码削除（dead-code elimination）

####解释执行

####即时执行

####静态绑定

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

### SA([Serviceability Agent](http://openjdk.java.net/groups/hotspot/docs/Serviceability.html) )

```
HotSpot有一套私有API提供了对JVM内部数据结构的审视功能，称为Serviceability Agent。它是一套Java API，虽然HotSpot是用C++写的，但SA提供了HotSpot中重要数据结构的Java镜像类，所以可以直接写Java代码来查看一个跑在HotSpot上的Java进程的内部状态。它也提供了一些封装好的工具，可以直接在命令行上跑，包括下面提到的ClassDump工具
```
### JVMTI(JVM Tool Interface)

* `JVMPI(Java Virtual Machine Profiler Interface)`
* `JVMDI(Java Virtual Machine Debug Interface)`
* `-agentlib:agent-lib-name=options`
* `-agentpath:path-to-agent=options`

###Agent

`Agent 是在 Java 虚拟机启动之时加载的，这个加载处于虚拟机初始化的早期，在这个时间点上：`

* `所有的 Java 类都未被初始化`
* `所有的对象实例都未被创建`
* `因而，没有任何 Java 代码被执行`

`但在这个时候，我们已经可以：`

* `但在这个时候，我们已经可以`
* ` 操作 JVMTI 的 Capability 参数`
* `使用系统参数`

### Instrumentation 

`类定义动态改变和操作`

* `public static void premain(String agentArgs， Instrumentation inst) `
* `public static void agentmain (String agentArgs, Instrumentation inst)`

### Attach API 

* `VirtualMachine`
* `Attach 动作和 Detach 动作（Attach 动作的相反行为，从 JVM 上面解除一个代理）`
* `VirtualMachineDescriptor 则是一个描述虚拟机的容器类`

### JPDA

### 优化

#### 循环优化

##### 循环无关代码（Loop-invariant Code）

`循环无关代码外提将循环中值不变的表达式，或者循环无关检测外提至循环之前`

* `循环无关代码外提`


* `循环预测（Loop Prediction，对应虚拟机参数-XX:+UseLoopPredicate)`

#### 循环展开(Loop Unrolling)

`在循环体中重复多次循环迭代，并减少循环次数的编译优化`

`在 C2 中，只有计数循环（Counted Loop）才能被展开。所谓的计数循环需要满足如下四个条件`

* `维护一个循环计数器，并且基于计数器的循环出口只有一个（但可以有基于其他判断条件的出口）`
* `循环计数器的类型为 int、short 或者 char（即不能是 byte、long，更不能是 float 或者 double）`
* `每个迭代循环计数器的增量为常数`
* `循环计数器的上限（增量为正数）或下限（增量为负数）是循环无关的数值`

##### 完全展开（Full Unroll）

##### 循环判断外提（loop unswitching）

`将循环中的 if 语句外提至循环之前，并且在该 if 语句的两个分支中分别放置一份循环代码`

#####循环剥离（loop peeling）

`将循环的前几个迭代或者后几个迭代剥离出循环的优化方式`

#### 向量化
