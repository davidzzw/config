### cpu

#### 上下文切换

* **进程上下文切换** 

* **线程上下文切换**

* **3中断上下文切换**

#### 排查

#### 优化

### 内存

#### buffer 

#### cache

#### 排查

#### 优化

### io

#### 模型

#### 排查

1.用top查看指标,发现 [系统] 有i/o瓶颈 或者 cpu瓶颈.
2.使用iostat辅助看下磁盘i/o读写速度和大小等指标.
3.用pidstat判断是哪个 [进程] 导致的. 既可以看进程各线程的cpu中断数,也可以看磁盘io数.
4.用strace追踪进程及各线程的 [系统调用].(以前经常到这里就知道了是操作的什么文件)
5.继续用lsof查看该进程打开的 [文件] .linux下一切皆文件,则可以查看的东西就很多很多了.连进程保持的socket等信息也一目了然

#### 优化

### 网络

#### 排查

#### 优化



centos安装jdk
rpm -qa | grep jdk
rpm -ivh 
taskkill -f -t -im
GRANT ALL PRIVILEGES ON *.* TO 'zzw'@'%' IDENTIFIED BY '123456' WITH GRANT OPTION;
grant all on xxxx.* to 'root'@'%' identified by 'password' with grant option;

-A INPUT -p tcp -m state --state NEW -m tcp --dport 3306 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 8080 -j ACCEPT

netstat -tln
netstat -lnp|grep 88
netstat -nap 

列出所有端口
netstat -ntlp


free -m | grep cache: | awk '{print $4}'
随手写的，不一定能用

