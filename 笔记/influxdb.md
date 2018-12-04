```
time： 由influxDB自动生成。记录着每条记录（Points）的生成时间。
field： 字段，各种记录的值。key-value的value为数值型。
tags: 需要被添加索引的key-value。一般经常被查询到的字段要设置为tag。

An InfluxDB measurement (foodships) is similar to an SQL database table.
InfluxDB tags ( park_id and planet) are like indexed columns in an SQL database.
InfluxDB fields (#_foodships) are like unindexed columns in an SQL database.
InfluxDB points (for example, 2015-04-16T12:00:00Z 5) are similar to SQL rows.
```

