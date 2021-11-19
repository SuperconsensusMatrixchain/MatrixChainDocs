acl 分为两部份，第一个是合约账号的acl, 第二个是合约方法的acl。

#### 1.1 个人账号，合约账号，合约关系依赖

个人账号管理合约账号需要符合合约账号的acl： 账号的创建、添加和删除AK、设置AK权重、权限模型

合约方法的acl设置依赖合约账号的acl：背书阈值，AK集合 （合约方法acl支持的2种权限模型）



需要注意的是：合约账号的acl提供了5种模型，但合约方法的acl模型仅支持背书阈值，AK集合 。



####  1.2 系统提供修改acl的接口

| 合约接口            | 用途                |
| ------------------- | ------------------- |
| NewAccountMethod    | 创建新的账号        |
| SetAccountACLMethod | 更新账号的ACL       |
| SetMethodACLMethod  | 更新合约Method的ACL |

####  1.3 关于合约方法权限选择

 合约方法调用权限模型目前仅仅支持：

1. 背书阈值：在名单中的AK或Account签名且他们的权重值加起来超过一定阈值，就可以调用合约
2. AK集合: 定义多组AK集合，集合内的AK需要全部签名，集合间只要有一个集合有全部签名即可

合约方法仅仅提供一组人，使用背书背书阈值策略；

合约方法需要多个人管理，可以使用AK集合策略；

没有权限控制，则就是所有用户都可以访问。（solidity）

#### 1.4 设置合约账号的acl

1. 创建合约账号(快捷方式)

```
./bin/xchain-cli account new --account 1111111111111111 # 16位数字组成的字符串
```

此时的ACL是默认的当前节点下拥有这个账号的控制权限。使用命令可以看到acl:

```
./bin/xchain-cli acl query --account XC1111111111111111@xuper
```

```
{
  "pm": {
    "rule": 1,
    "acceptValue": 1
  },
  "aksWeight": {
    "TeyyPLpp9L7QAcxHangtcHTu7HUZ6iydY": 1
  }
}

```

2. 现在需要修改账号的ACL规则。准备SetAccountACL.json文件，写入内容如下：

```json
{
  "module_name": "xkernel",
  "contract_name": "$acl",
  "method_name": "SetAccountAcl",
  "args" : {
    "account_name": "XC1111111111111111@xuper",
    "acl": "{\"pm\": {\"rule\": 1,\"acceptValue\": 0.3},\"aksWeight\": {\"TeyyPLpp9L7QAcxHangtcHTu7HUZ6iydY\": 0.3,\"SmJG3rH2ZzYQ9ojxhbRCPwFiE9y6pD1Co\": 0.3}}"
  }
}
```

3. 搜集需要签名的地址，一般将地址放在 data/acl/addr

```
echo "XC1111111111111111@xuper/$(cat $TestNet/node1/data/keys/address)" > data/acl/addrs
```

4. 生成需要签名的交易
```
./bin/xchain-cli multisig gen --desc SetAccountACL.json --fee 1000000
```

 5. 签名

```
./bin/xchain-cli multisig sign --output sign.out
```

 6. 发送交易

```
./bin/xchain-cli multisig send --tx tx.out sign.out sign.out
```

7. 此时成功设置合约账号的acl。查询合约账号的acl：

```
/bin/xchain-cli acl query --account XC1111111111111111@xuper
```



####  1.5 设置合约方法的acl

在没有给合约方法设置ACL的时候，基本上每个账号都可以调用到合约方法。合约方法设置acl的时候需要满足所属合约账号的acl。 


1. 查询合约方法的acl 。

```
./bin/xchain-cli acl query --contract nftevm --method name
```

​	2.  设置合约方法acl。准备SetMethodACL.json，写入：

```
{
  "module_name": "xkernel",
  "contract_name": "$acl",
  "method_name": "SetMethodAcl",
  "args" : {
    "contract_name": "counter.wasm",
    "method_name": "increase",
    "acl": "{\"pm\": {\"rule\": 1,\"acceptValue\": 1.0},\"aksWeight\": {\"TeyyPLpp9L7QAcxHangtcHTu7HUZ6iydY\": 1.0,\"SmJG3rH2ZzYQ9ojxhbRCPwFiE9y6pD1Co\": 1.0}}"
  }
}
```

3. 生成签名交易

```
./bin/xchain-cli multisig gen --desc SetMethodACL.json --from XC1111111111111111@xuper --fee 1000000
```

4. 搜集签名

```
// node1
./bin/xchain-cli multisig sign --keys  ./data/keys/ --output sign1.out
// node2
./bin/xchain-cli multisig sign --keys ../node2/data/keys/ --output sign2.out
// 发送交易
./bin/xchain-cli multisig send --tx tx.out sign1.out,sign2.out sign1.out,sign2.out
```



#### 1.6 ACL 数据结构

```
// --------   Account and Permission Section -------
enum PermissionRule {
    NULL = 0;             // 无权限控制
    SIGN_THRESHOLD = 1;   // 签名阈值策略
    SIGN_AKSET = 2;       // AKSet签名策略
    SIGN_RATE = 3;        // 签名率策略
    SIGN_SUM = 4;         // 签名个数策略
    CA_SERVER = 5;        // CA服务器鉴权
    COMMUNITY_VOTE = 6;   // 社区治理
}

message PermissionModel {
    PermissionRule rule = 1;
    double acceptValue = 2;    // 取决于用哪种rule, 可以表示签名率，签名数或权重阈值
}

// AK集的表示方法
message AkSet {
    repeated string aks = 1; //一堆公钥
}

message AkSets {
    map<string, AkSet> sets = 1;   // 公钥or账号名集
    string expression = 2;      // 表达式，一期不支持表达式，默认集合内是and，集合间是or
}

// Acl实际使用的结构
message Acl {
    PermissionModel  pm = 1;             // 采用的权限模型
    map<string, double>  aksWeight = 2;  // 公钥or账号名  -> 权重
    AkSets akSets = 3;
```

