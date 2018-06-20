#!/bin/sh  

## java env  
#export JAVA_HOME="/usr/lib/java/jdk1.8.0_121"
#export JRE_HOME="${JAVA_HOME}/jre  
export JAVA_HOME="/usr/lib/java/jdk1.8.0_121/"
export PATH="$PATH:$JAVA_HOME/bin:$JAVA_HOME/jre/bin:"          
export CLASS_PATH="$CLASSPATH:$JAVA_HOME/lib:$JAVA_HOME/jre/lib"

## service name  
SERVICE_NAME=trace-message
# APP PATH
SERVICE_PATH="/opt/trace-message/"
JAR_NAME=${SERVICE_NAME}.jar
PID=${SERVICE_NAME}.pid

#cd $SERVICE_PATH  
if [ $# -eq 0 ]; then 
    echo $"Usage: $0 {start|stop|restart}"
    exit 0
fi
case "$1" in  
    start)  
	cd ${SERVICE_PATH}
        nohup java -Xmn256m -Xms1024m -Xmx1024m  \
			-Djava.rmi.server.useCodebaseOnly=true \
			-XX:+DisableExplicitGC \
			-XX:+UseParNewGC \
			-XX:+UseConcMarkSweepGC \
			-XX:+UseFastAccessorMethods \
			-XX:+UseCMSCompactAtFullCollection \
			-XX:CMSFullGCsBeforeCompaction=5 \
			-XX:+CMSParallelRemarkEnabled \
			-XX:CMSInitiatingOccupancyFraction=60  \
			-XX:SoftRefLRUPolicyMSPerMB=0 \
			-XX:+CMSPermGenSweepingEnabled  \
			-XX:+CMSClassUnloadingEnabled \
			-XX:SurvivorRatio=7 \
			-XX:MaxTenuringThreshold=8 \
			-XX:-UseBiasedLocking \
			-XX:-UseAdaptiveSizePolicy \
			-Djava.awt.headless=true \
			-Duser.timezone=Asia/shanghai \
			-jar $JAR_NAME >$SERVICE_PATH/$SERVICE_NAME\.log --spring.profiles.active=prod 2>&1 > /dev/null &  
			#-Xdebug -Xrunjdwp:server=y,transport=dt_socket,address=8005,suspend=n \
        echo $! > $SERVICE_PATH/$PID  
        echo "=== start $SERVICE_NAME"  
        ;;  
      
    stop)  
        kill `cat $SERVICE_PATH/$PID`  
        rm -rf $SERVICE_PATH/$PID  
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
