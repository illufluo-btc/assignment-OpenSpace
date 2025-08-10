// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import {LinearVesting} from "../src/LinearVesting.sol";
import {BaseERC20} from "../src/BaseERC20.sol";

contract LinearVestingTest is Test {
    LinearVesting vest;
    BaseERC20 token;
    address beneficiary = address(0xBEEF);
    address funder = address(0xCAFE);

    uint256 private constant MONTH = 30 days;

    function setUp() public {
        vm.startPrank(funder);
        token = new BaseERC20(); 
        vm.stopPrank();

        vest = new LinearVesting(beneficiary, address(token));

        uint256 SEED = 1_000_000 * (10 ** uint256(token.decimals()));
        require(token.balanceOf(funder) >= SEED, "not enough initial balance for seeding");

        vm.startPrank(funder);
        token.approve(address(vest), SEED);
        vest.seed(SEED);
        vm.stopPrank();
    }

    function test_ReleasableBeforeCliffIsZero() public {
        assertEq(vest.releasable(), 0);
        vm.prank(beneficiary);
        vm.expectRevert(LinearVesting.NothingToRelease.selector);
        vest.release();
    }

    function test_ExactAmountAfter13thMonth() public {
        vm.warp(block.timestamp + 12 * MONTH + 1 * MONTH);
        uint256 expected = vest.totalAllocation() / 24;
        assertEq(vest.releasable(), expected);

        vm.prank(beneficiary);
        vest.release();

        assertEq(token.balanceOf(beneficiary), expected);
        assertEq(vest.releasable(), 0);
    }

    function test_MultipleReleasesOverTime() public {
        // 15 个月 -> (15-12)=3 -> 3/24
        vm.warp(block.timestamp + 15 * MONTH);
        vm.prank(beneficiary);
        vest.release();
        uint256 threeTwentyFourths = (vest.totalAllocation() * 3) / 24;
        assertEq(token.balanceOf(beneficiary), threeTwentyFourths);

        // 20 个月 -> 8/24
        vm.warp(block.timestamp - 15 * MONTH + 20 * MONTH);
        uint256 eightTwentyFourths = (vest.totalAllocation() * 8) / 24;
        vm.prank(beneficiary);
        vest.release();
        assertEq(token.balanceOf(beneficiary), eightTwentyFourths);
    }

    function test_AllReleasedAtEnd() public {
        vm.warp(block.timestamp + 36 * MONTH);
        vm.prank(beneficiary);
        vest.release();
        assertEq(token.balanceOf(beneficiary), vest.totalAllocation());
        assertEq(vest.releasable(), 0);
    }
}
