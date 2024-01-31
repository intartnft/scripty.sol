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
    const ethfsFileStorageAddress = deployedContracts.addressFor(networkName, "ETHFSV2FileStorage")
    const ethfsFileStorageContract = await ethers.getContractAt(
        "ETHFSV2FileStorage",
        ethfsFileStorageAddress
    );
    console.log("ETHFSV2FileStorage is already deployed at", ethfsFileStorageAddress);


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

    return { ethfsFileStorageContract, scriptyStorageContract, scriptyBuilderContract }
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
	console.log("Running ethfs_p5_URLSafe")
	console.log("----------------------------------")

	// Check if this script is running on forked localhost:
	if (hre.network.name == "localhost" && !hre.network.config.forking) {
		console.warn("Please run this example on localhost that forks the mainnet.")
		return
	}

	// Deploy or use already deployed contracts depending on the network that script runs on
	console.log("Deploying contracts");
	const {
		ethfsFileStorageContract,
		scriptyStorageContract,
		scriptyBuilderContract
	} = await getContracts(hre.network.name)

	await storeContent(scriptyStorageContract, "scriptyBase", "../../baseScripts/dist/scriptyBase.js");
	await storeContent(scriptyStorageContract, "pointsAndLines", "scripts/pointsAndLines.js");

	const nftContract = await (await ethers.getContractFactory("EthFS_P5_URLSafe")).deploy(
		ethfsFileStorageContract.address,
		scriptyStorageContract.address,
		scriptyBuilderContract.address
	)
	await nftContract.deployed()
	console.log("NFT Contract is deployed", nftContract.address);

	const tokenURI = await nftContract.tokenURI(0)
	const tokenURIDecoded = utilities.parseEscapedDataURI(tokenURI)
	const tokenURIJSONDecoded = JSON.parse(tokenURIDecoded)
	const animationURL = utilities.parseEscapedDataURI(tokenURIJSONDecoded.animation_url)

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
				ethfsFileStorageContract.address,
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