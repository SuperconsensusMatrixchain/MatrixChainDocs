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

### 1.3 solc编译器安装

```
sudo add-apt-repository ppa:ethereum/ethereum
sudo add-apt-repository ppa:ethereum/ethereum-dev
sudo apt-get update
sudo apt-get install solc
```



### 1.4 编写合约

参考样例

```
pragma solidity >=0.0.0;

contract Counter {
    address owner;
    mapping (string => uint256) values;

    constructor() public{
        owner = msg.sender;
    }

    function increase(string memory key) public payable{
        values[key] = values[key] + 1;
    }

    function get(string memory key) view public returns (uint) {
        return values[key];
    }

    function getOwner() view public returns (address) {
        return owner;
    }

}
```

### 1.5 编译合约

```
# 通过solc编译合约源码
$ solc --bin --abi Counter.sol -o .
# 合约二进制文件和abi文件分别存放在当前目录下，Counter.bin和Counter.abi
```

- `--bin` ：表示需要生成合约二进制文件
- `--abi` ：表示需要生成合约abi文件，用于合约方法以及参数编解码
- `-o`：表示编译结果输出路径

### 1.6 部署调用合约

```
#部署
./bin/xchain-cli evm deploy --account XC1111111111111111@xuper --cname counterevm  --fee 5200000 Counter.bin --abi Counter.abi

#调用
# 合约increase方法调用
$ xchain-cli evm invoke --method increase -a '{"key":"stones"}' counterevm --fee 22787517 --abi Counter.abi
# 合约get方法调用
$ xchain-cli evm query --method get -a '{"key":"stones"}' counterevm --abi Counter.abi
```

