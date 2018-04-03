#### 参数解析

```
两个接口分别对应请求方法参数的处理、响应返回值的处理，分别是HandlerMethodArgumentResolver和HandlerMethodReturnValueHandler
首先被DispatcherServlet截获，DispatcherServlet通过handlerMapping获得HandlerExecutionChain，然后获得HandlerAdapter。

HandlerAdapter在内部对于每个请求，都会实例化一个ServletInvocableHandlerMethod进行处理，ServletInvocableHandlerMethod在进行处理的时候，会分两部分别对请求跟响应进行处理。
之后HandlerAdapter得到ModelAndView，然后做相应的处理。

ServletInvocableHandlerMethod
HandlerMethodArgumentResolverComposite

@ResponseBody注解的话最终返回值会被RequestResponseBodyMethodProcessor这个HandlerMethodReturnValueHandler实现类处理。
```



```
1. RequestParamMethodArgumentResolver

 支持带有@RequestParam注解的参数或带有MultipartFile类型的参数

2. RequestParamMapMethodArgumentResolver

  支持带有@RequestParam注解的参数 && @RequestParam注解的属性value存在 && 参数类型是实现Map接口的属性

3. PathVariableMethodArgumentResolver

支持带有@PathVariable注解的参数 且如果参数实现了Map接口，@PathVariable注解需带有value属性

4. MatrixVariableMethodArgumentResolver

支持带有@MatrixVariable注解的参数 且如果参数实现了Map接口，@MatrixVariable注解需带有value属性 

5. RequestResponseBodyMethodProcessor

 本文已分析过

6. ServletRequestMethodArgumentResolver

 参数类型是实现或继承或是WebRequest、ServletRequest、MultipartRequest、HttpSession、Principal、Locale、TimeZone、InputStream、Reader、HttpMethod这些类。

（这就是为何我们在Controller中的方法里添加一个HttpServletRequest参数，Spring会为我们自动获得HttpServletRequest对象的原因）

7. ServletResponseMethodArgumentResolver

 参数类型是实现或继承或是ServletResponse、OutputStream、Writer这些类

8. RedirectAttributesMethodArgumentResolver

 参数是实现了RedirectAttributes接口的类

9. HttpEntityMethodProcessor

 参数类型是HttpEntity
```



```
从名字我们也看的出来， 以Resolver结尾的是实现了HandlerMethodArgumentResolver接口的类，以Processor结尾的是实现了HandlerMethodArgumentResolver和HandlerMethodReturnValueHandler的类。

下面来我们来看看常用的HandlerMethodReturnValueHandler实现类。

1. ModelAndViewMethodReturnValueHandler

返回值类型是ModelAndView或其子类

2. ModelMethodProcessor

返回值类型是Model或其子类

3. ViewMethodReturnValueHandler

返回值类型是View或其子类 

4. HttpHeadersReturnValueHandler

返回值类型是HttpHeaders或其子类  

5. ModelAttributeMethodProcessor

返回值有@ModelAttribute注解

6. ViewNameMethodReturnValueHandler

返回值是void或String
```

#### convert

```
ByteArrayHttpMessageConverter: 负责读取二进制格式的数据和写出二进制格式的数据；

StringHttpMessageConverter：   负责读取字符串格式的数据和写出二进制格式的数据；

ResourceHttpMessageConverter：负责读取资源文件和写出资源文件数据； 

FormHttpMessageConverter：       负责读取form提交的数据（能读取的数据格式为 application/x-www-form-urlencoded，不能读取multipart/form-data格式数据）；负责写入application/x-www-from-urlencoded和multipart/form-data格式的数据；

MappingJacksonHttpMessageConverter:  负责读取和写入json格式的数据；

SouceHttpMessageConverter：           负责读取和写入 xml 中javax.xml.transform.Source定义的数据；

Jaxb2RootElementHttpMessageConverter:  负责读取和写入xml 标签格式的数据；

AtomFeedHttpMessageConverter:              负责读取和写入Atom格式的数据；

RssChannelHttpMessageConverter:           负责读取和写入RSS格式的数据；

当使用@RequestBody和@ResponseBody注解时，RequestMappingHandlerAdapter就使用它们来进行读取或者写入相应格式的数据。
```

