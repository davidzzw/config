```
systemctl start etcd

systemctl start docker

systemctl start kube-apiserver

systemctl start kube-controller-manager

systemctl start kube-scheduler

systemctl start kubelet

systemctl start kube-proxy
```

`通过bash获得Pod中某个容器的TTY，相当于登陆容器`

kubectl exec -ti pod-name -c container-name /bin/bash

####执行容器的命令

![执行容器的命令](D:\workdir\config\pic\执行容器的命令.png)

#### 查看容器的日志

![查看容器的日志](D:\workdir\config\pic\查看容器的日志.png)

