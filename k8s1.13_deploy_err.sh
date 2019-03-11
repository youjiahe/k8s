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
