// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import "../src/GovToken.sol";
import "../src/ProtocolTimelock.sol";
import "../src/ProtocolGovernor.sol";

contract TimelockAccessTest is Test {
    GovToken token;
    ProtocolTimelock timelock;
    ProtocolGovernor governor;

    address voter = address(1);
    address attacker = address(999);

    function setUp() public {
        token = new GovToken(voter);

        address[] memory proposers = new address[](0);
        address[] memory executors = new address[](0);

        timelock = new ProtocolTimelock(2 days, proposers, executors, address(this));

        governor = new ProtocolGovernor(token, timelock);

        timelock.grantRole(timelock.PROPOSER_ROLE(), address(governor));
        timelock.grantRole(timelock.EXECUTOR_ROLE(), address(governor));

        timelock.renounceRole(timelock.DEFAULT_ADMIN_ROLE(), address(this));
    }

    function test_TimelockDelayIsTwoDays() public view {
        assertEq(timelock.getMinDelay(), 2 days);
    }

    function test_GovernorHasProposerRole() public view {
        assertTrue(timelock.hasRole(timelock.PROPOSER_ROLE(), address(governor)));
    }

    function test_GovernorHasExecutorRole() public view {
        assertTrue(timelock.hasRole(timelock.EXECUTOR_ROLE(), address(governor)));
    }

    function test_DeployerAdminRoleRenounced() public view {
        assertFalse(timelock.hasRole(timelock.DEFAULT_ADMIN_ROLE(), address(this)));
    }

    function test_RandomUserHasNoAdminOrGovernanceRoles() public view {
        assertFalse(timelock.hasRole(timelock.DEFAULT_ADMIN_ROLE(), attacker));
        assertFalse(timelock.hasRole(timelock.PROPOSER_ROLE(), attacker));
        assertFalse(timelock.hasRole(timelock.EXECUTOR_ROLE(), attacker));
    }

    function test_RandomUserCannotUpdateDelay() public {
        vm.prank(attacker);
        vm.expectRevert();

        timelock.updateDelay(1 days);
    }
}
