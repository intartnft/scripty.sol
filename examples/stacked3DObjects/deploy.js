const hre = require("hardhat")
const utilities = require("../../utilities/utilities")
const deployedContracts = require("../../utilities/deployedContracts")
const path = require('path');

const waitIfNeeded = async (tx) => {
	if (tx.wait) {
		// wait for one confirmation
		await (tx.wait())
	}
}

const delay = (ms) => {
    return new Promise(resolve => setTimeout(resolve, ms))
}

async function getContracts(networkName) {
	const scriptyStorageAddress = deployedContracts.addressFor(networkName, "ScriptyStorageV2")
	const scriptyStorageContract = await ethers.getContractAt(
		"ScriptyStorageV2",
		scriptyStorageAddress
	);
	console.log("ScriptyStorageV2 is already deployed at", scriptyStorageAddress);

	const scriptyBuilderAddress = deployedContracts.addressFor(networkName, "ScriptyBuilderV2")
	const scriptyBuilderContract = await ethers.getContractAt(
		"ScriptyBuilderV2",
		scriptyBuilderAddress
	);
	console.log("ScriptyBuilderV2 is already deployed at", scriptyBuilderAddress);

	return { scriptyStorageContract, scriptyBuilderContract }
}

async function storeContent(storageContract, name, filePath) {
	// Check if script is already stored
	const storedContent = await storageContract.contents(name)
	if (storedContent.size > 0) {
		console.log(`${name} is already stored`);
		return
	}

	// Grab file and break into chunks that SSTORE2 can handle
	const script = utilities.readFile(path.join(__dirname, filePath))
	const scriptChunks = utilities.chunkSubstr(script, 24575)

	if (storedContent.owner == utilities.emptyAddress) {
		// First create the script in the storage contract
		await waitIfNeeded(await storageContract.createContent(name, utilities.stringToBytes(name)))
	}

	// Store each chunk
	// [WARNING]: With big files this can be very costly
	for (let i = 0; i < scriptChunks.length; i++) {
		await waitIfNeeded(await storageContract.addChunkToContent(name, utilities.stringToBytes(scriptChunks[i])))
		console.log(`${name} chunk #`, i, "/", scriptChunks.length - 1, "chunk length: ", scriptChunks[i].length);
	}
	console.log(`${name} is stored`);
}

const getTokenURIAndHTMLFromContract = async (contract) => {
	const tokenURI = await contract.tokenURI(0)
	const tokenURIDecoded = utilities.parseBase64DataURI(tokenURI)
	const tokenURIJSONDecoded = JSON.parse(tokenURIDecoded)
	const html = utilities.parseBase64DataURI(tokenURIJSONDecoded.animation_url)
	return [tokenURI, html, tokenURIDecoded]
}

async function main() {
	console.log("")
	console.log("----------------------------------")
	console.log("Running stacked3DObjects")
	console.log("----------------------------------")

	// Deploy or use already deployed contracts depending on the network that script runs on
	console.log("Deploying contracts");
	const { scriptyStorageContract, scriptyBuilderContract } = await getContracts(hre.network.name)

	await storeContent(scriptyStorageContract, "scriptyBase", "../../baseScripts/dist/scriptyBase.js");
	await storeContent(scriptyStorageContract, "three.min.js.gz", "../commonScripts/three.min.js.gz.txt");
	await storeContent(scriptyStorageContract, "gunzipScripts-0.0.1", "../../baseScripts/dist/gunzipScripts-0.0.1.js");
	await storeContent(scriptyStorageContract, "stacked3DObjects1", "scripts/stacked3DObjects1.js");
	await storeContent(scriptyStorageContract, "stacked3DObjects2", "scripts/stacked3DObjects2.js");

	const nftContract1 = await (await ethers.getContractFactory("Stacked3DObjects_Cubes")).deploy(
		scriptyStorageContract.address,
		scriptyBuilderContract.address
	)
	await nftContract1.deployed()
	console.log("NFT Contract is deployed", nftContract1.address);

	const nftContract2 = await (await ethers.getContractFactory("Stacked3DObjects_Spheres")).deploy(
		scriptyStorageContract.address,
		scriptyBuilderContract.address
	)
	await nftContract1.deployed()
	console.log("NFT Contract is deployed", nftContract2.address);

	const [tokenURI1, html1, medatada1] = await getTokenURIAndHTMLFromContract(nftContract1)
	const [tokenURI2, html2, medatada2] = await getTokenURIAndHTMLFromContract(nftContract2)

	utilities.writeFile(path.join(__dirname, "tokenURI_1.txt"), tokenURI1)
	utilities.writeFile(path.join(__dirname, "tokenURI_2.txt"), tokenURI2)
	utilities.writeFile(path.join(__dirname, "html_1.html"), html1)
	utilities.writeFile(path.join(__dirname, "html_2.html"), html2)
	utilities.writeFile(path.join(__dirname, "metadata_1.json"), medatada1)
	utilities.writeFile(path.join(__dirname, "metadata_2.json"), medatada2)

	// Verify contracts if network is ethereum_sepolia
	if (hre.network.name == "ethereum_sepolia") {
		console.log("Waiting a little bytecode index on Etherscan");
    	await delay(30000)

		await hre.run("verify:verify", {
			address: nftContract1.address,
			constructorArguments: [
				scriptyStorageContract.address,
				scriptyBuilderContract.address
			],
		});

		await hre.run("verify:verify", {
			address: nftContract2.address,
			constructorArguments: [
				scriptyStorageContract.address,
				scriptyBuilderContract.address
			],
		});
	}
}

main().catch((error) => {
	console.error(error);
	process.exitCode = 1;
});