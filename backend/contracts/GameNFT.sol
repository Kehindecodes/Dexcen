// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GamingNFT is ERC721URIStorage, Ownable {
    struct GamingNFTInfo {
        string name;
        string description;
        uint256 price;
        string image;
        string rarity;
        string level;
        string abilities;
        uint256 baseAttackPower;
        uint256 baseDefensePower;
        uint256 health;
        address owner;
    }

    constructor() ERC721("GamingNFT", "GAME") {}

    mapping(uint256 => GamingNFTInfo) private _gamingNFTs;

    uint256 private _nextNFTId = 1;

    event TokenTransfer(
        address indexed from,
        address indexed to,
        uint256 tokenId
    );
    event TokenMinted(address indexed owner, uint256 tokenId);
    event TokenUpdated(uint256 tokenId);

    function createUserNFT(
        GamingNFTInfo memory nftInfo,
        string memory metadataUri
    ) public {
        uint256 tokenId = _nextNFTId;
        _nextNFTId++;

        // Input validation checks
        require(bytes(nftInfo.name).length > 0, "Invalid name");
        require(bytes(nftInfo.description).length > 0, "Invalid description");
        require(nftInfo.price > 0, "Invalid price");
        require(bytes(nftInfo.image).length > 0, "Invalid image");
        require(bytes(nftInfo.rarity).length > 0, "Invalid rarity");
        require(bytes(nftInfo.level).length > 0, "Invalid level");
        require(bytes(nftInfo.abilities).length > 0, "Invalid abilities");

        require(nftInfo.health > 0, "Invalid health");

        require(!_exists(tokenId), "NFT already exists");

        GamingNFTInfo memory newGamingNFT = GamingNFTInfo(
            nftInfo.name,
            nftInfo.description,
            nftInfo.price,
            nftInfo.image,
            nftInfo.rarity,
            nftInfo.level,
            nftInfo.abilities,
            nftInfo.baseAttackPower,
            nftInfo.baseDefensePower,
            nftInfo.health,
            nftInfo.owner
        );

        _gamingNFTs[tokenId] = newGamingNFT;
        string memory uri = metadataUri;

        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);

        emit TokenMinted(msg.sender, tokenId);
    }

    function transferGamingNFT(uint256 tokenId, address newOwner) public {
        address tokenOwner = _ownerOf(tokenId);
        require(
            tokenOwner == msg.sender ||
                isApprovedForAll(tokenOwner, msg.sender),
            "GamingNFT: transfer caller is not owner nor approved"
        );
        require(_exists(tokenId), "GamingNFT: Token does not exist");

        _transfer(tokenOwner, newOwner, tokenId);

        GamingNFTInfo storage gamingNFT = _gamingNFTs[tokenId];
        gamingNFT.owner = newOwner;

        emit TokenTransfer(tokenOwner, newOwner, tokenId);
    }

    // function ownerOf(uint256 tokenId) public view override returns (address) {
    //     return _gamingNFTs[tokenId].owner;
    // }

    function getGamingNFT(
        uint256 tokenId
    ) public view returns (GamingNFTInfo memory) {
        return _gamingNFTs[tokenId];
    }

    function updateGamingNFT(
        uint256 tokenId,
        string memory image,
        string memory rarity,
        string memory level,
        string memory abilities
    ) public onlyOwner {
        require(_exists(tokenId), "GamingNFT: NFT does not exist");
        GamingNFTInfo storage gamingNFT = _gamingNFTs[tokenId];
        gamingNFT.image = image;
        gamingNFT.rarity = rarity;
        gamingNFT.level = level;
        gamingNFT.abilities = abilities;

        emit TokenUpdated(tokenId);
    }

    function approve(address to, uint256 tokenId) public override {
        address tokenOwner = ownerOf(tokenId);
        require(
            tokenOwner == msg.sender ||
                isApprovedForAll(tokenOwner, msg.sender),
            "GamingNFT: Not authorized to approve"
        );

        _approve(to, tokenId);
    }

    function setApprovalForAll(
        address operator,
        bool approved
    ) public override {
        require(
            operator != msg.sender,
            "GamingNFT: You cannot set approval for yourself"
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
