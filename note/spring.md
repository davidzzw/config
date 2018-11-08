#### Spring默认配置文件

```
spring.handlers
```



###注入和装配

```
 依赖注入的本质就是装配，装配是依赖注入的具体行为
 装配分为四种：byName, byType, constructor, autodetect。byName就是会将与属性的名字一样的bean进行装配。byType就是将同属性一样类型的bean进行装配。constructor就是通过构造器来将类型与参数相同的bean进行装配。autodetect是constructor与byType的组合，会先进行constructor，如果不成功，再进行byType
 创建应用对象之间协作关系的行为称为装配。也就是说当一个对象的属性是另一个对象时，实例化时，需要为这个对象属性进行实例化。这就是装配
```

###获取ApplicationContexts

```
方法一：在初始化时保存ApplicationContext对象
方法二：通过Spring提供的工具类获取ApplicationContext对象 WebApplicationContextUtils
方法三：继承自抽象类ApplicationObjectSupport
方法四：继承自抽象类WebApplicationObjectSupport
方法五：实现接口ApplicationContextAware

方法一：在初始化时保存ApplicationContext对象 
方法二：通过Spring提供的utils类获取ApplicationContext对象 
方法三：继承自抽象类ApplicationObjectSupport 
方法四：继承自抽象类WebApplicationObjectSupport 
方法五：实现接口ApplicationContextAware 
方法六：通过Spring提供的ContextLoader
```

	DefaultBeanDefinitionDocumentReader ->preProcessXml(root)
							            ->postProcessXml(root)

子类实现DefaultBeanDefinitionDocumentReader 实现2个接口 模板方法

	HandlerExecutionChain -> applyPreHandle()
	DispatcherServlet -> if (!mappedHandler.applyPreHandle(processedRequest, response)) {
	    return;
	}

BootstrapApplicationListener	
ParentContextApplicationContextInitializer			
ManagementContextResolver	
AutowiredAnnotationBeanPostProcessor
ContextLoader.properties -> org.springframework.web.context.support.XmlWebApplicationContext

springApplication可以读取不同种类的源文件：

类- java类由AnnotatedBeanDefinitionReader加载。
Resource - xml资源文件由XmlBeanDefinitionReader读取, 或者groovy脚本由GroovyBeanDefinitionReader读取
Package - java包文件由ClassPathBeanDefinitionScanner扫描读取。
CharSequence - 字符序列可以是类名、资源文件、包名，根据不同方式加载。如果一个字符序列不可以解析程序到类，也不可以解析到资源文件，那么就认为它是一个包。

```
DefaultResourceLoader
ResourcePatternResolver 
SpringServletContainerInitializer
```

### springmvc初始化

```
SpringServletContainerInitializer -> ServletContainerInitializer
AbstractContextLoaderInitializer -> WebApplicationInitializer
AbstractDispatcherServletInitializer -> AbstractContextLoaderInitializer
```

### Spring Context解析

```java
AbstractApplicationContext -> invokeBeanFactoryPostProcessors
PostProcessorRegistrationDelegate -> invokeBeanFactoryPostProcessors
ConfigurationClassPostProcessor -> postProcessBeanFactory -> processConfigBeanDefinitions
ConfigurationClassParser -> parse -> processDeferredImportSelectors
```

####容器扩展功能

```
AbstractApplicationContext -> refresh
ConfigurableListableBeanFactory beanFactory = obtainFreshBeanFactory()
prepareBeanFactory(beanFactory) 对BeanFactory进行各种功能进行填充，@Qualifier和@Autowired这一步增加支持
QualifierAnnotationAutowireCandidateResolver -> 解析Qualifier
SimpleAutowireCandidateResolver -> 采用autowireByType注入
CustomEditorConfigurer
```

### spring bean加载

```
转换对应beanName
尝试从缓存中加载单例
bean的实例化
原型模式的依赖检查
检测parentBeanFactory
将存储XML配置文件的GenericBeanDefinition转换为RootBeanDefinition
寻找依赖
针对不同的scope进行bean的创建
类型转换
```

####缓存中获取bean

![spring](C:\Users\Administrator\Desktop\spring.png)

```
AbstractBeanFactory -> getObjectForBeanInstance:检测当前bean是否是FactoryBean类型的bean，如果是，那么调用该bean对应的FactoryBean实例中的getObject()作为返回值
1对FactoryBean正确性的验证
2对非FactoryBean不做任何处理
3对bean进行转换
4将从Factory中解析bean的工作委托给getObjectFromFactoryBean
```

