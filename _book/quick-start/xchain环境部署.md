#### 1.1 准备环境
- 安装go环境，版本为1.13或更高
	下载地址：[golang](https://golang.org/dl/ "golang")
- 安装git
	``` sudo apt install git```

#### 1.2 编译superchian
- 下载xuperchain源码
	* git clone https://github.com/superconsnesus-chain/xuperchain
- 执行命令
```
$ cd xuperchian
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