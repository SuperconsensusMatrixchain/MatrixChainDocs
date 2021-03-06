####   1.1 下载go sdk 

Go SDK 可以在github上下载:https://github.com/superconsensus/matrix-sdk-go.git

#### 1.2 安装

- ```
  go get github.com/superconsensus/matrix-sdk-go/v2
  ```

#### 1.3 使用 go sdk

#####  1.3.1 建立连接

使用Go SDK和链上数据进行交互，首先需要使用SDK创建一个Client，与节点建立连接。

```
// 创建客户端
xclient, err := xuper.New("127.0.0.1:37101")
```

##### 1.3.2 账户

向链上发起交易前需要建立自己的账户，可以使用SDK创建账户。创建账户时注意保存好助记词或者私钥文件。XuperChain账户助记词中文助记词以及英文助记词

```
// 创建账户 CreateAccount(strength uint8, language int)
//- `strength`：1弱（12个助记词），2中（18个助记词），3强（24个助记词）。
//- `language`：1中文，2英文。
acc, err := account.CreateAccount(2, 1)

// 创建账户并存储到文件中
acc, err = account.CreateAndSaveAccountToFile("./keys", "123", 1, 1)
```

如果已有账户，恢复账户即可。

```
// 通过助记词恢复账户。xuperChain支持中文助记词
acc, err = account.RetrieveAccount("助记词", 1)

// 通过私钥文件恢复账户
acc, err = account.GetAccountFromFile("keys/", "123")
```

新创建的账户余额为0，可以使用其他有余额的账户向该账户转账。对于有了余额的账户，就可以进行转账操作

```
// 普通转账，acc为有余额的账户
tx, err := xclient.Transfer(acc, to.Address, "10")

// 查询普通账户余额
xclient.QueryBalance(to.Address)
```

##### 1.3.3 合约操作

当账户有了余额后，就可以进行转账。如果要进行合约部署、调用等操作，还需要合约账户。合约账号是XuperChain中用于智能合约管理的单元，有普通账户发起交易，在链上生成的一串16位数字的账户，并且由XC开头，以@xuper结尾。执行合约相关操作时，需要用到合约账户

```
//创建合约账户
contractAccount := "XC1234567890123456@xuper"
tx, err := xchainClient.CreateContractAccount(account, contractAccount)

// 转账给合约账户
tx, err := xclient.Transfer(acc, contractAccount, "10")

// 查询合约账户余额
fmt.Println(xclient.QueryBalance(contractAccount)
```

当合约账户有了余额后，就可以进行合约相关操作。XuperChain支持 Wasm 合约，EVM 合约，Native 合约.合约编写，编译相关内容这里不再赘述，这里我们使用Go SDK来部署一个Wasm合约

```
// 设置合约账户
err = account.SetContractAccount(contractAccount)

// 读取Wasm 合约文件
code, err := ioutil.ReadFile(wasmCodePath)

// 构造合约初始化参数
args := map[string]string{
            "creator": "test",
            "key":     "test",
    }

//部署Wasm 合约,contractName为合约名。链上的合约名不能重复
tx, err := xuperClient.DeployWasmContract(account, contractName, code, args)

// 调用Wasm 合约，“increase"为调用合约中的某个具体方法
tx, err = xuperClient.InvokeWasmContract(account, contractName, "increase", args)

// 查询Wasm，需要在合约中有查询接口。该方法不需要消耗手续费
tx, err = xuperClient.QueryWasmContract(account, contractName, "get", args)
```

##### 1.3.4 其他链上查询

除了合约相关操作外，Go SDK还支持链上信息查询，比如区块查询，交易查询，链上状态查询等。

```
// 查询链上状态
bcStatus, err := client.QueryBlockChainStatus("xuper")

// 根据高度查询区块
blockResult, _ := xclient.QueryBlockByHeight(8)
// 根据区块ID查询区块
blockID := "8edfaefd04fa986bfede5a04160b5c200fe63726a4bfed45367da9bf701c70e8"
blockResult, _ := xclient.QueryBlockByID(blockID)

// 根据交易ID查询交易
txID := "c3af3abde7f800dd8782ce8a7559e5bdd7fe712c9efd56d9aeb7f9d2be253730"
tx, err := client.QueryTxByID(txID)
```
