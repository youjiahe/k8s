## docker概述
- docker是容器引擎，提供一系列命令管理容器、镜像、仓库
- docker基于容器技术的轻量级虚拟化解决方案
- docker把Linux的cgroup、namespace等容器底层技术进行封装抽象，为用户提供管理容器的便捷工具
- docker是一个开源项目，go语言编写
![docker](https://github.com/youjiahe/k8s/blob/master/picture/docker.jpg)
## docker与虚拟机的区别
- 传统虚拟机技术是虚拟出一套硬件后，在其上运行一个完整操作系统，在该系统上再运行所需应用进程
- 容器内的应用进程直接运行于宿主的内核，容器内没有自己的内核，而且也没有进行硬件虚拟。因此容器要比传统虚拟机更为轻便
![container_VS_VM](https://github.com/youjiahe/k8s/blob/master/picture/container_VM.jpg)
## docker三大核心
- 容器
- 镜像
- 仓库
## docker基本使用
[tedu.docker01](https://github.com/youjiahe/note/blob/master/11.cloud/CLD5.sh)
[tedu.docker02](https://github.com/youjiahe/note/blob/master/11.cloud/CLD6.sh)
