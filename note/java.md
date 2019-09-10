### 类的设计原则

```
依赖倒置原则－Dependency Inversion Principle (DIP) 
里氏替换原则－Liskov Substitution Principle (LSP) 
接口分隔原则－Interface Segregation Principle (ISP) 
单一职责原则－Single Responsibility Principle (SRP) 
开闭原则－The Open-Closed Principle (OCP)
```

 ```
Java语言中，虚方法可以通过覆写（override）的方式来实现子类型多态（subtype polymorphism）。Java语言支持三种多态，除了子类型多态外还有通过方法重载支持的ad-hoc多态（ad-hoc polymorphism）与通过泛型支持的参数化多态（parametric polymorphism）。在面向对象编程的语境里“多态”一般指子类型多态，下面提到“多态”一词也特定指子类型多态。 
Java语言中非虚方法可以通过“静态绑定”（static binding）或者叫“早绑定”（early binding）来选择实际的调用目标——因为无法覆写，无法产生多态的效果，于是可能的调用目标总是固定的一个。虚方法则一般需要等到运行时根据“接收者”的具体类型来选择到底要调用哪个版本的方法，这个过程称为“运行时绑定”（runtime binding）或者叫“迟绑定”（late-binding）。 
不过Java的虚方法的迟绑定具体如何去选择目标是写死在语言规范与JVM的实现中的，用户无法干涉选择的过程。这使得Java提供的迟绑定缺乏自由度。在Java 7开始提供invokedynamic支持后，用户可以自行编写程序来控制迟绑定的过程，开始对选择调用目标拥有完整的控制权。 
 ```

### 类加载

#### 一、加载

类的加载指的是将类的.class文件中二进制数据读入到内存中，将其放在运行时数据区的方法区内，然后在堆区创建一个java.lang.Class对象，用来封装类在方法区内的数据结构。在这个阶段，会执行类中声明的静态代码块。也就是类中的静态块执行时不需要等到类的初始化。

##### 加载.class文件的方式

- 1、从本地系统中直接加载
- 2、通过网络下载.class文件
- 3、从zip,jar等归档文件中加载.class文件
- 4、从专有数据库中提取.class文件
- 5、将Java源文件动态编译为.class文件

> 类加载的最终产品是位于堆区中的class对象，Class对象封装了类在方法区内的数据结构，并向Java程序员提供了访问方法区内的数据机构的接口. 我们可以通过类名.class来获取一个类的类型的引用，通过new 类名().getClass()来获取一个实例变量的类的引用

#### 类的加载机制

