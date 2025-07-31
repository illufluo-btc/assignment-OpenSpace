// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NFTMarketHighGas {
    IERC20 public token;
    IERC721 public nft;
    mapping(uint256 => uint256) public prices;   // tokenId => price
    mapping(uint256 => address) public sellers;  // tokenId => seller

    event ListingCreated(uint256 indexed tokenId, uint256 price, address indexed seller);
    event ListingCancelled(uint256 indexed tokenId, address indexed seller);
    event ListingPurchased(uint256 indexed tokenId, uint256 price, address indexed seller, address indexed buyer);

    constructor(address tokenAddress, address nftAddress) {
        token = IERC20(tokenAddress);
        nft = IERC721(nftAddress);
    }

    /// createListing
    function createListing(uint256 tokenId, uint256 price) external {
        require(nft.ownerOf(tokenId) == msg.sender, "NFTMarket: not owner");
        require(price > 0, "NFTMarket: price must be > 0");
        require(sellers[tokenId] == address(0), "NFTMarket: already listed");
        sellers[tokenId] = msg.sender;
        prices[tokenId] = price;
        emit ListingCreated(tokenId, price, msg.sender);
    }

    /// cancelListing
    function cancelListing(uint256 tokenId) external {
        require(sellers[tokenId] != address(0), "NFTMarket: not listed");
        require(sellers[tokenId] == msg.sender, "NFTMarket: not seller");
        address seller = sellers[tokenId];
        delete prices[tokenId];
        delete sellers[tokenId];
        emit ListingCancelled(tokenId, seller);
    }

    /// purchase
    function purchase(uint256 tokenId) external {
        require(sellers[tokenId] != address(0), "NFTMarket: not listed");
        uint256 price = prices[tokenId];
        address seller = sellers[tokenId];
        require(token.transferFrom(msg.sender, seller, price), "NFTMarket: payment failed");
        nft.transferFrom(seller, msg.sender, tokenId);
        delete prices[tokenId];
        delete sellers[tokenId];
        emit ListingPurchased(tokenId, price, seller, msg.sender);
    }
}
