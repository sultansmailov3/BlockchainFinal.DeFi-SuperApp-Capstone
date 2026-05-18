// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {PriceOracle} from "../src/PriceOracle.sol";

interface IChainlinkFeed {
    function latestRoundData() external view returns (
        uint80, int256, uint256, uint256, uint80
    );
    function decimals() external view returns (uint8);
}

contract ForkTest is Test {
    // Arbitrum Sepolia ETH/USD feed
    address constant ARB_SEP_ETH_USD = 0xd30e2101a97dcbAeBCBC04F14C3f624E67A35165;

    function setUp() public {
        string memory rpc = vm.envOr("ARBITRUM_SEPOLIA_RPC", string("https://sepolia-rollup.arbitrum.io/rpc"));
        vm.createSelectFork(rpc);
    }

    function test_fork_chainlinkFeedExists() public view {
        IChainlinkFeed feed = IChainlinkFeed(ARB_SEP_ETH_USD);
        uint8 dec = feed.decimals();
        assertEq(dec, 8);
    }

    function test_fork_chainlinkReturnsPositivePrice() public view {
        IChainlinkFeed feed = IChainlinkFeed(ARB_SEP_ETH_USD);
        (, int256 price,,,) = feed.latestRoundData();
        assertGt(price, 0);
    }

    function test_fork_priceOracleWithRealFeed() public {
        PriceOracle oracle = new PriceOracle(ARB_SEP_ETH_USD);
        int256 price = oracle.getPrice();
        assertGt(price, 0);
    }
}
