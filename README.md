# PVE集群初始化
## 功能说明
- [x] 集群初始化，包括创建集群、加入所有节点
- [x] 生成超级管理员apitoken，保存到本地执行目录logs/[tokenid]-[host].log
- [x] 数据盘创建LVM接入PVE存储

## 使用说明

### 使用国内开源apt仓库
```bash
rm -f /etc/apt/sources.list.d/pve-enterprise.list
cat <<EOF >/etc/apt/sources.list
deb http://mirrors.aliyun.com/debian bullseye main contrib

deb http://mirrors.aliyun.com/debian bullseye-updates main contrib

# security updates
deb http://mirrors.aliyun.com/debian-security bullseye-security main contrib
EOF
apt update -y
```
### Ansible安装
```bash
apt install -y python3-pip sshpass
pip3 install ansible -i https://pypi.tuna.tsinghua.edu.cn/simple
ansible --version
```

### 配置节点之间免密
* pve集群间通过ssh同步集群状态,所以需要自行配置集群间node ssh免密
* 本脚本初始化集群时会在inventory中master节点上创建集群, 其他节点加入进来,所以其余节点要能免密ssh登录master节点
```bash
ssh-copy-id [master-ip]
```

### 一、 编辑inventory文件
```bash
cp hosts.template hosts
```
hosts文件内容说明
```bash
[pve]
# 设定一个主节点，必须按照下面写法，其余节点直接写ip即可
master ansible_ssh_host=10.53.7.1
10.53.7.2
10.53.7.3

[pve:vars]
# ssh账号端口密码
ansible_ssh_user='root'
ansible_ssh_port=22
ansible_ssh_pass='rootpassword'

# 要创建的集群名称
cluster_name = 'test'
# 要创建的apitoken id
apitoken_name = 'root'
# 数据盘符, 自动创建为lvm类型存储
data_device = '/dev/sdb'
```

### 二、 执行pve集群初始化
```bash
# 配置集群
ansible-playbook -i hosts roles/pve.yml -t init,cluster
# 创建apitoken必须和创建lvm存储的节点一起执行，lvm依赖apitoken创建输出的变量
ansible-playbook -i hosts roles/pve.yml -t apitoken,lvm
```

创建的apitoken会存储在相对路径./logs下，后期可以通过这里创建的apitoken接管pve集群，文件名为`[tokenid]-[host].log`
```bash
ls -l ./logs
total 8
-rw-r--r-- 1 root root 36 Jul  6 17:53 test-10.53.7.1.log
```

### 三、如果集群配置异常需要重置pve状态,可以执行集群清理脚本
```bash
ansible-playbook -i hosts roles/pve.yml -t purge
```