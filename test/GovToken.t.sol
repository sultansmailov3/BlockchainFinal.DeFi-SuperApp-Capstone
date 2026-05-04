// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {GovToken} from "../src/GovToken.sol";

contract GovTokenTest is Test {
    GovToken public token;
    address public owner;
    address public alice;

    function setUp() public {
        owner = address(this); 
        alice = makeAddr("alice");
        token = new GovToken(owner);
    }

    function test_InitialSupply() public view {
        uint256 expectedSupply = 1_000_000 * 10 ** token.decimals();
        assertEq(token.totalSupply(), expectedSupply);
        assertEq(token.balanceOf(owner), expectedSupply);
    }

    function test_NameAndSymbol() public view {
        assertEq(token.name(), "DeFi Super-App Gov");
        assertEq(token.symbol(), "DSG");
    }
}