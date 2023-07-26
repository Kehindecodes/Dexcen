const { ethers } = require('hardhat');
const { expect } = require('chai');

describe('MusicNFT', function () {
	let musicNFT;

	beforeEach(async function () {
		this.timeout(80000);
		const MusicNFT = await ethers.getContractFactory('MusicNFT');
		musicNFT = await MusicNFT.deploy();
		await musicNFT.deployed();
	});

	it('should create and transfer NFT', async function () {
		// Create an NFT
		const title = 'My Love';
		const price = 100;
		const coverArt = 'ipfs://coverart';
		const rarity = 'Rare';
		const artist = 'John Doe';
		const genre = 'Pop';
		const releaseDate = 1637836800; // Epoch timestamp for 2021-11-26
		const audioFile = 'ipfs://audio';
		const owner = await ethers.provider.getSigner(0).getAddress();
		const metadataUri = 'ipfs://QmPx7nQjYExXDpKA5Fb1LvTGxQr1uxRzyL715TTqHYZ4eZ';
		console.log(owner);
		await musicNFT.createUserNFT(
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

		// Check the NFT token owner
		const tokenOwner = await musicNFT.ownerOf(0);
		expect(tokenOwner).to.equal(owner);

		// Check the NFT token URI
		const tokenURI = await musicNFT.tokenURI(0);
		expect(tokenURI).to.equal(metadataUri);

		// Transfer the NFT to a new owner
		const newOwner = '0x93A181F02614E8C74c7e6a8b9d53974a3366735a';
		await musicNFT.transferMusicNFT(0, newOwner);

		// Check the new NFT owner
		const newTokenOwner = await musicNFT.ownerOf(0);
		expect(newTokenOwner).to.equal(newOwner);

		// Check the emitted TokenTransfer event
		const filter = musicNFT.filters.TokenTransfer(null, null, null);
		const events = await musicNFT.queryFilter(filter);
		expect(events.length).to.equal(1);
		expect(events[0].args.from).to.equal(owner);
		expect(events[0].args.to).to.equal(newOwner);
		expect(events[0].args.tokenId).to.equal(0);
	});
});
