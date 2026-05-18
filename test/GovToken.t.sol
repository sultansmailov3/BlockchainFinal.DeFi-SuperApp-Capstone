// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {GovToken} from "../src/GovToken.sol";

contract GovTokenTest is Test {
    GovToken public token;

    address public owner;
    address public alice;
    address public bob;

    uint256 public alicePrivateKey;

    uint256 public constant INITIAL_SUPPLY = 1_000_000 ether;
    uint256 public constant TRANSFER_AMOUNT = 100 ether;

    function setUp() public {
        owner = address(this);
        bob = makeAddr("bob");

        (alice, alicePrivateKey) = makeAddrAndKey("alice");

        token = new GovToken(owner);
    }

    function test_InitialSupply() public view {
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY);
    }

    function test_NameAndSymbol() public view {
        assertEq(token.name(), "DeFi Super-App Gov");
        assertEq(token.symbol(), "DSG");
    }

    function test_VotesAreZeroBeforeDelegation() public view {
        assertEq(token.getVotes(owner), 0);
    }

    function test_SelfDelegationCreatesVotingPower() public {
        token.delegate(owner);

        assertEq(token.getVotes(owner), INITIAL_SUPPLY);
        assertEq(token.delegates(owner), owner);
    }

    function test_TransferUpdatesBalance() public {
        token.transfer(alice, TRANSFER_AMOUNT);

        assertEq(token.balanceOf(alice), TRANSFER_AMOUNT);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY - TRANSFER_AMOUNT);
    }

    function test_DelegateToAnotherAccount() public {
        token.transfer(alice, TRANSFER_AMOUNT);

        vm.prank(alice);
        token.delegate(bob);

        assertEq(token.delegates(alice), bob);
        assertEq(token.getVotes(bob), TRANSFER_AMOUNT);
    }

    function test_TransferAfterDelegationUpdatesVotingPower() public {
        token.delegate(owner);

        assertEq(token.getVotes(owner), INITIAL_SUPPLY);

        token.transfer(alice, TRANSFER_AMOUNT);

        assertEq(token.getVotes(owner), INITIAL_SUPPLY - TRANSFER_AMOUNT);
        assertEq(token.getVotes(alice), 0);
    }

    function test_CheckpointsWorkAfterDelegation() public {
        token.transfer(alice, TRANSFER_AMOUNT);

        vm.prank(alice);
        token.delegate(alice);

        uint256 checkpointBlock = block.number;

        vm.roll(block.number + 1);

        assertEq(token.getPastVotes(alice, checkpointBlock), TRANSFER_AMOUNT);
    }

    function test_NoncesStartAtZero() public view {
        assertEq(token.nonces(alice), 0);
    }

    function test_PermitApprovesSpenderAndIncrementsNonce() public {
        uint256 value = 50 ether;
        uint256 deadline = block.timestamp + 1 days;

        bytes32 permitTypeHash =
            keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

        bytes32 structHash = keccak256(abi.encode(permitTypeHash, alice, bob, value, token.nonces(alice), deadline));

        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", token.DOMAIN_SEPARATOR(), structHash));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(alicePrivateKey, digest);

        token.permit(alice, bob, value, deadline, v, r, s);

        assertEq(token.allowance(alice, bob), value);
        assertEq(token.nonces(alice), 1);
    }
}