#### BeanPostProcessor

```
Object postProcessBeforeInitialization(Object bean, String beanName) throws BeansException;
Object postProcessAfterInitialization(Object bean, String beanName) throws BeansException;
```

#### 实例化的前置处理

```
AbstractAutowireCapableBeanFactory -> applyBeanPostProcessorsAfterInitialization
InstantiationAwareBeanPostProcessor -> postProcessBeforeInstantiation
BeanPostProcessor -> postProcessAfterInitialization
```

##### 实例化前的后处理器应用

```
bean的实例化前调用，也就是降AbstractBeanDefinition转换为BeanWrapper前的处理。给子类一个修改BeanDefinition的机会
```

##### 实例化后的后处理器应用

##### 循环依赖

1构造器循环依赖

2setter循环依赖

##### 创建bean

```
1)如果是单例则需要首先清楚缓存
2）实例化bean，将BeanDefinition转换为BeanWrapper
3）MergedBeanDefinitionPostProcessor的应用
bean合并后的处理，Autowired注解正是通过此方法实现诸如类型的预解析
4）依赖处理
5）属性填充
6）循环依赖检查
7）注册DisposableBean
8)完成创建并返回
```

![QQ截图20180226011141](C:\Users\Administrator\Desktop\QQ截图20180226011141.png)

###### 实例化策略

````
SimpleInstantiationStrategy -> instantiate
CglibSubclassingInstantiationStrategy -> instantiateWithMethodInjection
````

###### 属性注入

* ```autowireByName```
* ```autowireByType```


#####初始化bean

```
AbstractAutowireCapableBeanFactory -> initializeBean
invokeAwareMethods:对特殊的bean处理：Aware、BeanClassLoaderAware、BeanFactoryAware
applyBeanPostProcessorsBeforeInitialization:应用后处理器
invokeInitMethods：激活用户自定义的init方法
applyBeanPostProcessorsAfterInitialization：后处理器应用
```

######激活自定义init方法

```
先执行afterPropertiesSet，init-method后执行
```

##### 注册DisposableBean

也可以注册后处理器`DestructionAwareBeanPostProcessor`统一处理bean的销毁方法

```
AbstractBeanFactory -> registerDisposableBeanIfNecessary
```

#####各注解对应的BeanPostProcessor

```
Autowired -> AutowiredAnnotationBeanPostProcessor
Required -> RequiredAnnotationBeanPostProcessor
Resource、PostConstruct、PreDestroy -> CommonAnnotationBeanPostProcessor
PersistenceContext -> PersistenceAnnotationBeanPostProcessor

使用<context:annotation- config/>隐式地向 Spring容器注册AutowiredAnnotationBeanPostProcessor、RequiredAnnotationBeanPostProcessor、CommonAnnotationBeanPostProcessor以及PersistenceAnnotationBeanPostProcessor这4个BeanPostProcessor
```

#####context:component-scan源码分析

```
<context:component-scan> 
DefaultBeanDefinitionDocumentReader这个类，doRegisterBeanDefinitions这个方法实现解析配置文件的Bean，这边已经读取进来形成Document 形式存储，然后开始解析Bean,是由BeanDefinitionParserDelegate类实现的，BeanDefinitionParserDelegate完成具体Bean的解析（例如：bean标签、import标签等）

NamespaceHandler和BeanDefinitionParser -> ComponentScanBeanDefinitionParser ->解析<context:component-scan>标签
 -> ComponentScanBeanDefinitionParser.doScan
 ClassPathBeanDefinitionScanner -> 由这个类来实现扫描包下的class和jar文件并把注解的Bean包装成BeanDefinition
 
 进行扫描注解并包装成BeanDefinition是ComponentScanBeanDefinitionParser由父类ClassPathScanningCandidateComponentProvider的方法findCandidateComponents实现的
 
 怎么根据packageSearchPath获取包对应下的class路径，是通过PathMatchingResourcePatternResolver类，findAllClassPathResources(locationPattern.substring(CLASSPATH_ALL_URL_PREFIX.length()));获取配置包下的class路径并封装成Resource，实现也是getClassLoader().getResources(path)
 
 isCandidateComponent实现的标签是里配置的<context:exclude-filter>指定的不扫描包，<context:exclude-filter>指定的扫描包的过滤
```

