// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NFTMarketLowGas {
    IERC20 public immutable token;
    IERC721 public immutable nft;
    // 高位160位存seller，低位96位存price
    mapping(uint256 => uint256) private _listing;

    event ListingCreated(uint256 indexed tokenId, uint96 price, address indexed seller);
    event ListingCancelled(uint256 indexed tokenId, address indexed seller);
    event ListingPurchased(uint256 indexed tokenId, uint96 price, address indexed seller, address indexed buyer);

    constructor(address tokenAddr, address nftAddr) {
        token = IERC20(tokenAddr);
        nft = IERC721(nftAddr);
    }

    function createListing(uint256 tokenId, uint96 price) external {
        require(nft.ownerOf(tokenId) == msg.sender, "NFTMarket: not owner");
        require(price > 0, "NFTMarket: invalid price");
        require(_listing[tokenId] == 0, "NFTMarket: already listed");
        _listing[tokenId] = (uint256(uint160(msg.sender)) << 96) | price;
        emit ListingCreated(tokenId, price, msg.sender);
    }

    function cancelListing(uint256 tokenId) external {
        uint256 data = _listing[tokenId];
        address seller = address(uint160(data >> 96));
        require(data != 0, "NFTMarket: not listed");
        require(seller == msg.sender, "NFTMarket: not seller");
        delete _listing[tokenId];
        emit ListingCancelled(tokenId, seller);
    }

    function purchase(uint256 tokenId) external {
        uint256 data = _listing[tokenId];
        address seller = address(uint160(data >> 96));
        uint96 price = uint96(data);
        require(data != 0, "NFTMarket: not listed");
        require(token.transferFrom(msg.sender, seller, price), "NFTMarket: payment failed");
        nft.transferFrom(seller, msg.sender, tokenId);
        delete _listing[tokenId];
        emit ListingPurchased(tokenId, price, seller, msg.sender);
    }

    function getListing(uint256 tokenId) external view returns (address seller, uint96 price) {
        uint256 data = _listing[tokenId];
        if (data == 0) return (address(0), 0);
        seller = address(uint160(data >> 96));
        price = uint96(data);
    }
}