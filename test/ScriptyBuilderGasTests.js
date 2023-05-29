const utilities = require("../utilities/utilities")

describe("ScriptyBuilder Gas Tests", function () {
	const script = "var c = document.createElement('canvas'); var ctx = c.getContext('2d'); ctx.beginPath(); ctx.rect(20, 20, 150, 100); ctx.stroke(); document.body.appendChild(c);"

	async function deploy() {
		const contentStore = await (await ethers.getContractFactory("ContentStore")).deploy()
		await contentStore.deployed()

		const scriptyStorageContract = await (await ethers.getContractFactory("ScriptyStorage")).deploy(
			contentStore.address
		)
		await scriptyStorageContract.deployed()

		const scriptyBuilderContract = await (await ethers.getContractFactory("ScriptyBuilderV2")).deploy()
		await scriptyBuilderContract.deployed()

		const scriptyTestContract = await (await ethers.getContractFactory("ScriptyBuilderGasTest")).deploy(
			scriptyBuilderContract.address
		)
		await scriptyTestContract.deployed()

		return { scriptyStorageContract, scriptyTestContract }
	}

	async function getHTMLRequest(scriptCount, scriptyStorageContract, TagType, headRequests = []) {
		let scriptRequests = []

		let wrappedScript = script;
		if (TagType == 1) {
			wrappedScript = utilities.toBase64String(wrappedScript)
		}else if (TagType == 2) {
			wrappedScript = utilities.toGZIPBase64String(wrappedScript)
		}

		let totalSize = 0
		for (let i = 0; i < scriptCount; i++) {
			let scriptName = "script" + i
			await scriptyStorageContract.createScript(scriptName, utilities.stringToBytes("details"))
			await scriptyStorageContract.addChunkToScript(scriptName, utilities.stringToBytes(script))
			totalSize += script.length
			scriptRequests.push([scriptName, scriptyStorageContract.address, 0, TagType, utilities.emptyBytes(), utilities.emptyBytes(), utilities.emptyBytes()])
		}

		return { scriptRequests, headRequests }
	}

	describe("Scripty Gas Tests - HTML Single Script Tag", function () {
		it("Gas Test - Encoded HTML - Single Script Tag - Few", async function () {
			const { scriptyStorageContract, scriptyTestContract } = await deploy()
			const htmlRequest = await getHTMLRequest(2, scriptyStorageContract, 0, [])

			await scriptyTestContract.getEncodedHTMLSingleScriptTag_Few(htmlRequest)
		});

		it("Gas Test - Encoded HTML - Single Script Tag - Many", async function () {
			const { scriptyStorageContract, scriptyTestContract } = await deploy()
			const htmlRequest = await getHTMLRequest(100, scriptyStorageContract, 0, [])

			await scriptyTestContract.getEncodedHTMLSingleScriptTag_Many(htmlRequest)
		});
	})

	describe("Scripty Gas Tests - HTML", function () {
		it("Gas Test - Encoded HTML - Script Type 0 - Few", async function () {
			const { scriptyStorageContract, scriptyTestContract } = await deploy()
			const htmlRequest = await getHTMLRequest(2, scriptyStorageContract, 0, [])

			await scriptyTestContract.getEncodedHTML_TagType_0_Few(htmlRequest)
		});

		it("Gas Test - Encoded HTML - Script Type 1 - Few", async function () {
			const { scriptyStorageContract, scriptyTestContract } = await deploy()
			const htmlRequest = await getHTMLRequest(2, scriptyStorageContract, 0, [])

			await scriptyTestContract.getEncodedHTML_TagType_1_Few(htmlRequest)
		});

		it("Gas Test - Encoded HTML - Script Type 2 - Few", async function () {
			const { scriptyStorageContract, scriptyTestContract } = await deploy()
			const htmlRequest = await getHTMLRequest(2, scriptyStorageContract, 0, [])

			await scriptyTestContract.getEncodedHTML_TagType_2_Few(htmlRequest)
		});

		//

		it("Gas Test - Encoded HTML - Script Type 0 - Many", async function () {
			const { scriptyStorageContract, scriptyTestContract } = await deploy()
			const htmlRequest = await getHTMLRequest(100, scriptyStorageContract, 0, [])

			await scriptyTestContract.getEncodedHTML_TagType_0_Many(htmlRequest)
		});

		it("Gas Test - Encoded HTML - Script Type 1 - Many", async function () {
			const { scriptyStorageContract, scriptyTestContract } = await deploy()
			const htmlRequest = await getHTMLRequest(100, scriptyStorageContract, 0, [])

			await scriptyTestContract.getEncodedHTML_TagType_1_Many(htmlRequest)
		});

		it("Gas Test - Encoded HTML - Script Type 2 - Many", async function () {
			const { scriptyStorageContract, scriptyTestContract } = await deploy()
			const htmlRequest = await getHTMLRequest(100, scriptyStorageContract, 0, [])

			await scriptyTestContract.getEncodedHTML_TagType_2_Many(htmlRequest)
		});
	})

	describe("Scripty Gas Tests - URL Safe", function () {
		it("Gas Test - URL Safe - Few", async function () {
			const { scriptyStorageContract, scriptyTestContract } = await deploy()
			const htmlRequest = await getHTMLRequest(2, scriptyStorageContract, 0, [])

			await scriptyTestContract.getHTMLURLSafe_Few(htmlRequest)
		});

		it("Gas Test - URL Safe - Many", async function () {
			const { scriptyStorageContract, scriptyTestContract } = await deploy()
			const htmlRequest = await getHTMLRequest(100, scriptyStorageContract, 0, [])

			await scriptyTestContract.getHTMLURLSafe_Many(htmlRequest)
		});
	})
});
