// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {ProtocolNFT} from "../src/ProtocolNFT.sol";
import {Factory} from "../src/Factory.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract ProtocolNFTTest is Test {
    ProtocolNFT public nft;
    address owner = makeAddr("owner");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        nft = new ProtocolNFT(owner);
    }

    function test_mint_basic() public {
        vm.prank(owner);
        uint256 id = nft.mint(alice, "ipfs://1");
        assertEq(nft.ownerOf(id), alice);
    }

    function test_mint_incrementsId() public {
        vm.startPrank(owner);
        nft.mint(alice, "ipfs://1");
        nft.mint(alice, "ipfs://2");
        vm.stopPrank();
        assertEq(nft.totalMinted(), 2);
    }

    function test_mint_setsURI() public {
        vm.prank(owner);
        uint256 id = nft.mint(alice, "ipfs://abc");
        assertEq(nft.tokenURI(id), "ipfs://abc");
    }

    function test_mint_revertsNonOwner() public {
        vm.prank(alice);
        vm.expectRevert();
        nft.mint(bob, "ipfs://hack");
    }

    function test_mint_emitsEvent() public {
        vm.prank(owner);
        vm.expectEmit(true, true, false, false);
        emit ProtocolNFT.Minted(alice, 0);
        nft.mint(alice, "ipfs://ev");
    }

    function test_minYul_correct() public view {
        assertEq(nft.minYul(3, 7), 3);
        assertEq(nft.minYul(7, 3), 3);
        assertEq(nft.minYul(5, 5), 5);
    }

    function test_maxYul_correct() public view {
        assertEq(nft.maxYul(3, 7), 7);
        assertEq(nft.maxYul(7, 3), 7);
        assertEq(nft.maxYul(5, 5), 5);
    }

    function test_minYul_matchesSolidity() public view {
        assertEq(nft.minYul(123, 456), nft.minSolidity(123, 456));
    }

    function test_maxYul_matchesSolidity() public view {
        assertEq(nft.maxYul(123, 456), nft.maxSolidity(123, 456));
    }

    function test_isContractYul_contract() public view {
        assertTrue(nft.isContractYul(address(nft)));
    }

    function test_isContractYul_eoa() public view {
        assertFalse(nft.isContractYul(alice));
    }

    function test_totalMintedYul() public {
        vm.startPrank(owner);
        nft.mint(alice, "1");
        nft.mint(alice, "2");
        vm.stopPrank();
        assertEq(nft.totalMintedYul(), 2);
    }

    function testFuzz_minYul(uint256 a, uint256 b) public view {
        assertEq(nft.minYul(a, b), nft.minSolidity(a, b));
    }

    function testFuzz_maxYul(uint256 a, uint256 b) public view {
        assertEq(nft.maxYul(a, b), nft.maxSolidity(a, b));
    }
}

contract FactoryTest is Test {
    Factory public factory;
    ERC20Mock public tokenA;
    ERC20Mock public tokenB;
    ERC20Mock public tokenC;

    function setUp() public {
        factory = new Factory();
        tokenA = new ERC20Mock();
        tokenB = new ERC20Mock();
        tokenC = new ERC20Mock();
    }

    function test_createPair_basic() public {
        address pair = factory.createPair(address(tokenA), address(tokenB));
        assertNotEq(pair, address(0));
    }

    function test_createPair_stored() public {
        factory.createPair(address(tokenA), address(tokenB));
        assertNotEq(factory.getPair(address(tokenA), address(tokenB)), address(0));
    }

    function test_createPair_symmetric() public {
        factory.createPair(address(tokenA), address(tokenB));
        assertEq(
            factory.getPair(address(tokenA), address(tokenB)),
            factory.getPair(address(tokenB), address(tokenA))
        );
    }

    function test_createPair_revertsIdentical() public {
        vm.expectRevert();
        factory.createPair(address(tokenA), address(tokenA));
    }

    function test_createPair_revertsExists() public {
        factory.createPair(address(tokenA), address(tokenB));
        vm.expectRevert();
        factory.createPair(address(tokenA), address(tokenB));
    }

    function test_createPair_multiple() public {
        factory.createPair(address(tokenA), address(tokenB));
        factory.createPair(address(tokenA), address(tokenC));
        assertEq(factory.allPairsLength(), 2);
    }

    function test_createPair2_basic() public {
        
        address pair = factory.createPairCreate(address(tokenA), address(tokenB));
        assertNotEq(pair, address(0));
    }

    function test_createPair2_matchesPrediction() public {
        
        address predicted = factory.predictAddress(address(tokenA), address(tokenB));
        address actual = factory.createPairCreate(address(tokenA), address(tokenB));
        assertEq(actual, predicted);
    }

    function test_allPairsLength_initial() public view {
        assertEq(factory.allPairsLength(), 0);
    }
}
