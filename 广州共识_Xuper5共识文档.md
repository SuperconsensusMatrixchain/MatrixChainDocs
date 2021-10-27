Xuper5共识文档
============

> 目前共识整体https://github.com/xuperchain/xupercore

目前支持Single、Pow、Tdpos、Xpos、Poa、Xpoa六种共识类型，其中Xpos为Tdpos配置enable-bft组件，他们都在tdpos文件夹下，XpoA同上。

系统全局支持 
single｜pow｜tdpos｜xpos｜poa | xpoa
六种小写全局标志表示上述类型，注意，enable-bft组件装载影响共识类型。

> enable-bft组件为参考Libra的Chained-HotStuff拜占庭容错实现，代码放置在/kernel/consensus/base/driver/chained-bft/ 文件夹下，通过xuper.json中配置 bft_config 实现装载。以Xpos为例:
``` json
{
    "genesis_consensus":{
        "name": "tdpos",
        "config": {
            .......,
            "bft_config": {}
        }
    }
}
```

后续内容将Tdpos和Xpoa统一成为**Tdpos类**，Poa/Xpoa统一成为**Xpoa类**。


1. 命令行整体介绍
----------
### 1.1 共识状态查询
 **1.1.1 命令行**

所有共识配置文件均在 /data/genesis/${CONSENSUS_NAME}.json 下，替代xuper.json即可。
所有共识都支持共识命令, 该命令返回了当前集群的共识候选人集合等信息，不同类型共识返回信息不同。
``` shell
./bin/xchain-cli consensus status -H:${PORT}
```
每种共识通过实现下述对外接口向该命令行吐出数据:
``` golang
GetConsensusStatus() (base.ConsensusStatus, error)
```

 > 所有共识查看操作，支持rpc接口GetConsensusStatus

 **1.1.2 共识变更操作**

 > 所有共识变更操作，全部通过三代合约预执行-执行实现，因此接口调用也会使用PreExec()和PostTx()

目前仅有Tdpos类和XpoA类支持共识变更操作，其余的操作都会执行失败。
上述两类共识命令使用下述命令行调用。	
部分共识还可通过下述命令查看当前状态机状态（走合约预执行PreExec()）。
``` shell
./bin/xchain-cli consensus invoke --type ${Consensus_Name} --method ${Consensus_Method} (optional flag.....) -H:${PORT}
```

2. Tdpos类介绍
----------
### 2.1 Tdpos状态流程

Tdpos类共识的所有相关存储都可以通过三代合约调用查看，每一步变更操作之后，可通过两个命令进行查看。

【注意】变更之后，并不会立即生效，必须在下一个term生效且假设下一term的高度为H，读取的快照数据为H-3，即任意一次变更，状态读取将在3个块之后生效，注意，下一个term的第一个区块开始，到下一个term的最后一个区块结束，候选人集合不变。

  * 共识状态查询
``` shell
./bin/xchain-cli consensus status -H:${PORT}
```

### 2.2 创世块配置介绍
Tdpos类共识的创世块示例在上述 /data/genesis/tdpos.json 中，下面简要介绍。
``` json
{
    "genesis_consensus":{
        "name": "tdpos",   // 共识名称
        "config": {
            "timestamp": "1559021720000000000",   // 开始时间，Tdpos类会将当前时间与此参数相减，得出时间段，可忽略
            "proposer_num": "2",   // 【重要】候选人集合总人数，配置后暂时无法修改，后续支持
            "period": "3000",   // 【重要】每个块生产固定时间，单位为毫秒，示例所示为3s一个块
            "alternate_interval": "3000",   // 同一轮矿工切换间隙时间，可忽略
            "term_interval": "6000",    // term切换间隙时间，可忽略
            "block_num": "20",  // 【重要】每个候选人在一轮轮数中需要出块的数目
            "vote_unit_price": "1", // 计票单位，暂未使用
            "init_proposer": {
                "1": ["TeyyPLpp9L7QAcxHangtcHTu7HUZ6iydY", "SmJG3rH2ZzYQ9ojxhbRCPwFiE9y6pD1Co"] // 【重要】数组中记录了全部初始候选人节点的address
            }
            // , "bft_config":{}  可选项，即配置chained-bft组件，此部分优先级较低，且比较复杂，最后测试。
        }
    }
}
```

