######################################################################
CentOS7环境部署kubenetes1.12版本五部曲之二：创建master节点
1.ssh登录master节点，身份是root；
2.修改/etc/hostname，确保每台机器的hostname是唯一的；
######################################################################
3.初始化kubernetes：
3.1 拉取镜像
  [root@kube-master ~]# kubeadm config images list 2>/dev/null
  k8s.gcr.io/kube-apiserver:v1.13.2
  k8s.gcr.io/kube-controller-manager:v1.13.2
  k8s.gcr.io/kube-scheduler:v1.13.2
  k8s.gcr.io/kube-proxy:v1.13.2
  k8s.gcr.io/pause:3.1
  k8s.gcr.io/etcd:3.2.24
  k8s.gcr.io/coredns:1.2.6  #需要单独拉取
  
  [root@kube-master ~]# kubeadm config images list 2>/dev/null \
                        |sed -e 's/^/docker pull /g' -e \
                        's#k8s.gcr.io#docker.io/mirrorgooglecontainers#g' | sh -x
  [root@kube-master ~]# docker images |grep mirrorgooglecontainers \
                         |awk '{print "docker tag ",$1":"$2,$1":"$2}' \ 
                         |sed -e 's#docker.io/mirrorgooglecontainers#k8s.gcr.io#2' |sh -x
  [root@kube-master ~]# docker images |grep mirrorgooglecontainers \
                         |awk '{print "docker rmi ", $1":"$2}' |sh -x
  [root@kube-master ~]# docker pull coredns/coredns:1.2.6
  [root@kube-master ~]# docker tag coredns/coredns:1.2.6 k8s.gcr.io/coredns:1.2.6
  [root@kube-master ~]# docker rmi coredns/coredns:1.2.6
  
