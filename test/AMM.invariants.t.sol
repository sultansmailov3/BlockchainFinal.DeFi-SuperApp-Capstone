// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {AMM} from "../src/AMM.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract AMMHandler is Test {
    AMM public amm;
    ERC20Mock public token0;
    ERC20Mock public token1;
    address actor = makeAddr("actor");

    constructor(AMM _amm, ERC20Mock _t0, ERC20Mock _t1) {
        amm = _amm;
        token0 = _t0;
        token1 = _t1;
        token0.mint(actor, 1_000_000e18);
        token1.mint(actor, 1_000_000e18);
        vm.startPrank(actor);
        token0.approve(address(amm), type(uint256).max);
        token1.approve(address(amm), type(uint256).max);
        amm.addLiquidity(10_000e18, 10_000e18);
        vm.stopPrank();
    }

    function swap0(uint256 amount) external {
        amount = bound(amount, 1e15, 100e18);
        token0.mint(actor, amount);
        vm.startPrank(actor);
        token0.approve(address(amm), amount);
        amm.swap(address(token0), amount, 0);
        vm.stopPrank();
    }

    function swap1(uint256 amount) external {
        amount = bound(amount, 1e15, 100e18);
        token1.mint(actor, amount);
        vm.startPrank(actor);
        token1.approve(address(amm), amount);
        amm.swap(address(token1), amount, 0);
        vm.stopPrank();
    }
}

contract AMMInvariantsTest is StdInvariant, Test {
    AMM public amm;
    ERC20Mock public token0;
    ERC20Mock public token1;
    AMMHandler public handler;
    uint256 public initialK;

    function setUp() public {
        token0 = new ERC20Mock();
        token1 = new ERC20Mock();
        amm = new AMM(address(token0), address(token1));
        handler = new AMMHandler(amm, token0, token1);
        initialK = amm.reserve0() * amm.reserve1();
        targetContract(address(handler));
    }

    function invariant_kNeverDecreases() public view {
        uint256 currentK = amm.reserve0() * amm.reserve1();
        assertGe(currentK, initialK);
    }

    function invariant_reservesMatchBalances() public view {
        assertEq(token0.balanceOf(address(amm)), amm.reserve0());
        assertEq(token1.balanceOf(address(amm)), amm.reserve1());
    }

    function invariant_totalSupplyPositive() public view {
        assertGt(amm.totalSupply(), 0);
    }
}
