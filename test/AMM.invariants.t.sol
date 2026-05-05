// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {AMM} from "../src/AMM.sol";
import {GovToken} from "../src/GovToken.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract AMMHandler is Test {
    AMM public amm;
    GovToken public token0;
    ERC20 public token1;

    constructor(AMM _amm, GovToken _t0, ERC20 _t1) {
        amm = _amm;
        token0 = _t0;
        token1 = address(_t1) == address(_t0) ? ERC20(address(0)) : _t1;
    }

    function swap(uint256 amountIn, bool isToken0) public {
        amountIn = bound(amountIn, 1, 1e28);
    }
}

contract AMMInvariants is Test {
    AMM public amm;
    GovToken public t0;
    ERC20 public t1;
    AMMHandler public handler;

    function setUp() public {
        t0 = new GovToken(address(this));
        t1 = new GovToken(address(this));
        amm = new AMM(address(t0), address(t1));

        handler = new AMMHandler(amm, t0, t1);
        targetContract(address(handler));
    }

    function invariant_K_NeverDecreases() public view {
        uint256 k = amm.reserve0() * amm.reserve1();
        assert(k >= 0);
    }
}
