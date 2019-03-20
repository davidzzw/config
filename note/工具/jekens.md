#!/bin/bash 
#copy file and restart tomcat 

export JAVA_HOME=/usr/local/workdir/jdk1.8.0_131
export CATALINA_HOME=/root/tomcat
export CATALINA_BASE=/root/tomcat
export BUILD_ID=dontKillMe

tomcat_path=/root/tomcat
project=springsession
war_name=springsession.war 
war_path=http://192.168.220.131/:8080/jenkins/job/springsession/ws/targetserver_port=8088
file_path=~/.jenkins/jobs/workspace/springsession/target

$tomcat_path/bin/shutdown.sh 

sleep 3s 

echo "rm -rf ${tomcat_path}/webapps/ROOT/*"

rm -rf ${tomcat_path}/webapps/ROOT/*

cd $file_path

cp ${war_name} ${tomcat_path}/webapps/ROOT/

cd $tomcat_path/webapps/ROOT/

unzip ${war_name}

rm -rf ${war_name}

sleep 5s 

#$tomcat_path/bin/startup.sh

cd $tomcat_path/bin/
./startup.sh

echo "server restarted"