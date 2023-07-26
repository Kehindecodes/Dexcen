// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ArtNFT is ERC721URIStorage, Ownable {
    struct Art {
        string title;
        uint256 price;
        string artist;
        string rarity;
        uint256 yearCreated;
        string image;
        address owner;
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

    function createUserNFT(
        string memory title,
        uint256 price,
        string memory rarity,
        string memory artist,
        uint256 yearCreated,
        string memory image,
        address owner,
        string memory metadataUri
    ) public {
        uint256 tokenId = _nextNFTId;
        _nextNFTId++;

        Art memory newArtNFT = Art(
            title,
            price,
            rarity,
            artist,
            yearCreated,
            image,
            owner
        );

        _artNFTs[tokenId] = newArtNFT;

        // In a real-world application, you would likely store the metadata URI on IPFS and get the URI here.
        // For simplicity, we'll use a placeholder URI here.
        string memory uri = metadataUri; // Replace with the actual IPFS URI

        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);

        emit TokenMinted(msg.sender, tokenId);
    }

    function transferArtNFT(uint256 tokenId, address newOwner) public {
        require(_exists(tokenId), "ArtNFT: Token does not exist");
        address currentOwner = _ownerOf(tokenId);
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

    function approve(address to, uint256 tokenId) public override {
        address tokenOwner = _ownerOf(tokenId);
        require(
            tokenOwner == msg.sender ||
                isApprovedForAll(tokenOwner, msg.sender),
            "ArtNFT: Not authorized to approve"
        );

        _approve(to, tokenId);
    }

    function setApprovalForAll(
        address operator,
        bool approved
    ) public override {
        require(
            operator != msg.sender,
            "ArtNFT: You cannot set approval for yourself"
        );

        _setApprovalForAll(msg.sender, operator, approved);
    }

    function _burn(uint256 tokenId) internal override(ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }
}
