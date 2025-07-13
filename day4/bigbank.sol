// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBank {
    function deposits(address account) external view returns (uint256);
    function withdraw(uint256 amount) external;
    function topDepositors(uint256 index) external view returns (address, uint256);
}

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
    }

    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }

    receive() external payable virtual {
        deposits[msg.sender] += msg.value;
        updateTopDepositors(msg.sender, deposits[msg.sender]);
    }

    function withdraw(uint256 amount) external virtual onlyAdmin {
        require(address(this).balance >= amount);
        (bool success, ) = admin.call{value: amount}("");
        require(success);
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

contract BigBank is Bank {

    uint256 public constant MIN_DEPOSIT = 1_000_000_000_000_000;

    modifier minDeposit() {
        require(msg.value >= MIN_DEPOSIT, "Deposit must be greater than 0.001 ether");
        _;
    }

    receive() external payable override minDeposit {
        deposits[msg.sender] += msg.value;
        updateTopDepositors(msg.sender, deposits[msg.sender]);
    }

    function transferAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "New admin cannot be zero address");
        admin = newAdmin;
    }
    function getBalance() public view returns (uint256) {
    return address(this).balance;
}
}

contract Admin {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function adminWithdraw(IBank bank, uint256 amount) external onlyOwner {
        bank.withdraw(amount);
    }

    receive() external payable {}
}
