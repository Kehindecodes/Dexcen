// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract ArtNFT is ERC721, Ownable {
    
    struct Art {
        string title;
        uint256 price;
        string artist;
        string image;
        string rarity;
        uint256 yearCreated;
        address owner;
        uint256 id;
    }

    constructor() ERC721("ArtNFT", "ART") {}

    mapping(uint256 => Art) private _artNFTs;
    uint256 private _nextNFTId = 0;
 event TokenTransfer(
        address indexed from,
        address indexed to,
        uint256 tokenId
    );
    event TokenMinted(address indexed owner, uint256 tokenId);
    function ownerOf(uint256 tokenId) public view override returns (address) {
        return ownerOf(tokenId);
    }

    function mintArtNFT(
        string title,
        uint256 price,
        string artist,
        string image,
        string rarity,
        uint256 yearCreated,
        address owner
    ) public onlyOwner returns (uint256) {

        bytes32 randomHash = keccak256(
            abi.encodePacked(
                title,
                image,
                artist,
                rarity,
                yearCreated,
                block.timestamp

            )
        )
        uint256 tokenId = uint256(randomHash);

        require(!_exists(tokenId) , "NFT already exists");          
        _safeMint(owner, tokenId);
     
     Art memory newArtNFT = Art(title, price, artist, image, rarity, yearCreated, owner, tokenId);
     _artNFTs[tokenId] = newArtNFT;

     emit TokenMinted(owner, tokenId);
     return tokenId;
}

function transferArtNFT(uint256 tokenId, address newOwner) public {
        require(_exists(tokenId), "ArtNFT: Token does not exist");
        address currentOwner = ownerOf(tokenId);
        require(
            currentOwner == msg.sender ||
                isApprovedForAll(currentOwner, msg.sender),
            "ArtNFT: Not authorized to transfer"
        );

        _transfer(currentOwner, newOwner, tokenId);

        Art storage artNFT = _artNFTs[tokenId];
        artNFT.owner = newOwner;

        emit TokenTransfer(currentOwner, newOwner, tokenId);
    }
}