// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "../src/ProtocolV1.sol";
import "../src/ProtocolV2.sol";

contract ProtocolUpgradeTest is Test {
    ProtocolV1 v1;
    ProtocolV2 v2;
    ERC1967Proxy proxy;
    address owner = address(1);

    function setUp() public {
        ProtocolV1 impl = new ProtocolV1();
        bytes memory data = abi.encodeCall(ProtocolV1.initialize, (owner));
        proxy = new ERC1967Proxy(address(impl), data);
        v1 = ProtocolV1(address(proxy));
    }

    function test_InitialValue() public view {
        assertEq(v1.value(), 0);
        assertEq(v1.owner(), owner);
    }

    function test_SetValue() public {
        vm.prank(owner);
        v1.setValue(42);
        assertEq(v1.value(), 42);
    }

    function test_UpgradeToV2() public {
        ProtocolV2 implV2 = new ProtocolV2();
        vm.prank(owner);
        v1.upgradeToAndCall(
            address(implV2),
            abi.encodeCall(ProtocolV2.initializeV2, ("MyProtocol"))
        );
        v2 = ProtocolV2(address(proxy));
        assertEq(v2.getVersion(), 2);
        assertEq(v2.name(), "MyProtocol");
    }

    function test_RevertUpgradeIfNotOwner() public {
        ProtocolV2 implV2 = new ProtocolV2();
        vm.expectRevert();
        v1.upgradeToAndCall(address(implV2), "");
    }
}
