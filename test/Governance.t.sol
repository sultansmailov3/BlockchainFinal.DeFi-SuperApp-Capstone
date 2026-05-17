// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/GovToken.sol";
import "../src/ProtocolTimelock.sol";
import "../src/ProtocolGovernor.sol";

contract GovernanceTest is Test {
    GovToken token;
    ProtocolTimelock timelock;
    ProtocolGovernor governor;

    address voter = address(1);
    address treasury = address(2);

    function setUp() public {
        token = new GovToken(voter);

        address[] memory proposers = new address[](0);
        address[] memory executors = new address[](0);
        timelock = new ProtocolTimelock(2 days, proposers, executors, address(this));

        governor = new ProtocolGovernor(token, timelock);

        timelock.grantRole(timelock.PROPOSER_ROLE(), address(governor));
        timelock.grantRole(timelock.EXECUTOR_ROLE(), address(governor));
        timelock.renounceRole(timelock.DEFAULT_ADMIN_ROLE(), address(this));

        vm.prank(voter);
        token.delegate(voter);
    }

    function test_GovernorParams() public view {
        assertEq(governor.votingDelay(), 7200);
        assertEq(governor.votingPeriod(), 50400);
        assertEq(governor.quorumNumerator(), 4);
    }

    function test_ProposeAndVote() public {
        vm.roll(block.number + 1);

        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);
        targets[0] = treasury;
        values[0] = 0;
        calldatas[0] = "";

        vm.prank(voter);
        uint256 proposalId = governor.propose(targets, values, calldatas, "Test proposal");

        vm.roll(block.number + 7201);

        vm.prank(voter);
        governor.castVote(proposalId, 1);

        vm.roll(block.number + 50401);

        assertEq(uint256(governor.state(proposalId)), 4);
    }
  
}
