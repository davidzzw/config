### spi

`ExtensionLoader`

```
jdk的spi会在一次实例化所有实现，可能会比较耗时，而且有些可能用不到的实现类也会实例化，浪费资源而且没有选择。另外dubbo的spi增加了对扩展点IOC和AOP的支持，一个扩展点可以直接setter注入其他扩展点。这是jdk spi不支持的。
```

