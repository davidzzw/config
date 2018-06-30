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

* `避免使用 IN 和 NOT IN`

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

