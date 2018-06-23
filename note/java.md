### 类的设计原则

```
依赖倒置原则－Dependency Inversion Principle (DIP) 
里氏替换原则－Liskov Substitution Principle (LSP) 
接口分隔原则－Interface Segregation Principle (ISP) 
单一职责原则－Single Responsibility Principle (SRP) 
开闭原则－The Open-Closed Principle (OCP)
```

 

http://cenalulu.github.io/mysql/mysql-mojibake/

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


优点： 
1.在单例模式中，活动的单例只有一个实例，对单例类的所有实例化得到的都是相同的一个实例。这样就 防止其它对象对自己的实例化，确保所有的对象都访问一个实例 
2.单例模式具有一定的伸缩性，类自己来控制实例化进程，类就在改变实例化进程上有相应的伸缩性。 
3.提供了对唯一实例的受控访问。 
4.由于在系统内存中只存在一个对象，因此可以 节约系统资源，当 需要频繁创建和销毁的对象时单例模式无疑可以提高系统的性能。 
5.允许可变数目的实例。 
6.避免对共享资源的多重占用。

https://gist.github.com/strongant

但对于方法参数的日志倒是可以自动化：

@RequestMapping("/access_token")
@IgnoreLogin
public ResponseEntity<Resp> accessToken(@RequestParam("auth_token") @LogMask String authToken,
    @RequestHeader("X-Xxxx-Device-Id") @LogMask String deviceId, String env, HttpServletRequest request) {
     xxxxxxx
}


java并发线程实战，并发编程艺术，多处理器编程的艺术

quasar

  Wait()方法和notify()方法：当一个线程执行到wait()方法时(线程休眠且释放机锁)，它就进入到一个和该对象相关的等待池中，
同时失去了对象的机锁。当它被一个notify()方法唤醒时，等待池中的线程就被放到了锁池中。该线程从锁池中获得机锁，然后回到wait()前的中断现场。


共同点： 他们都是在多线程的环境下，都可以在程序的调用处阻塞指定的毫秒数，并返回。
不同点： Thread.sleep(long)可以不在synchronized的块下调用，而且使用Thread.sleep()不会丢失当前线程对任何对象的同步锁(monitor);
object.wait(long)必须在synchronized的块下来使用，调用了之后失去对object的monitor, 这样做的好处是它不影响其它的线程对object进行操作。

登录注册要做好，http 协议和 https 你得非常熟悉，特别是各种涉及 Web 安全的响应头，cookie 的各种属性，302 重定向的作用等等。
还需要熟悉客户端的东西，比如设备指纹是怎么生成的。后端的东西就更多了，
会话服务器集群、会话拦截器给各 Web 应用使用的 jar 封装，处理各种千奇百怪产品登录注册需求的授权认证 api 和服务的系统架构。