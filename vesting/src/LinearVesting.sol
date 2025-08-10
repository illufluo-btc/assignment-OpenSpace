// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title Linear Vesting with 12-month cliff then 24-month linear schedule
/// @notice Start time is deployment time. Tokens are pulled via `seed(amount)` after deploy.
contract LinearVesting {
    IERC20 public immutable token;
    address public immutable beneficiary;

    uint64 public immutable start;      // deployment timestamp
    uint64 public immutable cliffEnd;   // start + 12 months
    uint64 public immutable vestingEnd; // cliffEnd + 24 months

    uint256 public totalAllocation; // total tokens locked (set by seed)
    uint256 public released;        // total tokens released so far

    event Seeded(uint256 amount);
    event Released(uint256 amount, address to);

    error AlreadySeeded();
    error NotBeneficiary();
    error NothingToRelease();
    error ZeroAmount();

    uint256 private constant MONTH = 30 days; // treat a month as 30 days

    constructor(address _beneficiary, address _token) {
        require(_beneficiary != address(0), "beneficiary=0");
        require(_token != address(0), "token=0");
        beneficiary = _beneficiary;
        token = IERC20(_token);
        start = uint64(block.timestamp);
        cliffEnd = start + uint64(12 * MONTH);
        vestingEnd = cliffEnd + uint64(24 * MONTH);
    }

    /// @notice Pull tokens into the contract and fix the allocation. Callable once.
    /// @dev Caller must approve `amount` to this contract prior to calling.
    function seed(uint256 amount) external {
        if (totalAllocation != 0) revert AlreadySeeded();
        if (amount == 0) revert ZeroAmount();
        totalAllocation = amount;
        bool ok = token.transferFrom(msg.sender, address(this), amount);
        require(ok, "transferFrom failed");
        emit Seeded(amount);
    }

    /// @notice Amount that has vested by `timestamp` according to the schedule.
    function vestedAmount(uint64 timestamp) public view returns (uint256) {
        if (timestamp < cliffEnd) return 0;
        if (timestamp >= vestingEnd) return totalAllocation;
        uint256 elapsed = uint256(timestamp - cliffEnd);
        uint256 duration = uint256(vestingEnd - cliffEnd); // 24 * MONTH
        return (totalAllocation * elapsed) / duration;
    }

    /// @notice Amount currently releasable to the beneficiary.
    function releasable() public view returns (uint256) {
        return vestedAmount(uint64(block.timestamp)) - released;
    }

    /// @notice Release currently vested tokens to the beneficiary.
    function release() external {
        if (msg.sender != beneficiary) revert NotBeneficiary();
        uint256 amount = releasable();
        if (amount == 0) revert NothingToRelease();
        released += amount;
        bool ok = token.transfer(beneficiary, amount);
        require(ok, "transfer failed");
        emit Released(amount, beneficiary);
    }
}
