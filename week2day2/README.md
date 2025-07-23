## 合约简介

- **ExtendedERC20.sol**  
  扩展的[BaseERC20.sol](https://github.com/illufluo-btc/assignment-OpenSpace/blob/main/week2day1/BaseERC20.sol)，新增了 `transferWithCallback` 函数：  
  - 在调用 `transferWithCallback` 转账时，若接收地址为合约，则自动调用目标合约的 `tokensReceived()` 方法，完成回调通知。  
  - 继承自基础 ERC20，保留标准代币功能。

- **TokenBankV2.sol**  
  继承自[tokenbank.sol](https://github.com/illufluo-btc/assignment-OpenSpace/blob/main/week2day1/tokenbank.sol)，支持接收扩展的 ERC20 代币：  
  - 实现 `tokensReceived` 函数，用于在收到代币时自动记录存款信息。  
  - 允许用户通过 `transferWithCallback` 直接将代币存入银行，无需先授权再调用存款函数。  
  - 兼容普通 ERC20 存取款功能。

## 功能亮点

- 通过 `transferWithCallback` 实现更智能的代币交互，目标合约收到代币后能即时响应。  
- 简化用户操作流程，提升用户体验。  
- `TokenBankV2` 作为代币银行，自动处理代币存款回调，保证账务准确。

## 在 Remix 测试

1. 打开 [Remix IDE](https://remix.ethereum.org)。  
2. 上传 `ExtendedERC20.sol` 和 `TokenBankV2.sol` 到 Remix 文件管理器。  
3. 在 **Solidity Compiler** 选择版本 `0.8.x`，分别编译两个合约。  
4. 在 **Deploy & Run Transactions** 面板：  
   1. 部署 `ExtendedERC20` 合约。  
   2. 部署 `TokenBankV2` 合约，构造参数为第 1 步部署的 `ExtendedERC20` 合约地址。
       
