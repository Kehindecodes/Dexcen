// test/GamingNFT.test.js

const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('GamingNFT', () => {
	let gamingNFT;
	let owner;
	let addr1;
	let tokenId;

	beforeEach(async () => {
		// Deploy the contract and get the deployed instance
		const GamingNFT = await ethers.getContractFactory('GamingNFT');
		gamingNFT = await GamingNFT.deploy();
		await gamingNFT.deployed();

		// Get accounts from Hardhat's ethers.provider
		[owner, addr1] = await ethers.getSigners();

		// Create a new NFT using the createUserNFT function
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
			owner: owner.address,
		};

		await gamingNFT.createUserNFT(nftInfo, 'ipfs://QmXYZ.nnvc..');
		tokenId = 1; // Assuming the NFT ID is 1
	});

	it('Should transfer the NFT to a new owner', async () => {
		// Transfer the NFT from the owner to addr1
		await gamingNFT.connect(owner).transferGamingNFT(tokenId, addr1.address);

		// Check if the NFT ownership has changed to addr1
		const newOwnerOfToken = await gamingNFT.ownerOf(tokenId);
		expect(newOwnerOfToken).to.equal(addr1.address);
	});

	it('Should approve an address to transfer the NFT', async () => {
		// Approve addr1 to transfer the NFT on behalf of the owner
		await gamingNFT.connect(owner).approve(addr1.address, tokenId);

		// Check if addr1 is approved to transfer the NFT
		const approvedAddress = await gamingNFT.getApproved(tokenId);
		expect(approvedAddress).to.equal(addr1.address);

		// Transfer the NFT from the owner to addr1 using the approved address
		await gamingNFT
			.connect(addr1)
			.transferFrom(owner.address, addr1.address, tokenId);

		// Check if the NFT ownership has changed to addr1
		const newOwnerOfToken = await gamingNFT.ownerOf(tokenId);
		expect(newOwnerOfToken).to.equal(addr1.address);
	});

	it('Should update the NFT metadata', async () => {
		const newImage = 'https://example.com/new_image.jpg';
		const newRarity = 'Epic';
		const newLevel = 'Master';
		const newAbilities = 'Fireball, Teleport, Thunderstorm';

		// Update the NFT metadata using the updateGamingNFT function
		await gamingNFT
			.connect(owner)
			.updateGamingNFT(tokenId, newImage, newRarity, newLevel, newAbilities);

		// Get the updated NFT information
		const updatedNFTInfo = await gamingNFT.getGamingNFT(tokenId);

		// Check if the metadata has been updated
		expect(updatedNFTInfo.image).to.equal(newImage);
		expect(updatedNFTInfo.rarity).to.equal(newRarity);
		expect(updatedNFTInfo.level).to.equal(newLevel);
		expect(updatedNFTInfo.abilities).to.equal(newAbilities);
	});
});
