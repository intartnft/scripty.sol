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

async function main() {
	console.log("")
	console.log("----------------------------------")
	console.log("Running ThreeJSModules_URLSafe")
	console.log("----------------------------------")

	// Deploy or use already deployed contracts depending on the network that script runs on
	console.log("Deploying contracts");
	const { scriptyStorageContract, scriptyBuilderContract } = await deployOrGetContracts(hre.network.name)

	await storeScript(scriptyStorageContract, "gunzipScripts-0.0.1.js", "scripts/gunzipScripts-0.0.1.txt");
	await storeScript(scriptyStorageContract, "es-module-shims.js.gz", "scripts/es-module-shims.js.gz.txt");
	await storeScript(scriptyStorageContract, "threejs.module.js.gz", "scripts/modules/threejs.module.js.gz.txt");
	await storeScript(scriptyStorageContract, "OrbitControls.module.js.gz", "scripts/modules/OrbitControls.module.js.gz.txt");
	await storeScript(scriptyStorageContract, "importHandler", "scripts/importHandler.js");
	await storeScript(scriptyStorageContract, "torus", "scripts/torus.min.js.txt");

	const scriptRequests = [
		{
			name: "gunzipScripts-0.0.1.js",
			contractAddress: scriptyStorageContract.address,
			contractData: 0,
			wrapType: 1,
			wrapPrefix: utilities.emptyBytes(),
			wrapSuffix: utilities.emptyBytes(),
			scriptContent: utilities.emptyBytes()
		},

        {
            name: "es-module-shims.js.gz",
            contractAddress: scriptyStorageContract.address,
            contractData: 0,
            wrapType: 2,
            wrapPrefix: utilities.emptyBytes(),
            wrapSuffix: utilities.emptyBytes(),
            scriptContent: utilities.emptyBytes()
        },

        {
            name: "threejs.module.js.gz",
            contractAddress: scriptyStorageContract.address,
            contractData: 0,
            wrapType: 4,
            // double encoded:
            // - <script>var t3 = "
            // - "</script>
            wrapPrefix: utilities.stringToBytes("%253Cscript%253Evar%2520t3%2520%253D%2520%2522"),
            wrapSuffix: utilities.stringToBytes("%2522%253C%252Fscript%253E"),
            scriptContent: utilities.emptyBytes()
        },

        {
            name: "OrbitControls.module.js.gz",
            contractAddress: scriptyStorageContract.address,
            contractData: 0,
			wrapType: 4,
			// double encoded:
			// - <script>var oc = "
			// - "</script>
			wrapPrefix: utilities.stringToBytes("%253Cscript%253Evar%2520oc%2520%253D%2520%2522"),
			wrapSuffix: utilities.stringToBytes("%2522%253C%252Fscript%253E"),
			scriptContent: utilities.emptyBytes()
        },

        {
            name: "importHandler",
            contractAddress: scriptyStorageContract.address,
            contractData: 0,
            wrapType: 0,
            wrapPrefix: utilities.emptyBytes(),
            wrapSuffix: utilities.emptyBytes(),
            scriptContent: utilities.emptyBytes()
        },

		{
			name: "",
			contractAddress: scriptyStorageContract.address,
			contractData: 0,
			wrapType: 0,
			wrapPrefix: utilities.emptyBytes(),
			wrapSuffix: utilities.emptyBytes(),
			scriptContent: utilities.stringToBytes('injectImportMap([["three",t3],["OrbitControls",oc]],gunzipScripts)')
		},

		{
			name: "torus",
			contractAddress: scriptyStorageContract.address,
			contractData: 0,
			wrapType: 4,
			// double encoded:
			// - <script type="module" src="data:text/javascript;base64,
			// - "></script>
			wrapPrefix: utilities.stringToBytes("%253Cscript%2520type%253D%2522module%2522%2520src%253D%2522data%253Atext%252Fjavascript%253Bbase64%252C"),
			wrapSuffix: utilities.stringToBytes("%2522%253E%253C%252Fscript%253E"),
			scriptContent: utilities.emptyBytes()
		}
	]
	const rawBufferSize = await scriptyBuilderContract.getBufferSizeForURLSafeHTMLWrapped(scriptRequests)
	console.log("Buffer size:", rawBufferSize);

	const nftContract = await (await ethers.getContractFactory("ThreeJSModules_URLSafe")).deploy(
		scriptyStorageContract.address,
		scriptyBuilderContract.address,
		rawBufferSize
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

	// Verify contracts if network is goerli
	if (hre.network.name == "goerli") {
		console.log("Waiting a little bytecode index on Etherscan");
    	await delay(30000)

		await hre.run("verify:verify", {
			address: nftContract.address,
			constructorArguments: [
				scriptyStorageContract.address,
				scriptyBuilderContract.address,
				rawBufferSize
			],
		});
	}
}

main().catch((error) => {
	console.error(error);
	process.exitCode = 1;
});