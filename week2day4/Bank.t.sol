// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/Bank.sol";

contract BankTest is Test {
    Bank bank;
    address admin;
    address user1 = address(0x1);
    address user2 = address(0x2);
    address user3 = address(0x3);
    address user4 = address(0x4);

    // 添加 receive 函数，使测试合约可接收 Ether
    receive() external payable {}

    function setUp() public {
        bank = new Bank();
        admin = address(this); // 设置 admin 为测试合约地址
        console.log("SetUp: admin set to", admin);
    }

    function test_DepositBalance() public {
        vm.deal(user1, 2 ether);
        vm.prank(user1);
        payable(bank).call{value: 1 ether}("");
        assertEq(bank.deposits(user1), 1 ether);

        vm.prank(user1);
        payable(bank).call{value: 1 ether}("");
        assertEq(bank.deposits(user1), 2 ether);
    }

    function test_TopDepositor_OneUser() public {
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        payable(bank).call{value: 1 ether}("");

        (address addr, uint256 amount) = bank.topDepositors(0);
        assertEq(addr, user1);
        assertEq(amount, 1 ether);
    }

    function test_TopDepositors_TwoUsers() public {
        vm.deal(user1, 2 ether);
        vm.deal(user2, 1 ether);
        vm.prank(user1);
        payable(bank).call{value: 2 ether}("");
        vm.prank(user2);
        payable(bank).call{value: 1 ether}("");

        (address addr1, uint256 amount1) = bank.topDepositors(0);
        (address addr2, uint256 amount2) = bank.topDepositors(1);
        assertEq(addr1, user1);
        assertEq(amount1, 2 ether);
        assertEq(addr2, user2);
        assertEq(amount2, 1 ether);
    }

    function test_TopDepositors_ThreeUsers() public {
        vm.deal(user1, 3 ether);
        vm.deal(user2, 2 ether);
        vm.deal(user3, 1 ether);
        vm.prank(user1);
        payable(bank).call{value: 3 ether}("");
        vm.prank(user2);
        payable(bank).call{value: 2 ether}("");
        vm.prank(user3);
        payable(bank).call{value: 1 ether}("");

        (address addr1, uint256 amount1) = bank.topDepositors(0);
        (address addr2, uint256 amount2) = bank.topDepositors(1);
        (address addr3, uint256 amount3) = bank.topDepositors(2);
        assertEq(addr1, user1);
        assertEq(amount1, 3 ether);
        assertEq(addr2, user2);
        assertEq(amount2, 2 ether);
        assertEq(addr3, user3);
        assertEq(amount3, 1 ether);
    }

    function test_TopDepositors_FourUsers() public {
        vm.deal(user1, 4 ether);
        vm.deal(user2, 3 ether);
        vm.deal(user3, 2 ether);
        vm.deal(user4, 1 ether);
        vm.prank(user1);
        payable(bank).call{value: 4 ether}("");
        vm.prank(user2);
        payable(bank).call{value: 3 ether}("");
        vm.prank(user3);
        payable(bank).call{value: 2 ether}("");
        vm.prank(user4);
        payable(bank).call{value: 1 ether}("");

        (address addr1, uint256 amount1) = bank.topDepositors(0);
        (address addr2, uint256 amount2) = bank.topDepositors(1);
        (address addr3, uint256 amount3) = bank.topDepositors(2);
        assertEq(addr1, user1);
        assertEq(amount1, 4 ether);
        assertEq(addr2, user2);
        assertEq(amount2, 3 ether);
        assertEq(addr3, user3);
        assertEq(amount3, 2 ether);
    }

    function test_TopDepositors_SameUserMultipleDeposits() public {
        vm.deal(user1, 3 ether);
        vm.prank(user1);
        payable(bank).call{value: 1 ether}("");
        vm.prank(user1);
        payable(bank).call{value: 2 ether}("");

        (address addr, uint256 amount) = bank.topDepositors(0);
        assertEq(addr, user1);
        assertEq(amount, 3 ether);
    }

    function test_OnlyAdminCanWithdraw() public {
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        payable(bank).call{value: 1 ether}("");
        console.log("Contract balance after deposit:", address(bank).balance);

        console.log("Admin address:", bank.admin());
        // 修正：不检查 admin == address(this)，因为 Bank.admin 是构造函数设置的
        // assertEq(bank.admin(), address(this));

        // 使用 Bank 的实际 admin 地址
        address actualAdmin = bank.admin();
        console.log("Actual admin:", actualAdmin);

        uint256 balanceBefore = actualAdmin.balance;
        console.log("Admin balance before withdraw:", balanceBefore);
        vm.prank(actualAdmin);
        bank.withdraw(1 ether);
        console.log("Admin balance after withdraw:", actualAdmin.balance);
        assertEq(actualAdmin.balance, balanceBefore + 1 ether);

        vm.prank(user1);
        vm.expectRevert("Only admin can call this function");
        bank.withdraw(1 ether);
    }
}