从JDK1.2开始类加载采用父亲委托机制。除了Java虚拟机自带的根类加载器以外，其余的类加载器都有且只有一个父加载器。当Java程序骑牛加载器加载某个类时，加载器会首先委托自己的父加载器去加载该类，若父加载器能加载，则由父加载器完成加载任务，否则才由自加载器去加载。 ![img](https://mmbiz.qpic.cn/mmbiz_png/kIaMYfhnA7n4eujoDmdIIOcaMcML47icNibibianicGdRfp6GyUtnJj0kcTia2fyMI7noWPlPbicYWObF8HCS0Cb2a8Bw/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

同时，所有能成功返回Class对象的引用的类加载器(包括定义类加载器，即包括定义类加载器和它下面的所有子加载器)都被称为初始类加载器。

假设loader1实际加载了Sample类，则loader1为Sample类的定义类加载器

> 加载阶段，虚拟机需要完成3件事：
>
> 1. 通过一个类的全限定名获取定义此类的二进制字节流。
> 2. 将这个字节流所代表的静态存储结构转换为方法区的运行时数据结构。
> 3. 在内存中生成一个代表这个类的java.lang.Class对象，作为方法区这个类的各种数据结构的访问入口。
>
> 上面说获取二进制字节流，而没有明确的说明是class文件中的字节流，因为还有其它获取字节流的方式，例如从jar包中获取、从网络中获取、动态代理运行时生成等。
>
> 加载阶段与连接阶段的部分内容是交叉进行的，如：一部分字节码文件格式验证动作。加载阶段尚未完成，连接阶段可能已经开始了

#### 二、连接

类加载完成后就进入了类的连接阶段，连接阶段主要分为三个过程分别是：验证，准备和解析。在连接阶段，主要是将已经读到内存的类的二进制数据合并到虚拟机的运行时环境中去。

验证是连接阶段的第一步，这一阶段的目的是为了确保Class文件的字节流中包含的信息符合虚拟机的要求，并且不会危害虚拟机自身的安全。验证阶段大致会完成以下4个阶段的校验动作：文件格式验证、元数据验证、字节码验证和符号引用验证。

##### 验证

这个阶段主要目的是保证Class流的格式是正确的。主要验证的内容包括：

###### 1.文件格式验证

这一阶段目的是验证二进制字节流是否符合Class文件格式的规范，并且能被当前版本的虚拟机处理，检测内容包括以下几点：

- 是否以魔数（0xCAFEBABY）开头。
- 主次版本号是否在当前虚拟机处理范围之内。
- 常量池中的常量是否有不支持的常量类型。
- 指向常量的各种索引值中是否有指向不存在的常量或不符合类型的常量。
- CONSTANT_Utf8_info 型常量是否有不符合UTF8数据编码的数据。
- Class文件中各个部分及文件本身是否有被删除的或附加的信息。

这个阶段是基于二进制字节流进行的，只有通过了这个阶段的验证，字节流才会流入方法区中进行存储，后面3个阶段全是基于方法区的存储结构进行的，不会再直接操作字节流。

######  2.元数据验证

这一阶段主要对字节码的描述信息进行语义分析，以保证其描述信息符合java语言规范，这阶段的验证点可能包括以下几点：

- 这个类是否有父类
- 这个类的父类是否继承了不被允许继承的类(被final 修饰)
- 如果这个类不是抽象类，是否实现了父类或接口中的方法
- 类中的字段、方法是否与父类产生矛盾（覆盖父类的final字段值等）

######  3.字节码验证

这一阶段目的主要目的是确定程序语义是合法的、符合逻辑的。这个阶段主要对类的字节码进行校验分析，保证该类的方法不会在运行时做出危害虚拟机安全的事：

- 保证任意时刻操作数栈的数据类型与指令代码序列都能配合工作，例如不会出险操作数栈上 int 类型的数据使用时按long类型加载进本地变量表中。
- 保证跳转指令不会跳转到方法体以外的字节码指令上。
- 保证方法体内的类型转化是有效的，可以把一个子类对象赋值给父类数据结构，这是安全的，而不能把父类赋值给子类甚至与它无关系的数据类型，这是危险和不合法的。

######  4.符号引用验证

这一阶段用来将符号引用转换为直接引用的时候，这个转化将在解析阶段中发生，符号引用验证可以看做是类对自身以外（常量池中各种符号引用）的信息进行匹配性校验，通常需要校验以下内容：

- 符号引用中能否根据字符串的权限定名找到对应的类。
- 在指定类中是否存在符合方法的字段描述符以及简单名称描述的方法和字段。
- 符号引用中的类、字段、方法的访问性是否可以被当前类访问。

##### 准备

```
这个阶段主要是为对象和变量分配内存，并为类设置初始值（方法区中） 对于static类型变量在这个阶段会为其赋值为默认值，比如public static int v=5,在这个阶段会为其赋值为v=0，而对于static final类型的变量，在准备阶段就会被赋值为正确的值
```

##### 解析

在这个阶段会将符号引用转换成直接引用。 原来的符号引用仅仅是一个字符串，而引用的对象不一定被加载，直接引用只的是将引用对象的指针或者地址偏移量指向真正的对象，将字符串所指向的对象加载到内存中。

解析阶段是将虚拟机常量池内的符号引用替换为直接引用的过程。解析动作主要针对类或接口、字段、类方法、接口方法、方法类型、方法句柄和调用点限定符7类符号进行。

可能大家有疑问Class文件中哪有这么多内容，其实上面也说了，是针对常量池。不管是CLass文件中的方法表还是字段表，不能直接表示的内容，基本都会直接或间接存在常量池中，因此解析过程就是针对常量池中的数据类型进行解析的。

###### 1.类或接口的解析

要把一个从未解析过的符号引用N解析为一个类或接口的直接引用，虚拟机需要完成以下3个步骤：

1. 如果C不是一个数组类型，那么虚拟机会把代表N的权限定名传递给D的类加载器去加载这个类C。在加载的过程当中，由于元数据、字节码验证的操作，又可能触发其它类的加载动作，一旦出险任何异常，则解析宣告失败。
2. 如果C是一个数组类型，并且数组元素为对象，描述符类似“[Ljava/lang/Integer”的形式按照第一点的规则加载数组元素类型。如果N的描述符如前面所假设的形式，需要加载的类型就是java.lang.Integer，接着由虚拟机生成一个代表次数组维度和元素的数组对象。
3. 如果上面的步骤没有任何异常，那么C在虚拟机中实际上已经称为一个有效的类或接口了。解析之前还要进行符号验证，确认D是否具有对C的访问权限，如果不具备则会抛出异常。

###### 2.字段解析

对字段表内class_index项中索引的CONSTANT_Class_info符号引用进行解析，也就是字段所属的类或接口的符号引用，如果解析这个类或符号引用的过程中出现任何异常，都会导致字段符号引用解析的失败。

如果解析成功，这个字段对应的类或接口用C表示，接下来沿着A和它的父类/父接口寻找是否有这个字段，如果有会进行权限验证，如果不具备权限则抛出异常。如果这个过程不出错，则会在找到符合字段的时候返回这个字段的直接饮用，查找结束。

###### 3.类(静态)方法解析

类方法解析首先也要首先解析出类方法表class_index项中索引的方法所属的类或接口的符号引用，解析成功用C表示。

1. 类方法和接口方法符号引用的常量类型定义是分开的，如果在类方法表中索引类是个接口，直接抛出异常。
2. 如果通过了第一步，在类C中查找是否有简单名称和描述符都与目标匹配的方法，有则返回这个方法的直接引用，查找结束。
3. 否则在类的父类递归查找是否有这个方法，有则返回直接引用，查找结束。
4. 否则在类的接口列表和父接口递归查找，如果存在匹配的方法，说明类C是一个抽象类，查找结束，抛出异常。
5. 否则宣告查找失败，抛出异常。

最后如果查找成功返回了直接引用，还要对这个方法进行权限验证，如果不具备权限，则会抛出异常。

###### 接口方法解析

接口方法需要先解析出接口方法表的class_index 项中索引的方法所属的类或接口的符号引用。

1. 如果发现class_index 中的索引C是个类而不是接口，直接抛出异常。
2. 否则在接口C中查找是否有描述符和名称都匹配的方法，有则返回方法的直接引用，查找结束。
3. 否则在其父接口中递归查找，匹配就返回方法的直接引用，查找结束。
4. 否则宣告方法查找失败。

#### 三、初始化

在这个阶段主要执行类的构造方法。并且为静态变量赋值为初始值，执行静态块代码。

##### 类的初始化步骤

- 假如这个类还没有被加载和连接，那就先进行加载和连接
- 假如类存在直接的父类，并且这个父类还没有被初始化，那就先初始化它的父类
- 假如类中存在初始化语句时，那就依次执行这些初始化语句。

##### 类的初始化时机

所有的Java类只有在对类的首次主动使用时才会被初始化。 主动使用的情况有六中，其他情况都属于被动使用：

- 1、 创建类的实例
- 2、访问某个类或接口的静态变量，或者对该静态变量赋值
- 3、调用类的静态方法
- 4、反射（Class.fotName）
- 5、初始化一个类的子类
- 6、Java虚拟机启动时被标明为启动类的类（面方法所在的类）

> 1. 遇到new、getstaic、putstatic或invokestatic这4条字节码指令时，如果类没有进行过初始化，则会触发初始化。
> 2. 使用java.lang.reflect包的方法对类进行反射调用的时候，如果类没有进行过初始化，则会先触发其初始化。
> 3. 当初始化一个类的时候，如果发现其父类还没进行过初始化，则需要触发其父类初始化。
> 4. 当虚拟机启动时，用户需要指定一个要执行的主类，虚拟机会先初始化这个主类。
> 5. 当使用jdk1.7动态语言支持时，如果一个java.lang.invoke.MethodHandle实例最后的解析结果 REF_getStatic、REF_putStatic、REF_invokeStatic的方法句柄，并且这个方法句柄所对应的类没有进行过初始化，则会先触发其初始化。

###### 注意：

- 1、当Java虚拟机初始化一个类时，要求他的所有父类都已经被初始化，但是这条规则并不适合接口。在初始化一个类或接口时，并不会先初始化它所实现的接口。
- 2、只有当程序访问的静态变量或静态方法确实在当前类或当前接口中定义时，才可以认为是对类或接口的主动使用。如果静态方法或变量在parent中定义，从子类进行调用，则不会初始化子类。

#### 破坏双亲委派模型：为了实现 回调/热替换--OSGi：

*java.\*开头委派给父类加载器；*

*否则将委派列表名单内的类委派给父类加载器；*

*否则，Import列表中的类委派给Export这个类的Bundle类加载器加载；*

*否则，查找当前Bundle的ClassPath，用自己的类加载器加载；*

*否则，查找类是否在自己的Fragment Bundle中，是则委派给Fragment Bundle的类加载器加载；*

*否则查找Dynamic Import列表中的Bundle委派对应Bundle加载；*

*否则失败。*

*OSGi：Java的模块化框架

*Bundle：类比于Java的类/包

*Fragment：片段，对Bundle的扩展

*Dynamic Import：类比与java中的import xxx.xxx.xxx.*，目标包下的所有子包，但不包括子类

### 反射

* `Class.forName()和ClassLoader.loadClass`

```
Class.forName(className)方法，内部实际调用的方法是  Class.forName(className,true,classloader);
第2个boolean参数表示类是否需要初始化，  Class.forName(className)默认是需要初始化。
一旦初始化，就会触发目标对象的 static块代码执行，static参数也也会被再次初始化。
ClassLoader.loadClass(className)方法，内部实际调用的方法是  ClassLoader.loadClass(className,false);
第2个 boolean参数，表示目标对象是否进行链接，false表示不进行链接，由上面介绍可以，
不进行链接意味着不进行包括初始化等一些列步骤，那么静态块和静态对象就不会得到执行
```

在 Java 中除了最为基础的东西之外，你只要看三样东西就可以了：
Java 中有三大支柱，在 java.util.concurrent、java.security、javax.cropty、javax.security 四个包中就占了两个（多线程、安全）
还有一个网络在 java.net、javax.net 中，呵呵
掌握了上面 6 个包及其子包中内容的话，那 Java 水平可以说达到了另一种境界。
PS：三大支柱是我之前给 Java 中多线程、网络和安全取的代号，嘿嘿
这三样中的东西非常多，基本上就是 Java 的核心所在。
多线程（multi-threading and concurrent）
1：关键词：volatile, sychronized
2：传统的线程 API：java.lang.Thread, java.lang.Runnable, java.lang.ThreadGroup, Object#wait, Object#notify, Object#notifyAll
3：JDK 5 并发包（java.util.concurrent）API：线程池、任务执行器、计数信号量、倒计数门闩、并发集合（并发 Map、阻塞队列等）、
基于 CPU CAS 指令的原子 API（java.util.concurrent.atomic）、锁 API（java.util.concurrent.lock）和条件对象等。
4：作为个人知识提升，还需要理解诸如自旋锁、分离锁、分拆锁、读写锁等的同步锁策略，以及可重入锁、锁的公平性的意义。以及各种并发锁的算法，
比如：Peterson锁、Bakery锁 等等，以及现代 CPU 体系结构
涉及多线程及并发的 API 在 java.lang 中及 java.util.concurrent.* 中。
网络（network communication）
1：阻塞 TCP 通信、阻塞 UDP 通信、组播
2：非阻塞 TCP 通信、非阻塞 UDP 通信
3：客户端通信 API（java.net.URL, java.net.URLConnection 等类库）
涉及网络通信的 API 都在 java.net 和 java.nio.channels 包中。这里的网络已经将 RMI 相关包 java.rmi, javax.rmi 都排除了。
安全（security, cryptography and AAA）
1：Java 加密类库 JCA
2：Java 加密类库扩展 JCE
3：涉及密码学知识点的消息摘要、消息认证码、对称加密、非对称加密、数字签名
4：涉及网络通信证书管理工具（keytool）及 API（PKI、X.509证书）
5：基于 SSL/TLS 的安全网络通信 API（JSSE），包括：密钥库管理、信任库管理、阻塞 SSL 通信和非阻塞 SSL 通信等等
6：Java 认证及授权服务（JAAS）API

涉及安全的东西都在：

java.security（JCA、JCE、数字证书，以及 JCE 的 SPI）
javax.net（SSL/TLS）
javax.security（JAAS）
javax.crypto（密码学）
keytool 的 JDK 工具 

-Dcom.sun.management.jmxremote=
-Dcom.sun.management.jmxremote.port=1009
-Dcom.sun.management.jmxremote.ssl=false
-Dcom.sun.management.jmxremote.authenticate=false
-Djava.rmi.server.hostname=127.0.0.1

  Wait()方法和notify()方法：当一个线程执行到wait()方法时(线程休眠且释放机锁)，它就进入到一个和该对象相关的等待池中，
同时失去了对象的机锁。当它被一个notify()方法唤醒时，等待池中的线程就被放到了锁池中。该线程从锁池中获得机锁，然后回到wait()前的中断现场。

共同点： 他们都是在多线程的环境下，都可以在程序的调用处阻塞指定的毫秒数，并返回。
不同点： Thread.sleep(long)可以不在synchronized的块下调用，而且使用Thread.sleep()不会丢失当前线程对任何对象的同步锁(monitor);
object.wait(long)必须在synchronized的块下来使用，调用了之后失去对object的monitor, 这样做的好处是它不影响其它的线程对object进行操作。

登录注册要做好，http 协议和 https 你得非常熟悉，特别是各种涉及 Web 安全的响应头，cookie 的各种属性，302 重定向的作用等等。
还需要熟悉客户端的东西，比如设备指纹是怎么生成的。后端的东西就更多了，
会话服务器集群、会话拦截器给各 Web 应用使用的 jar 封装，处理各种千奇百怪产品登录注册需求的授权认证 api 和服务的系统架构。

### JAVA里的阻塞队列

JDK 7 提供了7个阻塞队列，如下

1、**ArrayBlockingQueue** 数组结构组成的有界阻塞队列。

此队列按照先进先出（FIFO）的原则对元素进行排序，但是默认情况下不保证线程公平的访问队列，即如果队列满了，那么被阻塞在外面的线程对队列访问的顺序是不能保证线程公平（即先阻塞，先插入）的。

2、**LinkedBlockingQueue**一个由链表结构组成的有界阻塞队列

此队列按照先出先进的原则对元素进行排序

3、**PriorityBlockingQueue**支持优先级的无界阻塞队列

4、**DelayQueue**支持延时获取元素的无界阻塞队列，即可以指定多久才能从队列中获取当前元素

5、**SynchronousQueue**不存储元素的阻塞队列，每一个put必须等待一个take操作，否则不能继续添加元素。并且他支持公平访问队列。

6、**LinkedTransferQueue**由链表结构组成的无界阻塞TransferQueue队列。相对于其他阻塞队列，多了tryTransfer和transfer方法

**transfer方法**

如果当前有消费者正在等待接收元素（take或者待时间限制的poll方法），transfer可以把生产者传入的元素立刻传给消费者。如果没有消费者等待接收元素，则将元素放在队列的tail节点，并等到该元素被消费者消费了才返回。

**tryTransfer方法**

用来试探生产者传入的元素能否直接传给消费者。，如果没有消费者在等待，则返回false。和上述方法的区别是该方法无论消费者是否接收，方法立即返回。而transfer方法是必须等到消费者消费了才返回。

7、**LinkedBlockingDeque**链表结构的双向阻塞队列，优势在于多线程入队时，减少一半的竞争。

| 方法\处理方式 | 抛出异常      | 返回特殊值    | 一直阻塞   | 超时退出               |
| ------- | --------- | -------- | ------ | ------------------ |
| 插入方法    | add(e)    | offer(e) | put(e) | offer(e,time,unit) |
| 移除方法    | remove()  | poll()   | take() | poll(time,unit)    |
| 检查方法    | element() | peek()   | 不可用    | 不可用                |

### 涉及模式

#### 创建型模式

- [工厂方法模式](https://github.com/echoTheLiar/JavaCodeAcc/blob/master/src/designpattern/factory/method/FactoryClient.java)
- [抽象工厂模式](https://github.com/echoTheLiar/JavaCodeAcc/blob/master/src/designpattern/factory/abstraction/Client.java)
- [原型模式](https://github.com/echoTheLiar/JavaCodeAcc/blob/master/src/designpattern/prototype/PrototypeClient.java)
- [建造者模式](https://github.com/echoTheLiar/JavaCodeAcc/blob/master/src/designpattern/builder/BuilderClient.java)
- [单例模式](https://github.com/echoTheLiar/JavaCodeAcc/blob/master/src/designpattern/singleton/SingletonClient.java)

#### 结构型模式

- [适配器模式](https://github.com/echoTheLiar/JavaCodeAcc/blob/master/src/designpattern/adapter/AdapterClient.java)
- [桥接模式](https://github.com/echoTheLiar/JavaCodeAcc/blob/master/src/designpattern/bridge/BridgeClient.java)
- [组合模式](https://github.com/echoTheLiar/JavaCodeAcc/blob/master/src/designpattern/composite/CompositeClient.java)
- [装饰模式](https://github.com/echoTheLiar/JavaCodeAcc/blob/master/src/designpattern/decorator/DecoratorClient.java)
- [外观模式](https://github.com/echoTheLiar/JavaCodeAcc/blob/master/src/designpattern/facade/FacadeClient.java)
- [享元模式](https://github.com/echoTheLiar/JavaCodeAcc/blob/master/src/designpattern/flyweight/FlyWeightClient.java)
- [代理模式](https://github.com/echoTheLiar/JavaCodeAcc/blob/master/src/designpattern/proxy/ProxyClient.java)

#### 行为模式（类行为型模式）

- [解释器模式](https://github.com/echoTheLiar/JavaCodeAcc/blob/master/src/designpattern/interpreter/InterpreterClient.java)
- [模板方法模式](https://github.com/echoTheLiar/JavaCodeAcc/blob/master/src/designpattern/template/TemplateClient.java)

#### 行为模式（对象行为型模式）

- [策略模式](https://github.com/echoTheLiar/JavaCodeAcc/blob/master/src/designpattern/strategy/StrategyClient.java)
- [观察者模式](https://github.com/echoTheLiar/JavaCodeAcc/blob/master/src/designpattern/observer/ObserverClient.java)
- [状态模式](https://github.com/echoTheLiar/JavaCodeAcc/blob/master/src/designpattern/state/StateClient.java)
- [备忘录模式](https://github.com/echoTheLiar/JavaCodeAcc/blob/master/src/designpattern/memento/MementoClient.java)
- [迭代器模式](https://github.com/echoTheLiar/JavaCodeAcc/blob/master/src/designpattern/iterator/IteratorClient.java)
- [命令模式](https://github.com/echoTheLiar/JavaCodeAcc/blob/master/src/designpattern/command/CommandClient.java)
- [职责链模式](https://github.com/echoTheLiar/JavaCodeAcc/blob/master/src/designpattern/responsibilitychain/Client.java)
- [中介者模式](https://github.com/echoTheLiar/JavaCodeAcc/blob/master/src/designpattern/mediator/MediatorClient.java)
- [访问者模式](https://github.com/echoTheLiar/JavaCodeAcc/blob/master/src/designpattern/visitor/VisitorClient.java)

##### 命令模式

```
命令模式的本质是对请求进行封装，一个请求对应于一个命令，将发出命令的责任和执行命令的责任分割开。每一个命令都是一个操作：请求的一方发出请求要求执行一个操作；接收的一方收到请求，并执行相应的操作。命令模式允许请求的一方和接收的一方独立开来，使得请求的一方不必知道接收请求的一方的接口，更不必知道请求如何被接收、操作是否被执行、何时被执行，以及是怎么被执行的。
```

##### 主要优点

```
(1) 降低系统的耦合度。由于请求者与接收者之间不存在直接引用，因此请求者与接收者之间实现完全解耦，相同的请求者可以对应不同的接收者，同样，相同的接收者也可以供不同的请求者使用，两者之间具有良好的独立性。
(2) 新的命令可以很容易地加入到系统中。由于增加新的具体命令类不会影响到其他类，因此增加新的具体命令类很容易，无须修改原有系统源代码，甚至客户类代码，满足“开闭原则”的要求。
(3) 可以比较容易地设计一个命令队列或宏命令（组合命令）。
(4) 为请求的撤销(Undo)和恢复(Redo)操作提供了一种设计和实现方案。
```

##### 主要缺点

```
使用命令模式可能会导致某些系统有过多的具体命令类。因为针对每一个对请求接收者的调用操作都需要设计一个具体命令类，因此在某些系统中可能需要提供大量的具体命令类，这将影响命令模式的使用。
```

##### 适用场景

```
 在以下情况下可以考虑使用命令模式：
(1) 系统需要将请求调用者和请求接收者解耦，使得调用者和接收者不直接交互。请求调用者无须知道接收者的存在，也无须知道接收者是谁，接收者也无须关心何时被调用。
(2) 系统需要在不同的时间指定请求、将请求排队和执行请求。一个命令对象和请求的初始调用者可以有不同的生命期，换言之，最初的请求发出者可能已经不在了，而命令对象本身仍然是活动的，可以通过该命令对象去调用请求接收者，而无须关心请求调用者的存在性，可以通过请求日志文件等机制来具体实现。
(3) 系统需要支持命令的撤销(Undo)操作和恢复(Redo)操作。
(4) 系统需要将一组操作组合在一起形成宏命令。
```

### 线程

### 异常

### 特性

- `可见性`：`一个线程对主内存的修改可以及时的被其他线程观察到`
- `有序性`：`一个线程观察其他线程中的指令执行顺序，由于指令 重排序的存在，该观察结果一般杂乱无序`
- `原子性`：`提供了互斥访问`

##### 8种原子操作

- `lock（锁定）`：`作用于主内存的变量，它把一个变量标识为一条线程独占的状态`
- `unlock（解锁）`：`作用于主内存的变量，它把一个处于锁定状态的变量释放出来，释放后的变量才可以被其他线程锁定`
- `read（读取）`：`作用于主内存的变量，它把一个变量的值从主内存传输到线程的工作内存中，以便随后的 load 动作使用`
- `load（载入）`：`作用于工作内存的变量，它把 read 操作从主内存中得到的变量值放入工作内存的变量副本中`
- `use（使用）`：`作用于工作内存的变量，它把工作内存中一个变量的值传递给执行引擎，每当虚拟机遇到一个需要使用到变量的值的字节码指令时将会执行这个操作`
- `assign（赋值）`：`作用于工作内存的变量，它把一个从执行引擎接收到的值赋给工作内存的变量，每当虚拟机遇到一个给变量赋值的字节码指令时执行这个操作`
- `store（存储）`：`作用于工作内存的变量，它把工作内存中一个变量的值传送到主内存中，以便随后的 write 操作使用`
- `write（写入）`：`作用于主内存的变量，它把 store 操作从工作内存中得到的变量的值放入主内存的变量中`

#### 状态

> **NEW（新建）**
>
> RUNNABLE（可运行）
>
> BLOCKED（阻塞）
>
> TERMINATED（结束）
>
> WAITING（无限期等待）
>
> - `没有设置timeout参数的Object.wait()`
> - `没有设置timeout参数的Thread.join()`
> - `LockSupport.park()`
>
> TIMED_WAITING（限期等待）
>
> - `Thread.sleep()`
> - `设置了timeout参数的Object.wait()`
> - `设置了timeout参数的Thread.join()`
> - `LockSupport.parkNanos()`
> - `LockSupport.parkUntil()`

![线程状态转换图](D:\config\pic\线程状态转换图.jpg)

### Happen-before

```
1. 如果一个操作happens-before另一个操作，那么第一个操作的执行结果将对第二个操作可见，而且第一个操作的执行顺序排在第二个操作之前。 
2. 两个操作之间存在happens-before关系，并不意味着一定要按照happens-before原则制定的顺序来执行。如果重排序之后的执行结果与按照happens-before关系来执行的结果一致，那么这种重排序并不非法
```

#### happens-before原则规则

- `程序次序规则：一个线程内，按照代码顺序，书写在前面的操作先行发生于书写在后面的操作`
- `锁定规则：一个unLock操作先行发生于后面对同一个锁的lock操作`
- `volatile变量规则：对一个变量的写操作先行发生于后面对这个变量的读操作`
- `传递规则：如果操作A先行发生于操作B，而操作B又先行发生于操作C，则可以得出操作A先行发生于操作C`
- `线程启动规则：Thread对象的start()方法先行发生于此线程的每个一个动作`
- `线程中断规则：对线程interrupt()方法的调用先行发生于被中断线程的代码检测到中断事件的发生`
- `线程终结规则：线程中所有的操作都先行发生于线程的终止检测，我们可以通过Thread.join()方法结束Thread.isAlive()的返回值手段检测到线程已经终止执行`
- `对象终结规则：一个对象的初始化完成先行发生于他的finalize()方法的开始`

**程序次序规则**：`一段代码在单线程中执行的结果是有序的。注意是执行结果，因为虚拟机、处理器会对指令进行重排序（重排序后面会详细介绍）。虽然重排序了，但是并不会影响程序的执行结果，所以程序最终执行的结果与顺序执行的结果是一致的。故而这个规则只对单线程有效，在多线程环境下无法保证正确性`

**锁定规则**：`这个规则比较好理解，无论是在单线程环境还是多线程环境，一个锁处于被锁定状态，那么必须先执行unlock操作后面才能进行lock操作`

**volatile变量规则**：`这是一条比较重要的规则，它标志着volatile保证了线程可见性。通俗点讲就是如果一个线程先去写一个volatile变量，然后一个线程去读这个变量，那么这个写操作一定是happens-before读操作的`

**传递规则**：`提现了happens-before原则具有传递性，即A happens-before B , B happens-before C，那么A happens-before C`

**线程启动规则**：`假定线程A在执行过程中，通过执行ThreadB.start()来启动线程B，那么线程A对共享变量的修改在接下来线程B开始执行后确保对线程B可见`

**线程终结规则**：`假定线程A在执行的过程中，通过制定ThreadB.join()等待线程B终止，那么线程B在终止之前对共享变量的修改在线程A等待返回后可见`

上面八条是原生Java满足Happens-before关系的规则，但是我们可以对他们进行推导出其他满足happens-before的规则：

- `将一个元素放入一个线程安全的队列的操作Happens-Before从队列中取出这个元素的操作`
- `将一个元素放入一个线程安全容器的操作Happens-Before从容器中取出这个元素的操作`
- `在CountDownLatch上的倒数操作Happens-Before CountDownLatch#await()操作`
- `释放Semaphore许可的操作Happens-Before获得许可操作`
- `Future表示的任务的所有操作Happens-Before Future#get()操作`
- `向Executor提交一个Runnable或Callable的操作Happens-Before任务开始执行操作`

这里再说一遍happens-before的概念：**如果两个操作不存在上述（前面8条 + 后面6条）任一一个happens-before规则，那么这两个操作就没有顺序的保障，JVM可以对这两个操作进行重排序。如果操作A happens-before操作B，那么操作A在内存上所做的操作对操作B都是可见的**

#### volatile

### 重排序

#### 编译器重排序

`编译器在不改变单线程语义的前提下，为了提高程序的运行速度，可以对字节码指令进行重新排序，所以代码中a、b的赋值顺序，被编译之后可能就变成了先设置b，再设置a`

#### CPU指令重排序

```
在MESI协议中，每个Cache line有4种状态，分别是：
1、M(Modified) 这行数据有效，但是被修改了，和内存中的数据不一致，数据只存在于本Cache中
2、E(Exclusive) 这行数据有效，和内存中的数据一致，数据只存在于本Cache中
3、S(Shared) 这行数据有效，和内存中的数据一致，数据分布在很多Cache中
4、I(Invalid) 这行数据无效
每个Core的Cache控制器不仅知道自己的读写操作，也监听其它Cache的读写操作，假如有4个Core： 
1、Core1从内存中加载了变量X，值为10，这时Core1中缓存变量X的cache line的状态是E； 
2、Core2也从内存中加载了变量X，这时Core1和Core2缓存变量X的cache line状态转化成S； 
3、Core3也从内存中加载了变量X，然后把X设置成了20，这时Core3中缓存变量X的cache line状态转化成M，其它Core对应的cache line变成I（无效）
当然了，不同的处理器内部细节也是不一样的，比如Intel的core i7处理器使用从MESI中演化出的MESIF协议，F(Forward)从Share中演化而来，一个cache line如果是F状态，可以把数据直接传给其它内核，这里就不纠结了。
```

**CPU在cache line状态的转化期间是阻塞的，经过长时间的优化，在寄存器和L1缓存之间添加了LoadBuffer、StoreBuffer来降低阻塞时间，Buffer与L1进行数据传输时，CPU无须等待。**

**1、CPU执行load读数据时，把读请求放到LoadBuffer，这样就不用等待其它CPU响应，先进行下面操作，稍后再处理这个读请求的结果。**
**2、CPU执行store写数据时，把数据写到StoreBuffer中，待到某个适合的时间点，把StoreBuffer的数据刷到主存中。**
**因为StoreBuffer的存在，CPU在写数据时，真实数据并不会立即表现到内存中，所以对于其它CPU是不可见的；同样的道理，LoadBuffer中的请求也无法拿到其它CPU设置的最新数据；**
**由于StoreBuffer和LoadBuffer是异步执行的，所以在外面看来，先写后读，还是先读后写，没有严格的固定顺序。**

### 内存屏障

**从CPU缓存结构分析中已经知道：一个load操作需要进入LoadBuffer，然后再去内存加载；一个store操作需要进入StoreBuffer，然后再写入缓存，这两个操作都是异步的，会导致不正确的指令重排序，所以在JVM中定义了一系列的内存屏障来指定指令的执行顺序。**

- `loadload屏障（load1，loadload， load2）` 
- `loadstore屏障（load，loadstore， store）`
- `storestore屏障（store1，storestore， store2）`
- `storeload屏障（store，storeload， load）`

`cpu（x86）提供了sfence lfence 强制刷线cache`

### 死锁

##### 产生死锁的四个必要条件：

- `互斥条件：一个资源每次只能被一个进程使用`
- `请求与保持条件：一个进程因请求资源而阻塞时，对已获得的资源保持不放` 
- `不剥夺条件:进程已获得的资源，在末使用完之前，不能强行剥夺`
- `循环等待条件:若干进程之间形成一种头尾相接的循环等待资源关系` 

### 安全性

数据竞争： 多个线程同时访问一个数据，并且至少有一个线程会写这个数据。
竞态条件： 程序的执行结果依赖程序执行的顺序。
也可以按照以下的方式理解竞态条件： 程序的执行依赖于某个状态变量，在判断满足条件的时候执行，但是在执行时其他变量同时修改了状态变量。
if (状态变量 满足 执行条件) {
  执行操作
}

### 活跃性
死锁：破坏造成死锁的条件，1,使用等待-通知机制的Allocator; 2主动释放占有的资源；3,按顺序获取资源。
活锁：虽然没有发生阻塞，但仍会存在执行不下去的情况。我感觉像进入了某种怪圈。解决办法，等待随机的时间，例如Raft算法中重新选举leader。
饥饿：我想到了没有引入时间片概念时，cpu处理作业。如果遇到长作业，会导致短作业饥饿。如果优先处理短作业，则会饿死长作业。长作业就可以类比持有锁的时间过长，而时间片可以让cpu资源公平地分配给各个作业。当然，如果有无穷多的cpu，就可以让每个作业得以执行，就不存在饥饿了。

#### 饥饿 丢失信号 活锁

#### 无饥饿

#### 无障碍

#### 无等待

- 有界无等待
- 线程数无关

### 管程

#### synchronized

#### AbstractQueuedSynchronizer

#### Lock和Condition

#### ReadWriteLock

#### StampedLock

#### CountDownLatch

#### CyclicBarrier

#### Future

#### CompletableFuture

#### CompletionService

#### ForkJoin

### 信号量

#### Semaphore

![img](https://static001.geekbang.org/resource/image/6d/5c/6dfeeb9180ff3e038478f2a7dccc9b5c.png)

### 无锁(CAS)

```
CAS（compare and swap）的缩写，中文翻译成比较并交换。
CAS 不通过JVM,直接利用java本地方 JNI（Java Native Interface为JAVA本地调用）,直接调用CPU 的cmpxchg（是汇编指令）指令。
利用CPU的CAS指令，同时借助JNI来完成Java的非阻塞算法,实现原子操作。其它原子操作都是利用类似的特性完成的。整个java.util.concurrent都是建立在CAS之上的，因此对于synchronized阻塞算法，J.U.C在性能上有了很大的提升。
CAS是项乐观锁技术，当多个线程尝试使用CAS同时更新同一个变量时，只有其中一个线程能更新变量的值，而其它线程都失败，失败的线程并不会被挂起，而是被告知这次竞争中失败，并可以再次尝试。
```

![img](https://static001.geekbang.org/resource/image/00/4a/007a32583fbf519469462fe61805eb4a.png)

#### CAS应用

`CAS有3个操作数，内存值V，旧的预期值A，要修改的新值B。当且仅当预期值A和内存值V相同时，将内存值V修改为B，否则什么都不做`

#### CAS优点

`确保对内存的读-改-写操作都是原子操作执行`

#### CAS缺点

`CAS虽然很高效的解决原子操作，但是CAS仍然存在三大问题。ABA问题，循环时间长开销大和只能保证一个共享变量的原子操作`

#### 总结

- `使用CAS在线程冲突严重时，会大幅降低程序性能；CAS只适合于线程冲突较少的情况使1`
- `synchronized在jdk1.6之后，已经改进优化。synchronized的底层实现主要依靠Lock-Free的队列，基本思路是自旋后阻塞，竞争切换后继续竞争锁，稍微牺牲了公平性，但获得了高吞吐量。在线程冲突较少的情况下，可以获得和CAS类似的性能；而线程冲突严重的情况下，性能远高于CAS`

### 并发设计模式

![img](https://static001.geekbang.org/resource/image/11/65/11e0c64618c04edba52619f41aaa3565.png)

### MESA 模型

### Hasen 模型

### Hoare 模型