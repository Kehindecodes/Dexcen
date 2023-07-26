// test/ArtNFT.test.js

const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('ArtNFT', () => {
	let artNFT;
	let owner;
	let addr1;
	let addr2;

	beforeEach(async function () {
		this.timeout(80000);
		// Deploy the contract and get the deployed instance
		const ArtNFT = await ethers.getContractFactory('ArtNFT');
		artNFT = await ArtNFT.deploy();
		await artNFT.deployed();

		// Get accounts from Hardhat's ethers.provider
		[owner, addr1, addr2] = await ethers.getSigners();
	});

	it('Should mint an NFT and set its metadata URI', async () => {
		const title = 'My Artwork';
		const price = ethers.utils.parseEther('0.1');
		const rarity = 'Rare';
		const artist = 'John Doe';
		const yearCreated = 2023;
		const image = 'https://example.com/artwork.jpg';
		const ownerAddress = owner.address;
		const metadataUri = 'ipfs://QmPx7nQjYExXDpKA5Fb1LvTGxQr1uxRzyL715TTqHYZ4eZ'; // Replace with the actual IPFS URI

		// Call the createUserNFT function to mint an NFT
		await artNFT.createUserNFT(
			title,
			price,
			rarity,
			artist,
			yearCreated,
			image,
			ownerAddress,
			metadataUri,
		);

		// Check if the NFT has been minted with the correct metadata URI
		const tokenId = 0;
		const ownerOfToken = await artNFT.ownerOf(tokenId);
		const tokenUri = await artNFT.tokenURI(tokenId);

		expect(ownerOfToken).to.equal(ownerAddress);
		expect(tokenUri).to.equal(metadataUri);
	});

	it('Should transfer an NFT to a new owner', async () => {
		// Mint an NFT to the owner's address
		const metadataUri = 'ipfs://QmPx7nQjYExXDpKA5Fb1LvTGxQr1uxRzyL715TTqHYZ4eZ'; // Replace with the actual IPFS URI
		await artNFT.createUserNFT(
			'My Artwork',
			ethers.utils.parseEther('0.1'),
			'Rare',
			'John Doe',
			2023,
			'https://example.com/artwork.jpg',
			owner.address,
			metadataUri,
		);

		// Get the token ID of the minted NFT
		const tokenId = 0;

		// Transfer the NFT to addr1
		await artNFT.connect(owner).transferArtNFT(tokenId, addr1.address);

		// Check if the NFT ownership has changed to addr1
		const ownerOfToken = await artNFT.ownerOf(tokenId);
		expect(ownerOfToken).to.equal(addr1.address);
	});
	it('Should approve an address to transfer an NFT', async () => {
		// Mint an NFT to the owner's address
		const metadataUri = 'ipfs://QmPx7nQjYExXDpKA5Fb1LvTGxQr1uxRzyL715TTqHYZ4eZ'; // Replace with the actual IPFS URI
		await artNFT.createUserNFT(
			'My Artwork',
			0,
			'Rare',
			'John Doe',
			2023,
			'https://example.com/artwork.jpg',
			owner.address,
			metadataUri,
		);

		// Get the token ID of the minted NFT
		const tokenId = 0;

		// Approve addr1 to transfer the NFT on behalf of the owner
		await artNFT.connect(owner).approve(addr1.address, tokenId);

		// Check if addr1 is approved to transfer the NFT
		const approvedAddress = await artNFT.getApproved(tokenId);
		expect(approvedAddress).to.equal(addr1.address);

		// Transfer the NFT from the owner to addr2 using addr1 as the approved address
		await artNFT
			.connect(addr1)
			.transferFrom(owner.address, addr2.address, tokenId);

		// Check if the NFT ownership has changed to addr2
		const ownerOfToken = await artNFT.ownerOf(tokenId);
		expect(ownerOfToken).to.equal(addr2.address);
	});
});
