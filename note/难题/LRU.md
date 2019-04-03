### redis实现

Redis采用了一个近似的做法，就是随机取出若干个key，然后按照访问时间排序后，淘汰掉最不经常使用的

Redis支持和LRU相关淘汰策略包括，

volatile-lru设置了过期时间的key参与近似的lru淘汰策略

allkeys-lru所有的key均参与近似的lru淘汰策略