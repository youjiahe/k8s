###############################################################################################
#执行sysctl -p 时出现：
[root@localhost ~]# sysctl -p
sysctl: cannot stat /proc/sys/net/bridge/bridge-nf-call-ip6tables: No such file or directory
sysctl: cannot stat /proc/sys/net/bridge/bridge-nf-call-iptables: No such file or directory
 
#解决方法：
[root@localhost ~]# modprobe br_netfilter
[root@localhost ~]# ls /proc/sys/net/bridge
###############################################################################################
#问题
health check for peer 540fa0a1b3b843f3 could not connect: x509: certificate has expired or is not yet valid (prober "ROUN
rejected connection from "192.168.1.101:43534" (error "remote error: tls: bad certificate", ServerName "")
#解决  修改etcd 服务证书配置文件 server-csr.json
 修改为对应IP
 
##############################################################################################
#systemctl status flanneld 出现以下问题
Determining IP address of default interface
Failed to find any valid interface to use: failed to get default interface
flanneld.service: main process exited, code=exited, status=1/FAILURE
Failed to start Flanneld overlay address etcd agent.

#解决  添加默认路由
route add default gw 192.168.1.254 dev eth0
##############################################################################################
#kubelet启动不成功，journalctl -xe -u kubelet 有以下报错
failed to create kubelet: misconfiguration: kubelet cgroup driver: "cgroupfs" is different from docker cgroup driver: "systemd"
#解决
vi /usr/lib/systemd/system/docker.service

找到
--exec-opt native.cgroupdriver=systemd \
修改为：
--exec-opt native.cgroupdriver=cgroupfs \

或者：
vi /k8s/kubernetes/cfg/kubelet
--cgroup-driver=systemd \
kubelet的服务配置文件加上这么一行
 ##############################################################################################
#问题：kubectl get csr 显示 no resoure found
#并且查看节点 kubelet 日志看到 orbidden: node "192.168.1.100" cannot modify node #journalctl -xe -u kubelet

#解决：
则需要删除 kubelet.kubeconfig文件
在master上通过kubectl get node 获得的列表中，Name显示的名称是通过  
客户端kubelet和proxy配置文件中hostname-override配置参数定义的，
修改这2个参数为你想要的名称，并且删除kubelet.kubeconfig(这个文件是master认证后客户端自动生成的，如果不删除会报node节点forbidden)文件，
重新启动着2个服务，master端重新
kubectl certificate approve  name名称  就可以看到新名称。

##############################################################################################
#问题：kubectl get nodes 显示 no resoure found
#并且kubectl get csr只有approved 状态没有 issued状态
#并且systemctl restart kubelet很慢

#解决：
查看 master组件的 ca 证书路径是否正确，(如/opt/应为 /k8s)
vim /k8s/kubernetes/cfg/kube-apiserver
vim /k8s/kubernetes/cfg/kube-scheduler
vim /k8s/kubernetes/cfg/kube-controller-manager
##############################################################################################
#创建pod失败，比如dashboard
#找到pod 执行kubectl get pod  -n kube-system
#执行kubectl describe pod kubernetes-dashboard-66bb48f98c-lhlrl -n kube-system ，看到以下报错
Events:
  Type     Reason                  Age                   From                    Message
  ----     ------                  ----                  ----                    -------
  Warning  FailedCreatePodSandBox  3m9s (x70 over 104m)  kubelet, 192.168.1.102  Failed create pod sandbox: rpc error:
  code = Unknown desc = failed pulling image "registry.cn-hangzhou.aliyuncs.com/google-containers/pause-amd64:3.0": 
  Error response from daemon: Get https://registry.cn-hangzhou.aliyuncs.com/v2/: 
  net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)


#解决：
1.DNS设置成114.114.114.114或者8.8.8.8
  echo "nameserver 114.114.114.114" > /etc/resolv.conf
2.搭建私有仓库 #并且同步以下两个文件到所有节点
 echo "{
 "insecure-registries" : ["k8s-reistry:5000"]
 }" > /etc/docker/daemon.json
 
 echo "192.168.1.100 k8s-registry" >> /etc/hosts

3.重启docker
4.拉取镜像
docker search kubernetes-dashboard 
docker pull siriuszg/kubernetes-dashboard-amd64 
docker tag siriuszg/kubernetes-dashboard-amd64 k8s-registry:5000/kubernetes-dashboard-amd64:latest
docker push k8s-registry:5000/kubernetes-dashboard-amd64:latest

curl http://k8s-registry:5000/v2/_catalog  #看看仓库镜像
curl http://k8s-registry:5000/v2/kubernetes-dashboard-amd64/list #查看版本

5.修改镜像源
vim /root/kubernetes/cluster/addons/dashboard/dashboard-controller.yaml
34         image: k8s-registry:5000/kubernetes-dashboard-amd64

6.重建
cd /root/kubernetes/cluster/addons/dashboard
kubectl delete -f dashboard-rbac.yaml
kubectl delete -f dashboard-secret.yaml
kubectl delete -f dashboard-configmap.yaml
kubectl delete -f dashboard-controller.yaml
kubectl delete -f dashboard-service.yaml

kubectl create -f dashboard-rbac.yaml
kubectl create -f dashboard-secret.yaml
kubectl create -f dashboard-configmap.yaml
kubectl create -f dashboard-controller.yaml
kubectl create -f dashboard-service.yaml

7.查看状态
kubectl get pod -n kube-system
kubectl describe pod kubernetes-dashboard-56bd959dd5-4k8cx -n kube-system
##############################################################################################
#kubernetes-dashboard 状态为CrashLoopBackOff
按照 https://blog.csdn.net/qq1083062043/article/details/84949924 创建的
[root@k8s-master dashboard]# kubectl get all -n kube-system
NAME                                        READY   STATUS             RESTARTS   AGE
pod/coredns-7f5bdbf7bd-dm28f                0/1     CrashLoopBackOff   8          18m
pod/kubernetes-dashboard-6bfccbbb9b-bjznz   0/1     CrashLoopBackOff   1          9s

解决方案
修改下载的kubernetes-dashboard.yaml文件，更改RoleBinding修改为ClusterRoleBinding，并且修改roleRef中的kind和name，用cluster-admin这个非常牛逼的CusterRole（超级使用户权限，其拥有访问kube-apiserver的所有权限）。如下：

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: kubernetes-dashboard-minimal
  namespace: kube-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: kubernetes-dashboard
  namespace: kube-system

---
## 三步重新启动kubernetes-dashboard
删除原先配置
kubectl delete -f kubernetes-dashboard.yaml
重新加载配置
kubectl create -f kubernetes-dashboard.yaml
重启代理
kubectl proxy --address=192.168.112.38 --disable-filter=true &

########################################################################
[root@k8s-master pod_test]# kubectl run -it --image=k8s-registry:5000/busybox:latest --rm --restart=Never shell
If you don't see a command prompt, try pressing enter.
/ # nslookup kubernetes
Server:		10.0.0.2
Address:	10.0.0.2:53

** server can't find kubernetes.default.svc.cluster.local.: NXDOMAIN

*** Can't find kubernetes.svc.cluster.local.: No answer
*** Can't find kubernetes.cluster.local.: No answer
*** Can't find kubernetes.default.svc.cluster.local.: No answer
*** Can't find kubernetes.svc.cluster.local.: No answer
*** Can't find kubernetes.cluster.local.: No answer



