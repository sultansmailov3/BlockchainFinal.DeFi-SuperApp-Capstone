// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./AMM.sol";

contract Factory {
    address[] public allPairs;
    mapping(address => mapping(address => address)) public getPair;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint256 pairIndex);

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, "Factory: identical tokens");
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "Factory: zero address");
        require(getPair[token0][token1] == address(0), "Factory: pair exists");

        bytes memory bytecode = abi.encodePacked(type(AMM).creationCode, abi.encode(token0, token1));
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));

        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        require(pair != address(0), "Factory: create2 failed");
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair;
        allPairs.push(pair);

        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function createPairCreate(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, "Factory: identical tokens");
        bytes memory bytecode = abi.encodePacked(type(AMM).creationCode, abi.encode(tokenA, tokenB));

        assembly {
            pair := create(0, add(bytecode, 32), mload(bytecode))
        }

        require(pair != address(0), "Factory: create failed");
        allPairs.push(pair);
    }

    function allPairsLength() external view returns (uint256) {
        return allPairs.length;
    }

    function predictAddress(address tokenA, address tokenB) external view returns (address) {
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        bytes memory bytecode = abi.encodePacked(type(AMM).creationCode, abi.encode(token0, token1));
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff), address(this), salt, keccak256(bytecode)));
        return address(uint160(uint256(hash)));
    }
}
