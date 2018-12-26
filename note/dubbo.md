### spi

`ExtensionLoader`

```
jdk的spi会在一次实例化所有实现，可能会比较耗时，而且有些可能用不到的实现类也会实例化，浪费资源而且没有选择。另外dubbo的spi增加了对扩展点IOC和AOP的支持，一个扩展点可以直接setter注入其他扩展点。这是jdk spi不支持的。
```
###Spring 的 XML 扩展机制

使用 Spring 的 XML 扩展机制有以下几个步骤：

* 定义 Schema（编写 .xsd 文件）
* 定义 JavaBean
* 编写 NamespaceHandler 和 BeanDefinitionParser 完成 Schema 解析
* 编写 `spring.handlers`和 `spring.schemas` 文件串联解析部件
* 在 XML 文件中应用配置

`DubboNamespaceHandler 和 DubboBeanDefinitionParser `

