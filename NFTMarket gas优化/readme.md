# NFT Marketplace 项目

本仓库包含一个基于 ERC20/ERC721 的简易 NFT 市场（NFT Marketplace），提供 **HighGas** 与 **LowGas** 两个版本，用于对比 Gas 消耗。

## 文件结构 / File Structure

* **BaseERC20.sol**：卖家（Account1）部署，用于生成初始 ERC20 支付代币。
* **TestNFT.sol**：卖家部署，用于铸造 NFT。
* **NFTMarketHighGas.sol**：HighGas 版本，使用独立映射（mappings）和 `require` 验证。
* **NFTMarketLowGas.sol**：LowGas 优化版，使用单一打包映射（packed mapping）、`immutable` 字段和授权检查。

## 部署与测试 / Deployment & Testing

1. 使用 Solidity ^0.8.0 编译所有合约。
2. **账号一（Seller）**：部署 **BaseERC20.sol**，获得初始 ERC20 代币，并将部分代币转给**账号二（Buyer）**。
3. **账号一（Seller）**：部署 **TestNFT.sol**，执行 `mint` 铸造 NFT。
4. 部署 **NFTMarketHighGas.sol** 与 **NFTMarketLowGas.sol**，构造函数传入 `tokenAddress` 与 `nftAddress`。
5. **授权**：

   * 卖家授权市场合约转移 NFT：

     ```js
     await nft.connect(seller).approve(market.address, tokenId);
     // or
     await nft.connect(seller).setApprovalForAll(market.address, true);
     ```
   * 买家授权市场合约消费 ERC20：

     ```js
     await token.connect(buyer).approve(market.address, price);
     ```
6. 在两个合约上分别执行：

   ```js
   await market.createListing(tokenId, price);
   await market.cancelListing(tokenId);
   await market.purchase(tokenId);
   ```

   对比 Gas 消耗。

## Gas 优化总结 / Gas Optimization Summary

**LowGas 版本** 通过以下方法显著降低 Gas：

1. **Packed Storage**：单一 `mapping(uint256 => uint256)` 存储卖家地址（160 位）与价格（96 位），减少 Storage 写入次数。
2. **`immutable` 字段**：将 `token` 与 `nft` 声明为 `immutable`，降低多次读取开销。
3. **授权检查**（Authorization Check）：在 `createListing` 中验证 ERC721 授权，避免额外的 NFT 转移操作。
4. **代码体积精简**：使用内联 `require`，去除集中声明的自定义错误，缩减合约字节码大小。

## Gas 使用对比 / Gas Report Comparison

| 操作 / Operation                  | HighGas (v1) | LowGas (v2) |
| ------------------------------- | -----------: | ----------: |
| 部署 / Deployment                 |      932,730 |     807,633 |
| 上架 / createListing(tokenId,100) |       77,034 |      52,552 |
| 取消 / cancelListing(tokenId)     |       27,248 |      23,591 |
| 购买 / purchase(tokenId)          |       96,559 |      91,718 |

*数据来源于 `gas_report_v1.txt` 和 `gas_report_v2.txt`*

---

欢迎反馈与 PR！ / Welcome feedback and contributions!
