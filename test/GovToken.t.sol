// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {GovToken} from "../src/GovToken.sol";

contract GovTokenTest is Test {
    GovToken public token;
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        token = new GovToken(address(this));
    }

    function test_totalSupply() public view {
        assertEq(token.totalSupply(), 1_000_000e18);
    }

    function test_name() public view {
        assertEq(token.name(), "Governance Token");
    }

    function test_symbol() public view {
        assertEq(token.symbol(), "GOV");
    }

    function test_decimals() public view {
        assertEq(token.decimals(), 18);
    }

    function test_initialBalance() public view {
        assertEq(token.balanceOf(address(this)), 1_000_000e18);
    }

    function test_transfer() public {
        token.transfer(alice, 1000e18);
        assertEq(token.balanceOf(alice), 1000e18);
    }

    function test_delegate_self() public {
        token.transfer(alice, 1000e18);
        vm.prank(alice);
        token.delegate(alice);
        vm.roll(block.number + 1);
        assertEq(token.getVotes(alice), 1000e18);
    }

    function test_delegate_to_other() public {
        token.transfer(alice, 1000e18);
        vm.prank(alice);
        token.delegate(bob);
        vm.roll(block.number + 1);
        assertEq(token.getVotes(bob), 1000e18);
        assertEq(token.getVotes(alice), 0);
    }

    function test_votingPower_afterTransfer() public {
        token.transfer(alice, 500e18);
        vm.prank(alice);
        token.delegate(alice);
        vm.roll(block.number + 1);
        assertEq(token.getVotes(alice), 500e18);
        vm.prank(alice);
        token.transfer(bob, 200e18);
        vm.roll(block.number + 1);
        assertEq(token.getVotes(alice), 300e18);
    }

    function test_getPastVotes() public {
        token.transfer(alice, 1000e18);
        vm.prank(alice);
        token.delegate(alice);
        uint256 blockNum = block.number;
        vm.roll(blockNum + 2);
        assertEq(token.getPastVotes(alice, blockNum + 1), 1000e18);
    }

    function test_approve_and_transferFrom() public {
        token.approve(alice, 500e18);
        vm.prank(alice);
        token.transferFrom(address(this), bob, 500e18);
        assertEq(token.balanceOf(bob), 500e18);
    }

    function test_permit() public view {
        assertEq(token.nonces(alice), 0); // nonces starts at 0
    }

    function testFuzz_transfer(uint256 amount) public {
        amount = bound(amount, 1, 1_000_000e18);
        token.transfer(alice, amount);
        assertEq(token.balanceOf(alice), amount);
    }

    function testFuzz_delegate(uint256 amount) public {
        amount = bound(amount, 1e18, 500_000e18);
        token.transfer(alice, amount);
        vm.prank(alice);
        token.delegate(alice);
        vm.roll(block.number + 1);
        assertEq(token.getVotes(alice), amount);
    }
}
