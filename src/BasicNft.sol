//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

//install: forge install OpenZeppelin/openzeppelin-contracts --no-commit
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

//deployed on Sepolia: 0x6d347ca1b029f4d74ba028ab0da1617f128b75f3

contract BasicNft is ERC721 {
    uint256 private s_tokenCounter; //representing token IDs

    mapping(uint256 => string) private s_tokenIdToUri;

    constructor() ERC721("Dogie", "DOG") {
        s_tokenCounter = 0;
    }

    function mintNft(string memory tokenUri) public {
        //URI: uniform resource identifier
        s_tokenIdToUri[s_tokenCounter] = tokenUri;
        _safeMint(msg.sender, s_tokenCounter); //function defined in ERC721.sol
        s_tokenCounter++;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        return s_tokenIdToUri[tokenId];
    }
}
