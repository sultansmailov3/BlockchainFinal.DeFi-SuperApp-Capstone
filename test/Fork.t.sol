// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

interface IERC20Metadata {
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function symbol() external view returns (string memory);
}

interface AggregatorV3Interface {
    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function decimals() external view returns (uint8);
}

contract ForkTest is Test {
    // Ethereum mainnet addresses
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant CHAINLINK_ETH_USD = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;

    function setUp() public {
        string memory rpcUrl = vm.envString("MAINNET_RPC_URL");
        vm.createSelectFork(rpcUrl);
    }

    function testFork_USDCHasSixDecimals() public view {
        uint8 decimals = IERC20Metadata(USDC).decimals();
        assertEq(decimals, 6);
    }

    function testFork_USDCTotalSupplyGreaterThanZero() public view {
        uint256 supply = IERC20Metadata(USDC).totalSupply();
        assertGt(supply, 0);
    }

    function testFork_ChainlinkETHUSDReturnsValidPrice() public view {
        AggregatorV3Interface feed = AggregatorV3Interface(CHAINLINK_ETH_USD);

        (, int256 answer,, uint256 updatedAt,) = feed.latestRoundData();

        assertGt(answer, 0);
        assertGt(updatedAt, 0);
    }
}