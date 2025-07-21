// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
}

contract TokenBank {
    IERC20 public token;
    mapping(address => uint256) public deposits;

    constructor(address _tokenAddress) {
        token = IERC20(_tokenAddress);
    }

    function deposit(uint256 _amount) external {
        require(_amount > 0, "TokenBank: deposit amount must be greater than 0");
        require(token.allowance(msg.sender, address(this)) >= _amount, "TokenBank: insufficient allowance");
        require(token.transferFrom(msg.sender, address(this), _amount), "TokenBank: transfer failed");
        deposits[msg.sender] += _amount;
    }

    function withdraw(uint256 _amount) external {
        require(_amount > 0, "TokenBank: withdraw amount must be greater than 0");
        require(deposits[msg.sender] >= _amount, "TokenBank: insufficient deposit balance");
        deposits[msg.sender] -= _amount;
        require(token.transfer(msg.sender, _amount), "TokenBank: transfer failed");
    }
}