上述创世块配置以时间段划分的例子如下:

| term_interval | block | block | alternate_interval | block |  block | term_interval | block
|------|-----------|-----
| 6000 | 3000 | 3000 | 3000 | 3000 |  3000 | 6000| 3000 
| wait | minerA | minerA | wait | minerB |  minerB | wait | minerA


xuperchain中的Tdpos类介绍如下

https://xuperchain.readthedocs.io/zh/latest/design_documents/xpos.html

实际上，简单的说，就是指定一个候选人集合的数目，和每个候选人在一轮中需要出块的数目，系统启动之后，会按照轮数递增出块。

同一轮中，候选人A出N个块，紧接着B出N个块，直至遍历结束完成当前轮数。

需注意的是，当某个候选人(也就是当前矿工)卡死的时候，整个系统会卡死，直至其轮值时间结束，下一个矿工继续出块，因此term并不一定会和高度严格绑定。

### 2.3 投票流程介绍
Tdpos类命令行操作，仅限变更目前的proposer集合address地址，需要两步完成

某节点发起候选人提名<命令行操作>  即nominate，发起需要是一个acl，该acl包含被提名人的地址，走多签流程完成候选人池的修改。

节点们对候选人池进行投票<命令行操作> 即vote，对候选人池子中的address投票。

在每轮term开始时，会检查候选人投票池子的 TopK名候选人(K=${proposer_num}) 标示为该轮候选人集合。

注意，若投票的目标候选人<${proposer_num} 投票并不会生效

### 2.4  原生代币生成

Tdpos的先决条件是必须先生成相关代币，通过下述命令生成。代币的生成在任意节点皆可触发，但只会按照创世块的配置分配

``` shell
// 代币初始化，Tdpos候选人变更操作前应先操作该命令
./bin/xchain-cli governToken init --fee ${FEE}
 
// 代币查询
./bin/xchain-cli governToken query -a ${ADDRESS}
 
// 代币转账，可转账给address或者acl账户，注意下述投票时必须确保acl或者address账户拥有代币，即先向账户发起transfer，否则会报失败错误
./bin/xchain-cli governToken transfer --to ${ADDRESS} --amount ${AMOUNT} --fee ${FEE}
```
注意下述提案投票时必须确保acl或者address账户拥有代币，即先向账户发起transfer，否则会报失败错误。

### 2.5  提名候选人流程

 **2.5.1 合约ACL**

 提名候选人需要通过合约acl实现（若A提名B，则需要建立A、B的acl账户，并保证两者均签名才能通过提案）。合约acl多签流程如下。

``` shell
./bin/xchain-cli account new --desc account.des --fee 1000
./bin/xchain-cli transfer --to XC1111111111111111@xuper --amount 10000000 --fee 1000
```

``` shell
// account.des
{
    "module_name": "xkernel",
    "method_name": "NewAccount",
    "contract_name": "$acl",
    "args" : {
        "account_name": "1111111111111111",
        "acl": "{\"pm\": {\"rule\": 1,\"acceptValue\": 0.6},\"aksWeight\": {\"TeyyPLpp9L7QAcxHangtcHTu7HUZ6iydY\": 0.5, \"SmJG3rH2ZzYQ9ojxhbRCPwFiE9y6pD1Co\": 0.5}}"}
}
```
注意应有文件 data/acl/addrs
``` shell
// addrs
XC1111111111111111@xuper/TeyyPLpp9L7QAcxHangtcHTu7HUZ6iydY
XC1111111111111111@xuper/SmJG3rH2ZzYQ9ojxhbRCPwFiE9y6pD1Co
```

 **2.5.2 提名候选人**

提名之前要求账户有足够的治理代币，使用`./bin/xchain-cli governToken buy --amount 10000000 --fee 1000 （--desc "ss"）`

 ``` shell
./bin/xchain-cli consensus invoke --type tdpos --method nominateCandidate --isMulti --account ${ACL_ACCOUNT} --fee ${1000_IF_NEED} --desc ${NOMINATE_FILE} -H:${PORT}
// default: 后续会生成一个tx.out在当前目录下
// default: 注意需要在建立/data/acl/addrs，标明提名人和被提名人信息
// default: 上述走多签流程
 
 
./bin/xchain-cli multisig sign --tx=./tx.out --output=./key1.sign
./bin/xchain-cli multisig sign --tx=./tx.out  --keys ${被提名人keys地址}  --output=./key2.sign
./bin/xchain-cli multisig send --tx ./tx.out ./key1.sign,./key2.sign ./key1.sign,./key2.sign -H:${PORT}
// 成功后会生成txid
 ```
