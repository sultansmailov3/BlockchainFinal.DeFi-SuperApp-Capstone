// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface AggregatorV3Interface {
    function latestRoundData() external view returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    );
}

contract PriceOracle {
    AggregatorV3Interface public feed;
    uint256 public constant MAX_STALENESS = 3600; // 1 час

    constructor(address _feed) {
        feed = AggregatorV3Interface(_feed);
    }

    function getPrice() external view returns (int256) {
        (
            ,
            int256 price,
            ,
            uint256 updatedAt,
        ) = feed.latestRoundData();

        require(price > 0, "Invalid price");
        require(block.timestamp - updatedAt <= MAX_STALENESS, "Stale price");

        return price;
    }
}
