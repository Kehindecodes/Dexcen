// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MusicNFT is ERC721URIStorage, Ownable {
    struct Music {
        string title;
        uint256 price;
        string coverArt;
        string rarity;
        string artist;
        string genre;
        uint256 releaseDate;
        string audioFile;
        address owner;
    }

    constructor() ERC721("MusicNFT", "MUSIC") {}

    mapping(uint256 => Music) private _musicNFTs;

    uint256 private _nextNFTId = 0;

    // function ownerOf(uint256 tokenId) public view override returns (address) {
    //     return _ownerOf(tokenId);
    // }

    event TokenTransfer(
        address indexed from,
        address indexed to,
        uint256 tokenId
    );
    event TokenMinted(address indexed owner, uint256 tokenId);

    // Function for users to create and mint their NFTs
    function createUserNFT(
        string memory title,
        uint256 price,
        string memory coverArt,
        string memory rarity,
        string memory artist,
        string memory genre,
        uint256 releaseDate,
        string memory audioFile,
        address owner,
        string memory metadataUri
    ) public {
        uint256 tokenId = _nextNFTId;
        _nextNFTId++;

        Music memory newMusicNFT = Music(
            title,
            price,
            coverArt,
            rarity,
            artist,
            genre,
            releaseDate,
            audioFile,
            owner
        );

        _musicNFTs[tokenId] = newMusicNFT;

        string memory uri = metadataUri;
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);

        emit TokenMinted(msg.sender, tokenId);
    }

    function transferMusicNFT(uint256 tokenId, address newOwner) public {
        require(_exists(tokenId), "MusicNFT: Token does not exist");
        address currentOwner = _ownerOf(tokenId);
        require(
            currentOwner == msg.sender ||
                isApprovedForAll(currentOwner, msg.sender),
            "MusicNFT: Not authorized to transfer"
        );

        _transfer(currentOwner, newOwner, tokenId);

        Music storage musicNFT = _musicNFTs[tokenId];
        musicNFT.owner = newOwner;

        emit TokenTransfer(currentOwner, newOwner, tokenId);
    }

    function approve(address to, uint256 tokenId) public override {
        // address tokenOwner = _ownerOf(tokenId);
        _approve(to, tokenId);
    }

    function setApprovalForAll(
        address operator,
        bool approved
    ) public override {
        // require(
        //     operator != msg.sender,
        //     "musicNFT: You cannot set approval for yourself"
        // );

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