for jar in $(ls /lib/*.jar)
do
   lib=$lib:$jar
done
类似这样的，手机写的不一定 100% 准确，可以参考

比如，有一个目录下每天会生成一个备份目录，但是我们并不需要这么多，只需要保存最新的 10 个目录就好了，这样的话 awk 就能派上用场了

ls -lt | grep drwx | awk '{if(NR>10){print $9}}' | xargs -I {} rm -rf {}

### 内核文件系统

```
l  /proc/sys/vm/dirty_expire_centisecs
数据存在的时间超过了dirty_expire_centisecs（默认30s）时间
l  /proc/sys/vm/dirty_background_ratio  
脏页率超过dirty_background_ratio指标会启动pdflush开始Flush Dirty PageCache
l  /proc/sys/vm/dirty_ratio
脏页率超过dirty_ratio指标会阻塞所有的写操作来进行Flush
```

### linux下proc里关于磁盘性能的参数

```
1、/proc/sys/vm/dirty_ratio
这个参数控制文件系统的文件系统写缓冲区的大小，单位是百分比，表示系统内存的百分比，表示当写缓冲使用到系统内存多少的时候，开始向磁盘写出数据。增大之会使用更多系统内存用于磁盘写缓冲，也可以极大提高系统的写性能。但是，当你需要持续、恒定的写入场合时，应该降低其数值，：
echo '1' > /proc/sys/vm/dirty_ratio
2、/proc/sys/vm/dirty_background_ratio
这个参数控制文件系统的pdflush进程，在何时刷新磁盘。单位是百分比，表示系统内存的百分比，意思是当写缓冲使用到系统内存多少的时候，pdflush开始向磁盘写出数据。增大之会使用更多系统内存用于磁盘写缓冲，也可以极大提高系统的写性能。但是，当你需要持续、恒定的写入场合时，应该降低其数值，：
echo '1' > /proc/sys/vm/dirty_background_ratio
3、/proc/sys/vm/dirty_writeback_centisecs
这个参数控制内核的脏数据刷新进程pdflush的运行间隔。单位是 1/100 秒。缺省数值是500，也就是 5 秒。如果你的系统是持续地写入动作，那么实际上还是降低这个数值比较好，这样可以把尖峰的写操作削平成多次写操作。设置方法如下：
echo "100" > /proc/sys/vm/dirty_writeback_centisecs
如果你的系统是短期地尖峰式的写操作，并且写入数据不大（几十M/次）且内存有比较多富裕，那么应该增大此数值：
echo "1000" > /proc/sys/vm/dirty_writeback_centisecs
4、/proc/sys/vm/dirty_expire_centisecs
这个参数声明Linux内核写缓冲区里面的数据多“旧”了之后，pdflush进程就开始考虑写到磁盘中去。单位是 1/100秒。缺省是 30000，也就是 30 秒的数据就算旧了，将会刷新磁盘。对于特别重载的写操作来说，这个值适当缩小也是好的，但也不能缩小太多，因为缩小太多也会导致IO提高太快。
echo "100" > /proc/sys/vm/dirty_expire_centisecs
当然，如果你的系统内存比较大，并且写入模式是间歇式的，并且每次写入的数据不大（比如几十M），那么这个值还是大些的好
5、/proc/sys/vm/vfs_cache_pressure
该文件表示内核回收用于directory和inode   cache内存的倾向；缺省值100表示内核将根据pagecache和swapcache，把directory和inode   cache保持在一个合理的百分比；降低该值低于100，将导致内核倾向于保留directory和inode   cache；增加该值超过100，将导致内核倾向于回收directory和inode   cache
缺省设置：100
6、 /proc/sys/vm/min_free_kbytes
该文件表示强制Linux   VM最低保留多少空闲内存（Kbytes）。
缺省设置：724（512M物理内存）
7、/proc/sys/vm/nr_pdflush_threads
该文件表示当前正在运行的pdflush进程数量，在I/O负载高的情况下，内核会自动增加更多的pdflush进程。
缺省设置：2（只读）
8、/proc/sys/vm/overcommit_memory
该文件指定了内核针对内存分配的策略，其值可以是0、1、2。
0，表示内核将检查是否有足够的可用内存供应用进程使用；如果有足够的可用内存，内存申请允许；否则，内存申请失败，并把错误返回给应用进程。
1，表示内核允许分配所有的物理内存，而不管当前的内存状态如何。
2，表示内核允许分配超过所有物理内存和交换空间总和的内存（参照overcommit_ratio）。
缺省设置：0
9、/proc/sys/vm/overcommit_ratio
该文件表示，如果overcommit_memory=2，可以过载内存的百分比，通过以下公式来计算系统整体可用内存。
系统可分配内存=交换空间+物理内存*overcommit_ratio/100
缺省设置：50（%）
10、/proc/sys/vm/page-cluster
该文件表示在写一次到swap区的时候写入的页面数量，0表示1页，1表示2页，2表示4页。
缺省设置：3（2的3次方，8页）
11、/proc/sys/vm/swapiness
该文件表示系统进行交换行为的程度，数值（0-100）越高，越可能发生磁盘交换
```

### 零拷贝

### 用户态

### 内核态

#### Linux查看物理CPU个数、核数、逻辑CPU个数

```
# 总核数 = 物理CPU个数 X 每颗物理CPU的核数 
# 总逻辑CPU数 = 物理CPU个数 X 每颗物理CPU的核数 X 超线程数
# 查看物理CPU个数
cat /proc/cpuinfo| grep "physical id"| sort| uniq| wc -l
# 查看每个物理CPU中core的个数(即核数)
cat /proc/cpuinfo| grep "cpu cores"| uniq
# 查看逻辑CPU的个数
cat /proc/cpuinfo| grep "processor"| wc -l
 查看CPU信息（型号）
cat /proc/cpuinfo | grep name | cut -f2 -d: | uniq -c
```

### 查看进程占内存

```
top RES：进程占用的物理内存
pmap
ps -e -o 'pid,comm,args,pcpu,rsz,vsz,stime,user,uid' | grep appName |  sort -nrk5
```

### 刷盘

#### 一次正常的写流程

一次写数据的典型流程（不考虑异常和其它特殊情况）

1、数据在用户态的 buffer 中，调用 write 将数据传给内核

2、数据在 Page Cache 中，返回写入的字节数（成功返回）

3、内核将数据刷新到磁盘

### Page Cache 的异步刷新

1、脏页太多

2、脏页太久

```shell
sysctl -a | grep dirty
```

- **dirty_writeback_centisecs** 表示多久唤醒一次刷新脏页的后台线程。这里的500表示５秒唤醒一次。

-  **dirty_expire_centisecs** 表示脏数据多久会被刷新到磁盘上。这里的3000表示 30秒。

-  **dirty_background_ratio** 表示当脏页占总内存的的百分比超过这个值时，后台线程开始刷新脏页。这个值如果设置得太小，可能不能很好地利用内存加速文件操作。如果设置得太大，则会周期性地出现一个写 IO 的峰值。
-  **dirty_ratio** 当脏页占用的内存百分比超过此值时，内核会阻塞掉写操作，并开始刷新脏页。
-  **dirty_background_bytes**、**dirty_bytes**  是和 dirty_background_ratio、dirty_ratio 表示同样意义的不同单位的表示。两者不会同时生效。

### 详细的内存使用情况

#### pmap -d $pid

#### cat /proc/$pid/smaps
smaps的数据比较详细，可简单的归纳一下，归纳的命令如下：

cat /proc/$pid/smaps  | awk '/Size|Rss|Pss|Shared|Private|Referenced|Swap/{val_name=gensub(/([a-zA-Z_]*).*/,"\\1",1,$1); list[val_name]+=$2; }END{for(val in list)print val,list[val];}' 

#### cat /proc/$pid/maps

