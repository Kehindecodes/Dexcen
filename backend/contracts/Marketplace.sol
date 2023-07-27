// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Marketplace is Ownable {
    struct Listing {
        address nftContract;
        uint256 tokenId;
        address seller;
        uint256 price;
    }

    mapping(uint256 => Listing) private _listings;

    event ListingCreated(
        address indexed nftContract,
        uint256 indexed tokenId,
        address indexed seller,
        uint256 price
    );
    event ListingRemoved(address indexed nftContract, uint256 indexed tokenId);
    event PurchaseMade(
        address indexed nftContract,
        uint256 indexed tokenId,
        address buyer,
        address seller,
        uint256 price
    );

    // Create a new listing for an NFT
    function createListing(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) external {
        require(
            nftContract != address(0),
            "Marketplace: Invalid NFT contract address"
        );
        require(price > 0, "Marketplace: Invalid price");
        require(
            !_listingExists(nftContract, tokenId),
            "Marketplace: NFT already listed"
        );

        address tokenOwner = ERC721URIStorage(nftContract).ownerOf(tokenId);
        require(tokenOwner != address(0), "Marketplace: Invalid token");

        // Transfer the NFT from the owner to this contract
        ERC721URIStorage(nftContract).transferFrom(
            tokenOwner,
            address(this),
            tokenId
        );

        _listings[tokenId] = Listing(nftContract, tokenId, tokenOwner, price);

        emit ListingCreated(nftContract, tokenId, tokenOwner, price);
    }

    // Remove an existing listing for an NFT
    function removeListing(address nftContract, uint256 tokenId) external {
        require(
            nftContract != address(0),
            "Marketplace: Invalid NFT contract address"
        );
        require(
            _listingExists(nftContract, tokenId),
            "Marketplace: NFT not listed"
        );

        Listing storage listing = _listings[tokenId];
        require(
            listing.seller == msg.sender,
            "Marketplace: Not the seller of this NFT"
        );

        // Transfer the NFT back to the seller
        ERC721URIStorage(nftContract).transferFrom(
            address(this),
            listing.seller,
            tokenId
        );

        delete _listings[tokenId];

        emit ListingRemoved(nftContract, tokenId);
    }

    // Purchase an NFT from the marketplace
    function purchase(address nftContract, uint256 tokenId) external payable {
        require(
            nftContract != address(0),
            "Marketplace: Invalid NFT contract address"
        );
        require(
            _listingExists(nftContract, tokenId),
            "Marketplace: NFT not listed"
        );

        Listing memory listing = _listings[tokenId];
        require(listing.price > 0, "Marketplace: NFT not listed for sale");
        require(
            msg.value == listing.price,
            "Marketplace: Incorrect payment amount"
        );

        // Transfer the NFT from this contract to the buyer
        ERC721URIStorage(nftContract).transferFrom(
            address(this),
            msg.sender,
            tokenId
        );

        // Transfer the payment to the seller
        (bool success, ) = payable(listing.seller).call{value: listing.price}(
            ""
        );
        require(success, "Marketplace: Payment transfer failed");

        delete _listings[tokenId];

        emit PurchaseMade(
            nftContract,
            tokenId,
            msg.sender,
            listing.seller,
            listing.price
        );
    }

    // Check if a listing exists for a specific NFT
    function _listingExists(
        address nftContract,
        uint256 tokenId
    ) private view returns (bool) {
        return _listings[tokenId].nftContract == nftContract;
    }

    // Additional marketplace functionalities and helper functions
    // ...
}
