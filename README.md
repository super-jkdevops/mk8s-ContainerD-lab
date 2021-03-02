## Kubernetes containerd lab
```
.----------------------------------------------------------------------.
| This is 3 node cluster contains 1 control plane and 2 compute nodes. |
| Lab using containerd as containerization engine. I would like show   |
| You are not forced to use docker only!                               | 
'----------------------------------------------------------------------'
```

## Kubernetes version
Currently I'm using 1.19.3. Version is provided as ansible varabile stored separately for master, 
workers in ansible playbook vars manifest file.

Feel free to change `version` if 1.19.3 does not satisfied your requirements.

## Avoiding Ansible installation
Due to fact that you may use different OS distribution for Vagrant host I decided
to use ansible_local provisioner instead of ansible. This approach let you avoid 
additional effort and save a lot of time in case of Ansible package installation.
Of curse on Linux this easy task but same thing is not so colorfull on Windows.
I would say it may be an nightmare ;-)  

## Requirements
Here will be short list about all requirements needed to run this environment.

+ Hardware:
  * 2 CPU
  * 6,5GB RAM
  * 60GB HDD (preferable SSD) this is thin provisioning depends on storage used.

+ Operating system:
  * Widnows 10 installed WSL 1 preferable Ubuntu 18.04 LTS or 20.04 LTS (available in Microsoft Store)
  * Ubuntu 18.04 LTS or 20.04 LTS
  * CentOS/RHEL 7/8 64 bit preferable

`Sorry I have no time to check Debian and Suse.`   

