// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract FactoryCreatedContract {
    address public immutable creator;

    constructor() {
        creator = msg.sender;
    }
}

contract Factory {
    event Deployed(address indexed deployed, bytes32 indexed salt, bool create2);

    function deployCreate() external returns (address deployed) {
        bytes memory bytecode = type(FactoryCreatedContract).creationCode;

        assembly {
            deployed := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        require(deployed != address(0), "CREATE failed");
        emit Deployed(deployed, bytes32(0), false);
    }

    function deployCreate2(bytes32 salt) external returns (address deployed) {
        bytes memory bytecode = type(FactoryCreatedContract).creationCode;

        assembly {
            deployed := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
        }

        require(deployed != address(0), "CREATE2 failed");
        emit Deployed(deployed, salt, true);
    }

    function computeCreate2Address(bytes32 salt) public view returns (address) {
        bytes32 bytecodeHash = keccak256(type(FactoryCreatedContract).creationCode);

        bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff), address(this), salt, bytecodeHash));

        return address(uint160(uint256(hash)));
    }
}
