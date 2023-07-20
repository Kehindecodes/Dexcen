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
        Ability[] abilities;
        ItemStats stats;
    }

    struct Ability {
        string name;
        string description;
    }

    struct ItemStats {
        uint256 baseAttackPower;
        uint256 baseDefensePower;
        uint256 health;
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
    event TokenUpdated(uint256 tokenId, string name, string description, uint256 price, string image, string rarity, string level, Ability[] abilities, uint256 baseAttackPower, uint256 baseDefensePower, uint256 health);
    function mintGamingNFT(
        string memory name,
        string memory description,
        uint256 price,
        string memory image,
        string memory rarity,
        string memory level,
        Ability[] memory abilities,
        uint256 baseAttackPower,
        uint256 baseDefensePower,
        uint256 health,
        address owner
    ) public onlyOwner {
         uint256 tokenId = _nextNFTId;
        _nextNFTId++;
        require(!_exists(tokenId) , "NFT already exists");          
        _safeMint(owner, tokenId);
 
        uint256 totalAttackPower = baseAttackPower + (abilities.length * 10); // Increase attack power based on the number of abilities
        uint256 totalDefensePower = baseDefensePower + (abilities.length * 5); // Increase defense power based on the number of abilities

        ItemStats memory stats = ItemStats(totalAttackPower, totalDefensePower, health);

        GamingItem memory newGamingNFT = GamingItem(
            tokenId,
            name,
            description,
            price,
            image,
            rarity,
            owner
            level,
            abilities,
            stats
        );
        _gamingNFTs[tokenId] = newGamingNFT;

       emit TokenMinted(owner, tokenId);
    }

    function transferGamingNFT(uint256 tokenId, address newOwner) public {
        address tokenOwner = ownerOf(tokenId);
        require(tokenOwner == msg.sender || isApprovedForAll(tokenOwner, msg.sender), "GamingNFT: transfer caller is not owner nor approved");
     require(_exists(tokenId), "GamingNFT: Token does not exist");
        
        _transfer(tokenOwner, newOwner, tokenId);

        GamingItem storage gamingNFT = _gamingNFTs[tokenId];
        gamingNFT.owner = newOwner;


        emit TokenTransfer(tokenOwner, newOwner, tokenId);

    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
        return _gamingNFTs[tokenId].owner;
    }

    function getGamingNFT(uint256 tokenId) public view returns (GamingItem memory) {
        return _gamingNFTs[tokenId];
    }

    function updateGamingNFT(
        uint256 tokenId,
        string memory name,
        string memory description,
        uint256 price,
        string memory image,
        string memory rarity,
        string memory level,
        Ability[] memory abilities,
        uint256 baseAttackPower,
        uint256 baseDefensePower,
        uint256 health
    ) public onlyOwner {
        require(_exists(tokenId), "GamingNFT: NFT does not exist");
        GamingItem storage gamingNFT = _gamingNFTs[tokenId];

        gamingNFT.name = name;
        gamingNFT.description = description;
        gamingNFT.price = price;
        gamingNFT.image = image;
        gamingNFT.rarity = rarity;
        gamingNFT.level = level;
        gamingNFT.abilities = abilities;
        gamingNFT.stats = ItemStats(baseAttackPower, baseDefensePower, health);
        emit TokenUpdated(tokenId, name, description, price, image, rarity, level, abilities, baseAttackPower, baseDefensePower, health);
    }

    function approve(address to, uint256 tokenId) public {
    address tokenOwner = ownerOf(tokenId);
    require(tokenOwner == msg.sender || isApprovedForAll(tokenOwner, msg.sender), "GamingNFT: Not authorized to approve");

    _approve(to, tokenId);
}
function setApprovalForAll(address operator, bool approved) public {
    require(operator != msg.sender, "GamingNFT: You cannot set approval for yourself");

    _setApprovalForAll(msg.sender, operator, approved);
}



}