// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/console.sol";

contract Bank {
    mapping(address => uint256) public deposits;
    address public admin;
    struct Depositor {
        address addr;
        uint256 amount;
    }
    Depositor[3] public topDepositors;

    constructor() {
        admin = msg.sender;
        console.log("Constructor: admin set to", admin);
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    function setAdmin(address newAdmin) external onlyAdmin {
        admin = newAdmin;
        console.log("New admin set to:", admin);
    }

    receive() external payable {
        deposits[msg.sender] += msg.value;
        updateTopDepositors(msg.sender, deposits[msg.sender]);
    }

    function withdraw(uint256 amount) external onlyAdmin {
        console.log("Withdraw: contract balance:", address(this).balance);
        console.log("Withdraw: amount:", amount);
        console.log("Withdraw: sending to:", admin);
        require(address(this).balance >= amount, "Insufficient contract balance");
        (bool success, ) = admin.call{value: amount}("");
        console.log("Withdraw: success:", success);
        require(success, "Transfer failed");
    }

    function updateTopDepositors(address depositor, uint256 amount) internal {
        if (amount <= topDepositors[2].amount && topDepositors[2].addr != address(0)) {
            return;
        }
        for (uint256 i = 0; i < 3; i++) {
            if (topDepositors[i].addr == depositor) {
                topDepositors[i].amount = amount;
                break;
            } else if (topDepositors[i].addr == address(0) || amount > topDepositors[i].amount) {
                for (uint256 j = 2; j > i; j--) {
                    topDepositors[j] = topDepositors[j - 1];
                }
                topDepositors[i] = Depositor(depositor, amount);
                break;
            }
        }
    }
}
