// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/NFTMarket.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MockERC20 is ERC20 {
    address private immutable market;

    constructor(address _market) ERC20("Mock Token", "MTK") {
        market = _market;
        _mint(msg.sender, 1000000 * 10**18);
    }

    function mint(address to, uint256 amount) public {
        require(to != market, "MockERC20: cannot mint to market contract");
        _mint(to, amount);
    }
}

contract MockERC721 is ERC721 {
    constructor() ERC721("Mock NFT", "MNFT") {}

    function mint(address to, uint256 tokenId) public {
        _mint(to, tokenId);
    }
}

contract NFTMarketTest is Test {
    NFTMarket market;
    MockERC20 token;
    MockERC721 nft;
    address seller = address(0x1);
    address buyer = address(0x2);
    address other = address(0x3);

    event NFTListed(uint256 indexed tokenId, uint256 price, address indexed seller);
    event NFTBought(uint256 indexed tokenId, uint256 price, address indexed seller, address indexed buyer);

    function setUp() public {
        market = new NFTMarket(address(0), address(0)); // Temporary placeholder
        token = new MockERC20(address(market));
        nft = new MockERC721();
        market = new NFTMarket(address(token), address(nft));

        // Mint tokens and NFTs
        token.mint(buyer, 10000 * 10**18);
        nft.mint(seller, 1);

        // Approve market contract
        vm.startPrank(seller);
        nft.setApprovalForAll(address(market), true);
        vm.stopPrank();

        vm.startPrank(buyer);
        token.approve(address(market), type(uint256).max);
        vm.stopPrank();
    }

    // Test listing NFT
    function testListNFTSuccess() public {
        vm.startPrank(seller);
        vm.expectEmit(true, true, true, true);
        emit NFTListed(1, 100, seller);
        assertTrue(market.list(1, 100));
        assertEq(market.prices(1), 100);
        assertEq(market.sellers(1), seller);
        vm.stopPrank();
    }

    function test_RevertWhen_ListNotOwner() public {
        vm.startPrank(buyer);
        vm.expectRevert("NFTMarket: not owner");
        market.list(1, 100);
        vm.stopPrank();
    }

    function test_RevertWhen_ListZeroPrice() public {
        vm.startPrank(seller);
        vm.expectRevert("NFTMarket: price must be greater than zero");
        market.list(1, 0);
        vm.stopPrank();
    }

    // Test buying NFT
    function testBuyNFTSuccess() public {
        vm.startPrank(seller);
        market.list(1, 100);
        vm.stopPrank();

        vm.startPrank(buyer);
        vm.expectEmit(true, true, true, true);
        emit NFTBought(1, 100, seller, buyer);
        assertTrue(market.buyNFT(1));
        assertEq(nft.ownerOf(1), buyer);
        assertEq(token.balanceOf(seller), 100);
        assertEq(market.prices(1), 0);
        assertEq(market.sellers(1), address(0));
        vm.stopPrank();
    }

    function test_RevertWhen_BuyNotListed() public {
        vm.startPrank(buyer);
        vm.expectRevert("NFTMarket: NFT not listed");
        market.buyNFT(1);
        vm.stopPrank();
    }

    function test_RevertWhen_BuyOwnNFT() public {
        vm.startPrank(seller);
        market.list(1, 100);
        vm.expectRevert("ERC20: insufficient allowance");
        market.buyNFT(1);
        vm.stopPrank();
    }

    function test_RevertWhen_BuyTwice() public {
        vm.startPrank(seller);
        market.list(1, 100);
        vm.stopPrank();

        vm.startPrank(buyer);
        market.buyNFT(1);
        vm.expectRevert("NFTMarket: NFT not listed");
        market.buyNFT(1);
        vm.stopPrank();
    }

    function test_RevertWhen_BuyInsufficientTokens() public {
        vm.startPrank(seller);
        market.list(1, 1000000 * 10**18 + 1);
        vm.stopPrank();

        vm.startPrank(buyer);
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        market.buyNFT(1);
        vm.stopPrank();
    }

    // Fuzz testing
    function testFuzzListAndBuy(uint256 price, address randomBuyer) public {
        vm.assume(price >= 0.01 * 10**18 && price <= 10000 * 10**18);
        vm.assume(randomBuyer != address(0) && randomBuyer != seller);

        // Mint tokens to random buyer
        token.mint(randomBuyer, price);
        vm.startPrank(randomBuyer);
        token.approve(address(market), type(uint256).max);
        vm.stopPrank();

        // List NFT
        vm.startPrank(seller);
        market.list(1, price);
        vm.stopPrank();

        // Buy NFT
        vm.startPrank(randomBuyer);
        market.buyNFT(1);
        assertEq(nft.ownerOf(1), randomBuyer);
        assertEq(token.balanceOf(seller), price);
        vm.stopPrank();
    }
}