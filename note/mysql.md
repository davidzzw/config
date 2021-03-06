### 数据库和实例

```
在 Unix 上，启动一个 MySQL 实例往往会产生两个进程，mysqld 就是真正的数据库服务守护进程，而 mysqld_safe 是一个用于检查和设置 mysqld 启动的控制程序，它负责监控 MySQL 进程的执行，当 mysqld 发生错误时，mysqld_safe 会对其状态进行检查并在合适的条件下重启。
```

### 数据的存储

```
在 InnoDB 存储引擎中，所有的数据都被逻辑地存放在表空间中，表空间（tablespace）是存储引擎中最高的存储逻辑单位，在表空间的下面又包括段（segment）、区（extent）、页（page）
```

### 架构

#### 分析器

#### 优化器

#### 执行器

####　存储引擎

#### myisam innodb区别



### WAL（write ahead log）

```
redo log 和 binlog 都是顺序写，磁盘的顺序写比随机写速度要快
组提交机制，可以大幅度降低磁盘的 IOPS 消耗
```

### 缓存

### 锁的种类



### 锁的算法

* `Record Lock`
* `Gap Lock` 
* `Next-Key Lock`

### 索引

#### 聚簇索引、非聚簇索引

- 聚簇索引：将数据存储与索引放到了一块，找到索引也就找到了数据
- 非聚簇索引：将数据存储于索引分开结构，索引结构的叶子节点指向了数据的对应行，myisam通过key_buffer把索引先缓存到内存中，当需要访问数据时（通过索引访问数据），在内存中直接搜索索引，然后通过索引找到磁盘相应数据，这也就是为什么索引不在key buffer命中时，速度慢的原因

澄清一个概念：innodb中，在聚簇索引之上创建的索引称之为辅助索引，辅助索引访问数据总是需要二次查找，非聚簇索引都是辅助索引，像复合索引、前缀索引、唯一索引，辅助索引叶子节点存储的不再是行的物理位置，而是主键值

##### 何时使用聚簇索引与非聚簇索引

