// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {AMM} from "../src/AMM.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract AMMTest is Test {
    AMM public amm;
    ERC20Mock public tokenA;
    ERC20Mock public tokenB;
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        tokenA = new ERC20Mock();
        tokenB = new ERC20Mock();
        amm = new AMM(address(tokenA), address(tokenB));
        tokenA.mint(alice, 1_000_000e18);
        tokenB.mint(alice, 1_000_000e18);
        tokenA.mint(bob, 1_000_000e18);
        tokenB.mint(bob, 1_000_000e18);
    }

    function _seed(address who, uint256 a, uint256 b) internal {
        tokenA.mint(who, a);
        tokenB.mint(who, b);
        vm.startPrank(who);
        tokenA.approve(address(amm), a);
        tokenB.approve(address(amm), b);
        amm.addLiquidity(a, b);
        vm.stopPrank();
    }

    function test_addLiquidity_initial() public {
        vm.startPrank(alice);
        tokenA.approve(address(amm), 1000e18);
        tokenB.approve(address(amm), 1000e18);
        uint256 shares = amm.addLiquidity(1000e18, 1000e18);
        vm.stopPrank();
        assertGt(shares, 0);
    }

    function test_addLiquidity_setsReserves() public {
        vm.startPrank(alice);
        tokenA.approve(address(amm), 500e18);
        tokenB.approve(address(amm), 500e18);
        amm.addLiquidity(500e18, 500e18);
        vm.stopPrank();
        assertEq(amm.reserve0(), 500e18);
        assertEq(amm.reserve1(), 500e18);
    }

    function test_addLiquidity_mintLPTokens() public {
        vm.startPrank(alice);
        tokenA.approve(address(amm), 1000e18);
        tokenB.approve(address(amm), 1000e18);
        amm.addLiquidity(1000e18, 1000e18);
        vm.stopPrank();
        assertGt(amm.balanceOf(alice), 0);
    }

    function test_addLiquidity_subsequent() public {
        _seed(alice, 1000e18, 1000e18);
        vm.startPrank(bob);
        tokenA.approve(address(amm), 500e18);
        tokenB.approve(address(amm), 500e18);
        uint256 shares = amm.addLiquidity(500e18, 500e18);
        vm.stopPrank();
        assertGt(shares, 0);
    }

    function test_swap_token0In() public {
        _seed(alice, 10000e18, 10000e18);
        vm.startPrank(bob);
        tokenA.approve(address(amm), 100e18);
        uint256 out = amm.swap(address(tokenA), 100e18, 0);
        vm.stopPrank();
        assertGt(out, 0);
    }

    function test_swap_token1In() public {
        _seed(alice, 10000e18, 10000e18);
        vm.startPrank(bob);
        tokenB.approve(address(amm), 100e18);
        uint256 out = amm.swap(address(tokenB), 100e18, 0);
        vm.stopPrank();
        assertGt(out, 0);
    }

    function test_swap_revertsSlippage() public {
        _seed(alice, 10000e18, 10000e18);
        vm.startPrank(bob);
        tokenA.approve(address(amm), 100e18);
        vm.expectRevert();
        amm.swap(address(tokenA), 100e18, type(uint256).max);
        vm.stopPrank();
    }

    function test_swap_revertsInvalidToken() public {
        _seed(alice, 10000e18, 10000e18);
        vm.startPrank(bob);
        vm.expectRevert();
        amm.swap(address(0xdead), 100e18, 0);
        vm.stopPrank();
    }

    function test_swap_updatesReserves() public {
        _seed(alice, 10000e18, 10000e18);
        uint256 r0 = amm.reserve0();
        vm.startPrank(bob);
        tokenA.approve(address(amm), 100e18);
        amm.swap(address(tokenA), 100e18, 0);
        vm.stopPrank();
        assertGt(amm.reserve0(), r0);
    }

    function test_token0_address() public view {
        assertEq(address(amm.token0()), address(tokenA));
    }

    function test_token1_address() public view {
        assertEq(address(amm.token1()), address(tokenB));
    }

    function test_lpTokenName() public view {
        assertEq(amm.name(), "LP Token");
    }

    function test_lpTokenSymbol() public view {
        assertEq(amm.symbol(), "LPT");
    }

    function test_reservesZeroInitially() public view {
        assertEq(amm.reserve0(), 0);
        assertEq(amm.reserve1(), 0);
    }

    function test_feeConstant() public view {
        assertEq(amm.FEE_BPS(), 30);
    }

    function testFuzz_addLiquidity(uint256 a, uint256 b) public {
        a = bound(a, 1e18, 100_000e18);
        b = bound(b, 1e18, 100_000e18);
        tokenA.mint(address(this), a);
        tokenB.mint(address(this), b);
        tokenA.approve(address(amm), a);
        tokenB.approve(address(amm), b);
        uint256 shares = amm.addLiquidity(a, b);
        assertGt(shares, 0);
    }

    function testFuzz_swap_token0(uint256 amountIn) public {
        _seed(alice, 100_000e18, 100_000e18);
        amountIn = bound(amountIn, 1e15, 1000e18);
        tokenA.mint(bob, amountIn);
        vm.startPrank(bob);
        tokenA.approve(address(amm), amountIn);
        uint256 out = amm.swap(address(tokenA), amountIn, 0);
        vm.stopPrank();
        assertGt(out, 0);
    }

    function testFuzz_swap_token1(uint256 amountIn) public {
        _seed(alice, 100_000e18, 100_000e18);
        amountIn = bound(amountIn, 1e15, 1000e18);
        tokenB.mint(bob, amountIn);
        vm.startPrank(bob);
        tokenB.approve(address(amm), amountIn);
        uint256 out = amm.swap(address(tokenB), amountIn, 0);
        vm.stopPrank();
        assertGt(out, 0);
    }

    function testFuzz_getAmountOut(uint256 amountIn) public view {
        amountIn = bound(amountIn, 1e15, 1000e18);
        uint256 out = amm.getAmountOut(amountIn, 10000e18, 10000e18);
        assertGt(out, 0);
        assertLt(out, amountIn);
    }
}
