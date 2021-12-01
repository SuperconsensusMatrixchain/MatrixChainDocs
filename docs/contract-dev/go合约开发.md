### 1.1 环境准备

目前 XuperChain 节点主要运行在linux和mac上，windows不能运行 XuperChain 节点。

1. go >= 1.12.x && <= 1.13.x
2. g++ >= 4.8.2 或者 clang++ >= 3.3

智能合约只有部署到链上才能运行，因此我们首先要编译并启动xuperchain节点 。参考环境部署小节。

### 1.2 创建合约账号

合约账号用来进行合约管理，比如合约的权限控制等，要部署合约必须创建合约账号，同时合约账号里面需要有充足的xuper来部署合约。

创建合约账号XC1111111111111111@xuper.

```
$ ./bin/xchain-cli account new --account 1111111111111111 --fee 2000
contract response:
        {
            "pm": {
                "rule": 1,
                "acceptValue": 1.0
            },
            "aksWeight": {
                "dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN": 1.0
            }
        }
The gas you cousume is: 1000
The fee you pay is: 2000
Tx id: d62704970705a2682e2bd2c5b4f791065871fd45f64c87815b91d8a00039de35
account name: XC1111111111111111@xuper
```

给合约转账

```
$ ./bin/xchain-cli transfer --to XC1111111111111111@xuper --amount 100000000
cd26657006f6f75f07bd53ad0a7fe74d76985cd592542d8cc87dc3fcdde115f5
```

### 1.3 go合约开发sdk

下载[go合约sdk](https://https://github.com/superconsensus/contract-sdk-go.git),更多合约例子参考example中的文件。

### 1.4 合约编译

```
$ git clone https://github.com/xuperchain/contract-sdk-go.git       // 如果只需要测试，可将该合约代码复制下来
$ cd contract-sdk-go/example/counter
$ go build -o hello
```

### 1.5 合约部署调用

```
# 合约部署
$ xchain-cli native deploy --account XC1111111111111111@xuper --cname counterGo -a '{"creator":"test"}'  --fee 52000000 --runtime go ./hello

# 合约调用
$ xchain-cli native invoke --method increase -a '{"key":"test"}' helloGo --fee 22787517
```

