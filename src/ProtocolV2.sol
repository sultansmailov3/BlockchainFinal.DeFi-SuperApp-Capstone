// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract ProtocolV2 is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    uint256 public value;
    string public name;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address owner) public initializer {
        __Ownable_init(owner);
    }

    function initializeV2(string memory _name) public reinitializer(2) {
        name = _name;
    }

    function setValue(uint256 _value) external {
        value = _value;
    }

    function version() external pure returns (string memory) {
        return "V2";
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}
}
