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

async function deployOrGetContracts(networkName) {
	// If this script runs on localhost network, deploy all the contracts
	// Otherwise, use already deployed contracts
	if (networkName == "localhost") {
		const contentStoreContract = await (await ethers.getContractFactory("ContentStore")).deploy()
		await contentStoreContract.deployed()

		const scriptyStorageContract = await (await ethers.getContractFactory("ScriptyStorage")).deploy(
			contentStoreContract.address
		)
		await scriptyStorageContract.deployed()
		console.log("ScriptyStorage deployed");

		const scriptyBuilderContract = await (await ethers.getContractFactory("ScriptyBuilder")).deploy()
		await scriptyBuilderContract.deployed()
		console.log("ScriptyBuilder deployed");

		return { scriptyStorageContract, scriptyBuilderContract }
	}else{
		const scriptyStorageAddress = deployedContracts.addressFor(networkName, "ScriptyStorage")
		const scriptyStorageContract = await ethers.getContractAt(
			"ScriptyStorage",
			scriptyStorageAddress
		);
		console.log("ScriptyStorage is already deployed at", scriptyStorageAddress);

		const scriptyBuilderAddress = deployedContracts.addressFor(networkName, "ScriptyBuilder")
		const scriptyBuilderContract = await ethers.getContractAt(
			"ScriptyBuilder",
			scriptyBuilderAddress
		);
		console.log("ScriptyBuilder is already deployed at", scriptyBuilderAddress);

		return { scriptyStorageContract, scriptyBuilderContract }
	}
}

async function storeScript(storageContract, name, filePath) {

    // Check if script is already stored
    const storedScript = await storageContract.scripts(name)
    if (storedScript.size > 0) {
        console.log(`${name} is already stored`);
        return
    }

    // Grab file and break into chunks that SSTORE2 can handle
    const script = utilities.readFile(path.join(__dirname, filePath))
    const scriptChunks = utilities.chunkSubstr(script, 24575)

    // First create the script in the storage contract
    await waitIfNeeded(await storageContract.createScript(name, utilities.stringToBytes(name)))

    // Store each chunk
    // [WARNING]: With big files this can be very costly
    for (let i = 0; i < scriptChunks.length; i++) {
        await waitIfNeeded(await storageContract.addChunkToScript(name, utilities.stringToBytes(scriptChunks[i])))
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
	const { scriptyStorageContract, scriptyBuilderContract } = await deployOrGetContracts(hre.network.name)

	await storeScript(scriptyStorageContract, "scriptyBase", "../../baseScripts/dist/scriptyBase.js");
	await storeScript(scriptyStorageContract, "three.min.js.gz", "../commonScripts/three.min.js.gz.txt");
	await storeScript(scriptyStorageContract, "gunzipScripts-0.0.1", "../../baseScripts/dist/gunzipScripts-0.0.1.js");
	await storeScript(scriptyStorageContract, "stacked3DObjects1", "scripts/stacked3DObjects1.js");
	await storeScript(scriptyStorageContract, "stacked3DObjects2", "scripts/stacked3DObjects2.js");

	let scriptRequests = [
		{
			name: "scriptyBase",
			contractAddress: scriptyStorageContract.address,
			contractData: 0,
			wrapType: 0,
			wrapPrefix: utilities.emptyBytes(),
			wrapSuffix: utilities.emptyBytes(),
			scriptContent: utilities.emptyBytes()
		},
		{
			name: "three.min.js.gz",
			contractAddress: scriptyStorageContract.address,
			contractData: 0,
			wrapType: 2,
			wrapPrefix: utilities.emptyBytes(),
			wrapSuffix: utilities.emptyBytes(),
			scriptContent: utilities.emptyBytes()
		},
		{
			name: "gunzipScripts-0.0.1",
			contractAddress: scriptyStorageContract.address,
			contractData: 0,
			wrapType: 0,
			wrapPrefix: utilities.emptyBytes(),
			wrapSuffix: utilities.emptyBytes(),
			scriptContent: utilities.emptyBytes()
		},
		{
			name: "stacked3DObjects1",
			contractAddress: scriptyStorageContract.address,
			contractData: 0,
			wrapType: 0,
			wrapPrefix: utilities.emptyBytes(),
			wrapSuffix: utilities.emptyBytes(),
			scriptContent: utilities.emptyBytes()
		}
	]

	const rawBufferSize1 = await scriptyBuilderContract.getBufferSizeForHTMLWrapped(scriptRequests)
	console.log("Buffer size:", rawBufferSize1);

	scriptRequests.push(
		{
			name: "stacked3DObjects2",
			contractAddress: scriptyStorageContract.address,
			contractData: 0,
			wrapType: 0,
			wrapPrefix: utilities.emptyBytes(),
			wrapSuffix: utilities.emptyBytes(),
			scriptContent: utilities.emptyBytes()
		}
	)

	const rawBufferSize2 = await scriptyBuilderContract.getBufferSizeForHTMLWrapped(scriptRequests)
	console.log("Buffer size:", rawBufferSize2);

	const nftContract1 = await (await ethers.getContractFactory("Stacked3DObjects_Cubes")).deploy(
		scriptyStorageContract.address,
		scriptyBuilderContract.address,
		rawBufferSize1
	)
	await nftContract1.deployed()
	console.log("NFT Contract is deployed", nftContract1.address);

	const nftContract2 = await (await ethers.getContractFactory("Stacked3DObjects_Spheres")).deploy(
		scriptyStorageContract.address,
		scriptyBuilderContract.address,
		rawBufferSize2
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

	// Verify contracts if network is goerli
	if (hre.network.name == "goerli") {
		console.log("Waiting a little bytecode index on Etherscan");
    	await delay(30000)

		await hre.run("verify:verify", {
			address: nftContract1.address,
			constructorArguments: [
				scriptyStorageContract.address,
				scriptyBuilderContract.address,
				rawBufferSize1
			],
		});

		await hre.run("verify:verify", {
			address: nftContract2.address,
			constructorArguments: [
				scriptyStorageContract.address,
				scriptyBuilderContract.address,
				rawBufferSize2
			],
		});
	}
}

main().catch((error) => {
	console.error(error);
	process.exitCode = 1;
});