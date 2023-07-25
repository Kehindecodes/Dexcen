// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GamingNFT is ERC721, Ownable {
    struct GamingItem {
        uint256 id;
        string name;
        string description;
        uint256 price;
        string image;
        string rarity;
        address owner;
        string level;
        string abilities;
        // ItemStats stats;
    }

    // struct ItemStats {
    //     uint256 baseAttackPower;
    //     uint256 baseDefensePower;
    //     uint256 health;
    // }
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

    mapping(uint256 => GamingItem) private _gamingNFTs;
    uint256 private _nextNFTId = 1;
    event TokenTransfer(
        address indexed from,
        address indexed to,
        uint256 tokenId
    );
    event TokenMinted(address indexed owner, uint256 tokenId);
    event TokenUpdated(uint256 tokenId);


function  createUserNFT( string memory name, uint256 price, string memory image, string memory rarity, string memory level, string memory abilities, address owner, uint256 baseAttackPower, uint256 baseDefensePower, uint256 health) public {
    uint256 tokenId = _nextNFTId;
    _nextNFTId++;

    GamingItem memory newGamingNFT = GamingItem(
        name,
        image,
        price,
        rarity,
        level,
        abilities,
        owner,
        baseAttackPower,
        baseDefensePower,
        health,
    );
    _gamingNFTs[tokenId] = newGamingNFT;
}

    function mintGamingNFT(GamingNFTInfo memory nftInfo) public onlyOwner {
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

        _safeMint(nftInfo.owner, tokenId);

        // ItemStats memory stats = ItemStats(
        //     totalAttackPower,
        //     totalDefensePower,
        //     nftInfo.health
        // );

        GamingItem storage newGamingNFT = _gamingNFTs[tokenId];
        newGamingNFT.id = tokenId;
        newGamingNFT.name = nftInfo.name;
        newGamingNFT.description = nftInfo.description;
        newGamingNFT.price = nftInfo.price;
        newGamingNFT.image = nftInfo.image;
        newGamingNFT.rarity = nftInfo.rarity;
        newGamingNFT.owner = nftInfo.owner;
        newGamingNFT.level = nftInfo.level;
        // newGamingNFT.stats = stats;
        newGamingNFT.abilities = nftInfo.abilities;

        emit TokenMinted(nftInfo.owner, tokenId);
    }

    function transferGamingNFT(
        uint256 tokenId,
        address newOwner
    ) public {
        address tokenOwner = ownerOf(tokenId);
        require(
            tokenOwner == msg.sender ||
                isApprovedForAll(tokenOwner, msg.sender),
            "GamingNFT: transfer caller is not owner nor approved"
        );
        require(_exists(tokenId), "GamingNFT: Token does not exist");

        _transfer(tokenOwner, newOwner, tokenId);

        GamingItem storage gamingNFT = _gamingNFTs[tokenId];
        gamingNFT.owner = newOwner;

        emit TokenTransfer(tokenOwner, newOwner, tokenId);
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
        return _gamingNFTs[tokenId].owner;
    }

    function getGamingNFT(
        uint256 tokenId
    ) public view returns (GamingItem memory) {
        return _gamingNFTs[tokenId];
    }

    function updateGamingNFT(
        uint256 tokenId,
        string memory image,
        string memory rarity,
        string memory level,
        string memory abilities
    )
        public
        // uint256 baseAttackPower,
        // uint256 baseDefensePower,

        onlyOwner
    {
        require(_exists(tokenId), "GamingNFT: NFT does not exist");
        GamingItem storage gamingNFT = _gamingNFTs[tokenId];

        gamingNFT.image = image;
        gamingNFT.rarity = rarity;
        gamingNFT.level = level;
        gamingNFT.abilities = abilities;
        // gamingNFT.stats = ItemStats(baseAttackPower, baseDefensePower, health);
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
}
