// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Escrow is Ownable {
    struct EscrowData {
        address buyer;
        address seller;
        uint256 tokenId;
        uint256 amount;
        bool released;
        bool completed;
    }

    mapping(uint256 => EscrowData) private _escrows;

    event EscrowCreated(
        address indexed buyer,
        address indexed seller,
        uint256 indexed tokenId,
        uint256 amount
    );
    event NFTTransferred(uint256 indexed tokenId);
    event PaymentReleased(uint256 indexed tokenId);

    // Function to create an escrow contract when a buyer initiates a purchase
    function createEscrow(
        address nftContract,
        uint256 tokenId,
        address seller,
        uint256 amount
    ) external payable {
        require(
            nftContract != address(0),
            "Escrow: Invalid NFT contract address"
        );
        require(amount > 0, "Escrow: Invalid payment amount");

        // Check if the Marketplace contract is approved for this NFT
        require(
            ERC721(nftContract).getApproved(tokenId) == address(this),
            "Escrow: The escrow contract is not approved to transfer this NFT"
        );
        // Transfer the NFT from the seller to this escrow contract
        ERC721(nftContract).transferFrom(seller, address(this), tokenId);

        _escrows[tokenId] = EscrowData(
            msg.sender,
            seller,
            tokenId,
            amount,
            false,
            false
        );

        emit EscrowCreated(msg.sender, seller, tokenId, amount);
    }

    // Function for the buyer to confirm the receipt of the NFT and release payment
    function confirmReceipt(uint256 tokenId, address nftContract) external {
        EscrowData storage escrow = _escrows[tokenId];
        require(
            escrow.buyer == msg.sender,
            "Escrow: Only the buyer can confirm the receipt"
        );
        require(!escrow.completed, "Escrow: Transaction already completed");

        // transfer NFT to the buyer
        ERC721(nftContract).safeTransferFrom(
            address(this),
            escrow.buyer,
            escrow.tokenId
        );

        // Transfer the payment to the seller
        payable(escrow.seller).transfer(escrow.amount);
        escrow.released = true;
        escrow.completed = true;
        emit NFTTransferred(tokenId);
        emit PaymentReleased(tokenId);
    }

    // Function for the seller to cancel the escrow and get the NFT back
    function cancelEscrow(uint256 tokenId) external onlyOwner {
        EscrowData storage escrow = _escrows[tokenId];
        require(!escrow.completed, "Escrow: Transaction already completed");

        ERC721(address(this)).transferFrom(
            address(this),
            escrow.seller,
            tokenId
        );

        escrow.completed = true;

        emit NFTTransferred(tokenId);
    }

    function getEscrowData(
        uint256 tokenId
    ) public view returns (EscrowData memory) {
        return _escrows[tokenId];
    }
}
