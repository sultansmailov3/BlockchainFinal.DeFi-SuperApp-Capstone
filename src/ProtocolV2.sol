// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./ProtocolV1.sol";

contract ProtocolV2 is ProtocolV1 {
    uint256 public version;
    string public name;

    function initializeV2(string memory _name) external reinitializer(2) {
        name = _name;
        version = 2;
    }

    function getVersion() external pure returns (uint256) {
        return 2;
    }
}
