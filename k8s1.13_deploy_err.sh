###############################################################################################
执行sysctl -p 时出现：
[root@localhost ~]# sysctl -p
sysctl: cannot stat /proc/sys/net/bridge/bridge-nf-call-ip6tables: No such file or directory
sysctl: cannot stat /proc/sys/net/bridge/bridge-nf-call-iptables: No such file or directory
 
解决方法：
[root@localhost ~]# modprobe br_netfilter
[root@localhost ~]# ls /proc/sys/net/bridge
###############################################################################################
#问题
health check for peer 540fa0a1b3b843f3 could not connect: x509: certificate has expired or is not yet valid (prober "ROUN
rejected connection from "192.168.1.101:43534" (error "remote error: tls: bad certificate", ServerName "")
#解决  修改etcd 服务证书配置文件 server-csr.json
 修改为对应IP
