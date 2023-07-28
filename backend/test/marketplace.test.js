const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Marketplace', () => {
	let marketplace;
	let deployer;
	let addr1;
	let addr2;
	let nftContract;
	const tokenId = 1;

	beforeEach(async () => {
		// Deploy the contract and get the deployed instance
		const Marketplace = await ethers.getContractFactory('Marketplace');
		marketplace = await Marketplace.deploy();
		await marketplace.deployed();

		// Get accounts from Hardhat's ethers.provider
		[deployer, addr1, addr2] = await ethers.getSigners();

		// Deploy a sample NFT contract and get its deployed instance
		const GamingNFT = await ethers.getContractFactory('GamingNFT');
		nftContract = await GamingNFT.deploy();
		await nftContract.deployed();

		// Mint a sample NFT to the owner's address
		const nftInfo = {
			name: 'satoshi',
			description: 'freedom fighter',
			price: ethers.utils.parseEther('0.003'),
			image: 'https://example.com/gaming_nft.jpg',
			rarity: 'Rare',
			level: 'Advanced',
			abilities: 'Fireball, Teleport',
			baseAttackPower: 100,
			baseDefensePower: 80,
			health: 200,
			owner: deployer.address,
		};

		await nftContract.createUserNFT(nftInfo, 'ipfs://QmXYZ.nnvc..');
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
