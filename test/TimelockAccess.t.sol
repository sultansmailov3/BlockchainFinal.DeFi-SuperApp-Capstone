// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {ProtocolTimelock} from "../src/ProtocolTimelock.sol";

contract TimelockAccessTest is Test {
    ProtocolTimelock public timelock;
    address admin = makeAddr("admin");
    address proposer = makeAddr("proposer");
    address executor = makeAddr("executor");
    address attacker = makeAddr("attacker");

    function setUp() public {
        address[] memory proposers = new address[](1);
        address[] memory executors = new address[](1);
        proposers[0] = proposer;
        executors[0] = executor;
        timelock = new ProtocolTimelock(proposers, executors, admin);
    }

    function test_minDelay() public view {
        assertEq(timelock.getMinDelay(), 2 days);
    }

    function test_proposerHasRole() public view {
        assertTrue(timelock.hasRole(timelock.PROPOSER_ROLE(), proposer));
    }

    function test_executorHasRole() public view {
        assertTrue(timelock.hasRole(timelock.EXECUTOR_ROLE(), executor));
    }

    function test_adminHasRole() public view {
        assertTrue(timelock.hasRole(timelock.DEFAULT_ADMIN_ROLE(), admin));
    }

    function test_attackerHasNoRole() public view {
        assertFalse(timelock.hasRole(timelock.PROPOSER_ROLE(), attacker));
        assertFalse(timelock.hasRole(timelock.EXECUTOR_ROLE(), attacker));
    }

    function test_schedule_revertsNonProposer() public {
        vm.prank(attacker);
        vm.expectRevert();
        timelock.schedule(address(0), 0, "", bytes32(0), bytes32(0), 2 days);
    }

    function test_execute_revertsNotScheduled() public {
        vm.prank(executor);
        vm.expectRevert();
        timelock.execute(address(0), 0, "", bytes32(0), bytes32(0));
    }
}
