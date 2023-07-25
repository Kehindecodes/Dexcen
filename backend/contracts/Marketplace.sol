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
        uint256 id;
    }

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

    mapping(uint256 => address) private _nftOwners;
    mapping(address => uint256[]) private _ownerNFTs;
    mapping(uint256 => uint256) private _listingPrices;
    mapping(uint256 => GamingItem) private _gamingItems;

    event ListingCreated(uint256 tokenId, string message);
    event ListingRemoved(uint256 tokenId, string message);
    event PurchaseMade(
        uint256 tokenId,
        address buyer,
        address seller,
        uint256 price
    );

    constructor() ERC721("MarketplaceNFT", "MNFT") {}

    // Implement ownership tracking

    // function transferFrom(address from, address to, uint256 tokenId) public override {
    //     super.transferFrom(from, to, tokenId);
    //     _updateOwnership(tokenId, from, to);
    // }

    // function safeTransferFrom(address from, address to, uint256 tokenId) public override {
    //     super.safeTransferFrom(from, to, tokenId);
    //     _updateOwnership(tokenId, from, to);
    // }

    // function mintGamingItem(
    //     address to,
    //     uint256 tokenId,
    //     string memory tokenURI,
    //     GamingItem memory item
    // ) public onlyOwner {
    //     _mint(to, tokenId);
    //     _setTokenURI(tokenId, tokenURI);
    //     _nftOwners[tokenId] = to;
    //     _ownerNFTs[to].push(tokenId);
    //     // Assign unique attributes or properties to the gaming item
    //     GamingItem memory newItem = GamingItem(tokenId, "", "", 0, "", "", address(0), "", new Ability[](0), ItemStats(0, 0, 0));
    //     newItem.name = item.name;
    //     newItem.description = item.description;
    //     newItem.price = item.price;
    //     newItem.image = item.image;
    //     newItem.rarity = item.rarity;
    //     newItem.owner = to;
    //     newItem.level = item.level;
    //     newItem.abilities = item.abilities;
    //     newItem.stats = item.stats;

    //     _gamingItems[tokenId] = newItem;
    // }

    // function mintArt(
    //     address to,
    //     uint256 tokenId,
    //     string memory tokenURI,
    //     Art memory art
    // ) public onlyOwner {
    //     _mint(to, tokenId);
    //     _setTokenURI(tokenId, tokenURI);
    //     _nftOwners[tokenId] = to;
    //     _ownerNFTs[to].push(tokenId);
    //     // Store the relevant metadata for the art NFT
    //     Art memory newArt = Art(art.title, art.price, art.artist, art.image, art.rarity, art.yearCreated, to, tokenId);

    //     _artItems[tokenId] = newArt;
    // }

    // function modifyGamingItem(uint256 tokenId, GamingItem memory newItem) public {
    //     address tokenOwner = ownerOf(tokenId);
    //     require(tokenOwner == msg.sender, "Marketplace: you are not the owner of this NFT");

    //     GamingItem storage item = _gamingItems[tokenId];
    //     item.name = newItem.name;
    //     item.description = newItem.description;
    //     item.price = newItem.price;
    //     item.image = newItem.image;
    //     item.rarity = newItem.rarity;
    //     item.level = newItem.level;
    //     item.abilities = newItem.abilities;
    //     item.stats = newItem.stats;
    // }

    function createListing(uint256 tokenId, uint256 price) public {
        address tokenOwner = ownerOf(tokenId);
        require(tokenOwner != address(0), "Marketplace: Invalid token");
        require(
            _nftOwners[tokenId] == tokenOwner,
            "Marketplace: Invalid token owner"
        );
        require(
            _listingPrices[tokenId] == 0,
            "Marketplace: NFT already listed"
        );
        require(
            tokenOwner == msg.sender,
            "Marketplace: you are not the owner of this NFT"
        );
        require(price > 0, "Marketplace: Invalid price");
        _listingPrices[tokenId] = price;

        emit ListingCreated(tokenId, "Listing created");
    }

    function removeListing(uint256 tokenId) public {
        address tokenOwner = ownerOf(tokenId);
        require(tokenOwner != address(0), "Marketplace: Invalid token");
        require(
            _nftOwners[tokenId] == tokenOwner,
            "Marketplace: Invalid token owner"
        );
        require(_listingPrices[tokenId] > 0, "Marketplace: NFT not listed");
        require(
            tokenOwner == msg.sender,
            "Marketplace: you are not the owner of this NFT"
        );
        uint256 listingPrice = _listingPrices[tokenId];
        require(listingPrice > 0, "Marketplace: NFT not listed");

        _listingPrices[tokenId] = 0;

        emit ListingRemoved(tokenId, "Listing removed");
    }

    function purchase(uint256 tokenId) public payable {
        address tokenOwner = ownerOf(tokenId);
        require(tokenOwner != address(0), "Marketplace: Invalid token");
        require(
            _nftOwners[tokenId] == tokenOwner,
            "Marketplace: Invalid token owner"
        );
        require(_listingPrices[tokenId] > 0, "Marketplace: NFT not listed");
        require(
            msg.value == _listingPrices[tokenId],
            "Marketplace: Incorrect payment amount"
        );

        transferFrom(tokenOwner, msg.sender, tokenId);

        _listingPrices[tokenId] = 0;

        payable(tokenOwner).transfer(msg.value);

        emit PurchaseMade(tokenId, msg.sender, tokenOwner, msg.value);
    }

    function _updateOwnership(
        uint256 tokenId,
        address from,
        address to
    ) private {
        require(ownerOf(tokenId) == from, "Marketplace: Invalid token owner");
        _nftOwners[tokenId] = to;

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
