##################################################################################
前提
本次部署实战需要科学上网，才能顺利安装和部署kubernetes用于学习和实践，请确保您已经完成了相关操作；

系列文章简述
本次搭建过程由五部分实战构成：

标准化机器：kubernetes环境中的所有机器都要做些公共的设置，本篇就是讲述这些通用设置的，例如docker、kubeadm等应用的安装；
搭建master：主控节点；
节点加入：node节点加入主控节点所在的kubenetes环境；
扩展：安装dashboard；
扩展：在kubernetes集群之外的CentOS7服务器上安装kubectl，然后操作和控制kubernetes环境；
##################################################################################
环境信息
CentOS：7.4.1708；
Docker：1.13.1；
Kubeadm版本：1.12.2-0；
Kubenetes版本：1.12.2-0；

本次实战一共有四台CentOS7机器，基本信息如下：
hostname	IP地址	身份	配置
localhost	192.168.1.118	master，主控节点	双核，2G内存
node1	192.168.1.119	node，一号业务节点	双核，4G内存
node2	192.168.1.120	node，二号业务节点	双核，2G内存
normal	192.168.1.	普通linux服务器	单核，1G内存
##################################################################################
注意事项
关于科学上网的方法不在本文讨论之列，请自行完成；
注意：很多设置科学上网的教程中，都要求在/etc/profile文件中添加类似下面这些信息，但是在本次实战中，请不要设置！！！
PROXY_HOST=127.0.0.1
export all_proxy=http://$PROXY_HOST:8118
export ftp_proxy=http://$PROXY_HOST:8118
export http_proxy=http://$PROXY_HOST:8118
export https_proxy=http://$PROXY_HOST:8118
export no_proxy=localhost,172.16.0.0/16,192.168.0.0/16.,127.0.0.1,10.10.0.0/16
##################################################################################
接下来，就在CentOS机器上开始实战吧；

操作
CentOS环境如果用到了Privoxy代理，需要执行下面的命令，这样执行yum的时候才能用到代理（实际证明，在安装kubelet、kubeadm、kubectl的时候，这一步很重要）：
echo "proxy=http://127.0.0.1:8118" >> /etc/yum.conf
1
更新yum缓存：
yum makecache
1
关闭防火墙：
systemctl stop firewalld && systemctl disable firewalld
1
关闭swap：
swapoff -a
1
然后再打开文件/etc/fstab，找到swap有关的一行，如下图红框所示，在这一行的最左边加上"#"，将该行注释掉：

执行free -m命令检查，swap值应该都为0了，如下图红框所示：

关闭selinux，打开文件/etc/sysconfig/selinux，找到SELINUX=xxxxxx，如下图红框所示，将其改为SELINUX=disabled：

执行命令：

setenforce 0
1
iptable设置，不执行的话后面的初始化和节点加入都会失败：
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

安装docker：
yum install -y docker && systemctl enable docker && systemctl start docker
1
安装完毕后执行命令docker version检查服务，正常情况下显示以下信息：

Client:
 Version:         1.13.1
 API version:     1.26
 Package version: docker-1.13.1-75.git8633870.el7.centos.x86_64
 Go version:      go1.9.4
 Git commit:      8633870/1.13.1
 Built:           Fri Sep 28 19:45:08 2018
 OS/Arch:         linux/amd64

Server:
 Version:         1.13.1
 API version:     1.26 (minimum version 1.12)
 Package version: docker-1.13.1-75.git8633870.el7.centos.x86_64
 Go version:      go1.9.4
 Git commit:      8633870/1.13.1
 Built:           Fri Sep 28 19:45:08 2018
 OS/Arch:         linux/amd64
 Experimental:    false

配置docker代理，先执行以下命令创建目录：
mkdir -p /etc/systemd/system/docker.service.d

在目录/etc/systemd/system/docker.service.d下创建文件http-proxy.conf，内容如下：
[Service]
Environment="HTTP_PROXY=http://127.0.0.1:8118" "NO_PROXY=localhost,172.16.0.0/16,127.0.0.1,10.244.0.0/16"

在目录/etc/systemd/system/docker.service.d下创建文件https-proxy.conf，注意，上一步是http的，这一步是https的内容如下：
[Service]
Environment="HTTP_PROXY=https://127.0.0.1:8118" "NO_PROXY=localhost,172.16.0.0/16,127.0.0.1,10.244.0.0/16"

使配置生效，重启docker：
systemctl daemon-reload && systemctl restart docker
##################################################################################
配置kubernetes的yum信息：
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

安装kubelet、kubeadm、kubectl，并且将kubelet设置为自启动，然后再启动kubelet：
yum install -y kubelet kubeadm kubectl \
&& systemctl enable kubelet \
&& systemctl start kubelet

至此，标准化机器的工作就完成了；

如果您使用了多台电脑搭建kubernetes环境，那么每台电脑都要执行上述操作；
如果您是用VMware来搭建kubernetes环境，那么建议您现在先关闭当前的虚拟机，
将真个虚拟机文件夹做备份，后续搭建环境就不用重新创建系统了，直接复制一份这个文件夹，再打开运行就是个标准化的机器了；
