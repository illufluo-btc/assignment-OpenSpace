// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/// @title TestNFT — 简易 ERC721 用于测试 NFTMarket
contract TestNFT is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("TestNFT", "TNFT") {
        // 部署时铸造第一个 NFT 给部署者，方便立刻测试
        _tokenIds.increment();
        _mint(msg.sender, _tokenIds.current());
    }

    /// @notice 给任意地址铸造新 Token，tokenId 自增
    function mint(address to) external returns (uint256) {
        _tokenIds.increment();
        uint256 newId = _tokenIds.current();
        _mint(to, newId);
        return newId;
    }
}
