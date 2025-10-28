// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import {ERC721URIStorage, ERC721} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";



contract MyNFT is ERC721, ERC721URIStorage, Ownable {
    
    uint256 private _tokenId;

    constructor(string memory name, string memory symbol, address initialOwner) ERC721(name, symbol) Ownable(initialOwner) {
        _tokenId = 1;
    }

    function mintNft(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _tokenId;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns(string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override (ERC721, ERC721URIStorage) returns(bool) {
        return super.supportsInterface(interfaceId);
    }
}