### 1.1 准备环境
- 安装go环境，版本为1.13或更高
	下载地址：[golang](https://golang.org/dl/ "golang")

```
# 下载go环境
wget https://go.dev/dl/go1.16.10.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.16.10.linux-amd64.tar.gz
# 设置go环境,在/etc/profile文件末尾写入如下内容使用sudo vi /etc/profile)
export GOROOT=/usr/local/go
export GOPATH=$HOME/go_workspace
export PATH=$PATH:$GOROOT/bin
# 保存退出
source /etc/profile
# 查看go本版
go version
# 设置go的相关环境,将代理设置为国内的，这样加速拉包
go env -w GO111MODULE=on
go env -w GOPROXY=https://goproxy.cn,direct
```

- 编译环境准备

```
sudo apt update
sudo apt install make git unzip g++
# 如果在编译过程中提示缺少其他包，根据提示使用apt安装
```

### 1.2 编译matrixchain
- 下载matrixchain源码
	* git clone  -b formal https://github.com/superconsensus/matrixchain.git
- 执行命令
```
$ cd matrixchain
$ make
```
- 在output目录下bin，conf， data 三个文件夹以及一个 control.sh 脚本

### 1.3 部署单节点服务
##### 1.3.1 启动服务
matrixchain为我们启动服务提供了方便的脚本，只需要一条命令使用controll.sh即可启动单节点 single 共识的链。
``` 
# 切换到output目录下
$ cd output
# 使用脚本启动服务
$ bash control.sh start
```
control.sh 脚本提供了4个命令：start | stop | restart | forcestop，
可以使用bash control.sh help 查看。

各目录的功能如下表：

| 目录名                   | 功能                                                         |
| ------------------------ | ------------------------------------------------------------ |
| output/                  | 节点根目录                                                   |
| ├─ bin                   | 可执行文件存放目录                                           |
| │ ··· ├─ wasm2c          | XVM 虚拟机工具，将 WASM 转为 C                               |
| │ ··· ├─ xchain          | matrixchain服务的二进制文件                                  |
| │ ··· ├─ xchain-cli      | matrixxchain客户端工具                                       |
| ├─ conf                  | 配置相关目录                                                 |
| │ ··· ├─ xchain.yaml     | matrixchain服务的配置信息（注意端口冲突）                    |
| │ ··· ├─ engine.yaml     | 引擎相关配置                                                 |
| │ ··· ├─ env.yaml        | 本地环境相关配置，设置key存储路径等                          |
| │ ··· ├─ ledger.yaml     | 存储引擎相关配置，levelDB等                                  |
| │ ··· ├─ log.yaml        | 日志相关配置，日志级别，保留时间等                           |
| │ ··· ├─ network.yaml    | 网络相关配置，单机多节点配置时需更改端口等                   |
| │ ··· ├─ server.yaml     | 服务相关配置，如端口，tls等                                  |
| │ ··· ├─ xchain-cli.yaml | matrixxchain客户端相关配置，交易是否需要配置，交易发送节点等 |
| ├─ control.sh            | 启动脚本                                                     |
| ├─ data                  | 数据的存放目录，创世块信息，以及共识和合约的样例             |
| │ ··· ├─ blockchain      | 账本目录                                                     |
| │ ··· ├─ keys            | 此节点的地址，具有全局唯一性                                 |
| │ ··· ├─ netkeys         | 此节点的网络标识ID，具有全局唯一性                           |
| │ ··· └─ config          | 包括创始的共识，初始的资源数，矿工奖励机制等                 |
| ├─ logs                  | 程序日志目录                                                 |
| ├─ tmp                   | 临时文件夹，目前存储进程pid                                  |

##### 1.3.2 确认服务状态
```
# 确认服务状态
$ ./bin/xchain-cli status -H 127.0.0.1:37101
 {
   "blockchains": [
   {
     "name": "xuper",
     "ledger": {
       "rootBlockid": "d93c260ea5639a55e1fcad3df494495efad5c65d46e846b6db3a9194a4212886",
       "tipBlockid": "9555ca5af579db67734f27013dfaae48d93e4c3e8adcf6ca8f3dc1adb06d0b6f",
       "trunkHeight": 137
     },
     ....
         "9555ca5af579db67734f27013dfaae48d93e4c3e8adcf6ca8f3dc1adb06d0b6f"
      ]
     }
   ],
  "peers": null,
  "speeds": {}
}
```

### 1.4 多节点环境部署（常用）

 #### 1.4.1 准备环境
1. 创建网络部署环境
```
$ make testnet
# 说明：在当前目录下创建testnet目录，包含node1,node3,node3
```
2. 查看网络部署环境
```
$ tree testnet
```
可以看到3个节点。
```
testnet
├── node1
│   ├── bin
│   ├── conf
│   └── data
│       ├── genesis
│       ├── keys
│       └── netkeys
├── node2
│   ├── bin
│   ├── conf
│   └── data
│       ├── genesis
│       ├── keys
│       └── netkeys
└── node3
    ├── bin
    ├── conf
    └── data
        ├── genesis
        ├── keys
        └── netkeys
```

#### 1.4.2 网络配置查看
节点加入网络需要通过网络中一个或者多个种子节点，区块链网络中任何一个节点都可以作为种子节点，通过配置种子节点的网络连接地址netURL可以加入网络。

1 查看种子节点netURL
```
#查看node1节点连接地址netURL
cd node1
./bin/xchain-cli netURL preview
#得到如下结果，实际使用时，需要将ip配置节点的真实ip，port配置成
/ip4/{{ip}}/tcp/{{port}}/p2p/Qmf2HeHe4sspGkfRCTq6257Vm3UHzvh2TeQJHHvHzzuFw6
#查看node2节点连接地址netURL
cd ../node2
./bin/xchain-cli netURL preview
/ip4/{{ip}}/tcp/{{port}}/p2p/QmQKp8pLWSgV4JiGjuULKV1JsdpxUtnDEUMP8sGaaUbwVL

#查看node3节点连接地址netURL
cd ../node3
./bin/xchain-cli netURL preview
/ip4/{{ip}}/tcp/{{port}}/p2p/QmZXjZibcL5hy2Ttv5CnAQnssvnCbPEGBzqk7sAnL69R1E
```
2 查看p2p网络配置
```
# p2p network config

# Module is the name of p2p module plugin.(p2pv1 | p2pv2)
module: p2pv2
# Port the p2p network listened
port: 47101
# Address multiaddr string
address: /ip4/127.0.0.1/tcp/47101
# IsTls config the node use tls secure transparent
isTls: true
# KeyPath is the netdisk private key path
keyPath: netkeys
# BootNodes config the bootNodes the node to connect
bootNodes:
  - "/ip4/127.0.0.1/tcp/47101/p2p/Qmf2HeHe4sspGkfRCTq6257Vm3UHzvh2TeQJHHvHzzuFw6"
  - "/ip4/127.0.0.1/tcp/47102/p2p/QmQKp8pLWSgV4JiGjuULKV1JsdpxUtnDEUMP8sGaaUbwVL"
  - "/ip4/127.0.0.1/tcp/47103/p2p/QmZXjZibcL5hy2Ttv5CnAQnssvnCbPEGBzqk7sAnL69R1E"
# service name
serviceName: localhost
```

#### 1.4.3 启动网络
我们可以使用一个脚本启动3节点。创建run.sh文件，使用vi打开，并写入如下内容同时保存
```
# 启动节点1
cd ./testnet/node1
sh ./control.sh start
# 启动节点2
cd ../node2
sh ./control.sh start
# 启动节点3
cd ../node3
sh ./control.sh start
```
注意：run.sh 存放在matrixchian目录下
使用 ``` sh ./run.sh ``` 命令启动脚本创建3个节点的服务。

#### 1.4.4 确认服务
查看服务状态
```
./bin/xchain-cli status -H :37101
./bin/xchain-cli status -H :37102
./bin/xchain-cli status -H :37103
```