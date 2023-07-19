// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Marketplace is ERC721, Ownable {
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
        uint256 attackPower;
        uint256 defensePower;
        uint256 health;
    }
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
        uint256 id
    }
    struct Art {
        string title;
        uint256 price;
        string artist;
        string image;
        string rarity;
        uint256 yearCreated;
        address owner;
        uint256 id
    }
    mapping(uint256 => address) private _nftOwners;
    mapping(address => uint256[]) private _ownerNFTs;
    mapping(uint256 => uint256) private _listingPrices;

    constructor() ERC721("MarketplaceNFT", "MNFT") {}

    // Implement ownership tracking
    function ownerOf(uint256 tokenId) public view override returns (address) {
        return _nftOwners[tokenId];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        super.transferFrom(from, to, tokenId);
        _updateOwnership(tokenId, from, to);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        super.safeTransferFrom(from, to, tokenId);
        _updateOwnership(tokenId, from, to);
    }

    function mintGamingItem(
        address to,
        uint256 tokenId,
        string memory tokenURI,
        GamingItem memory item
    ) public onlyOwner {
        _mint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);
        _nftOwners[tokenId] = to;
        _ownerNFTs[to].push(tokenId);
        // Assign unique attributes or properties to the gaming item
        GamingItem.id = tokenId;
        GamingItem.name = item.name;
        GamingItem.description = item.description;
        GamingItem.price = item.price;
        GamingItem.image = item.image;
        GamingItem.rarity = item.rarity;
        GamingItem.owner = to;
        GamingItem.level = item.level;
        GamingItem.abilities = item.abilities;
        GamingItem.stats = item.stats;

        // Update the item struct with the generated attributes or properties
    }

    function mintMusic(
        address to,
        uint256 tokenId,
        string memory tokenURI,
        Music memory music
    ) public onlyOwner {
        _mint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);
        _nftOwners[tokenId] = to;
        _ownerNFTs[to].push(tokenId);
        // Store the relevant metadata for the music NFT
         Music.owner = to;
         Music.title = music.title;
         Music.price = music.price;
         Music.coverArt = music.coverArt;
         Music.rarity = music.rarity;
         Music.artist = music.artist;
         Music.genre = music.genre;
         Music.releaseDate = music.releaseDate;
         Music.audioFile = music.audioFile;
         Music.id = tokenId;

        // Update the music struct with the metadata
    }

    function mintArt(
        address to,
        uint256 tokenId,
        string memory tokenURI,
        Art memory art
    ) public onlyOwner {
        _mint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);
        _nftOwners[tokenId] = to;
        _ownerNFTs[to].push(tokenId);
        // Store the relevant metadata for the art NFT
        // Update the art struct with the metadata
        Art.artist = art.artist;
        Art.image = art.image;
        Art.rarity = art.rarity;
        Art.yearCreated = art.yearCreated;
        Art.id = tokenId;
        Art.title = art.title;
        Art.price = art.price;
        Art.rarity = art.rarity;
        Art.owner = to;
    }

     function createListing(uint256 tokenId, uint256 price) public {
        address tokenOwner = ownerOf(tokenId);
        require(tokenOwner != address(0), "Marketplace: Invalid token");
        require(_nftOwners[tokenId] == tokenOwner, "Marketplace: Invalid token owner");
       require(_nftOwners(tokenId) == address(0), "Marketplace: nft already listed");
       require(tokenOwner == msg.sender, "Marketplace: you are not the owner of this NFT");
        require(_listingPrices[tokenId] == 0, "Marketplace: NFT already listed");
        require(price > 0, "Marketplace: Invalid price");
        _listingPrices[tokenId] = price;
    }

     function removeListing(uint256 tokenId) public {
        address tokenOwner = ownerOf(tokenId);
        require(tokenOwner != address(0), "Marketplace: Invalid token");
        require(_nftOwners[tokenId] == tokenOwner, "Marketplace: Invalid token owner");

        // Additional validation and checks as per your marketplace requirements

        // Remove the listing by resetting the price to 0
        // Example:
        // _listingPrices[tokenId] = 0;
    }

    function purchase(uint256 tokenId) public payable {
        address tokenOwner = ownerOf(tokenId);
        require(tokenOwner != address(0), "Marketplace: Invalid token");
        require(_nftOwners[tokenId] == tokenOwner, "Marketplace: Invalid token owner");

        // Additional validation and checks as per your marketplace requirements

        // Verify that the buyer sent the correct amount of ETH for the purchase
        // Example:
        // require(msg.value == _listingPrices[tokenId], "Marketplace: Incorrect payment amount");

        // Transfer ownership of the token to the buyer
        // Example:
        // transferFrom(tokenOwner, msg.sender, tokenId);

        // Remove the listing by resetting the price to 0
        // Example:
        // _listingPrices[tokenId] = 0;

        // Transfer the payment to the seller
        // Example:
        // payable(tokenOwner).transfer(msg.value);
    }

   function _updateOwnership(
    uint256 tokenId,
    address from,
    address to
) private {
    require(ownerOf(tokenId) == from, "Marketplace: Invalid token owner");
    _nftOwners[tokenId] = to;
    // Update the _ownerNFTs mapping accordingly
    uint256[] storage ownerNFTs = _ownerNFTs[to];
    uint256 index;
    for (uint256 i = 0; i < ownerNFTs.length; i++) {
        if (ownerNFTs[i] == tokenId) {
            index = i;
            break;
        }
    }
    if (index < ownerNFTs.length - 1) {
        ownerNFTs[index] = ownerNFTs[ownerNFTs.length - 1];
    }
    ownerNFTs.pop();
}



}
