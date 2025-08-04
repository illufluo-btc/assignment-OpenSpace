// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./MemeToken.sol";

contract MemeFactory {
    address public implementation;

    address payable public projectOwner;

    address[] public allMemes;

    mapping(address => address[]) public issuerMemes;

    event MemeDeployed(address indexed tokenAddr, address indexed issuer);

    constructor() {
        implementation = address(new MemeToken());
        projectOwner   = payable(msg.sender);
    }

    function deployMeme(
        string memory symbol,
        uint256 totalSupply,
        uint256 perMint,
        uint256 price
    ) external {
        address clone = Clones.clone(implementation);

        MemeToken(clone).initialize(
            "MemeToken",
            symbol,
            totalSupply,
            perMint,
            price,
            msg.sender
        );

        allMemes.push(clone);
        issuerMemes[msg.sender].push(clone);
        emit MemeDeployed(clone, msg.sender);
    }

    function mintMeme(address tokenAddr) external payable {
        MemeToken(tokenAddr).mint{ value: msg.value }(msg.sender);
    }

    receive() external payable {}

    fallback() external payable {}
}
