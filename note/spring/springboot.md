
    2.0.0M7
    management:
      endpoints:
    web:
      expose: '*'
      exclude: env
    management.add-application-context-header = false
    spring.mvc.formcontent.putfilter.enabled = false
    mvn spring-boot:run -Dspring.cloud.bootstrap.enabled=false
    mvn clean package  -Dmaven.test.skip=true

### 配置文件

```
SpringApplication  将从以下位置加载 application.properties  文件，并把
它们添加到Spring  Environment  中：
1. 当前目录下的 /config  子目录。
2. 当前目录。
3. classpath下的 /config  包。
4. classpath根路径（root）。
   该列表是按优先级排序的（列表中位置高的路径下定义的属性将覆盖位置低的）。
```

### 异常处理

```
DefaultErrorAttributes，只负责把异常记录在Request attributes中，
name是org.springframework.boot.autoconfigure.web.DefaultErrorAttributes.ERROR
ExceptionHandlerExceptionResolver，根据@ExceptionHandler resolve
ResponseStatusExceptionResolver，根据@ResponseStatus resolve
DefaultHandlerExceptionResolver，负责处理Spring MVC标准异常
```

```java
spring.autoconfigure.exclude = org.springframework.boot.autoconfigure.admin.SpringApplicationAdminJmxAutoConfiguration,\
org.springframework.boot.autoconfigure.jmx.JmxAutoConfiguration,\
org.springframework.boot.autoconfigure.gson.GsonAutoConfiguration,\
org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration,\
org.springframework.boot.autoconfigure.jdbc.XADataSourceAutoConfiguration,\
org.springframework.boot.autoconfigure.jdbc.JndiDataSourceAutoConfiguration,\
org.springframework.boot.autoconfigure.transaction.jta.JtaAutoConfiguration,\
org.springframework.boot.autoconfigure.websocket.WebSocketAutoConfiguration,\
org.springframework.boot.autoconfigure.websocket.WebSocketMessagingAutoConfiguration,\
org.springframework.boot.autoconfigure.freemarker.FreeMarkerAutoConfiguration,\
org.springframework.boot.autoconfigure.groovy.template.GroovyTemplateAutoConfiguration,\
org.springframework.boot.autoconfigure.mustache.MustacheAutoConfiguration,\
org.springframework.boot.autoconfigure.mail.MailSenderAutoConfiguration,\
org.springframework.boot.autoconfigure.mail.MailSenderValidatorAutoConfiguration,\
org.springframework.boot.actuate.autoconfigure.TraceRepositoryAutoConfiguration,\
org.springframework.boot.actuate.autoconfigure.TraceWebFilterAutoConfiguration,\
org.springframework.boot.actuate.autoconfigure.MetricFilterAutoConfiguration
```

# spring-boot-loader

```
JarLauncher -> LaunchedURLClassLoader
WarLauncher
PropertiesLauncher
```



### Spring Boot配置文件加载

```
ConfigFileApplicationListener
BootstrapApplicationListener
```

####@Condition相关注解 

```
@ConditionalOnBean（仅仅在当前上下文中存在某个对象时，才会实例化一个Bean）
@ConditionalOnClass（某个class位于类路径上，才会实例化一个Bean）
@ConditionalOnExpression（当表达式为true的时候，才会实例化一个Bean）
@ConditionalOnMissingBean（仅仅在当前上下文中不存在某个对象时，才会实例化一个Bean）
@ConditionalOnMissingClass（某个class类路径上不存在的时候，才会实例化一个Bean）
@ConditionalOnNotWebApplication（不是web应用）
```

### 日志

```
LoggingApplicationListener -> initializeSystem
```



#### logback