+ Packages:
  * vagrant 2.2.10 or higher (https://www.vagrantup.com/intro/getting-started/install.html)
  * git 1.8 or higher for Linux / 2.29.2 or higher for Windows  (https://pl.atlassian.com/git/tutorials/install-git)
  * VirtualBox 6.1 or higher (https://www.virtualbox.org/wiki/Downloads)

## Before you start
There are some prerequisite task which need to be completed before you start.

### Installing VirtualBox
From your laptop/desktop if you have 

CentOS 7.X/RHEL 7.X, CentOS 8.X/RHEL 8.X or Windows go through documentation. This topic goes beyound scope of this article!

Windows: https://download.virtualbox.org/virtualbox/6.1.16/VirtualBox-6.1.16-140961-Win.exe
<br/>
Linux distributions: https://www.virtualbox.org/wiki/Linux_Downloads

### Windows
Please install WSL when you spin up lab on Windows machine. I recommend you to use 
Ubuntu 20.04 LTS. Be carefull and select proper WSL version! It should be always 
WSL 1 cause  WSL 2 is error prone! I would say more experimental. I faced cam across 
many troubles when I used WSL2 such as network connectivity issues related to ssh etc. 
Please put cloned repository out of /mnt/c and /mnt/d Windows directories. Why because 
Windows has own permission assignments! I advise to use Linux /home subsystem directory
otherwise you will be not able to use chmod commands.  

When you currently have WSL2 you need to convert it to WSL1.

List runs WSL distribution onboarded on your Windows Machine (please use powershell as Administrator)
```
wsl --list --verbose
```

Converting from WSL2 to WSL1
```
wsl --set-version <YOUR DISTRIBUTION> 1
```


`<YOUR DISTRIBUTION>`: is just output grabbed from previous command listing for example: Ubuntu-20.04

I highly encurage you to use Ubuntu 20.04 LTS!

## Items

+ Host entries:

```
172.18.0.2   mk8s-master
172.18.0.10  mk8s-worker1
172.18.0.11  mk8s-worker2
```

`Don't need to be added to your /etc/hosts, in all cases we will use vagrant ssh command instead of standard ssh!`

+ Pods networking
```
Weavenet Networks
```

+ Kubernetes version
```
Kubernetes v1.19.3
```

+ containerD
```

```

+ Operating system version
```
Ubuntu 18.04 LTS - Kubernetes control plane and compute nodes
```
+ Vagrant version
```
Vagrant 2.2.9
```

## Clone repo
How to clone repo? I'm sending you to documentation: https://confluence.atlassian.com/bitbucket/clone-a-repository-223217891.html

Please use following link to clone repository:

https://github.com/super-jkdevops/mk8s-ContainerD-lab.git


In your home directory type:

```
git clone https://github.com/super-jkdevops/mk8s-ContainerD-lab.git kubernetes-vagrant-containerd
```

Move to "kubernetes-vagrant-containerd" directory:

```
cd kubernetes-vagrant-containerd
```

## Start vagrant machines
When repo will be on your station then you need to run only 1 command.
You should be in kubernetes-vagrant-containerd directory. If not please enter this directory

run:

Run provisioning scripts one shoot setup.

```
vagrant up
```

`
Please be patient this process can take a while usually depends on your hardware: disk speed, memory type,
cpu type and generation. 
`

You should see similar output:
```

```

It can take a while, up to 20 mins. Please be patient.

### Smoke test from 1st master node:


vagrant ssh mk8s-master1

```
.--- k8s lab ---.
| Master Node 1 |
'---------------'
[vagrant@mk8s-master ~]$ hostname
mk8s-master
```


### Test if you can connect use names:

```
# ping -c 1 mk8s-master
PING mk8s-master (172.18.0.2) 56(84) bytes of data.
64 bytes from mk8s-master1 (172.18.0.2): icmp_seq=1 ttl=64 time=0.202 ms

--- mk8s-master1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.202/0.202/0.202/0.000 ms

# ping -c 1 mk8s-worker1
PING k8s-worker1 (172.18.0.10) 56(84) bytes of data.
64 bytes from mk8s-worker1 (172.18.0.10): icmp_seq=1 ttl=64 time=0.256 ms

--- k8s-worker1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.256/0.256/0.256/0.000 ms

$ ping -c 1 mk8s-worker2
PING mk8s-worker2 (172.18.0.11) 56(84) bytes of data.
64 bytes from mk8s-worker2 (172.18.0.11): icmp_seq=1 ttl=64 time=0.256 ms

--- mk8s-worker2 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.256/0.256/0.256/0.000 ms
```

You don't need to repeat this steps on other nodes cause it works on first master!

### List Kubernetes nodes
Kubectl binary has been installed only on master node. If you would like to use kubectl on your station you should install
it and copy configuration from .kubectl directory. Without kubectl you will be not able to check kubernetes status and
other cluster things.

On the master node: "mk8s-master" and vagrant user type:

```
kubectl get nodes -o wide
```

Then following output should be displayed:
```

```

Please remember that you should see all nodes and masters as ready. If for some reason
nodes are unavailable please check kubelet logs.

### List Kubernetes cluster objects:
In this section we will check Kubernetes cluster in details. Thanks to this we will know if
all parts of cluster are ready for future operation/deployments etc.

#### Check Kubernetes cluster:"

Namespaces:
```
kubectl get namespaces
```

should return output:

```
NAME              STATUS   AGE
default           Active   45m
kube-node-lease   Active   45m
kube-public       Active   45m
kube-system       Active   45m
```


Pods in kube-system namespace:
```
kubectl --namespace kube-system get pods
```

You should see following output:

```

```

Deployments in kube-system namespace:
```
kubectl --namespace kube-system get deployments
```

Desired output:

```

```

## Used technology:
- Ansible
- Kubernetes
- Vagrant
- Git
- Github

## Post installation steps
There is always good ida to have lab hosts in /etc/hosts file. It can be usefull in many cases 
(reach loadbalancer, check if ingress or application is running on the nodes and scheduled
properly).

If you are intrested please go as follow:

```
cat <<EOT >> /etc/hosts
172.18.0.2   mk8s-master
172.18.0.10  mk8s-worker1
172.18.0.11  mk8s-worker2
EOT
```

### Trouble shooting

Windows powershell: stop ruby and vagrant processes:
```
Stop-process -Name ruby 
Stop-Process -Name vagrant
```

Windows powershell: Search ruby and vagrant process:
```
Get-Process -Name ruby
Get-Process -Name vagrant
```

## Kubernetes applications

### Nginx ingress controller as default

### Service Mesh Istio

### Portworx as dynamic storage volume provisioner

More details about manage processes using powershell you can find under blow link:

https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-process?view=powershell-7.1

Thank you!