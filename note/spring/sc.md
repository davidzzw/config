### Hystrix初始化

```java
EnableCircuitBreaker  -> EnableCircuitBreakerImportSelector
EnableCircuitBreakerImportSelector.selectImports 此方法会根据注解启动的注解（这里指@EnableCircuitBreaker）从spring.factories文件中获取其配置需要初始化@Configuration类
（这里是org.springframework.cloud.netflix.hystrix.HystrixCircuitBreakerConfiguration）
HystrixCircuitBreakerConfiguration -> HystrixCommandAspect  
HystrixCommandAspect -> HystrixCommand
```

```
ConfigFileApplicationListener
```

