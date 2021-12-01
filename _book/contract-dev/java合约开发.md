### 1.1 环境准备

目前 XuperChain 节点主要运行在linux和mac上，windows不能运行 XuperChain 节点。

1. 编译Java sdk：Java版本不低于Java1.8版本
2. 包管理器：maven，mvn版本3.6+

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

### 1.3 java合约开发sdk

java合约sdk[java-sdk](https://https://github.com/superconsensus/contract-sdk-java.git),更多合约例子参考example中的文件。

### 1.4 合约编写

参考例子

```
package com.baidu.xuper.example;

import java.math.BigInteger;

import com.baidu.xuper.Context;
import com.baidu.xuper.Contract;
import com.baidu.xuper.ContractMethod;
import com.baidu.xuper.Driver;
import com.baidu.xuper.Response;

/**
* Counter
*/
public class Counter implements Contract {

    @Override
    @ContractMethod
    public Response initialize(Context ctx) {
        return Response.ok("ok".getBytes());
    }

    @ContractMethod
    public Response increase(Context ctx) {
        byte[] key = ctx.args().get("key");
        if (key == null) {
            return Response.error("missing key");
        }
        BigInteger counter;
        byte[] value = ctx.getObject(key);
        if (value != null) {
            counter = new BigInteger(value);
        } else {
            ctx.log("key " + new String(key) + " not found, initialize to zero");
            counter = BigInteger.valueOf(0);
        }
        ctx.log("get value " + counter.toString());
        counter = counter.add(BigInteger.valueOf(1));
        ctx.putObject(key, counter.toByteArray());

        return Response.ok(counter.toString().getBytes());
    }

    @ContractMethod
    public Response get(Context ctx) {
        byte[] key = ctx.args().get("key");
        if (key == null) {
            return Response.error("missing key");
        }
        BigInteger counter;
        byte[] value = ctx.getObject(key);
        if (value != null) {
            counter = new BigInteger(value);
        } else {
            return Response.error("key " + new String(key) + " not found)");
        }
        ctx.log("get value " + counter.toString());

        return Response.ok(counter.toString().getBytes());
    }

    public static void main(String[] args) {
        Driver.serve(new Counter());
    }
}
```

java合约的整体框架结构跟c++、go合约一样，在表现形式上稍微有点不一样：

- c++合约使用 **DEFINE_METHOD** 来定义合约方法，go通过结构体方法来定义合约方法，java通过定义class类方法来定义合约。
- c++通过 **ctx->ok** 来返回合约数据，go通过返回 **code.Response** 对象来返回合约数据，java通过 **Response.ok** 来返回合约数据。
- java合约需要在main函数里面调用 **Driver.serve** 来启动合约。

### 1.5 合约编译

java合约使用如下命令来编译合约

```
cd contractsdk/java/example/counter
mvn package -f pom.xml
# 产出二进制文件target/counter-0.1.0-jar-with-dependencies.jar，用于合约部署
```

### 1.6 合约部署调用

native合约和wasm合约在合约部署和合约执行上通过 **native** 和 **wasm** 字段进行区分。

不同语言的合约通过 **–runtime** 参数进行指定，完整命令如下。

```
# 部署golang native合约
xchain-cli native deploy --account XC1111111111111111@xuper --fee 15587517 --runtime java counter-0.1.0-jar-with-dependencies.jar --cname javacounter
```

- `--runtime c` ：表示部署的是c++合约
- `--runtime go` ：表示部署的是golang合约
- `--runtime java`：表示部署的是java合约