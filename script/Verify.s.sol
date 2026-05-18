// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {ProtocolGovernor} from "../src/ProtocolGovernor.sol";
import {ProtocolTimelock} from "../src/ProtocolTimelock.sol";
import {GovToken} from "../src/GovToken.sol";

/// @notice Post-deployment verification script.
/// @dev Run after Deploy.s.sol to confirm all protocol invariants hold.
contract Verify is Script {
    address constant GOV_TOKEN = 0x0d89094Ac95e7b77b9bfA789Fae56B114d717D52;
    address constant TIMELOCK  = 0x6D7031Bd523fe5Dab7eFD1e5e3CBE32726BE24de;
    address constant GOVERNOR  = 0x357BbC9D5D6D3964738F6B0fB2114c2EfB194258;
    address constant PROXY     = 0xAfbF9D149BB657f4562F30EAc26FD94c703a3E9D;

    function run() external view {
        console.log("=== DeFi Super-App Post-Deployment Verification ===");

        ProtocolGovernor governor = ProtocolGovernor(payable(GOVERNOR));
        ProtocolTimelock timelock = ProtocolTimelock(payable(TIMELOCK));
        GovToken token = GovToken(GOV_TOKEN);

        // 1. Voting delay ~1 day
        uint256 votingDelay = governor.votingDelay();
        require(votingDelay == 7200, "FAIL: votingDelay");
        console.log("PASS: votingDelay ==", votingDelay);

        // 2. Voting period ~1 week
        uint256 votingPeriod = governor.votingPeriod();
        require(votingPeriod == 50400, "FAIL: votingPeriod");
        console.log("PASS: votingPeriod ==", votingPeriod);

        // 3. Quorum 4%
        uint256 quorum = governor.quorumNumerator();
        require(quorum == 4, "FAIL: quorum");
        console.log("PASS: quorum ==", quorum);

        // 4. Timelock 2 days
        uint256 delay = timelock.getMinDelay();
        require(delay == 2 days, "FAIL: timelockDelay");
        console.log("PASS: timelockDelay ==", delay);

        // 5. GovToken supply 1M
        uint256 supply = token.totalSupply();
        require(supply == 1_000_000e18, "FAIL: totalSupply");
        console.log("PASS: totalSupply ==", supply);

        // 6. Governor timelock matches
        address govTimelock = address(governor.timelock());
        require(govTimelock == TIMELOCK, "FAIL: timelock mismatch");
        console.log("PASS: governor.timelock() == TIMELOCK");

        console.log("=== ALL CHECKS PASSED ===");
    }
}
