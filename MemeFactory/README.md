# Meme Factory Foundry Project

这是一个面向 EVM 公链的简易 Meme ERC20 Token 发射平台，每个 Meme 都是独立 ERC20 代币，工厂合约通过 Minimal Proxy 方式（Clones）极大降低部署和铸造的 Gas 成本。

## 项目结构

```
meme-factory/
├── src/
│   ├── MemeToken.sol      # ERC20 Token 实现
│   └── MemeFactory.sol    # 工厂合约 + 接收 ETH
├── foundry.toml           # Forge 配置
├── remappings.txt         # OpenZeppelin 路径映射
└── .env                   # 环境变量（RPC_URL, PRIVATE_KEY）
```

## 依赖环境

* macOS 或 Linux
* [Foundry](https://github.com/foundry-rs/foundry)（安装 `forge` 和 `cast`）
* Sepolia 测试网 RPC
* Sepolia 钱包私钥（有测试 ETH）

## 环境变量配置

在项目根目录创建 `.env`：

```bash
export RPC_URL="https://sepolia.infura.io/v3/<你的 Infura 项目 ID>"
export PRIVATE_KEY="0x<你的钱包私钥>"
```
```bash
source .env
```

## 编译

```bash
cd meme-factory
forge clean
forge build
```

## 部署与操作流程

### 1. 部署工厂合约

```bash
forge create src/MemeFactory.sol:MemeFactory \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY
```

输出：`Deployed src/MemeFactory.sol:MemeFactory at 0xFACTORY_ADDRESS`

### 2. 发行新 Meme Token

```bash
FACTORY=0xFACTORY_ADDRESS
cast send \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  $FACTORY \
  "deployMeme(string,uint256,uint256,uint256)" \
  "MEME" 1000 1 10000000000000000
```

* `1000`：总量
* `1`：每次铸造数量
* `0.01 ETH`：单价（wei）

日志会包含：

```
[emitted] MemeDeployed(tokenAddr=0xNEW_TOKEN_ADDRESS, issuer=0xYOUR_ADDR)
```

记录 `0xNEW_TOKEN_ADDRESS`。

### 3. 铸造 Meme（mint）

```bash
TOKEN=0xNEW_TOKEN_ADDRESS
cast send \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  $FACTORY \
  "mintMeme(address)" $TOKEN \
  --value 10000000000000000
```

* `--value` = `perMint * price` = `1 * 0.01 ETH`

### 4. 查询余额

```bash
MY_ADDR=0x<你的钱包地址>
cast call \
  --rpc-url $RPC_URL \
  $TOKEN \
  "balanceOf(address)(uint256)" \
  $MY_ADDR
```

结果应为 `1`。

### 5. 查询 ETH 收款

```bash
cast balance $MY_ADDR    --rpc-url $RPC_URL
cast balance $FACTORY     --rpc-url $RPC_URL
```

* 你的钱包减少 ≈`0.0001 ETH`（1% 分成 + Gas）
* Factory 合约增加 ≈`0.0001 ETH`
