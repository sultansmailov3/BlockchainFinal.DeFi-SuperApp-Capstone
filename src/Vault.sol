// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC4626, ERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract DeFiVault is ERC4626, Ownable {
    constructor(IERC20 asset, address initialOwner)
        ERC4626(asset)
        ERC20("Vault LP Token", "vLPT")
        Ownable(initialOwner)
    {}

    function depositYield(uint256 amount) external onlyOwner {
        SafeERC20.safeTransferFrom(IERC20(asset()), msg.sender, address(this), amount);
    }
}
