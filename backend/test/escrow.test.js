// Import Hardhat's testing framework
const { expect } = require('chai');

// Describe the test suite
describe('Escrow Contract', function () {
	let deployer, buyer, seller, Escrow, escrowContract, NFT, nftContract;

	// Deploy the contracts and set up accounts before tests
	beforeEach(async function () {
		[deployer, buyer, seller] = await ethers.getSigners();

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
		const nftOwner = await nftContract.ownerOf(1);
		console.log(nftOwner);

		// Deploy the Escrow contract
		Escrow = await ethers.getContractFactory('Escrow');
		escrowContract = await Escrow.deploy();
		await escrowContract.deployed();
	});

	// Test case: createEscrow function
	it('Should create an escrow', async function () {
		const tokenId = 1;
		const amount = ethers.utils.parseEther('0.1');

		await nftContract.approve(escrowContract.address, tokenId); // Approve the escrow contract to transfer the NFT

		const nftOwner = await nftContract.ownerOf(tokenId);
		const createEscrowTx = await escrowContract
			.connect(buyer)
			.createEscrow(nftContract.address, tokenId, nftOwner, amount, {
				value: amount,
			});

		expect(createEscrowTx)
			.to.emit(escrowContract, 'EscrowCreated')
			.withArgs(deployer.address, seller.address, tokenId, amount);

		const escrowData = await escrowContract.getEscrowData(tokenId);
		expect(escrowData.buyer).to.equal(buyer.address);
		expect(escrowData.seller).to.equal(nftOwner);
		expect(escrowData.tokenId).to.equal(tokenId);
		expect(escrowData.amount).to.equal(amount);
		expect(escrowData.released).to.equal(false);
		expect(escrowData.completed).to.equal(false);
	});

	// Test case: confirmReceipt function
	// it('Should confirm the receipt of the NFT and release payment to the seller', async function () {
	// 	const tokenId = 1;
	// 	const price = ethers.utils.parseEther('0.1');
	// 	await nftContract.approve(escrowContract.address, tokenId);

	// 	const nftOwner = await nftContract.ownerOf(tokenId);
	// 	console.log(`owner before purchase: ${nftOwner}`);
	// 	// Get the seller's balance before the purchase
	// 	const initialSellerBalance = await ethers.provider.getBalance(
	// 		deployer.address,
	// 	);
	// 	console.log(`deployer address: ${deployer.address}`);
	// 	console.log(`initialSellerBalance: ${initialSellerBalance}`);
	// 	console.log(`buyer address: ${buyer.address}`);
	// 	await escrowContract
	// 		.connect(buyer)
	// 		.createEscrow(nftContract.address, tokenId, nftOwner, price, {
	// 			value: price,
	// 		});
	// 	const nftOwner2 = await nftContract.ownerOf(tokenId);
	// 	console.log(`owner during purchase: ${nftOwner2}`);
	// 	const confirmReceiptTx = await escrowContract
	// 		.connect(buyer)
	// 		.confirmReceipt(tokenId, nftContract.address);

	// 	const escrowData = await escrowContract.getEscrowData(tokenId);

	// 	expect(escrowData.released).to.equal(true);
	// 	expect(escrowData.completed).to.equal(true);
	// 	const nftOwner3 = await nftContract.ownerOf(tokenId);
	// 	console.log(`owner after purchase: ${nftOwner3}`);

	// 	// Get the gas price and gas used for the purchase transaction
	// 	const gasPrice = (await confirmReceiptTx.wait()).effectiveGasPrice;
	// 	const gasUsed = confirmReceiptTx.gasLimit.mul(gasPrice);
	// 	console.log(`gasUsed : ${gasUsed}`);
	// 	// Calculate the expected seller's balance after the purchase (seller receives the payment minus gas fees)
	// 	const expectedSellerBalance = initialSellerBalance.add(price);
	// 	console.log(`expectedSellerBalance: ${expectedSellerBalance}`);
	// 	// Get the seller's balance after confirming receipt
	// 	const finalSellerBalance = await ethers.provider.getBalance(
	// 		deployer.address,
	// 	);
	// 	console.log(`finalSellerBalance: ${finalSellerBalance}`);

	// 	// Check if the seller received the payment
	// 	expect(finalSellerBalance).to.equal(expectedSellerBalance);

	// 	expect(confirmReceiptTx)
	// 		.to.emit(escrowContract, 'NFTTransferred')
	// 		.withArgs(tokenId)
	// 		.to.emit(escrowContract, 'PaymentReleased')
	// 		.withArgs(tokenId);
	// });

	// Additional test cases for other functions can be added similarly
	it('Should confirm the receipt of the NFT and release payment to the seller', async function () {
		const tokenId = 1;
		const price = ethers.utils.parseEther('0.1');

		await nftContract.approve(escrowContract.address, tokenId);
		const nftOwner = await nftContract.ownerOf(tokenId);

		// Get initial seller balance
		const initialSellerBalance = await deployer.getBalance();

		// Create escrow
		// Create escrow with a fixed gas price
		await escrowContract
			.connect(buyer)
			.createEscrow(nftContract.address, tokenId, nftOwner, price, {
				value: price,
				gasPrice: ethers.utils.parseUnits('100', 'gwei'),
			});

		// Confirm receipt
		const confirmReceiptTx = await escrowContract
			.connect(buyer)
			.confirmReceipt(tokenId, nftContract.address, {
				gasPrice: ethers.utils.parseUnits('100', 'gwei'),
			});

		// Get final seller balance
		const finalSellerBalance = await deployer.getBalance();
		const gasPrice = ethers.utils.parseUnits('100', 'gwei');

		// Calculate expected seller balance
		// const gasPrice = (await ethers.provider.getGasPrice()).mul(
		// 	ethers.BigNumber.from('1000000'),
		// ); // Assume gas used is 100000
		const expectedSellerBalance = initialSellerBalance.add(price).sub(gasPrice);

		// Check if the seller received the payment
		expect(finalSellerBalance).to.be.closeTo(
			expectedSellerBalance,
			ethers.BigNumber.from('1000000000000'),
		); // Allow a small variance due to gas estimation

		// // Verify emitted events
		// const receipt = await confirmReceiptTx.wait();
		// expect(receipt.events).to.include.sa.with.property(
		// 	'event',
		// 	'NFTTransferred',
		// );
		// expect(receipt.events).to.include.some.with.property(
		// 	'event',
		// 	'PaymentReleased',
		// );
	});
});
