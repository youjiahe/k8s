● 创建yaml 书写 Deployment  及 Service
# vim nginx-ds.yaml
---------------------------------------------------------------
	apiVersion: extensions/v1beta1
	kind: Deployment
	metadata: 
	  name: nginx-dm
	spec:
	  replicas: 2
	  template:
	    metadata:
	      labels: 
		name: nginx
	    spec: 
	      containers:
		- name: nginx
		  image: nginx:alpine
		  imagePullPolicy: IfNotPresent
		  ports:
		    - containerPort: 80
	---
	apiVersion: v1
	kind: Service
	metadata:
	  name: nginx-svc
	spec:
	  type: NodePort
	  ports:
	    - port: 80
	      targetPort: 80
	      nodePort: 30005
	      protocol: TCP
	  selector:
	    name: nginx

●执行创建命令
[root@huawei_8g k8s]# kubectl create -f nginx-ds.yaml  
[root@huawei_8g k8s]# kubectl get pods  #查看新创建的pod
[root@huawei_8g k8s]# kubectl get svc   #查看service
[root@huawei_8g k8s]# curl 192.168.1.226:30005  
#若访问不了 则在node运行 iptables -P FORWARD ACCEPT


          
