const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Marketplace', () => {
	let marketplace;
	let deployer;
	let addr1;
	let addr2;
	let nftContract;
	const tokenId = 0;

	beforeEach(async () => {
		// Deploy the contract and get the deployed instance
		const Marketplace = await ethers.getContractFactory('Marketplace');
		marketplace = await Marketplace.deploy();
		await marketplace.deployed();

		// Get accounts from Hardhat's ethers.provider
		[deployer, addr1, addr2] = await ethers.getSigners();

		// Deploy a sample NFT contract and get its deployed instance
		const MusicNFT = await ethers.getContractFactory('MusicNFT');
		nftContract = await MusicNFT.deploy();
		await nftContract.deployed();

		// Mint a sample NFT to the owner's address
		const title = 'My Love';
		const price = 100;
		const coverArt = 'ipfs://coverart';
		const rarity = 'Rare';
		const artist = 'John Doe';
		const genre = 'Pop';
		const releaseDate = 1637836800; // Epoch timestamp for 2021-11-26
		const audioFile = 'ipfs://audio';
		const owner = deployer.address;
		const metadataUri = 'ipfs://QmPx7nQjYExXDpKA5Fb1LvTGxQr1uxRzyL715TTqHYZ4eZ';
		await nftContract.createUserNFT(
			title,
			price,
			coverArt,
			rarity,
			artist,
			genre,
			releaseDate,
			audioFile,
			owner,
			metadataUri,
		);
	});

	it('Should create a new listing for an NFT', async () => {
		const price = ethers.utils.parseEther('0.1');
		await marketplace.approveMarketplace(nftContract.address, tokenId);
		// Create a new listing for the NFT
		await marketplace.createListing(nftContract.address, tokenId, price);

		// Check if the NFT listing exists
		const listing = await marketplace.getOneListing(tokenId);
		expect(listing.nftContract).to.equal(nftContract.address);
		expect(listing.tokenId).to.equal(tokenId);
		expect(listing.seller).to.equal(deployer.address);
		expect(listing.price).to.equal(price);

		// Check if the NFT has been transferred to the marketplace contract
		const nftOwner = await nftContract.ownerOf(tokenId);
		expect(nftOwner).to.equal(marketplace.address);
	});

	it('Should remove an existing listing for an NFT', async () => {
		const price = ethers.utils.parseEther('0.1');
		await marketplace.approveMarketplace(nftContract.address, tokenId);
		// Create a new listing for the NFT
		await marketplace.createListing(nftContract.address, tokenId, price);

		// Remove the listing by the seller
		await marketplace.removeListing(nftContract.address, tokenId);

		// Check if the NFT has been transferred back to the seller
		const nftOwner = await nftContract.ownerOf(tokenId);
		expect(nftOwner).to.equal(deployer.address);
	});

	it('Should purchase an NFT from the marketplace', async () => {
		const price = ethers.utils.parseEther('0.1');
		await marketplace.approveMarketplace(nftContract.address, tokenId);
		// Create a new listing for the NFT
		await marketplace.createListing(nftContract.address, tokenId, price);

		// Purchase the NFT by addr1
		await marketplace
			.connect(addr1)
			.purchase(nftContract.address, tokenId, { value: price });

		// Check if the NFT ownership has changed to addr1
		const nftOwner = await nftContract.ownerOf(tokenId);
		expect(nftOwner).to.equal(addr1.address);
	});
});
