// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./Escrow.sol";

contract Marketplace is Ownable {
    address public escrowContract;
    Escrow public escrow;
    struct Listing {
        address nftContract;
        uint256 tokenId;
        address seller;
        uint256 price;
    }

    mapping(uint256 => Listing) private _listings;
    mapping(address => mapping(uint256 => bool)) private _approvedContracts;

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

    function approveMarketplace(address nftContract, uint256 tokenId) external {
        address tokenOwner = ERC721URIStorage(nftContract).ownerOf(tokenId);
        require(
            tokenOwner == msg.sender,
            "Marketplace: Only the NFT owner can approve"
        );

        // Approve the Marketplace contract to transfer the NFT
        ERC721URIStorage(nftContract).approve(address(this), tokenId);

        // Mark the contract as approved for this NFT
        _approvedContracts[nftContract][tokenId] = true;
    }

    function setEscrowContract(address escrowAddress) external onlyOwner {
        require(
            escrowAddress != address(0),
            "Marketplace: Invalid Escrow contract address"
        );
        escrowContract = escrowAddress;
        escrow = Escrow(escrowAddress);
    }

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

        // Check if the Marketplace contract is approved for this NFT
        require(
            _approvedContracts[nftContract][tokenId] == true,
            "Marketplace: The Marketplace contract is not approved to transfer this NFT"
        );

        // Transfer the NFT from the owner to the Escrow contract
        ERC721URIStorage(nftContract).transferFrom(
            tokenOwner,
            escrowContract,
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

        // Check if the Marketplace contract is approved for this NFT
        require(
            _approvedContracts[nftContract][tokenId] == true,
            "Marketplace: The Marketplace contract is not approved to transfer this NFT"
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

        // Check if the Marketplace contract is approved for this NFT
        require(
            _approvedContracts[nftContract][tokenId] == true,
            "Marketplace: The Marketplace contract is not approved to transfer this NFT"
        );

        // Create an escrow contract to hold the NFT and payment
        escrow.createEscrow{value: msg.value}(
            nftContract,
            tokenId,
            listing.seller,
            listing.price
        );

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

    function getOneListing(
        uint256 tokenId
    ) public view returns (Listing memory) {
        return _listings[tokenId];
    }

    // Function for the buyer to confirm the receipt of the NFT and release payment
    function confirmReceipt(uint256 tokenId) external {
        // Call the confirmReceipt function of the Escrow contract
        escrow.confirmReceipt(tokenId);
    }

    // Function for the owner to cancel the escrow
    function cancelEscrow(uint256 tokenId) external onlyOwner {
        // Call the cancelEscrow function of the Escrow contract
        escrow.cancelEscrow(tokenId);
    }
}
