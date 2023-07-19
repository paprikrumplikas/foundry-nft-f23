//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

//deployed to Sepolia 0x28Ad65ff01E5B9A8e8F4f405FFC65626E42b5Bd8

/*An NFT needs a URI.
We can convert SVG to a URI that our browser can interpret.

1. In the image forlder, run 
base64 -i example.svg
<Result>: 
PHN2ZyB2aWV3Qm94PSIwIDAgMjAwIDIwMCIgd2lkdGg9IjQwMCIgIGhlaWdodD0iNDAwIiB4bWxu
cz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgogIDxjaXJjbGUgY3g9IjEwMCIgY3k9IjEw
MCIgZmlsbD0ieWVsbG93IiByPSI3OCIgc3Ryb2tlPSJibGFjayIgc3Ryb2tlLXdpZHRoPSIzIi8+
CiAgPGcgY2xhc3M9ImV5ZXMiPgogICAgPGNpcmNsZSBjeD0iNjEiIGN5PSI4MiIgcj0iMTIiLz4K
ICAgIDxjaXJjbGUgY3g9IjEyNyIgY3k9IjgyIiByPSIxMiIvPgogIDwvZz4KICA8cGF0aCBkPSJt
MTM2LjgxIDExNi41M2MuNjkgMjYuMTctNjQuMTEgNDItODEuNTItLjczIiBzdHlsZT0iZmlsbDpu
b25lOyBzdHJva2U6IGJsYWNrOyBzdHJva2Utd2lkdGg6IDM7Ii8+Cjwvc3ZnPg==

2. Paste the following in the browser:
data:image/svg+xml;base64,<Result>

This is practically what we are doing below, but we need to import Base64*/

contract MoodNft is ERC721 {
    //error
    error MoodNft__CantFlipMoodIfNotOnwer();

    uint256 private s_tokenCounter;
    string private s_sadSvgImageUri;
    string private s_happySvgImageUri;

    enum Mood {
        HAPPY,
        SAD
    }

    mapping(uint256 => Mood) private s_tokenIdToMood;

    constructor(
        string memory happySvgImgUri,
        string memory sadSvgImgUri
    ) ERC721("MoodNft", "MOOD") {
        s_tokenCounter = 0;
        s_happySvgImageUri = happySvgImgUri;
        s_sadSvgImageUri = sadSvgImgUri;
    }

    function mintNft() public {
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenIdToMood[s_tokenCounter] = Mood.HAPPY; //default is happy
        s_tokenCounter++;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        string memory imageURI;

        if (s_tokenIdToMood[tokenId] == Mood.HAPPY) {
            imageURI = s_happySvgImageUri;
        } else {
            imageURI = s_sadSvgImageUri;
        }

        return
            string(
                abi.encodePacked( //concat baseURI and base64-encoded json obsject
                    _baseURI(), //prepend baseURI
                    Base64.encode( //encode. This is still not what we are looking for, as we need to prepend stuff to this, hence the line above
                        bytes( //convert to bytes object
                            abi.encodePacked( //concat
                                '{"name": "',
                                name(),
                                '", "description": "An NFT that reflects the onwers mood.", "attributes": [{"trait_type": "moodiess, "value": 100}], "image": "',
                                imageURI,
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    function flipMood(uint256 tokenId) public {
        //we only want the NFT owner to be able to change the mood
        if (!_isApprovedOrOwner(msg.sender, tokenId)) {
            revert MoodNft__CantFlipMoodIfNotOnwer();
        }

        if (s_tokenIdToMood[tokenId] == Mood.HAPPY) {
            s_tokenIdToMood[tokenId] = Mood.SAD;
        } else {
            s_tokenIdToMood[tokenId] = Mood.HAPPY;
        }
    }
}
