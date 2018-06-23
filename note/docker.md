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

##### 创建

```
docker run -d -v /dbdata --name dbdata training/postgres echo Data-only container for postgres
然后其他容器要使用这个数据卷容器的话，只要使用--volumes-from参数即可。
$ sudo docker run -d --volumes-from dbdata --name db1 training/postgres
$ sudo docker run -d --volumes-from dbdata --name db2 training/postgres
```
