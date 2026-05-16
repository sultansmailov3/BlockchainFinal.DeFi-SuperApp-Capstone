// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/GovToken.sol";
import "../src/ProtocolTimelock.sol";
import "../src/ProtocolGovernor.sol";
import "../src/PriceOracle.sol";
import "../src/ProtocolV1.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract Deploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        GovToken token = new GovToken(deployer);

        address[] memory proposers = new address[](0);
        address[] memory executors = new address[](0);
        ProtocolTimelock timelock = new ProtocolTimelock(
            2 days, proposers, executors, deployer
        );

        ProtocolGovernor governor = new ProtocolGovernor(token, timelock);

        timelock.grantRole(timelock.PROPOSER_ROLE(), address(governor));
        timelock.grantRole(timelock.EXECUTOR_ROLE(), address(governor));
        timelock.renounceRole(timelock.DEFAULT_ADMIN_ROLE(), deployer);

        PriceOracle oracle = new PriceOracle(0xd30e2101a97dcbAeBCBC04F14C3f624E67A35165);

        ProtocolV1 impl = new ProtocolV1();
        bytes memory data = abi.encodeCall(ProtocolV1.initialize, (address(timelock)));
        ERC1967Proxy proxy = new ERC1967Proxy(address(impl), data);

        vm.stopBroadcast();

        console.log("GovToken:", address(token));
        console.log("Timelock:", address(timelock));
        console.log("Governor:", address(governor));
        console.log("PriceOracle:", address(oracle));
        console.log("ProtocolProxy:", address(proxy));
    }
}
