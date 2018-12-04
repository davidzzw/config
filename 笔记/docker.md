###数据卷

####介绍

```
数据卷就是可以让你把主机上的数据以挂载的方式链接到容器中，这样不同的容器也能共享，而且数据也不会因为容器的退出而丢失。
```

#### 使用

```
docker run -d -v ~/mynginx:/a -p 80:80 --name webserver nginx
这里命令会挂载主机的目录~/mynginx到容器中的目录/a。
你可以试验一下，分别在两端更改内容，比如新建一个文件，看是不是都变化了。
我们也可以创建数据卷容器，数据卷容器也是一个正常的容器，这种容器可以为其他容器提供和共享数据。
```
-Dsun.jvm.hotspot.tools.jcore.filter=com.zzw.hotspot.sa.MyFilter -Dsun.jvm.hotspot.tools.jcore.outputDir=. 6384
WebappClassLoader
  context: 
  delegate: false
  repositories:
    /WEB-INF/classes/
----------> Parent Classloader:
org.apache.catalina.loader.StandardClassLoader@55fbe5cc
org.apache.catalina.loader.WebappClassLoader

##### 创建

```
docker run -d -v /dbdata --name dbdata training/postgres echo Data-only container for postgres
然后其他容器要使用这个数据卷容器的话，只要使用--volumes-from参数即可。
$ sudo docker run -d --volumes-from dbdata --name db1 training/postgres
$ sudo docker run -d --volumes-from dbdata --name db2 training/postgres
```

1本次升级必须对csf版本升级到1.3.0-SNAPSHOT
csf版本提升到1.3.0-SNAPSHOT
2如果应用需要用到redis需要引入Chezhibao-cache，同时Dragon-core版本一定得升级到2.0.9-SNAPSHOT(redis)
<dependency>
   <groupId>dragon</groupId>
   <artifactId>dragon-core</artifactId>
   <version>2.0.9-SNAPSHOT</version>
</dependency>
<dependency>
	<groupId>com.chezhibao</groupId>
	<artifactId>chezhibao-cache</artifactId>
	<version>1.1.0-SNAPSHOT</version>
</dependency>
3如果应用需要用到rocketmq，需要引入Cmq依赖（mq）
<dependency>
   <groupId>com.chezhibao.cmq</groupId>
   <artifactId>cmq-client</artifactId>
   <version>1.0.0-SNAPSHOT</version>
</dependency>
4如果有用到msg-intf,需要版本升级到2.2.1-SNAPSHOT（http调用）
<dependency>
	<groupId>com.lebo.chezhibao</groupId>
	<artifactId>msg-intf</artifactId>
	<version>2.2.1-SNAPSHOT</version>
	<exclusions>
		<exclusion>
			<groupId>io.netty</groupId>
			<artifactId>netty-all</artifactId>
		</exclusion>
		<exclusion>
			<groupId>org.apache.rocketmq</groupId>
			<artifactId>rocketmq-client</artifactId>
		</exclusion>
	</exclusions>
</dependency>
5本次升级必须引入
<dependency>
    <groupId>com.chezhibao</groupId>
    <artifactId>init-core</artifactId>
    <version>1.0-SNAPSHOT</version>
</dependency>