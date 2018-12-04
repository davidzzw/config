```
nohup spark-submit  --master yarn-cluster  --driver-memory 2g  --executor-memory 2g  --executor-cores 2  --class Main trace-test.jar --files /data1/conf/log4j.properties --conf spark.executor.extraJavaOptions="-Dlog4j.configuration=log4j.properties" &

nohup spark-submit  --master yarn-cluster  --driver-memory 2g  --executor-memory 2g  --executor-cores 2  --class Main --driver-java-options "-Dlog4j.configuration=file:/root/log4j.properties " --conf spark.executor.extraJavaOptions="-Dlog4j.configuration=file:/root/log4j.properties" trace-test.jar &


nohup park-submit --class Main --master yarn --deploy-mode cluster --driver-cores 2 --driver-memory 2g--num-executors 2 --executor-cores 2 --executor-memory 2 --driver-java-options "-Dlog4j.configuration=log4j-driver.properties" --conf spark.executor.extraJavaOptions="-Dlog4j.configuration=log4j-executor.roperties" --files /root/log4j.properties trace-test.jar 
yarn application -kill id
```

