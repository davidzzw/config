### hash

```redis
hmset user:1000 username antirez birthyear 1977 verified 1
hget user:1000 username
hmget user:1000 username birthyear no-such-field
hincrby user:1000 birthyear 10
```

### zset

#### 添加数据

```
zadd myzset 1 "a"
zadd myzset 2 "b"
zadd myzset 3 "c"
zadd myzset 4 "d"
zadd myzset 5 "e"
zadd myzset 6 "f"
```

#### 排序

```
zrange myzset 0 -1
zrevrange myzset 0 -1
zrange myzset 0 -1 withscores
zrangebyscore myzset -inf 5
```

#### 删除数据

```
zremrangebyscore myzset 4 6
```

#### 判断key是否存在

```
zrank myzset "a"
如果成员在有序集合存在，返回整数：成员的权重。
如果成员在有序集合不存在或键不存在，字符串返回nil。
```

