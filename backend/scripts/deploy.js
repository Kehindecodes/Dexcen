const { ethers } = require('hardhat');

async function main() {
	const [deployer] = await ethers.getSigners();

	console.log('Deploying contract with account:', deployer.address);

	const MusicNFT = await ethers.getContractFactory('MusicNFT');
	const musicNFT = await MusicNFT.deploy();

	console.log('Contract address:', musicNFT.address);
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
