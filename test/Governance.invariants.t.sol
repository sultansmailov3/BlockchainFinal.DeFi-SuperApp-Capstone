// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {GovToken} from "../src/GovToken.sol";

contract GovTokenInvariantsTest is StdInvariant, Test {
    GovToken public token;
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        token = new GovToken(address(this));
        token.transfer(alice, 100_000e18);
        token.transfer(bob, 100_000e18);
        targetContract(address(token));
    }

    function invariant_totalSupplyConstant() public view {
        assertEq(token.totalSupply(), 1_000_000e18);
    }
}
