#### 数据库和实例

```
在 Unix 上，启动一个 MySQL 实例往往会产生两个进程，mysqld 就是真正的数据库服务守护进程，而 mysqld_safe 是一个用于检查和设置 mysqld 启动的控制程序，它负责监控 MySQL 进程的执行，当 mysqld 发生错误时，mysqld_safe 会对其状态进行检查并在合适的条件下重启。
```

#### 数据的存储

```
在 InnoDB 存储引擎中，所有的数据都被逻辑地存放在表空间中，表空间（tablespace）是存储引擎中最高的存储逻辑单位，在表空间的下面又包括段（segment）、区（extent）、页（page）
```

#### 锁的算法

```
Record Lock、Gap Lock 和 Next-Key Lock
```

alter table test change id  id int AUTO_INCREMENT;

MaperScannerConfigurer 属性不支持使用了 PropertyPlaceholderConfigurer 的属 性替换,因为会在 Spring 其中之前来它加载。
但是,你可以使用 PropertiesFactoryBean 和 SpEL 表达式来作为替代。

alter table t1 add column addr varchar(20) not null;

连接池一般配置这几个值就好了
初始连接数
最小连接数
最大连接池
最大空闲时间
最大空闲连接池

### mysql日志

* 重做日志（redo log）
* 回滚日志（undo log）
* 二进制日志（binlog）
* 错误日志（errorlog）
* 慢查询日志（slow query log）
* 一般查询日志（general log）
* 中继日志（relay log）

####查询死锁

```
1.SELECT     r.trx_id waiting_trx_id,     r.trx_mysql_thread_id waiting_thread,     r.trx_query wating_query,     b.trx_id blocking_trx_id,     b.trx_mysql_thread_id blocking_thread,     b.trx_query blocking_query 
FROM     information_schema.innodb_lock_waits w
INNER JOIN     information_schema.innodb_trx b 
ON b.trx_id = w.blocking_trx_id         
INNER JOIN   information_schema.innodb_trx r 
ON r.trx_id = w.requesting_trx_id;
2.show engine innodb status
```

```
SHOW VARIABLES [LIKE 匹配的模式];
```

```
经常变化的字段用varchar
知道固定长度的用char
尽量用varchar
超过255字符的只能用varchar或者text
能用varchar的地方不用text     　　　　　　
```

```
mvn mybatis-generator:generate
```

### 优化

- `避免使用 IN 和 NOT IN`

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
###innodb事务

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