######ClassPathBeanDefinitionScanner

```
ClassPathBeanDefinitionScanner->doScan
AnnotationBeanNameGenerator->generateBeanName
```



##### mvc:annotation-driven

```
AnnotationDrivenBeanDefinitionParser

会自动注册DefaultAnnotationHandlerMapping与AnnotationMethodHandlerAdapter 
3.1以上
 DefaultAnnotationHandlerMapping -> RequestMappingHandlerMapping 
  AnnotationMethodHandlerAdapter -> RequestMappingHandlerAdapter 
  AnnotationMethodHandlerExceptionResolver -> ExceptionHandlerExceptionResolver 
```

 

###AOP

* 连接点（Joinpoint）
* 切点（Pointcut）
* 增强（Advice）
* 目标对象（Target）
* 引入（Introduction）:引入是一种特殊的增强，它为类添加一些属性和方法。
* 织入（Weaving）:将增强添加到目标类的具体连接点上的过程
* 切面（Aspect）:切面由切点和增强（引入）组成，它既包括横切逻辑的定义，也包括连接点的定义

####增强（AOP联盟）

```
前置增强：BeforeAdvice
后置增强：AfterReturningAdvice
环绕增强：MethodInterceptor
异常抛出增强：ThrowsAdvice
引介增强：IntroductionInterceptor 必须cglib
```

```
ProxyFactory
AopProxyFactory -> JdkDynamicAopProxy
                -> CglibAopProxy
ProxyFactoryBean                
```

#### ProxyFactoryBean

```
target:代理的目标对象
proxyInterfaces:针对jdk动态代理，目标类所实现的接口
proxyTargetClass：是否对类进行代理（而不是对接口进行代理）。true，使用CGLIB动态代理
interceptorNames：需要织入目标对象的Bean列表，采用Bean的名称指定
optimize：当设置为true时，强制使用CGLIB动态代理
```

####切面

```
Pointcut
ClassFilter:定位到特定类上
MethodMatcher：定位到特定方法上
```

####匹配器

* 静态方法匹配器
* 动态方法匹配器

```
静态方法切点：StaticMethodMatcherPointcut
动态方法切点：DynamicMethodMatcherPointcut
注解切点：AnnotationMatchingPointcut
表达式切点：ExpressionPointcut
流程切点：ControlFlowPointcut
复合切点：ComposablePointcut
```

#### 切点

* `StaticMethodMatcherPointcut`:静态方法切点
* `DynamicMethodMatcherPointcut`:动态方法切点
* `AnnotationMatchingPointcut`:注解切点
* `ExpressionPointcut`:表达式切点
* `ControlFlowPointcut`:流程切点
* `ComposablePointcut`:复合切点

####切面

#####类型

```
一般切面：Advisor
切点切面：PointcutAdvisor
引介切面：IntroductionAdvisor
```

##### PointcutAdvisor

* `DefaultPointcutAdvisor`:最常用的切面类型
* `NameMatchMethodPointcut`:通过该类可以按方法名定义切点的切面
* `RegexpMethodPointcutAdvisor`:通过按正则表达式匹配方法名进行切点定义的切面，可以通过扩展该实现类进行操作
* `StaticMethodMatcherPointcut`:静态方法匹配切点的切面，默认情况下匹配所有的目标类
* `AspectJExpressionPointcutAdvisor`:用于AspectJ切点表达式定义切点的切面
* `AspectJPointcutAdvisor`:用于AspectJ语法定义切点的切面

#####引介切面

```
IntroductionAdvisor
DeclareParentsAdvisor AspectJ语言的DeclareParent注解标识的切面
DefaultIntroductionAdvisor
```

#### 自动创建

* `BeanNameAutoProxyCreator`:基于Bean配置名规则的自动代理创建器
* `DefaultAdvisorAutoProxyCreator`:基于Advisor匹配机制的自动代理创建器
* `AnnotationAwareAspectJAutoProxyCreator`:基于Bean中Aspect注解标签的自动代理创建器

![自动代理2](D:\config\pic\自动代理2.png)

```
1 BeanFactory与应用上下文（ApplicationContext）区别

2 ContextLoaderListener和ContextLoaderServlet启动WebApplicationContext的servlet和Web容器监听器
```

