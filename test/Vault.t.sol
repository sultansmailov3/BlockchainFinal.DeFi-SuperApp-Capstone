// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {DeFiVault} from "../src/Vault.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract VaultTest is Test {
    DeFiVault public vault;
    ERC20Mock public underlying;
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        underlying = new ERC20Mock();
        vault = new DeFiVault(underlying, address(this));
        underlying.mint(alice, 1_000_000e18);
        underlying.mint(bob, 1_000_000e18);
    }

    function test_deposit_basic() public {
        vm.startPrank(alice);
        underlying.approve(address(vault), 1000e18);
        uint256 shares = vault.deposit(1000e18, alice);
        vm.stopPrank();
        assertGt(shares, 0);
    }

    function test_deposit_updatesAssets() public {
        vm.startPrank(alice);
        underlying.approve(address(vault), 500e18);
        vault.deposit(500e18, alice);
        vm.stopPrank();
        assertEq(vault.totalAssets(), 500e18);
    }

    function test_deposit_multipleUsers() public {
        vm.startPrank(alice);
        underlying.approve(address(vault), 1000e18);
        vault.deposit(1000e18, alice);
        vm.stopPrank();
        vm.startPrank(bob);
        underlying.approve(address(vault), 500e18);
        vault.deposit(500e18, bob);
        vm.stopPrank();
        assertEq(vault.totalAssets(), 1500e18);
    }

    function test_withdraw_basic() public {
        vm.startPrank(alice);
        underlying.approve(address(vault), 1000e18);
        vault.deposit(1000e18, alice);
        vault.withdraw(500e18, alice, alice);
        vm.stopPrank();
        assertEq(vault.totalAssets(), 500e18);
    }

    function test_withdraw_full() public {
        vm.startPrank(alice);
        underlying.approve(address(vault), 1000e18);
        vault.deposit(1000e18, alice);
        uint256 before = underlying.balanceOf(alice);
        vault.withdraw(1000e18, alice, alice);
        vm.stopPrank();
        assertApproxEqAbs(underlying.balanceOf(alice) - before, 1000e18, 1);
    }

    function test_withdraw_revertsInsufficient() public {
        vm.startPrank(alice);
        underlying.approve(address(vault), 1000e18);
        vault.deposit(1000e18, alice);
        vm.expectRevert();
        vault.withdraw(2000e18, alice, alice);
        vm.stopPrank();
    }

    function test_redeem_basic() public {
        vm.startPrank(alice);
        underlying.approve(address(vault), 1000e18);
        uint256 shares = vault.deposit(1000e18, alice);
        uint256 assets = vault.redeem(shares, alice, alice);
        vm.stopPrank();
        assertGt(assets, 0);
    }

    function test_convertToShares() public {
        vm.startPrank(alice);
        underlying.approve(address(vault), 1000e18);
        vault.deposit(1000e18, alice);
        vm.stopPrank();
        assertGt(vault.convertToShares(500e18), 0);
    }

    function test_convertToAssets() public {
        vm.startPrank(alice);
        underlying.approve(address(vault), 1000e18);
        uint256 shares = vault.deposit(1000e18, alice);
        vm.stopPrank();
        assertApproxEqAbs(vault.convertToAssets(shares), 1000e18, 1);
    }

    function test_maxDeposit() public view {
        assertEq(vault.maxDeposit(alice), type(uint256).max);
    }

    function test_maxWithdraw() public {
        vm.startPrank(alice);
        underlying.approve(address(vault), 1000e18);
        vault.deposit(1000e18, alice);
        vm.stopPrank();
        assertApproxEqAbs(vault.maxWithdraw(alice), 1000e18, 1);
    }

    function testFuzz_deposit(uint256 amount) public {
        amount = bound(amount, 1e15, 100_000e18);
        underlying.mint(address(this), amount);
        underlying.approve(address(vault), amount);
        uint256 shares = vault.deposit(amount, address(this));
        assertGt(shares, 0);
    }

    function testFuzz_depositThenWithdraw(uint256 amount) public {
        amount = bound(amount, 1e15, 100_000e18);
        underlying.mint(address(this), amount);
        underlying.approve(address(vault), amount);
        vault.deposit(amount, address(this));
        vault.withdraw(amount, address(this), address(this));
        assertEq(vault.totalAssets(), 0);
    }

    function testFuzz_sharesRoundTrip(uint256 amount) public {
        amount = bound(amount, 1e15, 100_000e18);
        underlying.mint(address(this), amount);
        underlying.approve(address(vault), amount);
        uint256 shares = vault.deposit(amount, address(this));
        assertApproxEqAbs(vault.convertToAssets(shares), amount, 1);
    }
}
