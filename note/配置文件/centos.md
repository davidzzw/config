centos安装jdk
rpm -qa | grep jdk
rpm -ivh 
taskkill -f -t -im
GRANT ALL PRIVILEGES ON *.* TO 'zzw'@'%' IDENTIFIED BY '123456' WITH GRANT OPTION;
grant all on xxxx.* to 'root'@'%' identified by 'password' with grant option;

-A INPUT -p tcp -m state --state NEW -m tcp --dport 3306 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 8080 -j ACCEPT

lsof -i tcp:80
netstat -tln
netstat -lnp|grep 88  
netstat -nap 

nohup python api.py & 

列出所有端口
netstat -ntlp


free -m | grep cache: | awk '{print $4}'
随手写的，不一定能用

for jar in $(ls /lib/*.jar)
do
   lib=$lib:$jar
done
类似这样的，手机写的不一定 100% 准确，可以参考

比如，有一个目录下每天会生成一个备份目录，但是我们并不需要这么多，只需要保存最新的 10 个目录就好了，这样的话 awk 就能派上用场了

ls -lt | grep drwx | awk '{if(NR>10){print $9}}' | xargs -I {} rm -rf {}