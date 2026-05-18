// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {PriceOracle} from "../src/PriceOracle.sol";
import {MockAggregator} from "../src/mocks/MockAggregator.sol";

contract PriceOracleTest is Test {
    PriceOracle public oracle;
    MockAggregator public mock;

    function setUp() public {
        mock = new MockAggregator(2000e8, 8);
        oracle = new PriceOracle(address(mock));
    }

    function test_getPrice_returnsPrice() public view {
        int256 price = oracle.getPrice();
        assertEq(price, 2000e8);
    }

    function test_getPrice_revertsStale() public {
        mock.setUpdatedAt(block.timestamp - 3601);
        vm.expectRevert("PriceOracle: stale price");
        oracle.getPrice();
    }

    function test_getPrice_revertsNegative() public {
        mock.setPrice(-1);
        vm.expectRevert("PriceOracle: invalid price");
        oracle.getPrice();
    }

    function test_getPrice_revertsZero() public {
        mock.setPrice(0);
        vm.expectRevert("PriceOracle: invalid price");
        oracle.getPrice();
    }

    function test_decimals() public view {
        assertEq(oracle.decimals(), 8);
    }

    function test_getPrice_exactStaleness() public {
        mock.setUpdatedAt(block.timestamp - 3600);
        int256 price = oracle.getPrice();
        assertGt(price, 0);
    }

    function testFuzz_getPrice(int256 price) public {
        vm.assume(price > 0);
        mock.setPrice(price);
        assertEq(oracle.getPrice(), price);
    }
}
