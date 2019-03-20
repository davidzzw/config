Deploying From Source Control

直接使用 git 部署 webapp:
ansible webservers -m git -a "repo=git://foo.example.org/repo.git dest=/srv/myapp version=HEAD"

ansible-playbook -i deploy/hosts deploy/deploy.yml --extra-vars="hosts=tds-dev"

tar -zcvf ROOT.tar.gz /trendystack_web/target/ROOT  --exclude=/trendystack_web/target/ROOT/WEB-INF/classes/config.properties --exclude=/trendystack_web/target/ROOT/WEB-INF/classes/redis.properties --exclude=/trendystack_web/target/ROOT/WEB-INF/classes/email.properties --exclude=/trendystack_web/target/ROOT/WEB-INF/classes/log4j.properties

tar -zcvf ROOT.tar.gz ./ --exclude=./WEB-INF/classes/config.properties --exclude=./WEB-INF/classes/redis.properties --exclude=./WEB-INF/classes/email.properties --exclude=./WEB-INF/classes/log4j.properties
 
ansible文件传输方式 p2p
异常处理
文件服务器
机器数量的问题

NFS
中间调度
异步

tds

python murder_make_torrent.py /home/ftpuser/CentOS-7-x86_64-DVD-1511.iso 172.20.7.24:8998 deploy.torrent

ansible 172.20.7.24 -m synchronize -a "mode=pull src=/root/murder/dist/deploy.torrent dest=/root"

ansible 172.20.7.24 -m synchronize -a "mode=pull src=/root/CentOS-7-x86_64-DVD-1511.iso dest=/root"