``` shell
// nominate_file
{
    "candidate": "SmJG3rH2ZzYQ9ojxhbRCPwFiE9y6pD1Co",
    "amount": "1000000",
    "ratio": "1"
}
```

### 2.6  投票流程

投票命令如下。
``` shell
./bin/xchain-cli consensus invoke --type tdpos --method voteCandidate --fee ${1000_IF_NEED} --desc ${VOTE_FILE} -H:${PORT} (--isMulti[Optional] --account ${ACCOUNT_IF_NEED}[Optional])
// default: 成功后会生成txid
 
// optional流程，多签流程
// optional: 如果有--account --isMulti flag后续会生成一个tx.out在当前目录下，操作内容和nominate一样
// optional: 注意需要在建立/data/acl/addrs，标明提名人和被提名人信息
// optional: 上述走多签流程
./bin/xchain-cli multisig sign --tx=./tx.out --output=./key1.sign
./bin/xchain-cli multisig sign --tx=./tx.out  --keys ${acl keys地址}  --output=./key2.sign
./bin/xchain-cli multisig send --tx ./tx.out ./key1.sign,./key2.sign ./key1.sign,./key2.sign -H:${PORT}
// 成功后会生成txid
```
``` shell
// vote_file
    {
        "candidate": "iYjtLcW6SVCiousAb5DFKWtWroahhEj4u",
        "amount": "10"
    }
```

### 2.7 撤销投票流程
撤销投票流程如下。
``` shell
./bin/xchain-cli consensus invoke --type tdpos --method revokeVote --fee ${1000_IF_NEED} --desc ${REVOKE_VOTE_FILE} -H:${PORT} (--account ${ACCOUNT_IF_NEED}[Optional]  --isMulti[Optional])
 
// 走default还是走optional流程，取决于四中vote是否使用acl账户
// default: 成功后会生成txid
// optional流程，多签流程
// optional: 如果有--account --isMulti flag后续会生成一个tx.out在当前目录下，操作内容和nominate一样
// optional: 注意需要在建立/data/acl/addrs，标明提名人和被提名人信息
// optional: 上述走多签流程
./bin/xchain-cli multisig sign --tx=./tx.out --output=./key1.sign
./bin/xchain-cli multisig sign --tx=./tx.out  --keys ${acl keys地址}  --output=./key2.sign
./bin/xchain-cli multisig send --tx ./tx.out ./key1.sign,./key2.sign ./key1.sign,./key2.sign -H:${PORT}
// 成功后会生成txid
```
``` shell
// revoke_vote_file
{
    "candidate": "iYjtLcW6SVCiousAb5DFKWtWroahhEj4u",
    "amount": "1"
}
```

### 2.8 撤销候选人流程
撤销候选人流程如下。
``` shell
./bin/xchain-cli consensus invoke --type tdpos --method revokeNominate --account ${ACCOUNT_IF_NEED} --isMulti --fee ${1000_IF_NEED} --desc ${REVOKE_NOMINATE_FILE} -H:${PORT}
 
// default: 会生成一个tx.out在当前目录下，操作内容和nominate一样
// default: 注意需要在建立/data/acl/addrs，标明提名人和被提名人信息
// default: 上述走多签流程
./bin/xchain-cli multisig sign --tx=./tx.out --output=./key1.sign
./bin/xchain-cli multisig sign --tx=./tx.out  --keys ${acl keys地址}  --output=./key2.sign
./bin/xchain-cli multisig send --tx ./tx.out ./key1.sign,./key2.sign ./key1.sign,./key2.sign -H:${PORT}
// 成功后会生成txid
```
``` shell
// revoke_nominate_file
{
    "candidate": "iYjtLcW6SVCiousAb5DFKWtWroahhEj4u",
    "amount": "1000000" // 与提名时数量一致
}
```