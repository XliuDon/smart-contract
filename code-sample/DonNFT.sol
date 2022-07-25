// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts@4.6.0/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.6.0/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts@4.6.0/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@4.6.0/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts@4.6.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.6.0/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts@4.6.0/token/ERC721/extensions/draft-ERC721Votes.sol";
import "@openzeppelin/contracts@4.6.0/utils/Counters.sol";

contract DonNFT is ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Burnable, Ownable, EIP712, ERC721Votes {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    uint256 public mintRate = 0.01 ether;
    uint public MAX_SUPPLY = 10;
    mapping(address => bool) public redeemed;

    constructor() ERC721("DonNFT", "DON") EIP712("DonNFT", "1") {}

    function _baseURI() internal pure override returns (string memory) {
        return "https://api.donnft.com/tokens/";
    }

    function safeMint(address to, string memory uri) public payable{
        require(totalSupply() < MAX_SUPPLY, "Can't mint more.");
        require(msg.value >= mintRate,"Not enough ether sent.");
        require(redeemed[to] != true, "Already redeemed!");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        redeemed[to] = true;
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _afterTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Votes)
    {
        super._afterTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return  interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function withdraw() public onlyOwner{
        require(address(this).balance >0, "Balance is 0");
        payable(owner()).transfer(address(this).balance);
    }
}
