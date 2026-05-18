// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import "../src/ProtocolNFT.sol";
import "../src/Factory.sol";

contract NFTAndFactoryTest is Test {
    ProtocolNFT nft;
    Factory factory;

    address owner = address(this);
    address alice = address(0xA11CE);
    address bob = address(0xB0B);

    function setUp() public {
        nft = new ProtocolNFT(owner);
        factory = new Factory();
    }

    function test_NFTName() public view {
        assertEq(nft.name(), "Protocol NFT");
    }

    function test_NFTSymbol() public view {
        assertEq(nft.symbol(), "PNFT");
    }

    function test_OwnerCanMintNFT() public {
        uint256 tokenId = nft.mint(alice);

        assertEq(tokenId, 0);
        assertEq(nft.ownerOf(tokenId), alice);
        assertEq(nft.balanceOf(alice), 1);
    }

    function test_MultipleMintsIncrementTokenId() public {
        uint256 firstId = nft.mint(alice);
        uint256 secondId = nft.mint(bob);

        assertEq(firstId, 0);
        assertEq(secondId, 1);
        assertEq(nft.ownerOf(0), alice);
        assertEq(nft.ownerOf(1), bob);
        assertEq(nft.nextTokenId(), 2);
    }

    function test_NonOwnerCannotMintNFT() public {
        vm.prank(alice);
        vm.expectRevert();
        nft.mint(alice);
    }

    function test_FactoryCanDeployWithCreate() public {
        address deployed = factory.deployCreate();

        assertTrue(deployed != address(0));
    }

    function test_FactoryCanDeployWithCreate2() public {
        bytes32 salt = bytes32(uint256(1));

        address deployed = factory.deployCreate2(salt);

        assertTrue(deployed != address(0));
    }

    function test_FactoryCreate2AddressIsDeterministic() public {
        bytes32 salt = bytes32(uint256(123));

        address predicted = factory.computeCreate2Address(salt);
        address deployed = factory.deployCreate2(salt);

        assertEq(deployed, predicted);
    }

    function test_FactoryCreate2RevertsOnSameSalt() public {
        bytes32 salt = bytes32(uint256(999));

        factory.deployCreate2(salt);

        vm.expectRevert();
        factory.deployCreate2(salt);
    }
}
