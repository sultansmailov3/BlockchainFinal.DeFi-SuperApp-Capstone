// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import "../src/GovToken.sol";
import "../src/ProtocolTimelock.sol";
import "../src/ProtocolGovernor.sol";
import "../src/ProtocolNFT.sol";
import "../src/Factory.sol";
import "../src/PriceOracle.sol";
import "../src/mocks/MockAggregator.sol";
import "../src/ProtocolV1.sol";
import "../src/ProtocolV2.sol";

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract AdditionalCoverageTest is Test {
    GovToken token;
    ProtocolTimelock timelock;
    ProtocolGovernor governor;
    ProtocolNFT nft;
    Factory factory;
    MockAggregator feed;
    PriceOracle oracle;

    address owner = address(this);
    address alice = address(0xA11CE);
    address bob = address(0xB0B);

    function setUp() public {
        token = new GovToken(owner);

        address[] memory proposers = new address[](0);
        address[] memory executors = new address[](0);
        timelock = new ProtocolTimelock(2 days, proposers, executors, owner);

        governor = new ProtocolGovernor(token, timelock);

        timelock.grantRole(timelock.PROPOSER_ROLE(), address(governor));
        timelock.grantRole(timelock.EXECUTOR_ROLE(), address(governor));

        nft = new ProtocolNFT(owner);
        factory = new Factory();

        feed = new MockAggregator(2000e8);
        oracle = new PriceOracle(address(feed));
    }

    function test_Additional_GovTokenDecimals() public view {
        assertEq(token.decimals(), 18);
    }

    function test_Additional_GovTokenOwnerBalanceNonZero() public view {
        assertGt(token.balanceOf(owner), 0);
    }

    function test_Additional_GovTokenAliceStartsZero() public view {
        assertEq(token.balanceOf(alice), 0);
    }

    function test_Additional_GovTokenBobStartsZero() public view {
        assertEq(token.balanceOf(bob), 0);
    }

    function test_Additional_GovTokenTotalSupplyMillion() public view {
        assertEq(token.totalSupply(), 1_000_000 ether);
    }

    function test_Additional_GovTokenOwnerCanTransferAlice() public {
        token.transfer(alice, 1 ether);
        assertEq(token.balanceOf(alice), 1 ether);
    }

    function test_Additional_GovTokenOwnerCanTransferBob() public {
        token.transfer(bob, 2 ether);
        assertEq(token.balanceOf(bob), 2 ether);
    }

    function test_Additional_GovTokenTransferReducesOwner() public {
        uint256 beforeBalance = token.balanceOf(owner);
        token.transfer(alice, 3 ether);
        assertEq(token.balanceOf(owner), beforeBalance - 3 ether);
    }

    function test_Additional_GovTokenAllowanceStartsZero() public view {
        assertEq(token.allowance(owner, alice), 0);
    }

    function test_Additional_GovTokenApproveSetsAllowance() public {
        token.approve(alice, 10 ether);
        assertEq(token.allowance(owner, alice), 10 ether);
    }

    function test_Additional_GovTokenApproveCanUpdateAllowance() public {
        token.approve(alice, 10 ether);
        token.approve(alice, 4 ether);
        assertEq(token.allowance(owner, alice), 4 ether);
    }

    function test_Additional_GovTokenTransferFromWorks() public {
        token.approve(alice, 5 ether);
        vm.prank(alice);
        token.transferFrom(owner, bob, 5 ether);
        assertEq(token.balanceOf(bob), 5 ether);
    }

    function test_Additional_GovTokenTransferFromReducesAllowance() public {
        token.approve(alice, 5 ether);
        vm.prank(alice);
        token.transferFrom(owner, bob, 2 ether);
        assertEq(token.allowance(owner, alice), 3 ether);
    }

    function test_Additional_GovTokenDelegateOwnerVotes() public {
        token.delegate(owner);
        assertEq(token.getVotes(owner), token.balanceOf(owner));
    }

    function test_Additional_GovTokenDelegateAliceVotesAfterTransfer() public {
        token.transfer(alice, 10 ether);
        vm.prank(alice);
        token.delegate(alice);
        assertEq(token.getVotes(alice), 10 ether);
    }

    function test_Additional_GovTokenDelegatesDefaultZero() public view {
        assertEq(token.delegates(alice), address(0));
    }

    function test_Additional_GovTokenDelegateToBob() public {
        token.transfer(alice, 8 ether);
        vm.prank(alice);
        token.delegate(bob);
        assertEq(token.delegates(alice), bob);
    }

    function test_Additional_TimelockDelay() public view {
        assertEq(timelock.getMinDelay(), 2 days);
    }

    function test_Additional_TimelockGovernorIsProposer() public view {
        assertTrue(timelock.hasRole(timelock.PROPOSER_ROLE(), address(governor)));
    }

    function test_Additional_TimelockGovernorIsExecutor() public view {
        assertTrue(timelock.hasRole(timelock.EXECUTOR_ROLE(), address(governor)));
    }

    function test_Additional_TimelockOwnerIsAdminBeforeRenounce() public view {
        assertTrue(timelock.hasRole(timelock.DEFAULT_ADMIN_ROLE(), owner));
    }

    function test_Additional_TimelockAliceNotAdmin() public view {
        assertFalse(timelock.hasRole(timelock.DEFAULT_ADMIN_ROLE(), alice));
    }

    function test_Additional_TimelockBobNotProposer() public view {
        assertFalse(timelock.hasRole(timelock.PROPOSER_ROLE(), bob));
    }

    function test_Additional_TimelockBobNotExecutor() public view {
        assertFalse(timelock.hasRole(timelock.EXECUTOR_ROLE(), bob));
    }

    function test_Additional_GovernorName() public view {
        assertEq(governor.name(), "ProtocolGovernor");
    }

    function test_Additional_GovernorVotingDelay() public view {
        assertEq(governor.votingDelay(), 7200);
    }

    function test_Additional_GovernorVotingPeriod() public view {
        assertEq(governor.votingPeriod(), 50400);
    }

    function test_Additional_GovernorQuorumNumerator() public view {
        assertEq(governor.quorumNumerator(), 4);
    }

    function test_Additional_GovernorProposalThreshold() public view {
        assertEq(governor.proposalThreshold(), 1 ether);
    }

    function test_Additional_NftName() public view {
        assertEq(nft.name(), "Protocol NFT");
    }

    function test_Additional_NftSymbol() public view {
        assertEq(nft.symbol(), "PNFT");
    }

    function test_Additional_NftOwnerCanMint() public {
        nft.mint(alice);
        assertEq(nft.ownerOf(0), alice);
    }

    function test_Additional_NftMintIncreasesBalance() public {
        nft.mint(alice);
        assertEq(nft.balanceOf(alice), 1);
    }

    function test_Additional_NftSecondMintTokenIdOne() public {
        nft.mint(alice);
        nft.mint(bob);
        assertEq(nft.ownerOf(1), bob);
    }

    function test_Additional_NftNonOwnerCannotMint() public {
        vm.prank(alice);
        vm.expectRevert();
        nft.mint(alice);
    }

    function test_Additional_OracleReturnsPositivePrice() public view {
        assertGt(oracle.getPrice(), 0);
    }

    function test_Additional_OracleReturnsInitialPrice() public view {
        assertEq(oracle.getPrice(), 2000e8);
    }

    function test_Additional_OracleUpdatesPrice() public {
        feed.setPrice(2100e8);
        assertEq(oracle.getPrice(), 2100e8);
    }

    function test_Additional_OracleRejectsZeroPrice() public {
        feed.setPrice(0);
        vm.expectRevert("Invalid price");
        oracle.getPrice();
    }

    function test_Additional_OracleRejectsNegativePrice() public {
        feed.setPrice(-1);
        vm.expectRevert("Invalid price");
        oracle.getPrice();
    }

    function test_Additional_OracleRejectsStalePrice() public {
        vm.warp(10 days);
        feed.setUpdatedAt(block.timestamp - 2 days);
        vm.expectRevert("Stale price");
        oracle.getPrice();
    }

    function test_Additional_OracleAcceptsFreshPrice() public {
        feed.setUpdatedAt(block.timestamp);
        assertEq(oracle.getPrice(), 2000e8);
    }

    function test_Additional_FactoryAddressNotZero() public view {
        assertTrue(address(factory) != address(0));
    }

    function test_Additional_FactoryCanDeployCreate() public {
        address deployed = factory.deployCreate();
        assertTrue(deployed != address(0));
    }

    function test_Additional_FactoryCanDeployCreate2() public {
        address deployed = factory.deployCreate2(bytes32(uint256(1)));
        assertTrue(deployed != address(0));
    }

    function test_Additional_FactoryCreate2Deterministic() public {
        bytes32 salt = bytes32(uint256(123));
        address predicted = factory.computeCreate2Address(salt);
        address deployed = factory.deployCreate2(salt);
        assertEq(deployed, predicted);
    }

    function test_Additional_ProtocolV1InitializesValue() public {
        ProtocolV1 impl = new ProtocolV1();
        ERC1967Proxy proxy = new ERC1967Proxy(address(impl), abi.encodeCall(ProtocolV1.initialize, (owner)));
        ProtocolV1 v1 = ProtocolV1(address(proxy));
        assertEq(v1.value(), 0);
    }

    function test_Additional_ProtocolV1OwnerCanSetValue() public {
        ProtocolV1 impl = new ProtocolV1();
        ERC1967Proxy proxy = new ERC1967Proxy(address(impl), abi.encodeCall(ProtocolV1.initialize, (owner)));
        ProtocolV1 v1 = ProtocolV1(address(proxy));
        v1.setValue(777);
        assertEq(v1.value(), 777);
    }

    function test_Additional_ProtocolV1NonOwnerCanSetValueIfFunctionIsPublic() public {
        ProtocolV1 impl = new ProtocolV1();
        ERC1967Proxy proxy = new ERC1967Proxy(address(impl), abi.encodeCall(ProtocolV1.initialize, (owner)));
        ProtocolV1 v1 = ProtocolV1(address(proxy));
        vm.prank(alice);
        v1.setValue(1);
        assertEq(v1.value(), 1);
    }
}
