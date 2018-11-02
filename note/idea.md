###快捷键

* `快速找到Controller方法`:`ctrl+alt+shift+n`
* `Ctrl+Shift+Alt+J`:`批量修改变量快捷键`
* `Ctrl+Alt+Shift+T`:`弹出重构菜单`
* `Shift+F6`：`重命名类文件`
* `ctr+shift+u`：`小写转大写`
* `Ctrl + G`:` 跳到指定行`

###idea参数优化

```
-Xms1024m
-Xmx1024m
-Xmn372m
-XX:MetaspaceSize=256m
-XX:MaxMetaspaceSize=512m
-XX:ReservedCodeCacheSize=240m
-XX:+UseConcMarkSweepGC
-XX:+UseParNewGC
-XX:+CMSParallelRemarkEnabled
-XX:+CMSScavengeBeforeRemark
-XX:CMSInitiatingOccupancyFraction=75
-XX:+UseCMSInitiatingOccupancyOnly
-XX:+UseCMSCompactAtFullCollection
-XX:CMSFullGCsBeforeCompaction=3
-XX:SoftRefLRUPolicyMSPerMB=50
-XX:+HeapDumpOnOutOfMemoryError
-XX:CICompilerCount=2 
-XX:InitialHeapSize=31457280
-XX:+ManagementServer 
-XX:MaxHeapSize=480247808 
-XX:MaxNewSize=160038912
-XX:MinHeapDeltaBytes=196608 
-XX:NewSize=10485760 
-XX:OldSize=20971520 
-XX:+UseCompressedClassPointers 
-XX:+UseCompressedOops 
-XX:+UseFastUnorderedTimeStamps 
CATALINA_OPTS="$CATALINA_OPTS 
-Dcom.sun.management.jmxremote
-Djava.rmi.server.hostname=192.168.220.131 
-Dcom.sun.management.jmxremote.port=8999 
-Dcom.sun.management.jmxremote.ssl=false 
-Dcom.sun.management.jmxremote.authenticate=false"
MaxMetaspaceSize
CompressedClassSpaceSize
Klass Metaspace
NoKlass Metaspace
-XX:CompressedClassSpaceSize
UseLargePagesInMetaspace
InitialBootClassLoaderMetaspaceSize
MetaspaceSize
MaxMetaspaceSize
CompressedClassSpaceSize
MinMetaspaceExpansion
MaxMetaspaceExpansion
MinMetaspaceFreeRatio
MaxMetaspaceFreeRatio
```

