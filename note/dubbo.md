### spi

`ExtensionLoader`

####dubbo spi

`jdk的spi会在一次实例化所有实现，可能会比较耗时，而且有些可能用不到的实现类也会实例化，浪费资源而且没有选择。另外dubbo的spi增加了对扩展点IOC和AOP的支持，一个扩展点可以直接setter注入其他扩展点。这是jdk spi不支持的`

##### 注入

#### AOP

###Spring 的 XML 扩展机制

使用 Spring 的 XML 扩展机制有以下几个步骤：

* 定义 Schema（编写 .xsd 文件）
* 定义 JavaBean
* 编写 `NamespaceHandler` 和 `BeanDefinitionParser`完成 Schema 解析
* 编写 `spring.handlers`和 `spring.schemas` 文件串联解析部件
* 在 XML 文件中应用配置

`DubboNamespaceHandler 和 DubboBeanDefinitionParser `

### 超时

#### ReponseFuture

`DefaultFuture`

```java
public Object get(int timeout) throws RemotingException {
        if (timeout <= 0) {
            timeout = Constants.DEFAULT_TIMEOUT;
        }
        if (! isDone()) {
            long start = System.currentTimeMillis();
            lock.lock();
            try {
                while (! isDone()) {
                    done.await(timeout, TimeUnit.MILLISECONDS);
                    if (isDone() || System.currentTimeMillis() - start > timeout) {
                        break;
                    }
                }
            } catch (InterruptedException e) {
                throw new RuntimeException(e);
            } finally {
                lock.unlock();
            }
            if (! isDone()) {
                throw new TimeoutException(sent > 0, channel, getTimeoutMessage(false));
            }
        }
        return returnFromResponse();
    }
```

### 架构



- **config 配置层**：对外配置接口，以 `ServiceConfig`, `ReferenceConfig` 为中心，可以直接初始化配置类，也可以通过 spring 解析配置生成配置类
- **proxy 服务代理层**：服务接口透明代理，生成服务的客户端 Stub 和服务器端 Skeleton, 以 `ServiceProxy`为中心，扩展接口为 `ProxyFactory`
- **registry 注册中心层**：封装服务地址的注册与发现，以服务 URL 为中心，扩展接口为 `RegistryFactory`, `Registry`, `RegistryService`
- **cluster 路由层**：封装多个提供者的路由及负载均衡，并桥接注册中心，以 `Invoker` 为中心，扩展接口为 `Cluster`, `Directory`, `Router`, `LoadBalance`
- **monitor 监控层**：RPC 调用次数和调用时间监控，以 `Statistics` 为中心，扩展接口为 `MonitorFactory`, `Monitor`, `MonitorService`
- **protocol 远程调用层**：封装 RPC 调用，以 `Invocation`, `Result` 为中心，扩展接口为 `Protocol`, `Invoker`, `Exporter`
- **exchange 信息交换层**：封装请求响应模式，同步转异步，以 `Request`, `Response` 为中心，扩展接口为 `Exchanger`, `ExchangeChannel`, `ExchangeClient`, `ExchangeServer`
- **transport 网络传输层**：抽象 mina 和 netty 为统一接口，以 `Message` 为中心，扩展接口为 `Channel`, `Transporter`, `Client`, `Server`, `Codec`
- **serialize 数据序列化层**：可复用的一些工具，扩展接口为 `Serialization`, `ObjectInput`, `ObjectOutput`, `ThreadPool`

### Protocol

###服务注册

### 服务发现

### 服务消费方发起请求

当服务的消费方引用了某远程服务，服务的应用方在[spring](http://lib.csdn.net/base/javaee)的配置实例如下：

<[dubbo](https://www.baidu.com/s?wd=dubbo&tn=24004469_oem_dg&rsv_dl=gh_pl_sl_csd):referenceid=*"demoService"*interface=*"com.alibaba.dubbo.demo.DemoServ ice"* />

demoService实例其实是代理工厂生产的代理对象（大家可以参考代理那部分生成的伪代码），在代码中调用demoService.sayHello(“world!”)时，

1.将方法名方法参数传入InvokerInvocationHandler的invoke方

对于Object中的方法toString, hashCode, equals直接调用invoker的对应方法,

这里对于Object的方法需要被远程调用吗？调用了是不是报错比默认处理更好呢？？

远程调用层是以Invocation, Result为中心， 这里根据要调用的方法以及传入的参数构建RpcInvocation对象，作为Invoker的入参

2.MockClusterInvoker根据参数提供了三种调用策略

不需要mock， 直接调用FailoverClusterInvoker

强制mock，调用mock

先调FailoverClusterInvoker，调用失败在mock、

3.FailoverClusterInvoker默认调用策略

通过目录服务查找到所有订阅的服务提供者的Invoker对象

路由服务根据策略来过滤选择调用的Invokers

通过负载均衡策略LoadBalance来选择一个Invoker

4.执行选择的Invoker.inoker(invocation)

经过[监听器](https://www.baidu.com/s?wd=%E7%9B%91%E5%90%AC%E5%99%A8&tn=24004469_oem_dg&rsv_dl=gh_pl_sl_csd)链，默认没有

经过过滤器链，内置实现了很多

执行到远程调用的DubboInvoker

5.DubboInvoker

根据url 也就是根据服务提供者的长连接，这里封装成交互层对象ExchangeClient供这里调用

判断远程调用类型同步，异步还是oneway模式

ExchangeClient发起远程调用，底层remoting不在这里描述了

获取调用结果：

​        Oneway返回空RpcResult

​        异步，直接返回空RpcResult, ResponseFuture回调

​        同步， ResponseFuture模式同步转异步，等待响应返回

### 服务提供方接收调用请求

同样我们也是rpc调用层DubboProtocol层开始分析，对于通信层remoting的数据接收反序列等等过程不做分析。

DubboProtocol的requestHandler是ExchangeHandler的实现，是remoting层接收数据后的回调。

requestHandler.replay方法接收请求消息，这里只处理远程调用消息Invocation。

1.通过Invocation获取服务名和端口组成serviceKey=com.alibaba.dubbo.demo.DemoService:20880, 从DubboProtocol的exproterMap中获取暴露服务的DubboExporter, 在从dubboExporter 获取invoker返回

2.经过过滤器链

3.经过监听器链

4.到达执行真正调用的invoker， 这个invoker由代理工厂ProxyFactory.getInvoker(demoService, DemoService.class, registryUrl)创建，具体请看代理那部分介绍。

调用demoService实例方法，将结果封装成RpcResult返回

5.交换层构建Response，通过Remoting层编码传输将结果响应给调用方