#!/bin/sh  

## java env  
export JAVA_HOME=/opt/app/jdk1.8.0_121
export JRE_HOME=$JAVA_HOME/jre  

## service name  
APP_NAME=trace-spark-handle

SERVICE_DIR=/root/trace-spark
SERVICE_NAME=$APP_NAME
JAR_NAME=$SERVICE_NAME\.jar
PID=$SERVICE_NAME\.pid

cd $SERVICE_DIR  

case "$1" in  

    start)  
        nohup $JRE_HOME/bin/java -Xmn256m -Xms1024m -Xmx1024m -Duser.timezone=Asia/shanghai -Djava.rmi.server.useCodebaseOnly=true -XX:+DisableExplicitGC -XX:+UseParNewGC -XX:+UseConcMarkSweepGC -XX:+UseFastAccessorMethods -XX:+UseCMSCompactAtFullCollection -XX:CMSFullGCsBeforeCompaction=5 -XX:+CMSParallelRemarkEnabled -XX:CMSInitiatingOccupancyFraction=60  -XX:SoftRefLRUPolicyMSPerMB=0 -XX:+CMSPermGenSweepingEnabled  -XX:+CMSClassUnloadingEnabled -XX:SurvivorRatio=7 -XX:MaxTenuringThreshold=8 -XX:-UseBiasedLocking -XX:-UseAdaptiveSizePolicy -Djava.awt.headless=true -Duser.timezone=Asia/shanghai -Xdebug -Xrunjdwp:server=y,transport=dt_socket,address=8003,suspend=n -jar $JAR_NAME >$SERVICE_DIR/$SERVICE_NAME\.log &  
        echo $! > $SERVICE_DIR/$PID  
        echo "=== start $SERVICE_NAME"  
        ;;  
      
    stop)  
        kill `cat $SERVICE_DIR/$PID`  
        rm -rf $SERVICE_DIR/$PID  
        echo "=== stop $SERVICE_NAME"  
      
        sleep 5  
        P_ID=`ps -ef | grep -w "$SERVICE_NAME" | grep -v "grep" | awk '{print $2}'`  
        if [ "$P_ID" == "" ]; then  
            echo "=== $SERVICE_NAME process not exists or stop success"  
        else  
            echo "=== $SERVICE_NAME process pid is:$P_ID"  
            echo "=== begin kill $SERVICE_NAME process, pid is:$P_ID"  
            kill -9 $P_ID  
        fi  
        ;;  
      
    restart)  
        $0 stop  
        sleep 2  
        $0 start  
        echo "=== restart $SERVICE_NAME"  
        ;;  
      
    *)  
        ## restart  
        $0 stop  
        sleep 2  
        $0 start  
        ;;  

esac  
exit 0
