

```
"C:\Program Files\Java\jdk1.8.0_161\bin\java" -Dmaven.multiModuleProjectDirectory=D:\workdir\ZcCloud\cloud-common -Dmaven.home=D:\apache-maven-3.5.3-bin\apache-maven-3.5.3 -Dclassworlds.conf=D:\apache-maven-3.5.3-bin\apache-maven-3.5.3\bin\m2.conf "-javaagent:C:\Program Files\JetBrains\IntelliJ IDEA 2018.1\lib\idea_rt.jar=57046:C:\Program Files\JetBrains\IntelliJ IDEA 2018.1\bin" -Dfile.encoding=UTF-8 -classpath D:\apache-maven-3.5.3-bin\apache-maven-3.5.3\boot\plexus-classworlds-2.5.2.jar org.codehaus.classworlds.Launcher -s D:\settings.xml install -f pom.xml
```

```
kubectl --server https://127.0.0.1:6443 --certificate-authority /etc/kubernetes/ssl/k8s-root-ca.pem --client-certificate /etc/kubernetes/ssl/admin.pem --client-key /etc/kubernetes/ssl/admin-key.pem get cs
```

```
1、临时关闭selinux
setenforce 0    ##设置SELinux 成为permissive模式
setenforce 1    ##设置SELinux 成为enforcing模式
2、永久关闭selinux,
修改/etc/selinux/config 文件
将SELINUX=enforcing改为SELINUX=disabled
重启机器即可
```

```
hostnamectl set-hostname  NMServer-7.test.com
vi /etc/hostname 
nmserver-7.test.com
```

```
1.hbase、hadoop环境（1天）
2.kafak数据格式确认（1天）
3.hbase数据格式方案确定（1天）
4.整体架构确定（1天）
5.代码编写（5天）
6.自测（2天）
7.和前端联调（5天）
8.测试（2天）
```

```
create 'trace', 'rpc'
spark-submit --class com.mychebao.hbasetest.HbaseTest \
 --master yarn \
     --driver-memory 2g \
    --executor-memory 2g \
    --executor-cores 4 \
 hbasetest-1.0-SNAPSHOT.jar escnode0:2181 g1 trace 1

```

