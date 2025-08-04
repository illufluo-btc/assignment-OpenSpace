// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MemeToken {
    string public name;
    string public symbol;
    uint8  public decimals = 18;

    uint public totalSupplyLimit;
    uint public perMint;
    uint public price;
    uint public minted;

    address public factory;
    address public issuer;

    bool private initialized;

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    function initialize(
        string memory name_,
        string memory symbol_,
        uint totalSupply_,
        uint perMint_,
        uint price_,
        address issuer_
    ) external {
        require(!initialized, "Already initialized");
        initialized = true;

        name             = name_;
        symbol           = symbol_;
        totalSupplyLimit = totalSupply_;
        perMint          = perMint_;
        price            = price_;
        factory          = msg.sender;
        issuer           = issuer_;
    }

    function approve(address spender, uint amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Balance too low");
        balanceOf[msg.sender] -= amount;
        balanceOf[to]          += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint amount) external returns (bool) {
        require(allowance[from][msg.sender] >= amount, "Allowance exceeded");
        allowance[from][msg.sender] -= amount;
        require(balanceOf[from] >= amount, "Balance too low");
        balanceOf[from] -= amount;
        balanceOf[to]   += amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function mint(address to) external payable {
    require(minted + perMint <= totalSupplyLimit, "Exceeds total supply");
    require(msg.value == price * perMint,    "Incorrect payment");

    minted += perMint;
    uint fee          = (msg.value * 1) / 100;
    uint issuerAmount = msg.value - fee;

    payable(issuer).transfer(issuerAmount);
    payable(factory).transfer(fee);

    balanceOf[to] += perMint;
    emit Transfer(address(0), to, perMint);
}
}
