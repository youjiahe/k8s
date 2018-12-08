●集群搭建请看
https://blog.csdn.net/real_myth/article/details/78719244
########################################################
●kubernetes 常用命令
[root@huawei_8g k8s]# kubectl cluster-info  #查看集群状态
[root@huawei_8g k8s]# kubectl get nodes     #查看节点状态
[root@huawei_8g k8s]# kubectl run nginx --image nginx --port 8001  #运行一个共有仓库
[root@huawei_8g k8s]# kubectl get pods --all-namespaces #查看pods
[root@huawei_8g k8s]# kubectl get deployment #查看那创建的副本
[root@huawei_8g k8s]# kubectl get deploy/nginx #查看创建的副本，指定nginx pod
[root@huawei_8g k8s]# kubectl scale deployment nginx --replicas=2 #指定创建2个副本
[root@huawei_8g k8s]# kubectl run --image=ngin nginx-deploy -o yaml --dry-run > nginx-deploy.yaml #用现有镜像到处yaml 文件
[root@huawei_8g k8s]# kubectl create -f nginx-deploy.yaml  #创建pod
#########################################################
●Kubernetes学习常见问题
    1.问题 ContainerCreating ；  kubectl describe pod nginx 出现以下错误
    其中最主要的问题是：
    details: (open /etc/docker/certs.d/registry.access.redhat.com/redhat-ca.crt: no such file or directory)
    解决： 以下操作均在node服务器上
    [root@huawei4g ~]# yum -y install *rhsm*
    [root@huawei_8g ~]# kubectl delete pod -l run=nginx
    [root@huawei_8g ~]# rpm2cpio python-rhsm-certificates-1.19.10-1.el7_4.x86_64.rpm | cpio -iv --to-stdout ./etc/rhsm/ca/redhat-uep.pem | tee /etc/rhsm/ca/redhat-uep.pem
    [root@huawei_8g ~]# wget http://mirror.centos.org/centos/7/os/x86_64/Packages/python-rhsm-certificates-1.19.10-1.el7_4.x86_64.rpm
    [root@huawei4g ~]# ll /etc/rhsm/ca/redhat-uep.pem  #查看是否存在该文件
    [root@huawei4g ~]# docker pull registry.access.redhat.com/rhel7/pod-infrastructure:latest  #拉取该镜像

     结果：到master查看pods状态
