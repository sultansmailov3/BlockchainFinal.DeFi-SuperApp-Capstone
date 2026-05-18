// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {GovToken} from "../src/GovToken.sol";
import {ProtocolTimelock} from "../src/ProtocolTimelock.sol";
import {ProtocolGovernor} from "../src/ProtocolGovernor.sol";
import {PriceOracle} from "../src/PriceOracle.sol";
import {ProtocolV1} from "../src/ProtocolV1.sol";
import {ProtocolNFT} from "../src/ProtocolNFT.sol";
import {Factory} from "../src/Factory.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract Deploy is Script {
    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerKey);
        vm.startBroadcast(deployerKey);

        // 1. GovToken
        GovToken token = new GovToken(deployer);
        console.log("GovToken:", address(token));

        // 2. Timelock (2 day delay)
        address[] memory proposers = new address[](1);
        address[] memory executors = new address[](1);
        proposers[0] = address(0); // governor set after
        executors[0] = address(0); // anyone can execute
        ProtocolTimelock timelock = new ProtocolTimelock(proposers, executors, deployer);
        console.log("Timelock:", address(timelock));

        // 3. Governor
        ProtocolGovernor governor = new ProtocolGovernor(token, timelock);
        console.log("Governor:", address(governor));

        // 4. Grant roles: governor is proposer, timelock is executor
        bytes32 PROPOSER_ROLE = timelock.PROPOSER_ROLE();
        bytes32 EXECUTOR_ROLE = timelock.EXECUTOR_ROLE();
        bytes32 CANCELLER_ROLE = timelock.CANCELLER_ROLE();
        timelock.grantRole(PROPOSER_ROLE, address(governor));
        timelock.grantRole(EXECUTOR_ROLE, address(0));
        timelock.grantRole(CANCELLER_ROLE, address(governor));
        timelock.renounceRole(timelock.DEFAULT_ADMIN_ROLE(), deployer);

        // 5. PriceOracle (mock feed for testnet)
        // On real deploy: use actual Chainlink feed address
        address mockFeed = address(0x1234); // replace with real feed
        PriceOracle oracle = new PriceOracle(mockFeed);
        console.log("PriceOracle:", address(oracle));

        // 6. ProtocolV1 via UUPS proxy
        ProtocolV1 impl = new ProtocolV1();
        bytes memory initData = abi.encodeCall(ProtocolV1.initialize, (address(timelock)));
        ERC1967Proxy proxy = new ERC1967Proxy(address(impl), initData);
        console.log("ProtocolProxy:", address(proxy));

        // 7. ProtocolNFT
        ProtocolNFT nft = new ProtocolNFT(address(timelock));
        console.log("ProtocolNFT:", address(nft));

        // 8. Factory
        Factory factory = new Factory();
        console.log("Factory:", address(factory));

        vm.stopBroadcast();
    }
}