![img](https:////upload-images.jianshu.io/upload_images/10154499-d53a5ce9cecf22f3.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/864/format/webp)

**聚簇索引具有唯一性**

由于聚簇索引是将数据跟索引结构放到一块，因此一个表仅有一个聚簇索引

**一个误区：把主键自动设为聚簇索引**

**聚簇索引默认是主键**，如果表中没有定义主键，InnoDB 会选择一个**唯一的非空索引**代替。如果没有这样的索引，InnoDB 会**隐式定义一个主键**来作为聚簇索引。InnoDB 只聚集在同一个页面中的记录。包含相邻健值的页面可能相距甚远。**如果你已经设置了主键为聚簇索引，必须先删除主键，然后添加我们想要的聚簇索引，最后恢复设置主键即可**。

此时其他索引只能被定义为非聚簇索引。这个是最大的误区。有的主键还是无意义的自动增量字段，那样的话Clustered index对效率的帮助，完全被浪费了。

刚才说到了，聚簇索引性能最好而且具有唯一性，所以非常珍贵，必须慎重设置。**一般要根据这个表最常用的SQL查询方式来进行选择，某个字段作为聚簇索引，或组合聚簇索引**，这个要看实际情况。

记住我们的**最终目的**就是**在相同结果集情况下，尽可能减少逻辑IO**。

**结合图再仔细点看**



![img](https:////upload-images.jianshu.io/upload_images/10154499-5244179cc19a1c21.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/164/format/webp)



![img](https:////upload-images.jianshu.io/upload_images/10154499-5772dddedb909374.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/633/format/webp)

1. InnoDB使用的是聚簇索引，将**主键组织到一棵B+树**中，而**行数据就储存在叶子节点**上，若使用"where id = 14"这样的条件查找主键，则**按照B+树的检索算法即可查找到对应的叶节点，之后获得行数据**。
2. 若**对Name列进行条件搜索，则需要两个步骤**：**第一步在辅助索引B+树中检索Name，到达其叶子节点获取对应的主键**。第二步**使用主键在主索引B+树种再执行一次B+树检索操作，最终到达叶子节点即可获取整行数据**。（**重点在于通过其他键需要建立辅助索引**）

MyISM使用的是非聚簇索引，**非聚簇索引的两棵B+树看上去没什么不同**，节点的结构完全一致只是存储的内容不同而已，主键索引B+树的节点存储了主键，辅助键索引B+树存储了辅助键。表数据存储在独立的地方，这两颗B+树的叶子节点都使用一个地址指向真正的表数据，对于表数据来说，这两个键没有任何差别。由于**索引树是独立的，通过辅助键检索无需访问主键的索引树**。

##### 聚簇索引的优势

看上去聚簇索引的效率明显要低于非聚簇索引，因为**每次使用辅助索引检索都要经过两次B+树查找**，这不是多此一举吗？聚簇索引的优势在哪？

1. 由于**行数据和叶子节点存储在一起，同一页中会有多条行数据，访问同一数据页不同行记录时，已经把页加载到了Buffer中，再次访问的时候，会在内存中完成访问**，不必访问磁盘。这样**主键和行数据是一起被载入内存的，找到叶子节点就可以立刻将行数据返回**了，**如果按照主键Id来组织数据，获得数据更快**。
2. **辅助索引使用主键作为"指针"而不是使用地址值作为指针的好处**是，**减少了当出现行移动或者数据页分裂时辅助索引的维护工作**，**使用主键值当作指针会让辅助索引占用更多的空间，换来的好处是InnoDB在移动行时无须更新辅助索引中的这个"指针"**。**也就是说行的位置（实现中通过16K的Page来定位）会随着数据库里数据的修改而发生变化（前面的B+树节点分裂以及Page的分裂），使用聚簇索引就可以保证不管这个主键B+树的节点如何变化，辅助索引树都不受影响**。
3. 聚簇索引适合用在排序的场合，非聚簇索引不适合
4. 取出一定范围数据的时候，使用用聚簇索引
5. 二级索引需要两次索引查找，而不是一次才能取到数据，因为存储引擎第一次需要通过二级索引找到索引的叶子节点，从而找到数据的主键，然后在聚簇索引中用主键再次查找索引，再找到数据
6. 可以把**相关数据保存在一起**。例如实现电子邮箱时，可以根据用户 ID 来聚集数据，这样只需要从磁盘读取少数的数据页就能获取某个用户的全部邮件。如果没有使用聚簇索引，则每封邮件都可能导致一次磁盘 I/O。

##### 聚簇索引的劣势

1.  **维护索引很昂贵，特别是插入新行或者主键被更新导至要分页(page split)的时候**。建议在大量插入新行后，选在负载较低的时间段，通过OPTIMIZE TABLE优化表，因为必须被移动的行数据可能造成碎片。使用独享表空间可以弱化碎片
2.  表因为使用UUId（随机ID）作为主键，使数据存储稀疏，这就会出现聚簇索引有可能有比全表扫面更慢，



![img](https:////upload-images.jianshu.io/upload_images/10154499-ee09c38aeb148cd0.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/728/format/webp)

所以建议使用int的auto_increment作为主键



![img](https:////upload-images.jianshu.io/upload_images/10154499-75ad3e0e24d55317.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/730/format/webp)

主键的值是顺序的，所以 InnoDB 把每一条记录都存储在上一条记录的后面。当达到页的最大填充因子时（InnoDB 默认的最大填充因子是页大小的 15/16，留出部分空间用于以后修改），下一条记录就会写入新的页中。一旦数据按照这种顺序的方式加载，主键页就会近似于被顺序的记录填满（二级索引页可能是不一样的）

1. 如果主键比较大的话，那辅助索引将会变的更大，因为**辅助索引的叶子存储的是主键值；过长的主键值，会导致非叶子节点占用占用更多的物理空间** 

##### 为什么主键通常建议使用自增id

**聚簇索引的数据的物理存放顺序与索引顺序是一致的**，即：**只要索引是相邻的，那么对应的数据一定也是相邻地存放在磁盘上的**。如果主键不是自增id，那么可以想 象，它会干些什么，不断地调整数据的物理地址、分页，当然也有其他一些措施来减少这些操作，但却无法彻底避免。但，如果是自增的，那就简单了，它只需要一 页一页地写，索引结构相对紧凑，磁盘碎片少，效率也高。

因为**MyISAM的主索引并非聚簇索引，那么他的数据的物理地址必然是凌乱的，拿到这些物理地址，按照合适的算法进行I/O读取，于是开始不停的寻道不停的旋转**。**聚簇索引则只需一次I/O**。（强烈的对比）

不过，如果**涉及到大数据量的排序、全表扫描、count之类的操作的话，还是MyISAM占优势些，因为索引所占空间小，这些操作是需要在内存中完成的**。

##### mysql中聚簇索引的设定

聚簇索引**默认是主键**，如果表中没有定义主键，InnoDB 会选择一个**唯一的非空索引**代替。如果没有这样的索引，InnoDB 会**隐式定义一个主键**来作为聚簇索引。**InnoDB 只聚集在同一个页面中的记录。包含相邻健值的页面可能相距甚远。**

#### B++树

#### 优化

##### 覆盖索引

##### 最左前缀原则

##### 索引下推优化

1、覆盖索引：如果查询条件使用的是普通索引（或是联合索引的最左原则字段），查询结果是联合索引的字段或是主键，不用回表操作，直接返回结果，减少IO磁盘读写读取正行数据
2、最左前缀：联合索引的最左 N 个字段，也可以是字符串索引的最左 M 个字符
3、联合索引：根据创建联合索引的顺序，以最左原则进行where检索，比如（age，name）以age=1 或 age= 1 and name=‘张三’可以使用索引，单以name=‘张三’ 不会使用索引，考虑到存储空间的问题，还请根据业务需求，将查找频繁的数据进行靠左创建索引。
4、索引下推：like 'hello%’and age >10 检索，MySQL5.6版本之前，会对匹配的数据进行回表查询。5.6版本后，会先过滤掉age<10的数据，再进行回表查询，减少回表率，提升检索速度

#### 重建索引

`alter table T engine=InnoDB `

自适应hash索引 AHI

用索引” 和 “用索引快速定位记录

#### 索引失效

##### 全索引扫描

**条件字段函数操作**

> 对索引字段做函数操作，可能会破坏索引值的有序性，因此优化器就决定放弃走树搜索功能

**隐式类型转换**

> 如果规则是“将字符串转成数字”，那么就是做数字比较，结果应该是 1
>
> 如果规则是“将数字转成字符串”，那么就是做字符串比较，结果应该是 0
>
> 在 MySQL 中，字符串和数字做比较的话，是将字符串转换成数字
>
> select * from tradelog where  CAST(tradid AS signed int) = traceid 
>
> select * from tradelog where id = CAST(83126 AS signed int)

**隐式字符编码转换**

> CONVERT() 函数，在这里的意思是把输入的字符串转成 utf8mb4 字符集

### 回表

`回到主键索引树搜索的过程`

#### change buffer

```
innodb_change_buffer_max_size
```


内存、redo log（ib_log_fileX）、 数据表空间（t.ibd）、系统表空间（ibdata1）

redo log 主要节省的是随机写磁盘的 IO 消耗（转成顺序写），而 change buffer 主要节省的是随机读磁盘的 IO 消耗。

是否使用唯一索引

* 首先，业务正确性优先。咱们这篇文章的前提是“业务代码已经保证不会写入重复数据”的情况下，讨论性能问题。如果业务不能保证，或者业务就是要求数据库来做约束，那么没得选，必须创建唯一索引。这种情况下，本篇文章的意义在于，如果碰上了大量插入数据慢、内存命中率低的时候，可以给你多提供一个排查思路

* 然后，在一些“归档库”的场景，你是可以考虑使用普通索引的。比如，线上数据只需要保留半年，然后历史数据保存在归档库。这时候，归档数据已经是确保没有唯一键冲突了。要提高归档效率，可以考虑把表里面的唯一索引改成普通索引
### 事务

#### innodb事务

MySQL会最大程度的使用缓存机制来提高数据库的访问效率，但是万一数据库发生断电，因为缓存的数据没有写入磁盘，导致缓存在内存中的数据丢失而导致数据不一致怎么办？

Innodb主要是通过事务日志实现ACID特性

事务日志包括：重做日志redo和回滚日志undo

Redo记录的是已经全部完成的事务，就是执行了commit的事务，记录文件是ib_logfile0 ib_logfile1

Undo记录的是已部分完成并且写入硬盘的未完成的事务，默认情况下回滚日志是记录下表空间中的（共享表空间或者独享表空间）

一般情况下，mysql在崩溃之后，重启服务，innodb通过回滚日志undo将所有已完成并写入磁盘的未完成事务进行rollback，然后redo中的事务全部重新执行一遍即可恢复数据，但是随着redo的量增加，每次从redo的第一条开始恢复就会浪费长的时间，所以引入了checkpoint机制

Dirty page：脏页 什么意思呢？

一般业务运行过程中，当业务需要对某张的某行数据进行修改的时候，innodb会先将该数据从磁盘读取到缓存中去，然后在缓存中对这条数据进行修改，这样缓存中的数据就和磁盘的数据不一致了，这个时候缓存中的数据就称为dirty page，只有当脏页统一刷新到磁盘中才会是clean page

Checkpoint：如果在某个时间点，脏页的数据被刷新到了磁盘，系统就把这个刷新的时间点记录到redo log的结尾位置，在进行恢复数据的时候，checkpoint时间点之前的数据就不需要进行恢复了，可以缩短时间

Innodb_log_buffer_size 重做日志缓存大小

Innodb_log_file_size redo log文件大小 文件越大 数据恢复的时间越长

Innodb_log_file_group redo log文件数量 默认是2个 ib_logfile0 ib_logfile1

#### 隔离级别

##### Read UnCommitted(读未提交)

最低的隔离级别。一个事务可以读取另一个事务并未提交的更新结果。

##### Read Committed(读提交)

大部分数据库采用的默认隔离级别。一个事务的更新操作结果只有在该事务提交之后，另一个事务才可以的读取到同一笔数据更新后的结果。

##### Repeatable Read(重复读)

**mysql的默认级别**。整个事务过程中，对同一笔数据的读取结果是相同的，不管其他事务是否在对共享数据进行更新，也不管更新提交与否。

##### Serializable(序列化)

#### 并发问题

##### 脏读

脏读发生在一个事务A读取了被另一个事务B修改，但是还未提交的数据。假如B回退，则事务A读取的是无效的数据。这跟不可重复读类似，但是第二个事务不需要执行提交。 

##### 不可重复读

在基于锁的并行控制方法中，如果在执行select时不添加读锁，就会发生不可重复读问题。

在多版本并行控制机制中，当一个遇到提交冲突的事务需要回退但却被释放时，会发生不可重复读问题。

有两个策略可以防止这个问题的发生：

(1) 推迟事务2的执行，直至事务1提交或者回退。这种策略在使用锁时应用。

(2) 而在多版本并行控制中，事务2可以被先提交。而事务1，继续执行在旧版本的数据上。当事务1终于尝试提交时，数据库会检验它的结果是否和事务1、事务2顺序执行时一样。如果是，则事务1提交成功。如果不是，事务1会被回退。

##### **幻读** 

幻读发生在当两个完全相同的查询执行时，第二次查询所返回的结果集跟第一个查询不相同。

发生的情况：没有范围锁

#### MySQL 是如何解决幻读的

##### 多版本并发控制（MVCC）（快照读）

多数数据库都实现了多版本并发控制，并且都是靠保存数据快照来实现的。

以 `InnoDB` 为例，每一行中都冗余了两个字断。一个是行的创建版本，一个是行的删除（过期）版本。版本号随着每次事务的开启自增。事务每次取数据的时候都会取创建版本小于当前事务版本的数据，以及过期版本大于当前版本的数据。

普通的 select 就是快照读。

**原理**：将历史数据存一份快照，所以其他事务增加与删除数据，对于当前事务来说是不可见的。

##### next-key 锁 （当前读）

next-key 锁包含两部分

- 记录锁（行锁）
- 间隙锁

记录锁是加在索引上的锁，间隙锁是加在索引之间的

**原理**：将当前数据行与上一条数据和下一条数据之间的间隙锁定，保证此范围内读取的数据是一致的。

```
Mysql官方给出的幻读解释是：只要在一个事务中，第二次select多出了row就算幻读。
a事务先select，b事务insert确实会加一个gap锁，但是如果b事务commit，这个gap锁就会释放（释放后a事务可以随意dml操作），a事务再select出来的结果在MVCC下还和第一次select一样，接着a事务不加条件地update，这个update会作用在所有行上（包括b事务新加的），a事务再次select就会出现b事务中的新行，并且这个新行已经被update修改了，实测在RR级别下确实如此。
如果这样理解的话，Mysql的RR级别确实防不住幻读
```

```
在快照读读情况下，mysql通过mvcc来避免幻读。
在当前读读情况下，mysql通过next-key来避免幻读。
select * from t where a=1;属于快照读
select * from t where a=1 lock in share mode;属于当前读
不能把快照读和当前读得到的结果不一样这种情况认为是幻读，这是两种不同的使用。所以我认为mysql的rr级别是解决了幻读的。
```

```
如引用一问题所说，T1 select 之后 update，会将 T2 中 insert 的数据一起更新，那么认为多出来一行，所以防不住幻读。看着说法无懈可击，但是其实是错误的，InnoDB 中设置了 快照读 和 当前读 两种模式，如果只有快照读，那么自然没有幻读问题，但是如果将语句提升到当前读，那么 T1 在 select 的时候需要用如下语法： select * from t for update (lock in share mode) 进入当前读，那么自然没有 T2 可以插入数据这一回事儿了。
```

#### 可重复读实现



read view

#### 两阶段提交

#### 长事务

避免长事务

### 锁

#### 间隙锁和行锁(next-key lock)

```
可重复读下生效
产生死锁
影响系统的并发度
```





#### 全局锁

`FTWRL（Flush tables with read lock）`

#### 表级别的锁

##### 表锁

`lock tables … read/write`

#####　元数据锁（meta data lock，MDL)

MDL 不需要显式使用，在访问一个表的时候会被自动加上。MDL 的作用是，保证读写的正确性。你可以想象一下，如果一个查询正在遍历一个表中的数据，而执行期间另一个线程对这个表结构做变更，删了一列，那么查询线程拿到的结果跟表结构对不上，肯定是不行的。

因此，在 MySQL 5.5 版本中引入了 MDL，当对一个表做增删改查操作的时候，加 MDL 读锁；当要对表做结构变更操作的时候，加 MDL 写锁。

* 读锁之间不互斥，因此你可以有多个线程同时对一张表增删改查。
* 读写锁之间、写锁之间是互斥的，用来保证变更表结构操作的安全性。因此，如果有两个线程要同时给一个表加字段，其中一个要等另一个执行完才能开始执行。

Online DDL的过程是这样的：
1. 拿MDL写锁
2. 降级成MDL读锁
3. 真正做DDL
4. 升级成MDL写锁
5. 释放MDL锁


#### 行锁

##### 两阶段锁协议

**在InnoDB事务中，行锁是在需要的时候才加上的，但并不是不需要了就立刻释放，而是要等到事务结束时才释放。这个就是两阶段锁协议**

如果你的事务中需要锁多个行，要把最可能造成锁冲突、最可能影响并发度的锁的申请时机尽量往后放。

#### 死锁和死锁检测

当出现死锁以后，有两种策略

- 一种策略是，直接进入等待，直到超时。这个超时时间可以通过参数innodb_lock_wait_timeout来设置。
- 另一种策略是，发起死锁检测，发现死锁后，主动回滚死锁链条中的某一个事务，让其他事务得以继续执行。将参数innodb_deadlock_detect设置为on，表示开启这个逻辑。

在InnoDB中，innodb_lock_wait_timeout的默认值是50s，意味着如果采用第一个策略，当出现死锁以后，第一个被锁住的线程要过50s才会超时退出，然后其他线程才有可能继续执行。对于在线服务来说，这个等待时间往往是无法接受的。

但是，我们又不可能直接把这个时间设置成一个很小的值，比如1s。这样当出现死锁的时候，确实很快就可以解开，但如果不是死锁，而是简单的锁等待呢？所以，超时时间设置太短的话，会出现很多误伤。

所以，正常情况下我们还是要采用第二种策略，即：主动死锁检测，而且innodb_deadlock_detect的默认值本身就是on。主动死锁检测在发生死锁的时候，是能够快速发现并进行处理的，但是它也是有额外负担的。

所以，正常情况下我们还是要采用第二种策略，即：主动死锁检测，而且innodb_deadlock_detect的默认值本身就是on。主动死锁检测在发生死锁的时候，是能够快速发现并进行处理的，但是它也是有额外负担的。

你可以想象一下这个过程：每当一个事务被锁的时候，就要看看它所依赖的线程有没有被别人锁住，如此循环，最后判断是否出现了循环等待，也就是死锁。

那如果是我们上面说到的所有事务都要更新同一行的场景呢？

每个新来的被堵住的线程，都要判断会不会由于自己的加入导致了死锁，这是一个时间复杂度是O(n)的操作。假设有1000个并发线程要同时更新同一行，那么死锁检测操作就是100万这个量级的。虽然最终检测的结果是没有死锁，但是这期间要消耗大量的CPU资源。因此，你就会看到CPU利用率很高，但是每秒却执行不了几个事务

**一种头痛医头的方法，就是如果你能确保这个业务一定不会出现死锁，可以临时把死锁检测关掉**

**另一个思路是控制并发度**

#### 检测死锁



#### 加锁规则

1. 原则 1：加锁的基本单位是 next-key lock。希望你还记得，next-key lock 是前开后闭区间。
2. 原则 2：查找过程中访问到的对象才会加锁。
3. 优化 1：索引上的等值查询，给唯一索引加锁的时候，next-key lock 退化为行锁。
4. 优化 2：索引上的等值查询，向右遍历时且最后一个值不满足等值条件的时候，next-key lock 退化为间隙锁。
5. 一个 bug：唯一索引上的范围查询会访问到不满足条件的第一个值为止


### mvcc

#### 备份

`mysqldump 使用参数single-transaction`

merge

purge

### mysql日志

* 重做日志（redo log）
* 回滚日志（undo log）
* 二进制日志（binlog）
* 错误日志（errorlog）
* 慢查询日志（slow query log）
* 一般查询日志（general log）
* 中继日志（relay log）

#### 1.二进制日志binlog

 主要记录MySQL数据库的变化，二进制日志以一种有效的格式，并且是事务安全的方式包含更新日志中可用的所有信息，二进制日志包含了所有更新了数据或者已经潜在更新了数据的语句，语句以“事件”的形式保存，描述数据更改。

二进制日志还包含关于每个更新数据库的语句的执行时间信息，不包含没有修改任何数据的语句，如果想要记录所有的语句，需要使用一般查询日志，使用二进制日志的**主要目的是最大可能的恢复数据库**，因为二进制日志包含备份后进行的所有更新。

binlog附加参数

max_binlog_size:

设置binlog的最大存储上线，当日志达到该日志的上限时，mysql会重新创建一个日志开始记录，不过偶尔也会超出该设置的binlog，一般都是因为即将达到上限时候，产生了一个比较大的事物，为了保证事物的安全，mysql不会将同一个事物分开记录到两个binlog

binlog-do-db=db_name:

明确告诉mysql，需要对某个数据库记录binlog，如果有了binlog-do-db=db_name  显示指定，mysql会忽略正对其他书库执行query，而仅仅记录只对指定数据库执行的query

binlog-ignore-db=db_name:

显示的指定忽略某个数据库的binlog记录。

 binlog-do-db 和binlog-ignore-db参数:

 有一个共同的概念，参数db_name 不是指query 语句更新的数据所在的数据库，而是执行query的时候，当前所处的数据库。不论更新哪个数据库的数据，mysql仅仅比较当前连接所处的数据库与参数设置的数据库名。而不会分析query语句所更新的数据库所在数据库。

binlog_cache_size :

当使用事务的存储引擎InnoDB时，所有未提交的事务会记录到一个缓存中，等待事务提交时，直接将缓冲中的二进制日志写入二进制日志文件，而该缓冲的大小由binlog_cache_size决定，默认大小为32KB，此外，binlog_cache_size是基于回话的，也就是，当一个线程开始一个事务时，mysql会自动分配一个大小为binlog_cache_size的缓存，因此该值得设置需要相当小心，可以通过show global status 查看binlog_cache_use、binlog_cache_disk_use的状态，可以判断当前binlog_cache_size的设置是否合适。

sync_binlog:

参数sync_binlog=[N]表示每写缓存多少次就同步到磁盘，如果将N设置为1，则表示采用同步写磁盘的方式来写二进制日志，该参数很重要，这个以后还会提到。值得注意的是，在将该参数设置为1时，也应该将innodb_support_xa设为1来解决，这可以确保二进制日志和InnoDB存储引擎数据文件的同步

expire_logs_days:

定义了MySQL清楚过期日志的时间

二进制日志的开启方式：

（1）指定日志路径

mysqld_safe --user=mysql --log-bin=[path] &
如果没有指定文件名 默认mysql-bin，默认路径为datadir目录

（2）编辑my.cnf
[mysqld]
log-bin=[path]

log-bin= /var/log/mysql/mysql-bin.log    --指定二进制日志的名称

log_bin_index= /var/log/mysql/mysql-bin.log.index     

--二进制日志索引的名称

relay_log= /var/log/mysql/mysql-bin.relay    ---中继日志的名称

relay_log_index= /var/log/mysql/mysql-bin.relay.index    

---中继日志索引的名称

二进制日志的查看方式：

show binary logs可以查看当前的二进制日志文件个数以及文件名

+-----------------+------------+

| Log_name        | File_size  |

+-----------------+------------+

| mysqlbin.000001 |      27365 |

| mysqlbin.000002 |    1029074 |

| mysqlbin.000003 |       3457 |

| mysqlbin.000004 |        126 |

| mysqlbin.000005 | 1074144657 |

| mysqlbin.000006 | 1074572441 

mysqlbinlog命令可以用来查看当前日志里面的内容

如果执行FLUSH LOGS，log-bin 会使用新的二进制日志编号

#### 2.通用查询日志general_log

通用查询日志记录在MySQL上执行过的SQL语句，包含查询语句与启动时间。建议不是在调试环境下不要开启查询日志，因为它会不断占据磁盘空间，并且产生大量的IO，一般是在**需要采样分析或者调试的时候才开启**。

通用日志的开启方法：

(1)执行命令开启：

set global general_log=1;//=0就是关闭通用查询日志

此时在默认在mysql的data目录中生成了localhost.log文件，该文件就是通用查询日志文件

（2）my.cnf中配置的方式，在my.cnf文件的[mysqld]下面任意一行增加或修改配置：

general_log-file[=path/[filename]]   //=后面都是可选的，即有默认的保存日志的文件

general_log=1     //表示开启通用查询日志

推荐使用第一种方式开启或关闭通用查询日志，因为my.cnf的修改要生效需要重启mysql服务，并且这种通用查询日志的开启不需要一直开启而是短时间开启就需要关闭，所以在   my.cnf关闭时又要重启mysql服务。

#### 3.错误日志err_log

错误日志文件包含了当mysqld启动和停止时，以及服务器在运行过程中发生严重错误时候的相关信息，在mysql中，错误日志非常有用，MySQL会将启动和停止数据库信息以及一些错误信息记录保存到错误日志文件中。

默认时错误日志的存放位置在数据目录中，名称为“server_name.err”
错误日志记录的事件：
a)、服务器启动关闭过程中的信息
b)、服务器运行过程中的错误信息
c)、事件调试器运行一个事件时间生的信息
d)、在从服务器上启动从服务器进程时产生的信息

查看与日志相关的变量：
mysql> SHOW GLOBAL VARIABLES LIKE '%log_error%';


my.cnf中错误日志开启：
log_error=/PATH/TO/ERROR_LOG_FILENAME
例如：log_error =  /mydata/data/hostname.err
定义错误日志文件。作用范围为全局或会话级别，可用于配置文件，属非动态变量。


log_warnings=#
设定是否将警告信息记录进错误日志。默认设定为1，表示启用；可以将其设置为0以禁用；而其值为大于1的数值时表示将新发起连接时产生的“失败的连接”和“拒绝访问”类的错误信息也记录进错误日志。

删除错误日志之后要想重建日志：

在运行状态下删除错误日志文件后，mysql并不会自动创建日志文件，flush logs在重建加载日志的时候，如果文件不存在，则会自动创建，所以在删除错误日志之后，如果需要重建日志文件，需要在服务端执行以下命令：

mysqladmin -uroot -p flush-logs

#### 4.慢查询日志log-slow-queries

慢查询日志是记录查询时长超过指定时间的日志，慢查询日志主要用来记录执行时间较长的查询语句，

mysql中慢查询日志默认是关闭的，

开启方法如下：

（1）可以通过配置文件my.cnf中的log-slow-queries选项打开，设定是否启用慢查询日志。0或OFF表示禁用，1或ON表示启用。日志信息的输出位置取决于log_output变量的定义，如果其值为NONE，则即便slow_query_log为ON，也不会记录任何慢查询信息。作用范围为全局级别，可用于选项文件，属动态变量。

（2）也可以在MySQL服务启动的时候使用--log-slow-queries[=file_name]启动慢查询日志

启动慢查询时，需要在my.cnf文件中配置long_query_time选项指定记录阈值，如果某条查询语句的查询时间超过了这个值，这个查询过程将被记录到慢查询日志文件中。

#### 5.事务日志

 Innodb主要是通过事务日志实现ACID特性

事务日志包括：重做日志redo和回滚日志undo

事务日志文件名为"ib_logfile0"和“ib_logfile1”，默认存放在表空间所在目录，它是用来记录数据库更新情况的文件，它可以记录针对数据库的任何操作，并将记录的结果保存到独立的文件中。对于每一次数据库更新的过程，事务日志文件都有非常全面的记录。根据这些记录可以恢复数据库更新前的状态。


与事务日志相关变量：
 innodb_log_group_home_dir=/PATH/TO/DIR：
 设定InnoDB重做日志文件的存储目录。在缺省使用InnoDB日志相关的所有变量时，其默认会在数据目录中创建两个大小为5MB的名为ib_logfile0和ib_logfile1的日志文件。作用范围为全局级别，可用于选项文件，属非动态变量。

innodb_log_file_size={108576 .. 4294967295}
设定日志组中每个日志文件的大小，单位是字节，默认值是5MB。较为明智的取值范围是从1MB到缓存池体积的1/n，其中n表示日志组中日志文件的个数。日志文件越大，在缓存池中需要执行的检查点刷写操作就越少，这意味着所需的I/O操作也就越少，然而这也会导致较慢的故障恢复速度。作用范围为全局级别，可用于选项文件，属非动态变量。

innodb_log_files_in_group={2 .. 100}
设定日志组中日志文件的个数。InnoDB以循环的方式使用这些日志文件。默认值为2。作用范围为全局级别，可用于选项文件，属非动态变量。

innodb_log_buffer_size={262144 .. 4294967295}
设定InnoDB用于辅助完成日志文件写操作的日志缓冲区大小，单位是字节，默认为8MB。较大的事务可以借助于更大的日志缓冲区来避免在事务完成之前将日志缓冲区的数据写入日志文件，以减少I/O操作进而提升系统性能。因此，在有着较大事务的应用场景中，建议为此变量设定一个更大的值。作用范围为全局级别，可用于选项文件，属非动态变量。

innodb_flush_log_at_trx_commit = 1  
\# 表示有事务提交后，不会让事务先写进buffer，再同步到事务日志文件，而是一旦有事务提交就立刻写进事务日志，并且还每隔1秒钟也会把buffer里的数据同步到文件，这样IO消耗大，默认值是"1"，可修改为“2”

innodb_locks_unsafe_for_binlog          OFF 
\#这个变量建议保持OFF状态，详细的原理不清楚

innodb_mirrored_log_groups = 1  
\#事务日志组保存的镜像数

#### 6.中继日志
在复制环境中产的的日志信息

与中继日志相关的变量：
log_slave_updates
用于设定复制场景中的从服务器是否将从主服务器收到的更新操作记录进本机的二进制日志中。本参数设定的生效需要在从服务器上启用二进制日志功能。

relay_log=file_name
设定中继日志的文件名称，默认为host_name-relay-bin。也可以使用绝对路径，以指定非数据目录来存储中继日志。作用范围为全局级别，可用于选项文件，属非动态变量。

relay_log_index=file_name
设定中继日志的索引文件名，默认为为数据目录中的host_name-relay-bin.index。作用范围为全局级别，可用于选项文件，属非动态变量。

relay-log-info-file=file_name
设定中继服务用于记录中继信息的文件，默认为数据目录中的relay-log.info。作用范围为全局级别，可用于选项文件，属非动态变量。
relay_log_purge={ON|OFF}
设定对不再需要的中继日志是否自动进行清理。默认值为ON。作用范围为全局级别，可用于选项文件，属动态变量。

relay_log_space_limit=#
设定用于存储所有中继日志文件的可用空间大小。默认为0，表示不限定。最大值取决于系统平台位数。作用范围为全局级别，可用于选项文件，属非动态变量。

max_relay_log_size={4096..1073741824}
设定从服务器上中继日志的体积上限，到达此限度时其会自动进行中继日志滚动。此参数值为0时，mysqld将使用max_binlog_size参数同时为二进制日志和中继日志设定日志文件体积上限。作用范围为全局级别，可用于配置文件，属动态变量。

### order by

sort buffer

归并排序

内存临时表

磁盘临时表

随机排序方法

### join

Index Nested-Loop Join(NLJ)
Block Nested-Loop Join(BNL) 

#### NLJ优化

#### Multi-Range Read优化

**MRR能够提升性能的核心**在于，这条查询语句在索引a上做的是一个范围查询（也就是说，这是一个多值查询），可以得到足够多的主键id。这样通过排序以后，再去主键索引查数据，才能体现出“顺序性”的优势

1. 根据索引a， 定位到满足条件的记录， 将id值放入read_rnd_buffer中;
2. 将read_rnd_buffer中的id进行递增排序；
3. 排序后的id数组， 依次到主键id索引中查记录， 并作为结果返回。
    select * from t1 where a>=1 and a<=100;
    这里， read_rnd_buffer的大小是由read_rnd_buffer_size参数控制的。 如果步骤1
    中， read_rnd_buffer放满了， 就会先执行完步骤2和3， 然后清空read_rnd_buffer。 之后继续找
    索引a的下个记录， 并继续循环 

另外需要说明的是， 如果你想要稳定地使用MRR优化的话， 需要设置set
optimizer_switch="mrr_cost_based=off"。 （官方文档的说法， 是现在的优化器策略， 判断消耗
的时候， 会更倾向于不使用MRR， 把mrr_cost_based设置为off， 就是固定使用MRR了。 ） 

##### Batched Key Access

set optimizer_switch='mrr=on,mrr_cost_based=off,batched_key_access=on' 

#### BNL算法的优化 

大表join操作虽然对IO有影响， 但是在语句执行结束后， 对IO的影响也就结束了。 但是，
对Buffer Pool的影响就是持续性的， 需要依靠后续的查询请求慢慢恢复内存命中率。 

为了减少这种影响， 你可以考虑增大join_buffer_size的值， 减少对被驱动表的扫描次数。
也就是说， BNL算法对系统的影响主要包括三个方面：

1. 可能会多次扫描被驱动表， 占用磁盘IO资源；
2. 判断join条件需要执行M*N次对比（M、 N分别是两张表的行数） ， 如果是大表就会占用非常
    多的CPU资源；
3. 可能会导致Buffer Pool的热数据被淘汰， 影响内存命中率。 

我们执行语句之前， 需要通过理论分析和查看explain结果的方式， 确认是否要使用BNL算法。 如
果确认优化器会使用BNL算法， 就需要做优化。 优化的常见做法是， 给被驱动表的join字段加上
索引， 把BNL算法转成BKA算法。 

##### BNL转BKA

一些情况下， 我们可以直接在被驱动表上建索引， 这时就可以直接转成BKA算法了。
但是， 有时候你确实会碰到一些不适合在被驱动表上建索引的情况。 比如下面这个语句： 

```
select * from t1 join t2 on (t1.b=t2.b) where t2.b>=1 and t2.b<=2000
```

##### 加索引

##### 临时表 

这时候， 我们可以考虑使用临时表。 使用临时表的大致思路是：

1. 把表t2中满足条件的数据放在临时表tmp_t中；

2. 为了让join使用BKA算法， 给临时表tmp_t的字段b加上索引；

3. 让表t1和tmp_t做join操作。
    此时， 对应的SQL语句的写法如下：

  ```
  create temporary table temp_t(id int primary key, a int, b int, index(b))engine=innodb;
  insert into temp_t select * from t2 where b>=1 and b<=2000;
  select * from t1 join temp_t on (t1.b=temp_t.b);
  ```

  可以看到， 整个过程3个语句执行时间的总和还不到1秒， 相比于前面的1分11秒， 性能得到了大
  幅提升。 接下来， 我们一起看一下这个过程的消耗：


1. 执行insert语句构造temp_t表并插入数据的过程中， 对表t2做了全表扫描， 这里扫描行数是
    100万。
    create temporary table temp_t(id int primary key, a int, b int, index(b))engine=innodb;
    insert into temp_t select * from t2 where b>=1 and b<=2000;
    select * from t1 join temp_t on (t1.b=temp_t.b); 
2. 之后的join语句， 扫描表t1， 这里的扫描行数是1000； join比较过程中， 做了1000次带索引
    的查询。 相比于优化前的join语句需要做10亿次条件判断来说， 这个优化效果还是很明显
    的。 

#### 扩展-hash join 

业务实现

1. select * from t1;取得表t1的全部1000行数据， 在业务端存入一个hash结构， 比如C++里的
    set、 PHP的dict这样的数据结构。
2. select * from t2 where b>=1 and b<=2000; 获取表t2中满足条件的2000行数据。
3. 把这2000行数据， 一行一行地取到业务端， 到hash结构的数据表中寻找匹配的数据。 满足
    匹配的条件的这行数据， 就作为结果集的一行。 

###group by

### 查询死锁

```
1.SELECT r.trx_id waiting_trx_id,r.trx_mysql_thread_id waiting_thread,r.trx_query wating_query,b.trx_id blocking_trx_id,b.trx_mysql_thread_id blocking_thread,b.trx_query blocking_query 
FROM information_schema.innodb_lock_waits w
INNER JOIN information_schema.innodb_trx b 
ON b.trx_id = w.blocking_trx_id         
INNER JOIN information_schema.innodb_trx r 
ON r.trx_id = w.requesting_trx_id;
2.show engine innodb status
```

### 查看系统变量

`SHOW VARIABLES [LIKE 匹配的模式]`

### 提高性能

#### 短连接风暴

**第一种方法：先处理掉那些占着连接但是不工作的线程。**

show processlist

kill connection + id 

**第二种方法：减少连接过程的消耗**

跳过权限验证的方法是：重启数据库，并使用–skip-grant-tables 参数启动。这样，整个 MySQL 会跳过所有的权限验证阶段，包括连接过程和语句执行过程在内

#### 慢查询性能问题

1. 索引没有设计好
2. SQL 语句没写好
3. MySQL 选错了索引

**导致慢查询的第一种可能是，索引没有设计好。**

这种场景一般就是通过紧急创建索引来解决。MySQL 5.6 版本以后，创建索引都支持 Online DDL 了，对于那种高峰期数据库已经被这个语句打挂了的情况，最高效的做法就是直接执行 alter table 语句。

比较理想的是能够在备库先执行。假设你现在的服务是一主一备，主库 A、备库 B，这个方案的大致流程是这样的：

1. 在备库 B 上执行 set sql_log_bin=off，也就是不写 binlog，然后执行 alter table 语句加上索引；
2. 执行主备切换；
3. 这时候主库是 B，备库是 A。在 A 上执行 set sql_log_bin=off，然后执行 alter table 语句加上索引。

这是一个“古老”的 DDL 方案。平时在做变更的时候，你应该考虑类似 gh-ost 这样的方案，更加稳妥。但是在需要紧急处理时，上面这个方案的效率是最高的。

**导致慢查询的第二种可能是，语句没写好**

MySQL 5.7 提供了 query_rewrite 功能，可以把输入的一种语句改写成另外一种模式

insert into query_rewrite.rewrite_rules(pattern, replacement, pattern_database) values ("select * from t where id + 1 = ?", "select * from t where id = ? - 1", "db1");

call query_rewrite.flush_rewrite_rules()

**MySQL 选错了索引**

force index

#### 预先发现问题

1. 上线前，在测试环境，把慢查询日志（slow log）打开，并且把 long_query_time 设置成 0，确保每个语句都会被记录入慢查询日志；
2. 在测试表里插入模拟线上的数据，做一遍回归测试；
3. 观察慢查询日志里每类语句的输出，特别留意 Rows_examined 字段是否与预期一致。（我们在前面文章中已经多次用到过 Rows_examined 方法了，相信你已经动手尝试过了。如果还有不明白的，欢迎给我留言，我们一起讨论）。

如果新增的 SQL 语句不多，手动跑一下就可以。而如果是新项目的话，或者是修改了原有项目的 表结构设计，全量回归测试都是必要的。这时候，你需要工具帮你检查所有的 SQL 语句的返回结果。比如，你可以使用开源工具 pt-query-digest(<https://www.percona.com/doc/percona-toolkit/3.0/pt-query-digest.html>)。

#### QPS 突增问题

1. 一种是由全新业务的 bug 导致的。假设你的 DB 运维是比较规范的，也就是说白名单是一个个加的。这种情况下，如果你能够确定业务方会下掉这个功能，只是时间上没那么快，那么就可以从数据库端直接把白名单去掉。
2. 如果这个新功能使用的是单独的数据库用户，可以用管理员账号把这个用户删掉，然后断开现有连接。这样，这个新功能的连接不成功，由它引发的 QPS 就会变成 0。
3. 如果这个新增的功能跟主体功能是部署在一起的，那么我们只能通过处理语句来限制。这时，我们可以使用上面提到的查询重写功能，把压力最大的 SQL 语句直接重写成"select 1"返回。

当然，这个操作的风险很高，需要你特别细致。它可能存在两个副作用：

1. 如果别的功能里面也用到了这个 SQL 语句模板，会有误伤；
2. 很多业务并不是靠这一个语句就能完成逻辑的，所以如果单独把这一个语句以 select 1 的结果返回的话，可能会导致后面的业务逻辑一起失败。

所以，方案 3 是用于止血的，跟前面提到的去掉权限验证一样，应该是你所有选项里优先级最低的一个方案。

同时你会发现，其实方案 1 和 2 都要依赖于规范的运维体系：虚拟化、白名单机制、业务账号分离。由此可见，更多的准备，往往意味着更稳定的系统

### 保证数据不丢

#### binlog

事务执行过程中，先把日志写到 binlog cache，事务提交的时候，再把 binlog cache 写到 binlog 文件中。

一个事务的 binlog 是不能被拆开的，因此不论这个事务多大，也要确保一次性写入。这就涉及到了 binlog cache 的保存问题。

系统给 binlog cache 分配了一片内存，每个线程一个，参数 binlog_cache_size 用于控制单个线程内 binlog cache 所占内存的大小。如果超过了这个参数规定的大小，就要暂存到磁盘。

事务提交的时候，执行器把 binlog cache 里的完整事务写入到 binlog 中，并清空 binlog cache

![img](https://static001.geekbang.org/resource/image/9e/3e/9ed86644d5f39efb0efec595abb92e3e.png)

可以看到，每个线程有自己 binlog cache，但是共用同一份 binlog 文件。

- 图中的 write，指的就是指把日志写入到文件系统的 page cache，并没有把数据持久化到磁盘，所以速度比较快。
- 图中的 fsync，才是将数据持久化到磁盘的操作。一般情况下，我们认为 fsync 才占磁盘的 IOPS。

write 和 fsync 的时机，是由参数 sync_binlog 控制的：

1. sync_binlog=0 的时候，表示每次提交事务都只 write，不 fsync；
2. sync_binlog=1 的时候，表示每次提交事务都会执行 fsync；
3. sync_binlog=N(N>1) 的时候，表示每次提交事务都 write，但累积 N 个事务后才 fsync。

因此，在出现 IO 瓶颈的场景里，将 sync_binlog 设置成一个比较大的值，可以提升性能。在实际的业务场景中，考虑到丢失日志量的可控性，一般不建议将这个参数设成 0，比较常见的是将其设置为 100~1000 中的某个数值。

但是，将 sync_binlog 设置为 N，对应的风险是：如果主机发生异常重启，会丢失最近 N 个事务的 binlog 日志。

#### redo log

redo log 可能存在的三种状态说起

![img](https://static001.geekbang.org/resource/image/9d/d4/9d057f61d3962407f413deebc80526d4.png)

这三种状态分别是：

1. 存在 redo log buffer 中，物理上是在 MySQL 进程内存中，就是图中的红色部分；
2. 写到磁盘 (write)，但是没有持久化（fsync)，物理上是在文件系统的 page cache 里面，也就是图中的黄色部分；
3. 持久化到磁盘，对应的是 hard disk，也就是图中的绿色部分。

日志写到 redo log buffer 是很快的，wirte 到 page cache 也差不多，但是持久化到磁盘的速度就慢多了。

为了控制 redo log 的写入策略，InnoDB 提供了 innodb_flush_log_at_trx_commit 参数，它有三种可能取值：

1. 设置为 0 的时候，表示每次事务提交时都只是把 redo log 留在 redo log buffer 中 ;
2. 设置为 1 的时候，表示每次事务提交时都将 redo log 直接持久化到磁盘；
3. 设置为 2 的时候，表示每次事务提交时都只是把 redo log 写到 page cache。

InnoDB 有一个后台线程，每隔 1 秒，就会把 redo log buffer 中的日志，调用 write 写到文件系统的 page cache，然后调用 fsync 持久化到磁盘。

注意，事务执行中间过程的 redo log 也是直接写在 redo log buffer 中的，这些 redo log 也会被后台线程一起持久化到磁盘。也就是说，一个没有提交的事务的 redo log，也是可能已经持久化到磁盘的。

实际上，除了后台线程每秒一次的轮询操作外，还有两种场景会让一个没有提交的事务的 redo log 写入到磁盘中。

1. **一种是，redo log buffer 占用的空间即将达到 innodb_log_buffer_size 一半的时候，后台线程会主动写盘。**注意，由于这个事务并没有提交，所以这个写盘动作只是 write，而没有调用 fsync，也就是只留在了文件系统的 page cache。
2. **另一种是，并行的事务提交的时候，顺带将这个事务的 redo log buffer 持久化到磁盘。**假设一个事务 A 执行到一半，已经写了一些 redo log 到 buffer 中，这时候有另外一个线程的事务 B 提交，如果 innodb_flush_log_at_trx_commit 设置的是 1，那么按照这个参数的逻辑，事务 B 要把 redo log buffer 里的日志全部持久化到磁盘。这时候，就会带上事务 A 在 redo log buffer 里的日志一起持久化到磁盘。

这里需要说明的是，我们介绍两阶段提交的时候说过，时序上 redo log 先 prepare， 再写 binlog，最后再把 redo log commit。

如果把 innodb_flush_log_at_trx_commit 设置成 1，那么 redo log 在 prepare 阶段就要持久化一次，因为有一个崩溃恢复逻辑是要依赖于 prepare 的 redo log，再加上 binlog 来恢复的。

每秒一次后台轮询刷盘，再加上崩溃恢复这个逻辑，InnoDB 就认为 redo log 在 commit 的时候就不需要 fsync 了，只会 write 到文件系统的 page cache 中就够了。

通常我们说 MySQL 的“双 1”配置，指的就是 sync_binlog 和 innodb_flush_log_at_trx_commit 都设置成 1。也就是说，一个事务完整提交前，需要等待两次刷盘，一次是 redo log（prepare 阶段），一次是 binlog。

这时候，你可能有一个疑问，这意味着我从 MySQL 看到的 TPS 是每秒两万的话，每秒就会写四万次磁盘。但是，我用工具测试出来，磁盘能力也就两万左右，怎么能实现两万的 TPS？

解释这个问题，就要用到组提交（group commit）机制了。

#### 组提交

这里，我需要先和你介绍日志逻辑序列号（log sequence number，LSN）的概念。LSN 是单调递增的，用来对应 redo log 的一个个写入点。每次写入长度为 length 的 redo log， LSN 的值就会加上 length。

LSN 也会写到 InnoDB 的数据页中，来确保数据页不会被多次执行重复的 redo log。关于 LSN 和 redo log、checkpoint 的关系，我会在后面的文章中详细展开。

如图 3 所示，是三个并发事务 (trx1, trx2, trx3) 在 prepare 阶段，都写完 redo log buffer，持久化到磁盘的过程，对应的 LSN 分别是 50、120 和 160。

![img](https://static001.geekbang.org/resource/image/93/cc/933fdc052c6339de2aa3bf3f65b188cc.png)

图 3 redo log 组提交

从图中可以看到，

1. trx1 是第一个到达的，会被选为这组的 leader；
2. 等 trx1 要开始写盘的时候，这个组里面已经有了三个事务，这时候 LSN 也变成了 160；
3. trx1 去写盘的时候，带的就是 LSN=160，因此等 trx1 返回时，所有 LSN 小于等于 160 的 redo log，都已经被持久化到磁盘；
4. 这时候 trx2 和 trx3 就可以直接返回了。

所以，一次组提交里面，组员越多，节约磁盘 IOPS 的效果越好。但如果只有单线程压测，那就只能老老实实地一个事务对应一次持久化操作了。

在并发更新场景下，第一个事务写完 redo log buffer 以后，接下来这个 fsync 越晚调用，组员可能越多，节约 IOPS 的效果就越好。

为了让一次 fsync 带的组员更多，MySQL 有一个很有趣的优化：拖时间。在介绍两阶段提交的时候，我曾经给你画了一个图，现在我把它截过来。

![img](https://static001.geekbang.org/resource/image/98/51/98b3b4ff7b36d6d72e38029b86870551.png)

图 4 两阶段提交

图中，我把“写 binlog”当成一个动作。但实际上，写 binlog 是分成两步的：

1. 先把 binlog 从 binlog cache 中写到磁盘上的 binlog 文件；
2. 调用 fsync 持久化。

MySQL 为了让组提交的效果更好，把 redo log 做 fsync 的时间拖到了步骤 1 之后。也就是说，上面的图变成了这样：

![img](https://static001.geekbang.org/resource/image/5a/28/5ae7d074c34bc5bd55c82781de670c28.png)

图 5 两阶段提交细化

这么一来，binlog 也可以组提交了。在执行图 5 中第 4 步把 binlog fsync 到磁盘时，如果有多个事务的 binlog 已经写完了，也是一起持久化的，这样也可以减少 IOPS 的消耗。

不过通常情况下第 3 步执行得会很快，所以 binlog 的 write 和 fsync 间的间隔时间短，导致能集合到一起持久化的 binlog 比较少，因此 binlog 的组提交的效果通常不如 redo log 的效果那么好。

如果你想提升 binlog 组提交的效果，可以通过设置 binlog_group_commit_sync_delay 和 binlog_group_commit_sync_no_delay_count 来实现。

1. binlog_group_commit_sync_delay 参数，表示延迟多少微秒后才调用 fsync;
2. binlog_group_commit_sync_no_delay_count 参数，表示累积多少次以后才调用 fsync。

这两个条件是或的关系，也就是说只要有一个满足条件就会调用 fsync。

所以，当 binlog_group_commit_sync_delay 设置为 0 的时候，binlog_group_commit_sync_no_delay_count 也无效了。

之前有同学在评论区问到，WAL 机制是减少磁盘写，可是每次提交事务都要写 redo log 和 binlog，这磁盘读写次数也没变少呀？

现在你就能理解了，WAL 机制主要得益于两个方面：

1. redo log 和 binlog 都是顺序写，磁盘的顺序写比随机写速度要快；
2. 组提交机制，可以大幅度降低磁盘的 IOPS 消耗。

分析到这里，我们再来回答这个问题：**如果你的 MySQL 现在出现了性能瓶颈，而且瓶颈在 IO 上，可以通过哪些方法来提升性能呢？**

针对这个问题，可以考虑以下三种方法：

1. 设置 binlog_group_commit_sync_delay 和 binlog_group_commit_sync_no_delay_count 参数，减少 binlog 的写盘次数。这个方法是基于“额外的故意等待”来实现的，因此可能会增加语句的响应时间，但没有丢失数据的风险。
2. 将 sync_binlog 设置为大于 1 的值（比较常见是 100~1000）。这样做的风险是，主机掉电时会丢 binlog 日志。
3. 将 innodb_flush_log_at_trx_commit 设置为 2。这样做的风险是，主机掉电的时候会丢数据。

我不建议你把 innodb_flush_log_at_trx_commit 设置成 0。因为把这个参数设置成 0，表示 redo log 只保存在内存中，这样的话 MySQL 本身异常重启也会丢数据，风险太大。而 redo log 写到文件系统的 page cache 的速度也是很快的，所以将这个参数设置成 2 跟设置成 0 其实性能差不多，但这样做 MySQL 异常重启时就不会丢数据了，相比之下风险会更小。

#### crash-safe

1. 如果客户端收到事务成功的消息，事务就一定持久化了；
2. 如果客户端收到事务失败（比如主键冲突、回滚等）的消息，事务就一定失败了；
3. 如果客户端收到“执行异常”的消息，应用需要重连后通过查询当前状态来继续后续的逻辑。此时数据库只需要保证内部（数据和日志之间，主库和备库之间）一致就可以了。

### 高可用

#### 主从复制

#### 主备延迟

主备切换可能是一个主动运维动作，比如软件升级、主库所在机器按计划下线等，也可能是被动操作，比如主库所在机器掉电。

接下来，我们先一起看看主动切换的场景。

在介绍主动切换流程的详细步骤之前，我要先跟你说明一个概念，即“同步延迟”。与数据同步有关的时间点主要包括以下三个：

1. 主库A执行完成一个事务，写入binlog，我们把这个时刻记为T1;
2. 之后传给备库B，我们把备库B接收完这个binlog的时刻记为T2;
3. 备库B执行完成这个事务，我们把这个时刻记为T3。

所谓主备延迟，就是同一个事务，在备库执行完成的时间和主库执行完成的时间之间的差值，也就是T3-T1。

你可以在备库上执行show slave status命令，它的返回结果里面会显示seconds_behind_master，用于表示当前备库延迟了多少秒。

seconds_behind_master的计算方法是这样的：

1. 每个事务的binlog 里面都有一个时间字段，用于记录主库上写入的时间；
2. 备库取出当前正在执行的事务的时间字段的值，计算它与当前系统时间的差值，得到seconds_behind_master。

可以看到，其实seconds_behind_master这个参数计算的就是T3-T1。所以，我们可以用seconds_behind_master来作为主备延迟的值，这个值的时间精度是秒。

如果主备库机器的系统时间设置不一致，会不会导致主备延迟的值不准？

其实不会的。因为，备库连接到主库的时候，会通过执行SELECT UNIX_TIMESTAMP()函数来获得当前主库的系统时间。如果这时候发现主库的系统时间与自己不一致，备库在执行seconds_behind_master计算的时候会自动扣掉这个差值。

需要说明的是，在网络正常的时候，日志从主库传给备库所需的时间是很短的，即T2-T1的值是非常小的。也就是说，网络正常情况下，主备延迟的主要来源是备库接收完binlog和执行完这个事务之间的时间差。

主备延迟最直接的表现是，备库消费中转日志（relay log）的速度，比主库生产binlog的速度要慢。

#### 主备延迟的来源

**首先，有些部署条件下，备库所在机器的性能要比主库所在的机器性能差。**

**第二种常见的可能了，即备库的压力大**

**这就是第三种可能了，即大事务。**

#### 可靠性优先策略

在图1的双M结构下，从状态1到状态2切换的详细过程是这样的：

1. 判断备库B现在的seconds_behind_master，如果小于某个值（比如5秒）继续下一步，否则持续重试这一步；
2. 把主库A改成只读状态，即把readonly设置为true；
3. 判断备库B的seconds_behind_master的值，直到这个值变成0为止；
4. 把备库B改成可读写状态，也就是把readonly 设置为false；
5. 把业务请求切到备库B。

这个切换流程，一般是由专门的HA系统来完成的，我们暂时称之为可靠性优先流程。

![img](https://static001.geekbang.org/resource/image/54/4a/54f4c7c31e6f0f807c2ab77f78c8844a.png)

图2 MySQL可靠性优先主备切换流程

备注：图中的SBM，是seconds_behind_master参数的简写。

可以看到，这个切换流程中是有不可用时间的。因为在步骤2之后，主库A和备库B都处于readonly状态，也就是说这时系统处于不可写状态，直到步骤5完成后才能恢复。

在这个不可用状态中，比较耗费时间的是步骤3，可能需要耗费好几秒的时间。这也是为什么需要在步骤1先做判断，确保seconds_behind_master的值足够小。

试想如果一开始主备延迟就长达30分钟，而不先做判断直接切换的话，系统的不可用时间就会长达30分钟，这种情况一般业务都是不可接受的。

当然，系统的不可用时间，是由这个数据可靠性优先的策略决定的。你也可以选择可用性优先的策略，来把这个不可用时间几乎降为0。

#### 可用性优先策略

如果我强行把步骤4、5调整到最开始执行，也就是说不等主备数据同步，直接把连接切到备库B，并且让备库B可以读写，那么系统几乎就没有不可用时间了。

我们把这个切换流程，暂时称作可用性优先流程。这个切换流程的代价，就是可能出现数据不一致的情况。

#### 造成主从延迟的情况

```
1.主库DML语句并发大,从库qps高
2.从库服务器配置差或者一台服务器上几台从库(资源竞争激烈,特别是io)
3.主库和从库的参数配置不一样
4.大事务(DDL,我觉得DDL也相当于一个大事务)
5.从库上在进行备份操作
6.表上无主键的情况(主库利用索引更改数据,备库回放只能用全表扫描,这种情况可以调整slave_rows_search_algorithms参数适当优化下)
7.设置的是延迟备库
8.备库空间不足的情况下
```

### 主备延迟

#### 解决方案

- 强制走主库方案
- sleep方案
- 判断主备无延迟方案
- 配合semi-sync方案
- 等主库位点方案
- 等GTID方案

#### 判断主备无延迟方案

**第一种确保主备无延迟的方法是，**每次从库执行查询请求前，先判断seconds_behind_master是否已经等于0。如果还不等于0 ，那就必须等到这个参数变为0才能执行查询请求。

seconds_behind_master的单位是秒，如果你觉得精度不够的话，还可以采用对比位点和GTID的方法来确保主备无延迟，也就是我们接下来要说的第二和第三种方法。

**第二种方法，**对比位点确保主备无延迟：

- Master_Log_File和Read_Master_Log_Pos，表示的是读到的主库的最新位点；
- Relay_Master_Log_File和Exec_Master_Log_Pos，表示的是备库执行的最新位点。

如果Master_Log_File和Relay_Master_Log_File、Read_Master_Log_Pos和Exec_Master_Log_Pos这两组值完全相同，就表示接收到的日志已经同步完成。

**第三种方法，**对比GTID集合确保主备无延迟：

- Auto_Position=1 ，表示这对主备关系使用了GTID协议。
- Retrieved_Gtid_Set，是备库收到的所有日志的GTID集合；
- Executed_Gtid_Set，是备库所有已经执行完成的GTID集合。

如果这两个集合相同，也表示备库接收到的日志都已经同步完成。

可见，对比位点和对比GTID这两种方法，都要比判断seconds_behind_master是否为0更准确。

我们现在一起来回顾下，一个事务的binlog在主备库之间的状态：

1. 主库执行完成，写入binlog，并反馈给客户端；
2. binlog被从主库发送给备库，备库收到；
3. 在备库执行binlog完成。

我们上面判断主备无延迟的逻辑，是“备库收到的日志都执行完成了”。但是，从binlog在主备之间状态的分析中，不难看出还有一部分日志，处于客户端已经收到提交确认，而备库还没收到日志的状态。

如图4所示就是这样的一个状态。

![img](https://static001.geekbang.org/resource/image/55/9e/557445207b57d6c0f2747509d7d6619e.png)

图4 备库还没收到trx3

这时，主库上执行完成了三个事务trx1、trx2和trx3，其中：

1. trx1和trx2已经传到从库，并且已经执行完成了；
2. trx3在主库执行完成，并且已经回复给客户端，但是还没有传到从库中。

如果这时候你在从库B上执行查询请求，按照我们上面的逻辑，从库认为已经没有同步延迟，但还是查不到trx3的。严格地说，就是出现了过期读。

那么，这个问题有没有办法解决呢？

#### 配合semi-sync

要解决这个问题，就要引入半同步复制，也就是semi-sync replication。

semi-sync做了这样的设计：

1. 事务提交的时候，主库把binlog发给从库；
2. 从库收到binlog以后，发回给主库一个ack，表示收到了；
3. 主库收到这个ack以后，才能给客户端返回“事务完成”的确认。

也就是说，如果启用了semi-sync，就表示所有给客户端发送过确认的事务，都确保了备库已经收到了这个日志。

在[第25篇文章](https://time.geekbang.org/column/article/76795)的评论区，有同学问到：如果主库掉电的时候，有些binlog还来不及发给从库，会不会导致系统数据丢失？

答案是，如果使用的是普通的异步复制模式，就可能会丢失，但semi-sync就可以解决这个问题。

这样，semi-sync配合前面关于位点的判断，就能够确定在从库上执行的查询请求，可以避免过期读。

但是，semi-sync+位点判断的方案，只对一主一备的场景是成立的。在一主多从场景中，主库只要等到一个从库的ack，就开始给客户端返回确认。这时，在从库上执行查询请求，就有两种情况：

1. 如果查询是落在这个响应了ack的从库上，是能够确保读到最新数据；
2. 但如果是查询落到其他从库上，它们可能还没有收到最新的日志，就会产生过期读的问题。

其实，判断同步位点的方案还有另外一个潜在的问题，即：如果在业务更新的高峰期，主库的位点或者GTID集合更新很快，那么上面的两个位点等值判断就会一直不成立，很可能出现从库上迟迟无法响应查询请求的情况。

实际上，回到我们最初的业务逻辑里，当发起一个查询请求以后，我们要得到准确的结果，其实并不需要等到“主备完全同步”。

为什么这么说呢？我们来看一下这个时序图。

![img](https://static001.geekbang.org/resource/image/9c/09/9cf54f3e91dc8f7b8947d7d8e384aa09.png)

图5 主备持续延迟一个事务

图5所示，就是等待位点方案的一个bad case。图中备库B下的虚线框，分别表示relaylog和binlog中的事务。可以看到，图5中从状态1 到状态4，一直处于延迟一个事务的状态。

备库B一直到状态4都和主库A存在延迟，如果用上面必须等到无延迟才能查询的方案，select语句直到状态4都不能被执行。

但是，其实客户端是在发完trx1更新后发起的select语句，我们只需要确保trx1已经执行完成就可以执行select语句了。也就是说，如果在状态3执行查询请求，得到的就是预期结果了。

到这里，我们小结一下，semi-sync配合判断主备无延迟的方案，存在两个问题：

1. 一主多从的时候，在某些从库执行查询请求会存在过期读的现象；
2. 在持续延迟的情况下，可能出现过度等待的问题。

接下来，我要和你介绍的等主库位点方案，就可以解决这两个问题。

#### 等主库位点方案

要理解等主库位点方案，我需要先和你介绍一条命令：

`select master_pos_wait(file, pos[, timeout])`

这条命令的逻辑如下：

1. 它是在从库执行的；
2. 参数file和pos指的是主库上的文件名和位置；
3. timeout可选，设置为正整数N表示这个函数最多等待N秒。

这个命令正常返回的结果是一个正整数M，表示从命令开始执行，到应用完file和pos表示的binlog位置，执行了多少事务。

当然，除了正常返回一个正整数M外，这条命令还会返回一些其他结果，包括：

1. 如果执行期间，备库同步线程发生异常，则返回NULL；
2. 如果等待超过N秒，就返回-1；
3. 如果刚开始执行的时候，就发现已经执行过这个位置了，则返回0。

对于图5中先执行trx1，再执行一个查询请求的逻辑，要保证能够查到正确的数据，我们可以使用这个逻辑：

1. trx1事务更新完成后，马上执行show master status得到当前主库执行到的File和Position；
2. 选定一个从库执行查询语句；
3. 在从库上执行select master_pos_wait(File, Position, 1)；
4. 如果返回值是>=0的正整数，则在这个从库执行查询语句；
5. 否则，到主库执行查询语句。

我把上面这个流程画出来。

![img](https://static001.geekbang.org/resource/image/b2/57/b20ae91ea46803df1b63ed683e1de357.png)

图6 master_pos_wait方案

这里我们假设，这条select查询最多在从库上等待1秒。那么，如果1秒内master_pos_wait返回一个大于等于0的整数，就确保了从库上执行的这个查询结果一定包含了trx1的数据。

步骤5到主库执行查询语句，是这类方案常用的退化机制。因为从库的延迟时间不可控，不能无限等待，所以如果等待超时，就应该放弃，然后到主库去查。

你可能会说，如果所有的从库都延迟超过1秒了，那查询压力不就都跑到主库上了吗？确实是这样。

但是，按照我们设定不允许过期读的要求，就只有两种选择，一种是超时放弃，一种是转到主库查询。具体怎么选择，就需要业务开发同学做好限流策略了。

#### GTID方案

如果你的数据库开启了GTID模式，对应的也有等待GTID的方案。

MySQL中同样提供了一个类似的命令：

`select wait_for_executed_gtid_set(gtid_set, 1);`

这条命令的逻辑是：

1. 等待，直到这个库执行的事务中包含传入的gtid_set，返回0；
2. 超时返回1。

在前面等位点的方案中，我们执行完事务后，还要主动去主库执行show master status。而MySQL 5.7.6版本开始，允许在执行完更新类事务后，把这个事务的GTID返回给客户端，这样等GTID的方案就可以减少一次查询。

这时，等GTID的执行流程就变成了：

1. trx1事务更新完成后，从返回包直接获取这个事务的GTID，记为gtid1；
2. 选定一个从库执行查询语句；
3. 在从库上执行 select wait_for_executed_gtid_set(gtid1, 1)；
4. 如果返回值是0，则在这个从库执行查询语句；
5. 否则，到主库执行查询语句。

跟等主库位点的方案一样，等待超时后是否直接到主库查询，需要业务开发同学来做限流考虑。

我把这个流程图画出来。

![img](https://static001.geekbang.org/resource/image/d5/39/d521de8017297aff59db2f68170ee739.png)

图7 wait_for_executed_gtid_set方案

在上面的第一步中，trx1事务更新完成后，从返回包直接获取这个事务的GTID。问题是，怎么能够让MySQL在执行事务后，返回包中带上GTID呢？

你只需要将参数session_track_gtids设置为OWN_GTID，然后通过API接口mysql_session_track_get_first从返回包解析出GTID的值即可。

在专栏的[第一篇文章](https://time.geekbang.org/column/article/68319)中，我介绍mysql_reset_connection的时候，评论区有同学留言问这类接口应该怎么使用。

这里我再回答一下。其实，MySQL并没有提供这类接口的SQL用法，是提供给程序的API(<https://dev.mysql.com/doc/refman/5.7/en/c-api-functions.html>)。

比如，为了让客户端在事务提交后，返回的GITD能够在客户端显示出来，我对MySQL客户端代码做了点修改，如下所示：

![img](https://static001.geekbang.org/resource/image/97/63/973bdd8741f830acebe005cbf37a7663.png)

图8 显示更新事务的GTID--代码

这样，就可以看到语句执行完成，显示出GITD的值。

![img](https://static001.geekbang.org/resource/image/25/fe/253106d31d9d97aaa2846b2015f593fe.png)

图9 显示更新事务的GTID--效果

当然了，这只是一个例子。你要使用这个方案的时候，还是应该在你的客户端代码中调用mysql_session_track_get_first这个函数。

### 备份恢复

```
show master status
show master logs
show binlog events in 'mysql-bin.000002';
```

```
mysqlbinlog --no-defaults mysql-bin.000002 --start-position="794" --stop-position="1055" | /usr/bin/mysql -uroot -p123456 test
```

mysqlbinlog常见的选项有以下几个：
--start-datetime：从二进制日志中读取指定等于时间戳或者晚于本地服务器的时间
--stop-datetime：从二进制日志中读取指定小于时间戳或者等于本地服务器的时间 取值和上述一样
--start-position：从二进制日志中读取指定position 事件位置作为开始。
--stop-position：从二进制日志中读取指定position 事件位置作为事件截至

### sql优化

- `避免使用 IN 和 NOT IN`

- > 经常变化的字段用varchar
  > 知道固定长度的用char
  > 尽量用varchar
  > 超过255字符的只能用varchar或者text
  > 能用varchar的地方不用text     　

### 例子

```
优化前
select id1 from test1
where id1 not in (select id2 from test2)
优化后
select id1 from test1
LEFT JOIN test2 ON id2 = id1
where id2 IS NULL
```

```
 where(条件查询)、having（筛选）、group by（分组）、order by（排序）、limit（限制结果数）
```
> 如果你用过5.1 甚至5.0， 在从现在的观点看，你会发现很多“匪夷所思”。还有：并行复制官方5.6才引入、MDL 5.5 才有、Innodb 自增主键持久化、多源复制、online DDL ... 

### 删除数据

### 数据据回环问题解决方案

#### 同步操作不生成binlog

#### 控制binlog同步方向

##### ROW模式下的SQL

##### 通过附加表

#####  通过GTID

* `show variables like "server_uuid"`:`查看uuid`
* `show global variables like "gtid_executed"`
* `show binlog events`

### 双M结构会出现循环复制

```
一种场景是，在一个主库更新事务后，用命令set global server_id=x修改了server_id。等日志再传回来的时候，发现server_id跟自己的server_id不同，就只能执行了。
另一种场景是，有三个节点的时候，如图7所示，trx1是在节点 B执行的，因此binlog上的server_id就是B，binlog传给节点 A，然后A和A’搭建了双M结构，就会出现循环复制。
```

这种三节点复制的场景，做数据库迁移的时候会出现。

如果出现了循环复制，可以在A或者A’上，执行如下命令：

```
stop slave；
CHANGE MASTER TO IGNORE_SERVER_IDS=(server_id_of_B);
start slave;
```

这样这个节点收到日志后就不会再执行。过一段时间后，再执行下面的命令把这个值改回来。

```
stop slave；
CHANGE MASTER TO IGNORE_SERVER_IDS=();
start slave;
```

连接池一般配置

```
初始连接数
最小连接数
最大连接池
最大空闲时间
最大空闲连接池
```

### 参数

### 查询语句

> show binary logs
>
> select * from information_schema.`PROCESSLIST` where info is not null ORDER BY time desc
>
> show variables like "gener%"
>
> set global general_log=on
>
> show 【session|global】 status
>
> show global status like 'connections'
>
> show session status like 'InnoDB_rows%'
>
> show global status like 'Slow_queries'
>
> show variables like 'log_%'; 

`show global variables like ‘gtid_purged’`:`得到主库已经删除的GTID集合`

查看binlog是否开启

`show variables like 'log_bin'`

设置binlog格式

查看binlog日志

`show binlog events`

### GTID

```
show global variables like 'gtid_mode';
set @@GLOBAL.GTID_MODE = OFF_PERMISSIVE;
```

生成一个新的binlog文件

flush logs

查看原有表字段 字符集

show full columns from tablename

修改表字符集

alter table tableName convert to character set utf8mb4



排查工具

```
hexdump 
```

