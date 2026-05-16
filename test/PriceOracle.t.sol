// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/PriceOracle.sol";
import "../src/mocks/MockAggregator.sol";

contract PriceOracleTest is Test {
    PriceOracle oracle;
    MockAggregator mock;

    function setUp() public {
        vm.warp(10000);
        mock = new MockAggregator(2000e8);
        oracle = new PriceOracle(address(mock));
    }

    function test_GetPrice() public view {
        int256 price = oracle.getPrice();
        assertEq(price, 2000e8);
    }

    function test_RevertIfStale() public {
        mock.setUpdatedAt(block.timestamp - 7200);
        vm.expectRevert("Stale price");
        oracle.getPrice();
    }

    function test_RevertIfInvalidPrice() public {
        mock.setPrice(-1);
        vm.expectRevert("Invalid price");
        oracle.getPrice();
    }
}
