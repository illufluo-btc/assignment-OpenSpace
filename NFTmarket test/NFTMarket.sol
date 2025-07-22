// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface ITokenReceiver {
    function tokensReceived(address sender, uint256 amount, bytes calldata data) external;
}

contract NFTMarket is ITokenReceiver {
    IERC20 public token;
    IERC721 public nft;
    mapping(uint256 => uint256) public prices; // tokenId => price in tokens
    mapping(uint256 => address) public sellers; // tokenId => seller address

    event NFTListed(uint256 indexed tokenId, uint256 price, address indexed seller);
    event NFTBought(uint256 indexed tokenId, uint256 price, address indexed seller, address indexed buyer);

    constructor(address _tokenAddress, address _nftAddress) {
        token = IERC20(_tokenAddress);
        nft = IERC721(_nftAddress);
    }

    function list(uint256 _tokenId, uint256 _price) public returns (bool) {
        require(nft.ownerOf(_tokenId) == msg.sender, "NFTMarket: not owner");
        require(_price > 0, "NFTMarket: price must be greater than zero");

        prices[_tokenId] = _price;
        sellers[_tokenId] = msg.sender;

        emit NFTListed(_tokenId, _price, msg.sender);

        return true;
    }

    function buyNFT(uint256 _tokenId) public returns (bool) {
        require(prices[_tokenId] > 0, "NFTMarket: NFT not listed");
        require(token.transferFrom(msg.sender, sellers[_tokenId], prices[_tokenId]), "NFTMarket: transfer failed");

        address seller = sellers[_tokenId];
        nft.transferFrom(seller, msg.sender, _tokenId);

        emit NFTBought(_tokenId, prices[_tokenId], seller, msg.sender);

        delete prices[_tokenId];
        delete sellers[_tokenId];

        return true;
    }

    function tokensReceived(address sender, uint256 amount, bytes calldata data) external override {
        require(msg.sender == address(token), "NFTMarket: caller must be token contract");
        require(amount > 0, "NFTMarket: amount must be greater than zero");

        uint256 tokenId = abi.decode(data, (uint256));
        require(prices[tokenId] > 0, "NFTMarket: NFT not listed");
        require(amount >= prices[tokenId], "NFTMarket: insufficient token amount");

        address seller = sellers[tokenId];
        require(token.transfer(seller, prices[tokenId]), "NFTMarket: transfer to seller failed");
        if (amount > prices[tokenId]) {
            require(token.transfer(sender, amount - prices[tokenId]), "NFTMarket: refund failed");
        }

        nft.transferFrom(seller, sender, tokenId);

        delete prices[tokenId];
        delete sellers[tokenId];
    }
}