3.2初始化
  [root@kube-master ~]# kubeadm init --kubernetes-version=v1.13.2 --pod-network-cidr=10.244.0.0/16
  [init] Using Kubernetes version: v1.13.2
  [preflight] Running pre-flight checks
  	[WARNING Service-Docker]: docker service is not enabled, please run 'systemctl enable docker.service'
  [preflight] Pulling images required for setting up a Kubernetes cluster
  [preflight] This might take a minute or two, depending on the speed of your internet connection
  [preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
  [kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
  [kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
  [kubelet-start] Activating the kubelet service
  [certs] Using certificateDir folder "/etc/kubernetes/pki"
  [certs] Generating "etcd/ca" certificate and key
  [certs] Generating "etcd/peer" certificate and key
  [certs] etcd/peer serving cert is signed for DNS names [kube-master localhost] and IPs [192.168.1.118 127.0.0.1 ::1]
  [certs] Generating "etcd/healthcheck-client" certificate and key
  [certs] Generating "apiserver-etcd-client" certificate and key
  [certs] Generating "etcd/server" certificate and key
  [certs] etcd/server serving cert is signed for DNS names [kube-master localhost] and IPs [192.168.1.118 127.0.0.1 ::1]
  [certs] Generating "ca" certificate and key
  [certs] Generating "apiserver" certificate and key
  [certs] apiserver serving cert is signed for DNS names [kube-master kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 192.168.1.118]
  [certs] Generating "apiserver-kubelet-client" certificate and key
  [certs] Generating "front-proxy-ca" certificate and key
  [certs] Generating "front-proxy-client" certificate and key
  [certs] Generating "sa" key and public key
  [kubeconfig] Using kubeconfig folder "/etc/kubernetes"
  [kubeconfig] Writing "admin.conf" kubeconfig file
  [kubeconfig] Writing "kubelet.conf" kubeconfig file
  [kubeconfig] Writing "controller-manager.conf" kubeconfig file
  [kubeconfig] Writing "scheduler.conf" kubeconfig file
  [control-plane] Using manifest folder "/etc/kubernetes/manifests"
  [control-plane] Creating static Pod manifest for "kube-apiserver"
  [control-plane] Creating static Pod manifest for "kube-controller-manager"
  [control-plane] Creating static Pod manifest for "kube-scheduler"
  [etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
  [wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
  [kubelet-check] Initial timeout of 40s passed.
  [apiclient] All control plane components are healthy after 59.505060 seconds
  [uploadconfig] storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
  [kubelet] Creating a ConfigMap "kubelet-config-1.13" in namespace kube-system with the configuration for the kubelets in the cluster
  [patchnode] Uploading the CRI Socket information "/var/run/dockershim.sock" to the Node API object "kube-master" as an annotation
  [mark-control-plane] Marking the node kube-master as control-plane by adding the label "node-role.kubernetes.io/master=''"
  [mark-control-plane] Marking the node kube-master as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule]
  [bootstrap-token] Using token: 2wrpbs.1lbui1erahievvbp
  [bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
  [bootstraptoken] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
  [bootstraptoken] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
  [bootstraptoken] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
  [bootstraptoken] creating the "cluster-info" ConfigMap in the "kube-public" namespace
  [addons] Applied essential addon: CoreDNS
  [addons] Applied essential addon: kube-proxy
  
  Your Kubernetes master has initialized successfully!
  
  To start using your cluster, you need to run the following as a regular user:
  
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
  
  You should now deploy a pod network to the cluster.
  Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
    https://kubernetes.io/docs/concepts/cluster-administration/addons/
  
  You can now join any number of machines by running the following on each node
  as root:
  
    kubeadm join 192.168.1.118:6443 --token 2wrpbs.1lbui1erahievvbp \
    --discovery-token-ca-cert-hash sha256:dd4ec1aeeee61692c6da324c73564443beb8964ca5b307c96803093b4820063d

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml
################################################################################################
执行成功后控制台输入如下：
[root@localhost ~]# kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/\
bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml
clusterrole.rbac.authorization.k8s.io/flannel created
clusterrolebinding.rbac.authorization.k8s.io/flannel created
serviceaccount/flannel created
configmap/kube-flannel-cfg created
daemonset.extensions/kube-flannel-ds-amd64 created
daemonset.extensions/kube-flannel-ds-arm64 created
daemonset.extensions/kube-flannel-ds-arm created
daemonset.extensions/kube-flannel-ds-ppc64le created
daemonset.extensions/kube-flannel-ds-s390x created
################################################################################################
执行以下命令查看pod情况：
[root@localhost ~]# kubectl get pods --all-namespaces
NAMESPACE     NAME                                            READY   STATUS    RESTARTS   AGE
kube-system   coredns-576cbf47c7-564dg                        1/1     Running   0          164m
kube-system   coredns-576cbf47c7-snqkd                        1/1     Running   0          164m
kube-system   etcd-localhost.localdomain                      1/1     Running   0          164m
kube-system   kube-apiserver-localhost.localdomain            1/1     Running   0          163m
kube-system   kube-controller-manager-localhost.localdomain   1/1     Running   0          163m
kube-system   kube-flannel-ds-amd64-r8wbb                     1/1     Running   0          4m17s
kube-system   kube-proxy-z7kn2                                1/1     Running   0          164m
kube-system   kube-scheduler-localhost.localdomain            1/1     Running   0          163m


执行命令docker images看看下载了哪些镜像：
[root@localhost ~]# docker images
REPOSITORY                           TAG                 IMAGE ID            CREATED             SIZE
k8s.gcr.io/kube-apiserver            v1.13.2             177db4b8e93a        3 weeks ago         181 MB
k8s.gcr.io/kube-proxy                v1.13.2             01cfa56edcfc        3 weeks ago         80.3 MB
k8s.gcr.io/kube-controller-manager   v1.13.2             b9027a78d94c        3 weeks ago         146 MB
k8s.gcr.io/kube-scheduler            v1.13.2             3193be46e0b3        3 weeks ago         79.6 MB
k8s.gcr.io/coredns                   1.2.6               f59dcacceff4        2 months ago        40 MB
k8s.gcr.io/etcd                      3.2.24              3cab8e1b9802        4 months ago        220 MB
quay.io/coreos/flannel               v0.10.0-amd64       f0fad859c909        12 months ago       44.6 MB
k8s.gcr.io/pause                     3.1                 da86e6ba6ca1        13 months ago       742 kB
