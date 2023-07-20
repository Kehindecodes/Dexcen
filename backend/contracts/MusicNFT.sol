// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MusicNFT is ERC721, Ownable {
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
        uint256 id;
    }

    constructor() ERC721("MusicNFT", "MUSIC") {}

    mapping(uint256 => Music) private _musicNFTs;
    uint256 private _nextNFTId = 0;

    function ownerOf(uint256 tokenId) public view override returns (address) {
        return ownerOf(tokenId);
    }

    event TokenTransfer(
        address indexed from,
        address indexed to,
        uint256 tokenId
    );
    event TokenMinted(address indexed owner, uint256 tokenId);

    function mintMusicNFT(
        string title,
        uint256 price,
        string coverArt,
        string rarity,
        string artist,
        string genre,
        uint256 releaseDate,
        string audioFile,
        address owner
    ) public onlyOwner returns (uint256) {
        bytes32 randomHash = keccak256(
            abi.encodePacked(
                title,
                coverArt,
                artist,
                genre,
                releaseDate,
                audioFile,
                block.timestamp
            )
        );
        uint256 tokenId = uint256(randomHash);

        require(!_exists(tokenId), "MusicNFT: Token ID already exists");

        _safeMint(owner, tokenId);

        Music memory newMusicNFT = Music(
            title,
            price,
            coverArt,
            rarity,
            artist,
            genre,
            releaseDate,
            audioFile,
            owner,
            tokenId
        );

        _musicNFTs[tokenId] = newMusicNFT;
        emit TokenMinted(owner, tokenId);
        return tokenId;
    }

    function transferMusicNFT(uint256 tokenId, address newOwner) public {
        require(_exists(tokenId), "MusicNFT: Token does not exist");
        address currentOwner = ownerOf(tokenId);
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
}
