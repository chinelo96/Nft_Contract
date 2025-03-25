// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {ERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {Base64} from "../lib/openzeppelin-contracts/contracts/utils/Base64.sol";

contract MoodNft is ERC721 {
    error MoodNft_CantFlipMoodIfNotOnwer();
    uint256 private s_tokenCounter;
    string private s_sadsvgImageUri;
    string private s_happysvgImageUri;

    enum Mood {
        HAPPY,
        SAD
    }
    mapping(uint256 => Mood) private s_tokenIdToMood;

    constructor(
        string memory sadsvgImageUri,
        string memory happysvgImageUri
    ) ERC721("Mood NFT", "MN") {
        s_tokenCounter = 0;
        s_sadsvgImageUri = sadsvgImageUri;
        s_happysvgImageUri = happysvgImageUri;
    }
    /** @dev  this is the function any one can call to mint their own moodNFT*/
     function mintNft() public {
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenIdToMood[s_tokenCounter] = Mood.HAPPY;
        s_tokenCounter++;
        }

    function flipMood(uint256 tokenId) public {
        // we only want the nft owners to be able to change the mood
        if (
            getApproved(tokenId) != msg.sender && ownerOf(tokenId) != msg.sender
        ) {
            revert MoodNft_CantFlipMoodIfNotOnwer();
        }
        if (s_tokenIdToMood[tokenId] == Mood.HAPPY) {
            s_tokenIdToMood[tokenId] = Mood.SAD;
        } else {
            s_tokenIdToMood[tokenId] = Mood.HAPPY;
        }
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    /**@dev what the token actually looks like */
    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        string memory imageURI;
        if (s_tokenIdToMood[tokenId] == Mood.HAPPY) {
            imageURI = s_happysvgImageUri;
        } else {
            imageURI = s_sadsvgImageUri;
        }
        return
            string(
                abi.encodePacked(
                    _baseURI(),
                        Base64.encode(
                            bytes(
                                abi.encodePacked(
                                    '{"name":"',
                                    name(),
                                    '", "description": "An Nft that reflects the owners mood.", "attributes":[{"trait_type": "moodiness", "value": 100}], "image": "',
                                    imageURI,
                                    '"}'
                                )
                            )
                        )
                    
                )
            );
    }

      function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
        }

    
}


