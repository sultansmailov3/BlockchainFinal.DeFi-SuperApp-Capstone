// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice Mock Chainlink aggregator for tests.
contract MockAggregator {
    int256 private _price;
    uint256 private _updatedAt;
    uint8 private _decimals;

    constructor(int256 initialPrice, uint8 decimals_) {
        _price = initialPrice;
        _updatedAt = block.timestamp;
        _decimals = decimals_;
    }

    function setPrice(int256 price) external {
        _price = price;
        _updatedAt = block.timestamp;
    }

    function setUpdatedAt(uint256 updatedAt) external {
        _updatedAt = updatedAt;
    }

    function latestRoundData() external view returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ) {
        return (1, _price, block.timestamp, _updatedAt, 1);
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }
}
