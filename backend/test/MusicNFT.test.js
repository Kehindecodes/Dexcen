const { expect } = require('chai');

describe('MusicNFT', function () {
	let musicNFT;
	let owner;
	let addr1;
	let addr2;

	beforeEach(async function () {
		const MusicNFT = await ethers.getContractFactory('MusicNFT');
		[owner, addr1, addr2] = await ethers.getSigners();

		musicNFT = await MusicNFT.deploy();
		await musicNFT.deployed();
	});

	it('Should mint and transfer NFT', async function () {
		// Mint a new Music NFT
		await musicNFT
			.connect(owner)
			.mintMusicNFT(
				'Test Music',
				100,
				'cover-art-hash',
				'Common',
				'wizkid',
				'Afrobeat',
				Date.now(),
				'audio-file-hash',
				owner.address,
			);

		// Check ownership after minting
		expect(await musicNFT.ownerOf(0)).to.equal(owner.address);

		// Transfer the NFT to addr1
		await musicNFT.connect(owner).transferMusicNFT(0, addr1.address);

		// Check ownership after transfer
		expect(await musicNFT.ownerOf(0)).to.equal(addr1.address);

		// Check if approval is set correctly
		expect(await musicNFT.isApprovedForAll(owner.address, addr1.address)).to.be
			.false;
		await musicNFT.connect(owner).setApprovalForAll(addr1.address, true);
		expect(await musicNFT.isApprovedForAll(owner.address, addr1.address)).to.be
			.true;

		// Transfer the NFT from addr1 to addr2
		await musicNFT.connect(addr1).transferMusicNFT(0, addr2.address);

		// Check ownership after second transfer
		expect(await musicNFT.ownerOf(0)).to.equal(addr2.address);
	});

	it('Should not allow duplicate minting', async function () {
		// Mint a new Music NFT
		await musicNFT
			.connect(owner)
			.mintMusicNFT(
				'Test Music',
				100,
				'cover-art-hash',
				'Common',
				'Artist Name',
				'Genre',
				Date.now(),
				'audio-file-hash',
				owner.address,
			);

		// Attempt to mint the same Music NFT again, which should fail due to duplication
		await expect(
			musicNFT
				.connect(owner)
				.mintMusicNFT(
					'Test Music',
					100,
					'cover-art-hash',
					'Common',
					'Artist Name',
					'Genre',
					Date.now(),
					'audio-file-hash',
					owner.address,
				),
		).to.be.revertedWith('MusicNFT: Token ID already exists');
	});
});
