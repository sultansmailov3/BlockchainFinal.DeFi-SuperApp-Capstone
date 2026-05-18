// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title ProtocolNFT
/// @notice ERC-721 membership NFT for DeFi Super-App governance participants.
///         Includes inline Yul assembly for gas-efficient operations,
///         benchmarked against pure-Solidity equivalents.
contract ProtocolNFT is ERC721, ERC721URIStorage, Ownable {
    uint256 private _nextTokenId;
    uint256 public constant MAX_SUPPLY = 10_000;
    event Minted(address indexed to, uint256 indexed tokenId);

    constructor(address initialOwner) ERC721("DeFi Protocol Member", "DPM") Ownable(initialOwner) {}

    function mint(address to, string calldata uri) external onlyOwner returns (uint256 tokenId) {
        require(_nextTokenId < MAX_SUPPLY, "Max supply reached");
        tokenId = _nextTokenId;
        unchecked {
            _nextTokenId++;
        }
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        emit Minted(to, tokenId);
    }

    function minYul(uint256 a, uint256 b) public pure returns (uint256 result) {
        assembly { result := xor(b, mul(xor(a, b), lt(a, b))) }
    }

    function minSolidity(uint256 a, uint256 b) public pure returns (uint256) {
        return a < b ? a : b;
    }

    function maxYul(uint256 a, uint256 b) public pure returns (uint256 result) {
        assembly { result := xor(a, mul(xor(a, b), lt(a, b))) }
    }

    function maxSolidity(uint256 a, uint256 b) public pure returns (uint256) {
        return a > b ? a : b;
    }

    function isContractYul(address target) public view returns (bool result) {
        assembly { result := gt(extcodesize(target), 0) }
    }

    function totalMintedYul() public view returns (uint256 result) {
        assembly { result := sload(_nextTokenId.slot) }
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function totalMinted() public view returns (uint256) {
        return _nextTokenId;
    }
}