#### cat /proc/$pid/statm

```
第一列  size:任务虚拟地址空间大小
第二列  Resident：正在使用的物理内存大小
第三列  Shared：共享页数
第四列  Trs：程序所拥有的可执行虚拟内存大小
第五列  Lrs：被映像倒任务的虚拟内存空间的库的大小
第六列  Drs：程序数据段和用户态的栈的大小
第七列 dt：脏页数量
```

### 释放cache

```
free -m
sync
echo 1 > /proc/sys/vm/drop_caches 仅清除页面缓存（PageCache）
To free dentries and inodes:
echo 2 > /proc/sys/vm/drop_caches 清除目录项和inode
To free pagecache, dentries and inodes:
echo 3 > /proc/sys/vm/drop_caches 清除页面缓存，目录项和inode
As this is a non-destructive operation, and dirty objects are notfreeable, the user should run "sync" first in order to make sure allcached objects are freed
```

### free

```
free -m ：查看内存情况，单位为MB。
total 内存总数
used 已经使用的内存数（我的程序使用内存数量+系统缓存使用的内数量）
free 空闲的物理内存数（是真正的空闲，未被任何程序占用）
shared 多个进程共享的内存总额
buffers 磁盘缓存（Buffer Cache）的大小（可提高系统I/O调用的性能）
cached  磁盘缓存（Page Cache）的大小（可提高系统I/O调用的性能）
-buffers/cache 表示已被我们的程序使用的内存数，计算方法：used - buffers - cached
+buffers/cache 表示还可已被我使用的内存数，计算方法：free + buffers + cached
```

### ulimit

```
ulimit [-aHS][-c <core文件上限>][-d <数据节区大小>][-f <文件大小>][-m <内存大小>][-n <文件数目>][-p <缓冲区大小>][-s <堆叠大小>][-t <CPU时间>][-u <程序数目>][-v <虚拟内存大小>]
-a 　显示目前资源限制的设定。 
-c <core文件上限> 　设定core文件的最大值，单位为区块。 
-d <数据节区大小> 　程序数据节区的最大值，单位为KB。 
-f <文件大小> 　shell所能建立的最大文件，单位为区块。 
-H 　设定资源的硬性限制，也就是管理员所设下的限制。 
-m <内存大小> 　指定可使用内存的上限，单位为KB。 
-n <文件数目> 　指定同一时间最多可开启的文件数。 
-p <缓冲区大小> 　指定管道缓冲区的大小，单位512字节。 
-s <堆叠大小> 　指定堆叠的上限，单位为KB。 
-S 　设定资源的弹性限制。 
-t <CPU时间> 　指定CPU使用时间的上限，单位为秒。 
-u <程序数目> 　用户最多可开启的程序数目。 
-v <虚拟内存大小> 　指定可使用的虚拟内存上限，单位为KB。
```

### 性能工具

```
stress sysstat pstack pmap
```

#### pidstat

`主要用于监控全部或指定进程占用系统资源的情况`

```
pidstat -p ALL---------------------------显示所有的进程统计信息，包括idle进程。
pidstat -p ALL -t------------------------更加详细的显示了线程统计信息。
pidstat [option] interval [count]-----周期采样和采样次数
pidstat -p ALL -d
```

`pidstat -p ALL -t`

```
minflt/s: 每秒次缺页错误次数(minor page faults)，次缺页错误次数意即虚拟内存地址映射成物理内存地址产生的page fault次数。
majflt/s: 每秒主缺页错误次数(major page faults)，当虚拟内存地址映射成物理内存地址时，相应的page在swap中，这样的page fault为major page fault，一般在内存使用紧张时产生。
VSZ: 该进程使用的虚拟内存(以kB为单位)。
RSS: 该进程使用的物理内存(以kB为单位)。
%MEM: 该进程使用内存的百分比。
Command: 拉起进程对应的命令。
```

`pidstat -p ALL -d`

```
kB_rd/s: 每秒进程从磁盘读取的数据量(以kB为单位)。
kB_wr/s: 每秒进程向磁盘写的数据量(以kB为单位)。
kB_ccwr/s:每秒进程被取消向磁盘写的数据量(以kB为单位)。
Command: 拉起进程对应的命令。
```

/proc/meminfo vm.overcommit_memory

`vm.overcommit_memory`的用处: 控制过量分配的策略. 这个参数一共有3个可选值:

1.  `0`: Heuristic overcommit handling. 就是由操作系统自己决定过量分配策略
2.  `1`: Always overcommit. 一直允许过量分配
3.  `2`: Don't overcommit. 不允许过量分配

### 工具使用

#### strace

```
-f表示跟踪子进程和子线程，-T表示显示系统调用的时长，-tt表示显示跟踪时间
```

