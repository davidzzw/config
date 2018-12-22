###Spring 的 XML 扩展机制

使用 Spring 的 XML 扩展机制有以下几个步骤：

* 定义 Schema（编写 .xsd 文件）
* 定义 JavaBean
* 编写 NamespaceHandler 和 BeanDefinitionParser 完成 Schema 解析
* 编写 `spring.handlers`和 `spring.schemas` 文件串联解析部件
* 在 XML 文件中应用配置

`DubboNamespaceHandler 和 DubboBeanDefinitionParser `

