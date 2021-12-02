### 1.1 环境准备

目前 XuperChain 节点主要运行在linux和mac上，windows不能运行 XuperChain 节点。

1. go >= 1.12.x && <= 1.13.x
2. g++ >= 4.8.2 或者 clang++ >= 3.3
3. Docker

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

### 1.3 创建合约工程

[xdev](https://https://github.com/superconsensus/xdev.git) 工具是随MatrixChain生态中一个合约编译和测试工具,使用xdev可以很快地对c++合约进行快速的而编译。

```
$ git clone https://github.com/xuperchain/xdev.git
$ make
# 将xdev添加到PATH变量下
$ export PATH=$HOME/xdev/bin:$PATH
```

xdev提供了一个默认的c++合约工程模板

```
$ xdev init hello-cpp
```

### 1.4 编译合约

```
第一次编译的时间会长一点，因为xdev需要下载编译器镜像，以及编译 XuperChain 的标准库。
```

```
$ cd hello-cpp
$ xdev build -o hello.wasm
CC main.cc
LD wasm
```

编译结果为hello.wasm，后面我们使用这个文件来部署合约。

### 1.5 部署合约

```
$ ./bin/xchain-cli wasm deploy --account XC1111111111111111@xuper --cname hello  --fee 5200000 --runtime c ./hello.wasm
contract response: initialize succeed
The gas you cousume is: 151875
The fee you pay is: 5200000
Tx id: 8c33a91c5cf564a28e7b62cad827ba91e19abf961702659dd8b70a3fb872bdf1
```

此命令看起来很长，但是其中很多参数都有默认值，我们先来看一下参数的含义：

> - **wasm deploy** ：此为部署wasm合约的命令参数，不做过多解释
> - **–account XC1111111111111111@xuper** ：此为部署wasm合约的账号（只有合约账号才能进行合约的部署）
> - **–cname hello** ：这里的hello是指部署后在链上的合约名字，可以自行命名（但有规则，长度在4～16字符）
> - **–runtime c** 指明我们部署的是一个c++代码编译的合约，如果是go合约这里填 **go** 即可。
> - **–fee** 为我们部署这个合约所需要的xuper
> - 最后的hello.wasm是合约编译好的文件

### 1.6 合约调用

```
$ ./bin/xchain-cli wasm invoke --method hello --fee 110000 hello
contract response: hello world
The gas you cousume is: 35
The fee you pay is: 110000
Tx id: d8989ad1bfd2d08bd233b7a09a544cb07976fdf3429144c42f6166d28e9ff695
```

参数解释如下：

> - **wasm invoke** 表示我们要调用一个合约
> - **–method hello** 表示我们要调用合约的 **hello** 方法
> - **–fee** 指明我们这次调用合约花费的xuper
> - 最后的参数指明我们调用的合约名字 **hello**

### 1.7 cpp合约sdk

更多合约例子参考[cpp-sdk](https://https://github.com/superconsensus/contract-sdk-cpp.git)，在example中提供更多例子。