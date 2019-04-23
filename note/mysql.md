连接池一般配置这几个值就好了
初始连接数
最小连接数
最大连接池
最大空闲时间
最大空闲连接池

### 数据库和实例

```
在 Unix 上，启动一个 MySQL 实例往往会产生两个进程，mysqld 就是真正的数据库服务守护进程，而 mysqld_safe 是一个用于检查和设置 mysqld 启动的控制程序，它负责监控 MySQL 进程的执行，当 mysqld 发生错误时，mysqld_safe 会对其状态进行检查并在合适的条件下重启。
```

### 数据的存储

```
在 InnoDB 存储引擎中，所有的数据都被逻辑地存放在表空间中，表空间（tablespace）是存储引擎中最高的存储逻辑单位，在表空间的下面又包括段（segment）、区（extent）、页（page）
```

### 锁的算法

```
Record Lock、Gap Lock 和 Next-Key Lock
```

### 事务



### mysql日志

* 重做日志（redo log）
* 回滚日志（undo log）
* 二进制日志（binlog）
* 错误日志（errorlog）
* 慢查询日志（slow query log）
* 一般查询日志（general log）
* 中继日志（relay log）

**1.二进制日志binlog**

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

 

**2.通用查询日志general_log**

通用查询日志记录在MySQL上执行过的SQL语句，包含查询语句与启动时间。建议不是在调试环境下不要开启查询日志，因为它会不断占据磁盘空间，并且产生大量的IO，一般是在**需要采样分析或者调试的时候才开启**。

通用日志的开启方法：

(1)执行命令开启：

set global general_log=1;//=0就是关闭通用查询日志

此时在默认在mysql的data目录中生成了localhost.log文件，该文件就是通用查询日志文件

（2）my.cnf中配置的方式，在my.cnf文件的[mysqld]下面任意一行增加或修改配置：

general_log-file[=path/[filename]]   //=后面都是可选的，即有默认的保存日志的文件

general_log=1     //表示开启通用查询日志

 

推荐使用第一种方式开启或关闭通用查询日志，因为my.cnf的修改要生效需要重启mysql服务，并且这种通用查询日志的开启不需要一直开启而是短时间开启就需要关闭，所以在   my.cnf关闭时又要重启mysql服务。

 

**3.错误日志err_log**

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

 

 

**4.慢查询日志log-slow-queries**

慢查询日志是记录查询时长超过指定时间的日志，慢查询日志主要用来记录执行时间较长的查询语句，

mysql中慢查询日志默认是关闭的，

开启方法如下：

（1）可以通过配置文件my.cnf中的log-slow-queries选项打开，设定是否启用慢查询日志。0或OFF表示禁用，1或ON表示启用。日志信息的输出位置取决于log_output变量的定义，如果其值为NONE，则即便slow_query_log为ON，也不会记录任何慢查询信息。作用范围为全局级别，可用于选项文件，属动态变量。

（2）也可以在MySQL服务启动的时候使用--log-slow-queries[=file_name]启动慢查询日志

启动慢查询时，需要在my.cnf文件中配置long_query_time选项指定记录阈值，如果某条查询语句的查询时间超过了这个值，这个查询过程将被记录到慢查询日志文件中。

 

**5.事务日志**

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

**6.中继日志**
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

#### 查询死锁

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
### innodb事务

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