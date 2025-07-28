# Sepolia CLI Wallet & BERC20 Token

这是一个包含命令行钱包脚本 (`wallet.js`) 和 BERC20 合约 (`BaseERC20.sol`) 的示例项目，支持：

* 生成随机钱包（助记词、私钥、地址）
* 查询 Sepolia ETH 余额
* 查询任意 ERC20 代币余额
* 构建并发送 EIP‑1559 ERC20 转账交易
* 使用 `cast` 发送 Sepolia ETH 交易

## 目录结构

```text
├── CLI-wallet/           # 命令行钱包脚本目录
│   ├── wallet.js         # Node.js CLI 钱包脚本
│   ├── package.json      # npm 配置
│   └── .env              # 环境变量（RPC_URL）
└── token-test/           # Foundry 合约测试目录
    ├── src/
    │   └── BaseERC20.sol # BERC20 合约源码
    ├── foundry.toml      # Foundry 配置
    └── lib/              # OpenZeppelin 依赖
```

## 一、环境准备

* Node.js ≥ v18
* npm ≥ v8
* Foundry（`forge` & `cast`）
* Sepolia RPC URL（可通过 Infura 或 Alchemy 获取）

## 二、配置环境变量

在 `CLI-wallet` 目录下创建 `.env`：

```env
RPC_URL="https://sepolia.infura.io/v3/<你的InfuraKey>"
```

## 三、安装依赖

```bash
# 进入钱包脚本目录
cd CLI-wallet
npm install ethers dotenv
```

## 四、命令行钱包使用

### 1. 生成新钱包

```bash
node wallet.js gen
```

输出：助记词、私钥、地址。

### 2. 查询 Sepolia ETH 余额

```bash
node wallet.js balance <你的私钥>
```

### 3. 查询 ERC20 余额

```bash
node wallet.js tokenbalance <你的私钥> <合约地址>
```

### 4. ERC20 转账

```bash
node wallet.js transfer <你的私钥> <合约地址> <接收地址> <数量>
```

### 5. Sepolia ETH 转账

```bash
# 使用 cast 发送 0.01 ETH
cast send --rpc-url $RPC_URL \
  --private-key <你的私钥> \
  <接收地址> \
  --value 10000000000000000
```

## 五、部署和测试 BERC20 合约

本项目使用 Foundry 的 `forge create` 命令直接将 `BaseERC20.sol` 合约部署到 Sepolia 网络，自动铸造初始代币并分发到部署者地址。

1. 安装 OpenZeppelin 依赖（如未安装）：

   ```bash
   npm install @openzeppelin/contracts
   ```

2. 配置 `foundry.toml`：

   ```toml
   [profile.default]
   src = "src"
   out = "out"
   libs = ["lib", "node_modules/@openzeppelin/contracts"]
   rpc_url = "$RPC_URL"
   ```

3. 部署合约：

```bash
forge create src/BaseERC20.sol:BaseERC20 \
  --private-key <你的私钥> \
  --broadcast
```

4. 记录部署后的合约地址（`Deployed to: 0x...`）。


```

## 六、查看交易

* Sepolia Etherscan: [https://sepolia.etherscan.io](https://sepolia.etherscan.io)
* 地址查询：`/address/<你的地址>`
* 交易查询：`/tx/<交易Hash>`
