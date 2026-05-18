// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {ProtocolV1} from "../src/ProtocolV1.sol";
import {ProtocolV2} from "../src/ProtocolV2.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract ProtocolUpgradeTest is Test {
    ProtocolV1 public v1impl;
    ProtocolV2 public v2impl;
    ERC1967Proxy public proxy;
    ProtocolV1 public v1;

    address owner = makeAddr("owner");

    function setUp() public {
        v1impl = new ProtocolV1();
        bytes memory init = abi.encodeCall(ProtocolV1.initialize, (owner));
        proxy = new ERC1967Proxy(address(v1impl), init);
        v1 = ProtocolV1(address(proxy));
    }

    function test_v1_version() public view {
        assertEq(v1.version(), "V1");
    }

    function test_v1_setValue() public {
        vm.prank(owner);
        v1.setValue(42);
        assertEq(v1.value(), 42);
    }

    function test_upgrade_toV2() public {
        v2impl = new ProtocolV2();
        vm.prank(owner);
        v1.upgradeToAndCall(address(v2impl), "");
        ProtocolV2 v2 = ProtocolV2(address(proxy));
        assertEq(v2.version(), "V2");
    }

    function test_upgrade_preservesValue() public {
        vm.prank(owner);
        v1.setValue(99);

        v2impl = new ProtocolV2();
        vm.prank(owner);
        v1.upgradeToAndCall(address(v2impl), "");

        ProtocolV2 v2 = ProtocolV2(address(proxy));
        assertEq(v2.value(), 99);
    }

    function test_upgrade_revertsNonOwner() public {
        v2impl = new ProtocolV2();
        vm.prank(makeAddr("attacker"));
        vm.expectRevert();
        v1.upgradeToAndCall(address(v2impl), "");
    }

    function test_v2_initializeV2() public {
        v2impl = new ProtocolV2();
        vm.prank(owner);
        v1.upgradeToAndCall(address(v2impl), "");
        ProtocolV2 v2 = ProtocolV2(address(proxy));
        vm.prank(owner);
        v2.initializeV2("DeFi Protocol");
        assertEq(v2.name(), "DeFi Protocol");
    }

    function test_v2_setValue() public {
        v2impl = new ProtocolV2();
        vm.prank(owner);
        v1.upgradeToAndCall(address(v2impl), "");
        ProtocolV2 v2 = ProtocolV2(address(proxy));
        vm.prank(owner);
        v2.setValue(777);
        assertEq(v2.value(), 777);
    }
}
