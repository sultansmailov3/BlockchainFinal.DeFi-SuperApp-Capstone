// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface AggregatorV3Interface {
    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
    function decimals() external view returns (uint8);
}

contract PriceOracle {
    AggregatorV3Interface public immutable feed;
    uint256 public constant MAX_STALENESS = 3600;

    constructor(address _feed) {
        feed = AggregatorV3Interface(_feed);
    }

    function getPrice() external view returns (int256 price) {
        uint80 roundId;
        uint256 startedAt;
        uint256 updatedAt;
        uint80 answeredInRound;
        (roundId, price, startedAt, updatedAt, answeredInRound) = feed.latestRoundData();
        require(block.timestamp - updatedAt <= MAX_STALENESS, "PriceOracle: stale price");
        require(price > 0, "PriceOracle: invalid price");
    }

    function decimals() external view returns (uint8) {
        return feed.decimals();
    }
}
