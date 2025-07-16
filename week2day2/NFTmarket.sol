// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
}

interface IERC721 {
    function transferFrom(address from, address to, uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns (address);
}

interface ITokenReceiver {
    function tokensReceived(address sender, uint256 amount, bytes calldata data) external;
}

contract NFTMarket is ITokenReceiver {
    IERC20 public token;
    IERC721 public nft;
    mapping(uint256 => uint256) public prices; // tokenId => price in tokens
    mapping(uint256 => address) public sellers; // tokenId => seller address

    constructor(address _tokenAddress, address _nftAddress) {
        token = IERC20(_tokenAddress);
        nft = IERC721(_nftAddress);
    }

    function list(uint256 _tokenId, uint256 _price) public returns (bool) {
        require(nft.ownerOf(_tokenId) == msg.sender, "NFTMarket: not owner");
        require(_price > 0, "NFTMarket: price must be greater than zero");

        prices[_tokenId] = _price;
        sellers[_tokenId] = msg.sender;

        return true;
    }

    function buyNFT(uint256 _tokenId) public returns (bool) {
        require(prices[_tokenId] > 0, "NFTMarket: NFT not listed");
        require(token.transferFrom(msg.sender, sellers[_tokenId], prices[_tokenId]), "NFTMarket: transfer failed");

        address seller = sellers[_tokenId];
        nft.transferFrom(seller, msg.sender, _tokenId);

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
        require(token.transfer(seller, amount), "NFTMarket: transfer to seller failed");

        nft.transferFrom(seller, sender, tokenId);

        delete prices[tokenId];
        delete sellers[tokenId];
    }
}
