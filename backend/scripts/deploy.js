const { ethers } = require('hardhat');

async function main() {
	const [deployer] = await ethers.getSigners();

	console.log('Deploying contract with account:', deployer.address);

	const MusicNFT = await ethers.getContractFactory('MusicNFT');
	const musicNFT = await MusicNFT.deploy();

	const ArtNFT = await ethers.getContractFactory('ArtNFT');
	const artNFT = await ArtNFT.deploy();

	const GamingNFT = await ethers.getContractFactory('GamingNFT');
	const gamingNFT = await GamingNFT.deploy();

	const Marketplace = await ethers.getContractFactory('Marketplace');
	const marketplace = await Marketplace.deploy();

	console.log(' musicNFT Contract address:', musicNFT.address);
	console.log(' gamingNFT  Contract address:', gamingNFT.address);
	console.log(' artNFT Contract address:', artNFT.address);
	console.log('  Marketplace Contract address:', marketplace.address);
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
