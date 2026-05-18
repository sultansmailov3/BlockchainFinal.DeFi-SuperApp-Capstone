// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ProtocolNFT is ERC721, Ownable {
    uint256 private _nextTokenId;

    constructor(address initialOwner) ERC721("Protocol NFT", "PNFT") Ownable(initialOwner) {}

    function mint(address to) external onlyOwner returns (uint256 tokenId) {
        tokenId = _nextTokenId;
        _nextTokenId++;
        _safeMint(to, tokenId);
    }

    function nextTokenId() external view returns (uint256) {
        return _nextTokenId;
    }
}
