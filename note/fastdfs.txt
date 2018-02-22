命令上传文件
/usr/bin/fdfs_upload_file  /etc/fdfs/client.conf  /opt/BLIZZARD.jpg

maven打包fastdfs
mvn install:install-file -DgroupId=org.csource -DartifactId=fastdfs-client-java -Dversion=${version} 
-Dpackaging=jar -Dfile=fastdfs-client-java-${version}.jar

mvn install:install-file -DgroupId=org.csource
-DartifactId=fastdfs-client-java -Dversion=${version} 
-Dpackaging=jar 