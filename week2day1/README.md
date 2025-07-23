## 合约简介

- **BaseERC20.sol**：
  - 一个简化版的 ERC20 代币合约实现。
  - 部署时会铸造 `100000000 * 10^18` 代币，全部分配给部署者账户。
  - 支持常见功能，如 `transfer`、`transferFrom`、`approve` 等。
- **tokenbank.sol**：
  - 一个简单的代币银行合约，允许用户存入和提取指定的 ERC20 代币。
  - 部署时需要传入支持的 ERC20 合约地址。
  - 包含 `deposit` 和 `withdraw` 两个核心函数。

## 在 Remix 测试

1. 打开 [Remix IDE](https://remix.ethereum.org)。
2. 将 `BaseERC20.sol` 和 `tokenbank.sol` 上传到 Remix 的文件管理器中。
3. 在 **Solidity Compiler** 面板选择版本 `0.8.x`，分别编译两个合约文件。
4. 在 **Deploy & Run Transactions** 面板：
   1. 选择 `BaseERC20` 合约，点击 **Deploy**，部署完成后记下合约地址。
   2. 选择 `TokenBank` 合约，部署时输入上一步的 ERC20 合约地址，点击 **Deploy**。
5. 测试存取款操作：
   1. 在 `BaseERC20` 合约中调用 `approve(TokenBank地址, 金额)`，授权银行合约转移代币。
   2. 在 `TokenBank` 合约中调用 `deposit(金额)` 存入代币，或调用 `withdraw(金额)` 提取代币。
