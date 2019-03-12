1.centos7，k8s二进制部署
https://www.kubernetes.org.cn/4963.html
##############################################################################
2.centos7 kubernetes-dashboard部署
 2.1拉取安装文件
 [root@k8s-master ~]# git clone https://github.com/kubernetes/kubernetes.git
 [root@k8s-master ~]# cd kubernetes/cluster/addons/dashboard/
 [root@k8s-master dashboard]# ll
 total 32
 -rw-r--r-- 1 root root  264 Dec 18 10:14 dashboard-configmap.yaml
 -rw-r--r-- 1 root root 1822 Dec 18 10:14 dashboard-controller.yaml
 -rw-r--r-- 1 root root 1353 Dec 18 10:14 dashboard-rbac.yaml
 -rw-r--r-- 1 root root  551 Dec 18 10:14 dashboard-secret.yaml
 -rw-r--r-- 1 root root  322 Dec 18 10:14 dashboard-service.yaml
 
 2.2 DNS设置成114.114.114.114或者8.8.8.8
   echo "nameserver 114.114.114.114" > /etc/resolv.conf
 
 2.3 搭建私有仓库 #并且同步以下两个文件到所有节点
 echo '{
 "insecure-registries" : ["k8s-reistry:5000"]
 }' > /etc/docker/daemon.json 
 echo "192.168.1.100 k8s-registry" >> /etc/hosts
 
 2.4 重启docker
 systemctl daemon-reload && systemctl restart docker
 2.5 拉取镜像
 docker search kubernetes-dashboard 
 docker pull siriuszg/kubernetes-dashboard-amd64 
 docker tag siriuszg/kubernetes-dashboard-amd64 k8s-registry:5000/kubernetes-dashboard-amd64:latest
 docker push k8s-registry:5000/kubernetes-dashboard-amd64:latest
 curl http://k8s-registry:5000/v2/_catalog  #看看仓库镜像
 curl http://k8s-registry:5000/v2/kubernetes-dashboard-amd64/list #查看版本
 
 2.6 修改镜像源
 vim /root/kubernetes/cluster/addons/dashboard/dashboard-controller.yaml
 34         image: k8s-registry:5000/kubernetes-dashboard-amd64
 2.7 创建
 cd /root/kubernetes/cluster/addons/dashboard
 kubectl create -f dashboard-rbac.yaml
 kubectl create -f dashboard-secret.yaml
 kubectl create -f dashboard-configmap.yaml
 kubectl create -f dashboard-controller.yaml
 kubectl create -f dashboard-service.yaml
 
 2.8 查看状态
 kubectl get pod -n kube-system
 kubectl describe pod `kubectl get pod -n kube-system | awk '/dashboard/{print $1}'` -n kube-system
