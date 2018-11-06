#### 加载

#### 链接（验证、准备、解析） 

####初始化

```
gcCause.hpp
```

### jvm参数

* UseTLAB


####Java 栈帧

```
栈轨迹跟弹出方法栈帧 是两个概念
调用栈
```

###jvm优化

#### 堆转储分析

`jmap -dump:format=b,file=filename.hprof pid`

###栈

####栈帧

`支持虚拟机进行方法调用和方法执行的数据结构`

`存储了方法的局部变量表、操作数栈、动态连接、方法返回地址等信息`

####局部变量表

####操作数栈

###jvm如何调用java方法

#### 入口：JavaCalls

#### 实际例程：CallStub

#### Stub Rountines

#### 栈顶缓存（Tos）



### 方法调用

#### 直接调用

`这些指令与包含目标方法类名、方法名以及方法描述符的符号引用捆绑。在实际运行之前，Java 虚拟机将根据这个符号引用链接到具体的目标方法。`

#####invokestatic

#####invokespecial

#####invokevirtual

#####invokeinterface

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