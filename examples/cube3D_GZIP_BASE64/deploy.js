const hre = require("hardhat")
const utilities = require("../../utilities/utilities")
const deployedContracts = require("../../utilities/deployedContracts")
const path = require('path');

const waitIfNeeded = async (tx) => {
	if (tx.wait) {
		// wait for one confirmation
		await (tx.wait(1))
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

async function main() {
	console.log("")
	console.log("----------------------------------")
	console.log("Running cube3D_GZIP_BASE64")
	console.log("----------------------------------")

	// Deploy or use already deployed contracts depending on the network that script runs on
	console.log("Deploying contracts");
	const { scriptyStorageContract, scriptyBuilderContract } = await getContracts(hre.network.name)

	await storeContent(scriptyStorageContract, "scriptyBase", "../../baseScripts/dist/scriptyBase.js");
	await storeContent(scriptyStorageContract, "three.min.js.gz", "../commonScripts/three.min.js.gz.txt");
	await storeContent(scriptyStorageContract, "gunzipScripts-0.0.1", "../../baseScripts/dist/gunzipScripts-0.0.1.js");
	await storeContent(scriptyStorageContract, "cube3D_GZIP", "scripts/cube3D_GZIP.js");

	const nftContract = await (await ethers.getContractFactory("Cube3D_GZIP_BASE64")).deploy(
		scriptyStorageContract.address,
		scriptyBuilderContract.address
	)
	await nftContract.deployed()

	const tokenURI = await nftContract.tokenURI(0)
	const tokenURIDecoded = utilities.parseBase64DataURI(tokenURI)
	const tokenURIJSONDecoded = JSON.parse(tokenURIDecoded)
	const animationURL = utilities.parseBase64DataURI(tokenURIJSONDecoded.animation_url)

	utilities.writeFile(path.join(__dirname, "tokenURI.txt"), tokenURI)
	utilities.writeFile(path.join(__dirname, "output.html"), animationURL)
	utilities.writeFile(path.join(__dirname, "metadata.json"), tokenURIDecoded)

	// Verify contracts if network is ethereum_sepolia
	if (hre.network.name == "ethereum_sepolia") {
		console.log("Waiting a little bytecode index on Etherscan");
		await delay(30000)

		await hre.run("verify:verify", {
			address: nftContract.address,
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