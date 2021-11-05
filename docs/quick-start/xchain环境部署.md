#### 1.1 准备环境
- 安装go环境，版本为1.13或更高
	下载地址：[golang](https://golang.org/dl/ "golang")
	
- 安装git

  Ubuntu/Debine：``` sudo apt install git```

  window:  https://git-scm.com/downloads

  Centos: ```yum install git```

#### 1.2 编译superchain
- 下载xuperchain源码
	* git clone https://github.com/superconsnesus-chain/xuperchain
- 执行命令
```
$ cd xuperchain
$ make
```
- 在output目录下bin，conf， data 三个文件夹以及一个 control.sh 脚本

#### 1.3 部署xchain服务
##### 1 启动服务
xuper为我们启动服务提供了方便的脚本，只需要一条命令使用controll.sh即可启动单节点 single 共识的链。
``` 
# 切换到output目录下
$ cd output
# 使用脚本启动服务
$ bash control.sh start
```
control.sh 脚本提供了4个命令：start | stop | restart | forcestop，
可以使用bash control.sh help 查看。

各目录的功能如下表：

| 目录名                   | 功能                                                   |
| ------------------------ | ------------------------------------------------------ |
| output/                  | 节点根目录                                             |
| ├─ bin                   | 可执行文件存放目录                                     |
| │ ··· ├─ wasm2c          | XVM 虚拟机工具，将 WASM 转为 C                         |
| │ ··· ├─ xchain          | xchain服务的二进制文件                                 |
| │ ··· ├─ xchain-cli      | xchain客户端工具                                       |
| ├─ conf                  | 配置相关目录                                           |
| │ ··· ├─ xchain.yaml     | xchain服务的配置信息（注意端口冲突）                   |
| │ ··· ├─ engine.yaml     | 引擎相关配置                                           |
| │ ··· ├─ env.yaml        | 本地环境相关配置，设置key存储路径等                    |
| │ ··· ├─ ledger.yaml     | 存储引擎相关配置，levelDB等                            |
| │ ··· ├─ log.yaml        | 日志相关配置，日志级别，保留时间等                     |
| │ ··· ├─ network.yaml    | 网络相关配置，单机多节点配置时需更改端口等             |
| │ ··· ├─ server.yaml     | 服务相关配置，如端口，tls等                            |
| │ ··· ├─ xchain-cli.yaml | xchain客户端相关配置，交易是否需要配置，交易发送节点等 |
| ├─ control.sh            | 启动脚本                                               |
| ├─ data                  | 数据的存放目录，创世块信息，以及共识和合约的样例       |
| │ ··· ├─ blockchain      | 账本目录                                               |
| │ ··· ├─ keys            | 此节点的地址，具有全局唯一性                           |
| │ ··· ├─ netkeys         | 此节点的网络标识ID，具有全局唯一性                     |
| │ ··· └─ config          | 包括创始的共识，初始的资源数，矿工奖励机制等           |
| ├─ logs                  | 程序日志目录                                           |
| ├─ tmp                   | 临时文件夹，目前存储进程pid                            |

##### 2 确认服务状态
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