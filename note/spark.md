```
nohup spark-submit  --master yarn-cluster  --driver-memory 2g  --executor-memory 2g  --executor-cores 2  --class Main trace-test.jar --files /data1/conf/log4j.properties --conf spark.executor.extraJavaOptions="-Dlog4j.configuration=log4j.properties" &
yarn application -kill id
```

