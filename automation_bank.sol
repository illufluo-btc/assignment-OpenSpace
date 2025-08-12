// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IAutomationCompatible {
    function checkUpkeep(bytes calldata checkData)
        external
        returns (bool upkeepNeeded, bytes memory performData);
    function performUpkeep(bytes calldata performData) external;
}

contract Bank is IAutomationCompatible {
    address public owner;
    uint256 public threshold;

    event Deposited(address indexed from, uint256 amount);
    event Swept(uint256 amount, address indexed to);
    event OwnerUpdated(address indexed oldOwner, address indexed newOwner);
    event ThresholdUpdated(uint256 newThreshold);

    modifier onlyOwner() { require(msg.sender == owner, "Not owner"); _; }

    constructor(uint256 _threshold, address _owner) {
        owner = _owner == address(0) ? msg.sender : _owner;
        threshold = _threshold;
        emit OwnerUpdated(address(0), owner);
        emit ThresholdUpdated(_threshold);
    }

    function setOwner(address _owner) external onlyOwner {
        require(_owner != address(0), "zero addr");
        emit OwnerUpdated(owner, _owner);
        owner = _owner;
    }

    function setThreshold(uint256 _threshold) external onlyOwner {
        threshold = _threshold;
        emit ThresholdUpdated(_threshold);
    }

    function deposit() external payable {
        require(msg.value > 0, "no value");
        emit Deposited(msg.sender, msg.value);
    }

    receive() external payable { emit Deposited(msg.sender, msg.value); }

    function sweepIfNeeded() public {
        uint256 bal = address(this).balance;
        if (bal > threshold) {
            uint256 half = bal / 2;
            (bool ok, ) = payable(owner).call{value: half}("");
            require(ok, "transfer failed");
            emit Swept(half, owner);
        }
    }

    // Chainlink Automation
    function checkUpkeep(bytes calldata)
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory performData)
    {
        upkeepNeeded = address(this).balance > threshold;
        performData = bytes("");
    }

    function performUpkeep(bytes calldata) external override {
        sweepIfNeeded();
    }

    function bankBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
