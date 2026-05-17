// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import "../src/GovToken.sol";
import "../src/ProtocolTimelock.sol";
import "../src/ProtocolGovernor.sol";

contract GovernanceInvariants is Test {
    GovToken token;
    ProtocolTimelock timelock;
    ProtocolGovernor governor;

    address voter = address(1);

    uint256 initialSupply;

    function setUp() public {
        token = new GovToken(voter);
        initialSupply = token.totalSupply();

        address[] memory proposers = new address[](0);
        address[] memory executors = new address[](0);

        timelock = new ProtocolTimelock(2 days, proposers, executors, address(this));
        governor = new ProtocolGovernor(token, timelock);

        timelock.grantRole(timelock.PROPOSER_ROLE(), address(governor));
        timelock.grantRole(timelock.EXECUTOR_ROLE(), address(governor));
        timelock.renounceRole(timelock.DEFAULT_ADMIN_ROLE(), address(this));
    }

    function invariant_GovTokenTotalSupplyConstant() public view {
        assertEq(token.totalSupply(), initialSupply);
    }

    function invariant_TimelockDelayAlwaysTwoDays() public view {
        assertEq(timelock.getMinDelay(), 2 days);
    }

    function invariant_GovernorVotingDelayAlwaysOneDay() public view {
        assertEq(governor.votingDelay(), 7200);
    }

    function invariant_GovernorVotingPeriodAlwaysOneWeek() public view {
        assertEq(governor.votingPeriod(), 50400);
    }

    function invariant_GovernorQuorumAlwaysFourPercent() public view {
        assertEq(governor.quorumNumerator(), 4);
    }

    function invariant_GovernorKeepsProposerRole() public view {
        assertTrue(timelock.hasRole(timelock.PROPOSER_ROLE(), address(governor)));
    }

    function invariant_GovernorKeepsExecutorRole() public view {
        assertTrue(timelock.hasRole(timelock.EXECUTOR_ROLE(), address(governor)));
    }

    function invariant_DeployerDoesNotKeepAdminRole() public view {
        assertFalse(timelock.hasRole(timelock.DEFAULT_ADMIN_ROLE(), address(this)));
    }
}
