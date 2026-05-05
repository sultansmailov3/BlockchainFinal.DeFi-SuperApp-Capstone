// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract AMM is ERC20, ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public immutable token0;
    IERC20 public immutable token1;

    uint256 public reserve0;
    uint256 public reserve1;

    uint256 public constant FEE_BPS = 30; // 0.3% (30/10000)

    event Mint(address indexed sender, uint256 amount0, uint256 amount1, uint256 shares);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, uint256 shares);
    event Swap(address indexed sender, uint256 amountIn, uint256 amountOut, bool token0In);

    constructor(address _token0, address _token1) ERC20("LP Token", "LPT") {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }

    function _sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }


    function addLiquidity(uint256 amount0, uint256 amount1) external nonReentrant returns (uint256 shares) {
        token0.safeTransferFrom(msg.sender, address(this), amount0);
        token1.safeTransferFrom(msg.sender, address(this), amount1);

        uint256 _totalSupply = totalSupply();
        if (_totalSupply == 0) {
            shares = _sqrt(amount0 * amount1);
        } else {
            shares = (amount0 * _totalSupply) / reserve0; // Упрощенно
        }

        require(shares > 0, "Insufficient shares");
        _mint(msg.sender, shares);
        
        reserve0 = token0.balanceOf(address(this));
        reserve1 = token1.balanceOf(address(this));

        emit Mint(msg.sender, amount0, amount1, shares);
    }

    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) 
        public 
        pure 
        returns (uint256 amountOut) 
    {
        require(amountIn > 0, "Insufficient input amount");
        require(reserveIn > 0 && reserveOut > 0, "Insufficient liquidity");

        uint256 amountInWithFee = amountIn * 997;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = (reserveIn * 1000) + amountInWithFee;
        amountOut = numerator / denominator;
    }

    function swap(address tokenIn, uint256 amountIn, uint256 minAmountOut) 
        external 
        nonReentrant 
        returns (uint256 amountOut) 
    {
        require(tokenIn == address(token0) || tokenIn == address(token1), "Invalid token");
        
        bool isToken0 = tokenIn == address(token0);
        (IERC20 tIn, IERC20 tOut, uint256 resIn, uint256 resOut) = isToken0 
            ? (token0, token1, reserve0, reserve1) 
            : (token1, token0, reserve1, reserve0);

        tIn.safeTransferFrom(msg.sender, address(this), amountIn);

        amountOut = getAmountOut(amountIn, resIn, resOut);
        
        require(amountOut >= minAmountOut, "Slippage exceeded");

        tOut.safeTransfer(msg.sender, amountOut);

        (Checks-Effects-Interactions)
        reserve0 = token0.balanceOf(address(this));
        reserve1 = token1.balanceOf(address(this));

        emit Swap(msg.sender, amountIn, amountOut, isToken0);
    }
}