// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {GovToken} from "../src/GovToken.sol";
import {ProtocolGovernor} from "../src/ProtocolGovernor.sol";
import {ProtocolTimelock} from "../src/ProtocolTimelock.sol";
import {IGovernor} from "@openzeppelin/contracts/governance/IGovernor.sol";

contract GovernanceTest is Test {
    GovToken public token;
    ProtocolGovernor public governor;
    ProtocolTimelock public timelock;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        token = new GovToken(address(this));

        address[] memory proposers = new address[](1);
        address[] memory executors = new address[](1);
        proposers[0] = address(0);
        executors[0] = address(0);
        timelock = new ProtocolTimelock(proposers, executors, address(this));
        governor = new ProtocolGovernor(token, timelock);

        bytes32 PROPOSER_ROLE = timelock.PROPOSER_ROLE();
        bytes32 EXECUTOR_ROLE = timelock.EXECUTOR_ROLE();
        timelock.grantRole(PROPOSER_ROLE, address(governor));
        timelock.grantRole(EXECUTOR_ROLE, address(0));

        // Give alice enough tokens to propose
        token.transfer(alice, 100_000e18);
        token.transfer(bob, 100_000e18);

        vm.prank(alice);
        token.delegate(alice);
        vm.prank(bob);
        token.delegate(bob);

        vm.roll(block.number + 1);
    }

    function test_governorName() public view {
        assertEq(governor.name(), "ProtocolGovernor");
    }

    function test_votingDelay() public view {
        assertEq(governor.votingDelay(), 7200);
    }

    function test_votingPeriod() public view {
        assertEq(governor.votingPeriod(), 50400);
    }

    function test_quorumNumerator() public view {
        assertEq(governor.quorumNumerator(), 4);
    }

    function test_propose() public {
        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);
        targets[0] = address(token);
        values[0] = 0;
        calldatas[0] = "";

        vm.prank(alice);
        uint256 proposalId = governor.propose(targets, values, calldatas, "Proposal #1");
        assertGt(proposalId, 0);
    }

    function test_proposalState_pending() public {
        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);
        targets[0] = address(token);

        vm.prank(alice);
        uint256 proposalId = governor.propose(targets, values, calldatas, "Test");
        assertEq(uint256(governor.state(proposalId)), uint256(IGovernor.ProposalState.Pending));
    }

    function test_castVote() public {
        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);
        targets[0] = address(token);

        vm.prank(alice);
        uint256 proposalId = governor.propose(targets, values, calldatas, "Vote test");

        vm.roll(block.number + governor.votingDelay() + 1);

        vm.prank(alice);
        governor.castVote(proposalId, 1);

        (uint256 against, uint256 forVotes,) = governor.proposalVotes(proposalId);
        assertGt(forVotes, 0);
        assertEq(against, 0);
    }

    function test_castVote_against() public {
        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);
        targets[0] = address(token);

        vm.prank(alice);
        uint256 proposalId = governor.propose(targets, values, calldatas, "Against test");

        vm.roll(block.number + governor.votingDelay() + 1);

        vm.prank(bob);
        governor.castVote(proposalId, 0);

        (uint256 against,,) = governor.proposalVotes(proposalId);
        assertGt(against, 0);
    }

    function test_timelockDelay() public view {
        assertEq(timelock.getMinDelay(), 2 days);
    }
}
