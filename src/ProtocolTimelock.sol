// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";

/// @notice 2-day timelock for all governance actions.
contract ProtocolTimelock is TimelockController {
    constructor(
        address[] memory proposers,
        address[] memory executors,
        address admin
    ) TimelockController(2 days, proposers, executors, admin) {}
}
